class UgAuthLoginRequest {
  final String aplicacion;
  final String usuario;
  final String clave;

  const UgAuthLoginRequest({
    required this.aplicacion,
    required this.usuario,
    required this.clave,
  });

  Map<String, dynamic> toJson() => {
        "aplicacion": aplicacion,
        "usuario": usuario,
        "clave": clave,
      };

  static const app = UgAuthLoginRequest(
    aplicacion: "2",
    usuario: "userJWTApiGenericoExterno",
    clave: "3G5CWaKXeW",
  );
}

class UgSesionLoginRequest {
  final String ip;
  final String username;
  final String password;
  final String tipoUsuario;

  const UgSesionLoginRequest({
    required this.ip,
    required this.username,
    required this.password,
    required this.tipoUsuario,
  });

  Map<String, dynamic> toJson() => {
        "ip": ip,
        "username": username,
        "password": password,
        "tipoUsuario": tipoUsuario,
      };
}

/// ======================= GETDATA (MENU/SUBMENU) =======================

class UgGetDataRequest {
  final String conexion; // SER_ACA_PRD
  final String sentencia; // SP_CU_GET_MENU_SISTEMAS
  final Map<String, dynamic> parametros;

  const UgGetDataRequest({
    required this.conexion,
    required this.sentencia,
    required this.parametros,
  });

  Map<String, dynamic> toJson() => {
        "conexion": conexion,
        "sentencia": sentencia,
        "parametros": parametros,
      };

  static const String defaultConexion = "SER_ACA_PRD";
  static const String defaultSentencia = "SP_CU_GET_MENU_SISTEMAS";

  static String _xml({
    required String usuario, // cedula
    required int sistema, // sistemaId
    String moduloIdText = "", // vacío permitido para menu
  }) {
    return "<root><usuario>$usuario</usuario><sistema>$sistema</sistema><moduloId>$moduloIdText</moduloId></root>";
  }

  /// Menú
  static UgGetDataRequest obtenerMenu({
    required String usuario,
    required int sistema,
  }) {
    return UgGetDataRequest(
      conexion: defaultConexion,
      sentencia: defaultSentencia,
      parametros: {
        "@transaccion": "consulta_modulos_sistema",
        "@parametros": _xml(usuario: usuario, sistema: sistema, moduloIdText: ""),
      },
    );
  }

  /// Submenú
  static UgGetDataRequest obtenerSubMenu({
    required String usuario,
    required int sistema,
    required int moduloId,
  }) {
    return UgGetDataRequest(
      conexion: defaultConexion,
      sentencia: defaultSentencia,
      parametros: {
        "@transaccion": "consulta_opciones_modulos_sistema",
        "@parametros": _xml(usuario: usuario, sistema: sistema, moduloIdText: moduloId.toString()),
      },
    );
  }
}

class UgGetDataResponse {
  final String estado;
  final String mensaje;
  final List<Map<String, dynamic>> resultado;

  const UgGetDataResponse({
    required this.estado,
    required this.mensaje,
    required this.resultado,
  });

  factory UgGetDataResponse.fromJson(Map<String, dynamic> json) {
    final raw = json["resultado"];
    final list = (raw is List)
        ? raw.whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList()
        : <Map<String, dynamic>>[];

    return UgGetDataResponse(
      estado: (json["estado"] ?? "").toString(),
      mensaje: (json["mensaje"] ?? "").toString(),
      resultado: list,
    );
  }
}

/// Menu principal (consulta_modulos_sistema)
class UgMenuItem {
  final String usuarioId;
  final int sistemaId;
  final int moduloId;
  final String nombre;
  final int posicion;
  final int orden;
  final String icono; // "icono"

  const UgMenuItem({
    required this.usuarioId,
    required this.sistemaId,
    required this.moduloId,
    required this.nombre,
    required this.posicion,
    required this.orden,
    required this.icono,
  });

  factory UgMenuItem.fromJson(Map<String, dynamic> j) {
    return UgMenuItem(
      usuarioId: (j["usuarioId"] ?? "").toString(),
      sistemaId: _toInt(j["sistemaId"]),
      moduloId: _toInt(j["moduloId"]),
      nombre: (j["nombre"] ?? "").toString(),
      posicion: _toInt(j["posicion"]),
      orden: _toInt(j["orden"]),
      icono: (j["icono"] ?? "").toString(),
    );
  }
}

/// SubMenu (consulta_opciones_modulos_sistema)
class UgSubMenuItem {
  final String usuarioId;
  final int sistemaId;
  final int moduloId;
  final String nombre;
  final int posicion;
  final int orden;
  final String icono; // "ICONO"
  final String rutaForma;
  final String iframe;

  const UgSubMenuItem({
    required this.usuarioId,
    required this.sistemaId,
    required this.moduloId,
    required this.nombre,
    required this.posicion,
    required this.orden,
    required this.icono,
    required this.rutaForma,
    required this.iframe,
  });

  factory UgSubMenuItem.fromJson(Map<String, dynamic> j) {
    return UgSubMenuItem(
      usuarioId: (j["usuarioId"] ?? "").toString(),
      sistemaId: _toInt(j["sistemaId"]),
      moduloId: _toInt(j["moduloId"]),
      nombre: (j["nombre"] ?? "").toString(),
      posicion: _toInt(j["posicion"]),
      orden: _toInt(j["orden"]),
      icono: (j["ICONO"] ?? "").toString(),
      rutaForma: (j["rutaForma"] ?? "").toString(),
      iframe: (j["iframe"] ?? "").toString(),
    );
  }
}

/// ======================= OFERTA PPE (DATOS PERSONALES / EDUCACION / IDIOMA) =======================

class UgParametroGeneral {
  final String nombreSp; // "OFERTA_PPE.GetDatosEstudiante"
  final String transaccion; // "OBTIENE_DATOS_PERSONALES" | "OBTIENE_EDUCACION" | "OBTIENE_IDIOMA"
  final String usuarioTrx; // cedula

  const UgParametroGeneral({
    required this.nombreSp,
    required this.transaccion,
    required this.usuarioTrx,
  });

  Map<String, dynamic> toJson() => {
        "NombreSp": nombreSp,
        "Transaccion": transaccion,
        "UsuarioTrx": usuarioTrx,
      };

  static const String defaultNombreSp = "OFERTA_PPE.GetDatosEstudiante";
}

class UgDatosPersonalesRequest {
  final String codEstudiante;
  final int idDatoPersonal;
  final UgParametroGeneral parametroGeneral;

  const UgDatosPersonalesRequest({
    required this.codEstudiante,
    required this.idDatoPersonal,
    required this.parametroGeneral,
  });

  Map<String, dynamic> toJson() => {
        "CodEstudiante": codEstudiante,
        "IdDatoPersonal": idDatoPersonal,
        "ParametroGeneral": parametroGeneral.toJson(),
      };

  static UgDatosPersonalesRequest build({
    required String codEstudiante,
    int idDatoPersonal = 0,
    required String usuarioTrx,
  }) {
    return UgDatosPersonalesRequest(
      codEstudiante: codEstudiante,
      idDatoPersonal: idDatoPersonal,
      parametroGeneral: UgParametroGeneral(
        nombreSp: UgParametroGeneral.defaultNombreSp,
        transaccion: "OBTIENE_DATOS_PERSONALES",
        usuarioTrx: usuarioTrx,
      ),
    );
  }
}

class UgEducacionRequest {
  final int idEducacion; // 0
  final int idDatoPersonal;
  final UgParametroGeneral parametroGeneral;

  const UgEducacionRequest({
    required this.idEducacion,
    required this.idDatoPersonal,
    required this.parametroGeneral,
  });

  Map<String, dynamic> toJson() => {
        "IdEducacion": idEducacion,
        "IdDatoPersonal": idDatoPersonal,
        "ParametroGeneral": parametroGeneral.toJson(),
      };

  static UgEducacionRequest build({
    required int idDatoPersonal,
    int idEducacion = 0,
    required String usuarioTrx,
  }) {
    return UgEducacionRequest(
      idEducacion: idEducacion,
      idDatoPersonal: idDatoPersonal,
      parametroGeneral: UgParametroGeneral(
        nombreSp: UgParametroGeneral.defaultNombreSp,
        transaccion: "OBTIENE_EDUCACION",
        usuarioTrx: usuarioTrx,
      ),
    );
  }
}

class UgIdiomaRequest {
  final int idIdioma; // 0
  final int idDatoPersonal;
  final UgParametroGeneral parametroGeneral;

  const UgIdiomaRequest({
    required this.idIdioma,
    required this.idDatoPersonal,
    required this.parametroGeneral,
  });

  Map<String, dynamic> toJson() => {
        "IdIdioma": idIdioma,
        "IdDatoPersonal": idDatoPersonal,
        "ParametroGeneral": parametroGeneral.toJson(),
      };

  static UgIdiomaRequest build({
    required int idDatoPersonal,
    int idIdioma = 0,
    required String usuarioTrx,
  }) {
    return UgIdiomaRequest(
      idIdioma: idIdioma,
      idDatoPersonal: idDatoPersonal,
      parametroGeneral: UgParametroGeneral(
        nombreSp: UgParametroGeneral.defaultNombreSp,
        transaccion: "OBTIENE_IDIOMA",
        usuarioTrx: usuarioTrx,
      ),
    );
  }
}

/// Respuesta genérica:
/// {"CodError":0,"Mensaje":"OK","dtResultado":[ ... ]}
class UgOfertaPpeResponse {
  final int codError;
  final String mensaje;
  final List<Map<String, dynamic>> dtResultado;

  const UgOfertaPpeResponse({
    required this.codError,
    required this.mensaje,
    required this.dtResultado,
  });

  factory UgOfertaPpeResponse.fromJson(Map<String, dynamic> json) {
    final raw = json["dtResultado"];
    final list = (raw is List)
        ? raw.whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList()
        : <Map<String, dynamic>>[];

    return UgOfertaPpeResponse(
      codError: _toInt(json["CodError"]),
      mensaje: (json["Mensaje"] ?? "").toString(),
      dtResultado: list,
    );
  }
}

class UgDatosPersonales {
  final int idDatoPersonal;
  final String codEstudiante;

  final String nombres;
  final String apellidos;

  final String estadoCivil;
  final String nacionalidad;

  final String provinciaNacimiento;
  final String ciudadNacimiento;

  final DateTime? fechaNacimiento;
  final int edad;

  final String? correoInstitucional;
  final String? correoPersonal;

  final String telefonoConvencional;
  final String celular;

  final String sexo; // "MASCULINO" etc

  final String paisDomicilio;
  final String provinciaDomicilio;
  final String ciudadDomicilio;
  final String direccion;
  final String referencia;

  final String etnia;

  final Map<String, dynamic> raw;

  const UgDatosPersonales({
    required this.idDatoPersonal,
    required this.codEstudiante,
    required this.nombres,
    required this.apellidos,
    required this.estadoCivil,
    required this.nacionalidad,
    required this.provinciaNacimiento,
    required this.ciudadNacimiento,
    required this.fechaNacimiento,
    required this.edad,
    required this.correoInstitucional,
    required this.correoPersonal,
    required this.telefonoConvencional,
    required this.celular,
    required this.sexo,
    required this.paisDomicilio,
    required this.provinciaDomicilio,
    required this.ciudadDomicilio,
    required this.direccion,
    required this.referencia,
    required this.etnia,
    required this.raw,
  });

  factory UgDatosPersonales.fromJson(Map<String, dynamic> j) {
    return UgDatosPersonales(
      idDatoPersonal: _toInt(j["IdDatoPersonal"]),
      codEstudiante: (j["COD_ESTUDIANTE"] ?? "").toString(),
      nombres: (j["NOMBRE"] ?? "").toString(),
      apellidos: (j["APELLIDO"] ?? "").toString(),
      estadoCivil: (j["ESTADO_CIVIL"] ?? "").toString(),
      nacionalidad: (j["NACIONALIDAD"] ?? "").toString(),
      provinciaNacimiento: (j["PROVINCIA_NACIMIENTO"] ?? "").toString(),
      ciudadNacimiento: (j["CIUDAD_NACIMIENTO"] ?? "").toString(),
      fechaNacimiento: _toDate(j["FECHA_NACIMIENTO"]),
      edad: _toInt(j["EDAD"]),
      correoInstitucional: _toNullableString(j["CORREO_INSTITUCIONAL"]),
      correoPersonal: _toNullableString(j["CORREO_PERSONAL"]),
      telefonoConvencional: (j["TELEFONO_CONVENCIONAL"] ?? "").toString(),
      celular: (j["CELULAR"] ?? "").toString(),
      sexo: (j["SEXO"] ?? "").toString(),
      paisDomicilio: (j["PAIS_DOMICILIO"] ?? "").toString(),
      provinciaDomicilio: (j["PROVINCIA_DOMICILIO"] ?? "").toString(),
      ciudadDomicilio: (j["CIUDAD_DOMICILIO"] ?? "").toString(),
      direccion: (j["DIRECCION"] ?? "").toString(),
      referencia: (j["REFERENCIA_DOMICILIARIA"] ?? "").toString(),
      etnia: (j["ETNIA"] ?? "").toString(),
      raw: j,
    );
  }

  String get nombreCompleto => "$nombres $apellidos".trim();
}

class UgEducacion {
  final int idEducacion;
  final int idDatoPersonal;

  final String nivelEstudio;
  final String nivelInstruccion;
  final String institucion;

  final String facultad;
  final String carrera;
  final String semestre;

  final String? titulo;

  final Map<String, dynamic> raw;

  const UgEducacion({
    required this.idEducacion,
    required this.idDatoPersonal,
    required this.nivelEstudio,
    required this.nivelInstruccion,
    required this.institucion,
    required this.facultad,
    required this.carrera,
    required this.semestre,
    required this.titulo,
    required this.raw,
  });

  factory UgEducacion.fromJson(Map<String, dynamic> j) {
    return UgEducacion(
      idEducacion: _toInt(j["IdEducacion"]),
      idDatoPersonal: _toInt(j["IdDatoPersonal"]),
      nivelEstudio: (j["NivelEstudio"] ?? "").toString(),
      nivelInstruccion: (j["NivelInstruccion"] ?? "").toString(),
      institucion: (j["Institucion"] ?? "").toString(),
      facultad: (j["Facultad"] ?? "").toString(),
      carrera: (j["Carrera"] ?? "").toString(),
      semestre: (j["Semestre"] ?? "").toString(),
      titulo: _toNullableString(j["Titulo"]),
      raw: j,
    );
  }
}

class UgIdioma {
  /// La API puede devolver dtResultado vacío o con campos variables.
  /// Guardamos "raw" para no romper si cambia el esquema.
  final int idIdioma;
  final int idDatoPersonal;

  final String idioma;
  final String nivel;

  final Map<String, dynamic> raw;

  const UgIdioma({
    required this.idIdioma,
    required this.idDatoPersonal,
    required this.idioma,
    required this.nivel,
    required this.raw,
  });

  factory UgIdioma.fromJson(Map<String, dynamic> j) {
    // Intentos típicos de campos (si vinieran)
    final idioma = (j["Idioma"] ?? j["IDIOMA"] ?? j["NombreIdioma"] ?? "").toString();
    final nivel = (j["Nivel"] ?? j["NIVEL"] ?? j["NivelIdioma"] ?? "").toString();

    return UgIdioma(
      idIdioma: _toInt(j["IdIdioma"] ?? j["ID_IDIOMA"]),
      idDatoPersonal: _toInt(j["IdDatoPersonal"] ?? j["ID_DATO_PERSONAL"]),
      idioma: idioma,
      nivel: nivel,
      raw: j,
    );
  }
}

int _toInt(dynamic v) {
  if (v is int) return v;
  return int.tryParse(v?.toString() ?? "") ?? 0;
}

String? _toNullableString(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.trim().isEmpty ? null : s;
}

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  if (s.isEmpty) return null;

  // Formato esperado: "YYYY-MM-DD" (por tu salida)
  try {
    return DateTime.parse(s);
  } catch (_) {
    return null;
  }
}