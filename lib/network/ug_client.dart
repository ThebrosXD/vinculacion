import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'jwt_utils.dart';
import 'token_store.dart';
import 'ug_auth_api.dart';
import 'ug/ug_endpoints.dart';
import 'ug/ug_models.dart';

class UgClient {
  UgClient._internal() : _http = http.Client(), _store = TokenStore() {
    _authApi = UgAuthApi(_http);
  }

  static final UgClient instance = UgClient._internal();

  final http.Client _http;
  final TokenStore _store;
  late final UgAuthApi _authApi;

  Future<String>? _refreshing;

  // Endpoints OfertaPPE
  static const String _ppeDatosPersonalesUrl =
      "https://servicioenlinea.ug.edu.ec/OfertaPPEapi/api/DatosPersonales/ObtieneDatosPersonales";
  static const String _ppeEducacionUrl =
      "https://servicioenlinea.ug.edu.ec/OfertaPPEapi/api/Educacion/ObtieneEducacion";
  static const String _ppeIdiomaUrl =
      "https://servicioenlinea.ug.edu.ec/OfertaPPEapi/api/Idioma/ObtieneIdioma";

  // ------------------ FIX: JSON decode robusto ------------------

  dynamic _decodeJsonLoose(String body) {
    dynamic v;
    try {
      v = jsonDecode(body);
    } catch (e) {
      throw Exception("JSON inválido: $e\nBody: $body");
    }

    // Si viene doblemente codificado: jsonDecode devuelve String con { ... } o [ ... ]
    if (v is String) {
      final s = v.trim();
      final looksJson =
          (s.startsWith('{') && s.endsWith('}')) ||
          (s.startsWith('[') && s.endsWith(']'));
      if (looksJson) {
        try {
          v = jsonDecode(s);
        } catch (_) {
          // si falla, dejamos el String tal cual
        }
      }
    }

    return v;
  }

  Map<String, dynamic> _asMap(dynamic v, {String where = "respuesta"}) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);

    // Algunas APIs a veces responden [ { ... } ]
    if (v is List && v.isNotEmpty && v.first is Map) {
      return Map<String, dynamic>.from(v.first as Map);
    }

    throw Exception("Formato inesperado en $where: $v");
  }

  Map<String, dynamic> _normalizeOfertaPpe(Map<String, dynamic> m) {
    // Acepta variantes de claves y deja todo consistente para UgOfertaPpeResponse.fromJson
    dynamic cod =
        m['codError'] ??
        m['CodError'] ??
        m['CODERROR'] ??
        m['CodigoError'] ??
        m['codigoError'];
    dynamic msg = m['mensaje'] ?? m['Mensaje'] ?? m['MENSAJE'];
    dynamic dt =
        m['dtResultado'] ??
        m['DtResultado'] ??
        m['DTRESULTADO'] ??
        m['resultado'] ??
        m['Resultado'];

    // Normaliza codError como int (si viene string)
    int codInt = 0;
    if (cod != null) {
      final s = cod.toString().trim();
      codInt = int.tryParse(s) ?? 0;
    }

    // Normaliza mensaje
    final msgStr = (msg ?? '').toString();

    // Normaliza dtResultado: puede venir list/map/string
    dynamic dtFixed = dt;

    if (dtFixed is String) {
      final s = dtFixed.trim();
      final looksJson =
          (s.startsWith('{') && s.endsWith('}')) ||
          (s.startsWith('[') && s.endsWith(']'));
      if (looksJson) {
        try {
          dtFixed = jsonDecode(s);
        } catch (_) {
          // si no se puede, se queda string
        }
      }
    }

    if (dtFixed is Map) {
      dtFixed = [Map<String, dynamic>.from(dtFixed)];
    } else if (dtFixed is List) {
      dtFixed = dtFixed
          .where((e) => e is Map)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else if (dtFixed == null) {
      dtFixed = <Map<String, dynamic>>[];
    } else {
      // raro: lo envolvemos para que no explote
      dtFixed = <Map<String, dynamic>>[];
    }

    // Dejamos ambos estilos de keys por compatibilidad
    m['codError'] = codInt;
    m['CodError'] = codInt;
    m['mensaje'] = msgStr;
    m['Mensaje'] = msgStr;
    m['dtResultado'] = dtFixed;
    m['DtResultado'] = dtFixed;
    m['resultado'] = dtFixed;

    return m;
  }

  // ---------------------------------------------------------------

  Future<String> _refreshToken() {
    _refreshing ??= () async {
      final req = UgAuthLoginRequest.app;

      final token = await _authApi.fetchAppToken(
        aplicacion: req.aplicacion,
        usuario: req.usuario,
        clave: req.clave,
      );

      final exp = jwtExpiry(token);
      final expUtc =
          exp ?? DateTime.now().toUtc().add(const Duration(minutes: 10));

      await _store.save(token: token, expUtc: expUtc);
      return token;
    }().whenComplete(() => _refreshing = null);

    return _refreshing!;
  }

  Future<String> getValidToken() async {
    final data = await _store.load();
    if (data == null) return _refreshToken();

    if (isExpiringSoon(data.expUtc, threshold: const Duration(minutes: 3))) {
      return _refreshToken();
    }
    return data.token;
  }

  Future<Map<String, dynamic>> loginSesion({
    required String username,
    required String password,
    required String tipoUsuario,
    String ip = '127.0.0.1',
  }) async {
    final req = UgSesionLoginRequest(
      ip: ip,
      username: username,
      password: password,
      tipoUsuario: tipoUsuario,
    );

    Future<http.Response> doCall(String token) {
      return _http.post(
        Uri.parse(UgEndpoints.sesionLogin),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(req.toJson()),
      );
    }

    var token = await getValidToken();
    var res = await doCall(token);

    print("--Logeando-- ");
    print("Data:  ${res.statusCode} - ${res.body}");

    if (res.statusCode == 401 || res.statusCode == 403) {
      token = await _refreshToken();
      res = await doCall(token);
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Sesion/Login falló (${res.statusCode}): ${res.body}');
    }

    final body = res.body.trim();
    if (body.isEmpty) throw Exception('Respuesta vacía en Sesion/Login');

    final decodedAny = _decodeJsonLoose(body);
    final decoded = _asMap(decodedAny, where: "Sesion/Login");

    final id = (decoded['idRespuesta'] ?? '').toString().trim();
    if (id != '1') throw Exception('Credenciales incorrectas');

    return decoded;
  }

  Future<Map<String, dynamic>> loginUser({
    required String username,
    required String password,
    required String tipoUsuario,
    String ip = '127.0.0.1',
  }) {
    return loginSesion(
      username: username,
      password: password,
      tipoUsuario: tipoUsuario,
      ip: ip,
    );
  }

  // ======================= GETDATA (MENU/SUBMENU) =======================

  Future<List<UgMenuItem>> obtenerMenu({
    required String usuario,
    required int sistema,
  }) async {
    final req = UgGetDataRequest.obtenerMenu(
      usuario: usuario,
      sistema: sistema,
    );
    final resp = await _postGetData(req);

    if (resp.estado.toUpperCase() != 'OK') {
      throw Exception(
        resp.mensaje.isEmpty ? 'Error al obtener menú' : resp.mensaje,
      );
    }

    final items = resp.resultado.map(UgMenuItem.fromJson).toList();
    items.sort((a, b) {
      final c = a.orden.compareTo(b.orden);
      if (c != 0) return c;
      return a.posicion.compareTo(b.posicion);
    });
    return items;
  }

  Future<List<UgSubMenuItem>> obtenerSubMenu({
    required String usuario,
    required int sistema,
    required int moduloId,
  }) async {
    final req = UgGetDataRequest.obtenerSubMenu(
      usuario: usuario,
      sistema: sistema,
      moduloId: moduloId,
    );

    final resp = await _postGetData(req);

    if (resp.estado.toUpperCase() != 'OK') {
      throw Exception(
        resp.mensaje.isEmpty ? 'Error al obtener submenú' : resp.mensaje,
      );
    }

    final items = resp.resultado.map(UgSubMenuItem.fromJson).toList();
    items.sort((a, b) {
      final c = a.orden.compareTo(b.orden);
      if (c != 0) return c;
      return a.posicion.compareTo(b.posicion);
    });
    return items;
  }

  Future<UgGetDataResponse> _postGetData(UgGetDataRequest req) async {
    Future<http.Response> doCall(String token) {
      return _http.post(
        Uri.parse(UgEndpoints.getData),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(req.toJson()),
      );
    }

    var token = await getValidToken();
    var res = await doCall(token);

    if (res.statusCode == 401 || res.statusCode == 403) {
      token = await _refreshToken();
      res = await doCall(token);
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('GetData falló (${res.statusCode}): ${res.body}');
    }

    final body = res.body.trim();
    if (body.isEmpty) throw Exception('Respuesta vacía en GetData');

    final decodedAny = _decodeJsonLoose(body);
    final decoded = _asMap(decodedAny, where: "GetData");

    return UgGetDataResponse.fromJson(decoded);
  }

  // ======================= OFERTA PPE =======================

  Future<List<UgDatosPersonales>> obtenerDatosPersonales({
    required String codEstudiante,
    int idDatoPersonal = 0,
    String? usuarioTrx,
  }) async {
    final req = UgDatosPersonalesRequest.build(
      codEstudiante: codEstudiante,
      idDatoPersonal: idDatoPersonal,
      usuarioTrx: usuarioTrx ?? codEstudiante,
    );

    final resp = await _postOfertaPpe(_ppeDatosPersonalesUrl, req.toJson());

    if (resp.codError != 0) {
      throw Exception(
        resp.mensaje.isEmpty ? "Error en ObtieneDatosPersonales" : resp.mensaje,
      );
    }

    return resp.dtResultado.map(UgDatosPersonales.fromJson).toList();
  }

  Future<UgDatosPersonales?> obtenerDatosPersonalesPrimero({
    required String codEstudiante,
    String? usuarioTrx,
  }) async {
    final list = await obtenerDatosPersonales(
      codEstudiante: codEstudiante,
      idDatoPersonal: 0,
      usuarioTrx: usuarioTrx,
    );
    if (list.isEmpty) return null;
    return list.first;
  }

  Future<List<UgEducacion>> obtenerEducacion({
    required int idDatoPersonal,
    required String usuarioTrx,
    int idEducacion = 0,
  }) async {
    final req = UgEducacionRequest.build(
      idDatoPersonal: idDatoPersonal,
      idEducacion: idEducacion,
      usuarioTrx: usuarioTrx,
    );

    final resp = await _postOfertaPpe(_ppeEducacionUrl, req.toJson());

    if (resp.codError != 0) {
      throw Exception(
        resp.mensaje.isEmpty ? "Error en ObtieneEducacion" : resp.mensaje,
      );
    }

    return resp.dtResultado.map(UgEducacion.fromJson).toList();
  }

  Future<List<UgIdioma>> obtenerIdiomas({
    required int idDatoPersonal,
    required String usuarioTrx,
    int idIdioma = 0,
  }) async {
    final req = UgIdiomaRequest.build(
      idDatoPersonal: idDatoPersonal,
      idIdioma: idIdioma,
      usuarioTrx: usuarioTrx,
    );

    final resp = await _postOfertaPpe(_ppeIdiomaUrl, req.toJson());

    if (resp.codError != 0) {
      throw Exception(
        resp.mensaje.isEmpty ? "Error en ObtieneIdioma" : resp.mensaje,
      );
    }

    return resp.dtResultado.map(UgIdioma.fromJson).toList();
  }

  Future<UgOfertaPpeResponse> _postOfertaPpe(
    String url,
    Map<String, dynamic> bodyMap,
  ) async {
    Future<http.Response> doCall(String token) {
      return _http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyMap),
      );
    }

    var token = await getValidToken();
    var res = await doCall(token);

    if (res.statusCode == 401 || res.statusCode == 403) {
      token = await _refreshToken();
      res = await doCall(token);
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('OfertaPPE falló (${res.statusCode}): ${res.body}');
    }

    final body = res.body.trim();
    if (body.isEmpty) throw Exception('Respuesta vacía en OfertaPPE');

    final decodedAny = _decodeJsonLoose(body);
    final decodedMap = _asMap(decodedAny, where: "OfertaPPE");

    final normalized = _normalizeOfertaPpe(decodedMap);

    return UgOfertaPpeResponse.fromJson(normalized);
  }

  Future<void> clearToken() => _store.clear();
}
