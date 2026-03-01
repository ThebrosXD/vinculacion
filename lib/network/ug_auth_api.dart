import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ug/ug_endpoints.dart';

class UgAuthApi {
  final http.Client _http;
  UgAuthApi(this._http);

  Future<String> fetchAppToken({
    required String aplicacion,
    required String usuario,
    required String clave,
  }) async {
    final uri = Uri.parse(UgEndpoints.authLogin);

    final res = await _http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'aplicacion': aplicacion,
        'usuario': usuario,
        'clave': clave,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Auth/login falló (${res.statusCode}): ${res.body}');
    }

    // Puede venir como JSON o string plano. Lo parseamos flexible.
    final body = res.body.trim();
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final token = decoded['token'] ??
            decoded['access_token'] ??
            decoded['jwt'] ??
            decoded['data'];
        if (token is String && token.isNotEmpty) return token;
      }
      if (decoded is String && decoded.isNotEmpty) return decoded;
    } catch (_) {
      // si no es JSON, asumimos string plano
    }

    if (body.isEmpty) throw Exception('Auth/login respondió vacío');
    return body;
  }
}
