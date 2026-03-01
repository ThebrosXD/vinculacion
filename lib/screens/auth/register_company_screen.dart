import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterCompanyScreen extends StatefulWidget {
  const RegisterCompanyScreen({super.key});

  @override
  State<RegisterCompanyScreen> createState() => _RegisterCompanyScreenState();
}

class _RegisterCompanyScreenState extends State<RegisterCompanyScreen> {
  int _step = 0;

  final _formCompanyKey = GlobalKey<FormState>();
  final _formAddressKey = GlobalKey<FormState>();

  // --- Controllers (Paso 1)
  final _razonSocialCtrl = TextEditingController();
  final _rucCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _correoAltCtrl = TextEditingController();
  final _telConvCtrl = TextEditingController();
  final _celularCtrl = TextEditingController();
  final _repNombreCtrl = TextEditingController();
  final _repCargoCtrl = TextEditingController();
  final _repTelefonoCtrl = TextEditingController();

  // --- Controllers (Paso 2)
  final _paisCtrl = TextEditingController();
  final _provinciaCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  // --- Dropdowns
  String? _tipoInstitucion; // Pública / Privada
  String? _sectorEconomico; // lista grande

  // --- Archivos
  Uint8List? _logoBytes;
  String? _logoName;

  Uint8List? _rucFileBytes;
  String? _rucFileName;

  final List<String> _tipoInstitucionItems = ["Pública", "Privada"];

  final List<String> _sectorEconomicoItems = [
    "Agricultura / Ganadería / Pesca / Silvicultura",
    "Comercio (mayoristas y minoristas) / Negocios / Comercio exterior",
    "Construcción / Bienes Raíces",
    "Consultoría / Servicios Profesionales",
    "Defensa / Seguridad / Rescate",
    "Educación Superior",
    "Alimentos / Bienes de consumo masivo",
    "Energías renovables",
    "Entretenimiento / Ocio",
    "Farmacia / Biotecnología",
    "Finanzas/ Contabilidad / Banca / Aseguradoras",
    "Hotelería / Viajes / Turismo / Restaurantes",
    "Ingeniería",
    "Investigación & Desarrollo / Ciencia",
    "Asesoría legal / Jurídico",
    "Transporte / Almacenamiento / Abastecimiento / Logística",
    "Manufactura",
    "Marketing / Medios de Comunicación / Publicidad",
    "Metalurgia / Minería",
    "Petróleo / Gas",
    "Recursos Humanos / Reclutamiento / Capacitación / Entrenamiento",
    "Salud / Medicina / Nutrición",
    "Servicios públicos (electricidad, agua, alcantarillado, teléfono)",
    "Sin fines de lucro / Fundaciones / ONGs / Voluntariado",
    "Computación / Informática / Tecnologías",
    "Telecomunicaciones",
    "Educación Básica y Bachillerato",
    "Otros",
  ];

  @override
  void initState() {
    super.initState();
    for (final c in [
      _razonSocialCtrl,
      _rucCtrl,
      _correoCtrl,
      _correoAltCtrl,
      _telConvCtrl,
      _celularCtrl,
      _repNombreCtrl,
      _repCargoCtrl,
      _repTelefonoCtrl,
      _paisCtrl,
      _provinciaCtrl,
      _ciudadCtrl,
      _direccionCtrl,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _razonSocialCtrl.dispose();
    _rucCtrl.dispose();
    _correoCtrl.dispose();
    _correoAltCtrl.dispose();
    _telConvCtrl.dispose();
    _celularCtrl.dispose();
    _repNombreCtrl.dispose();
    _repCargoCtrl.dispose();
    _repTelefonoCtrl.dispose();

    _paisCtrl.dispose();
    _provinciaCtrl.dispose();
    _ciudadCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  bool get _companyReady {
    return _razonSocialCtrl.text.trim().isNotEmpty &&
        (_tipoInstitucion != null) &&
        _rucCtrl.text.trim().length == 13 &&
        _rucFileBytes != null &&
        _correoCtrl.text.trim().isNotEmpty &&
        _correoAltCtrl.text.trim().isNotEmpty &&
        _telConvCtrl.text.trim().isNotEmpty &&
        _celularCtrl.text.trim().isNotEmpty &&
        (_sectorEconomico != null) &&
        _repNombreCtrl.text.trim().isNotEmpty &&
        _repCargoCtrl.text.trim().isNotEmpty &&
        _repTelefonoCtrl.text.trim().isNotEmpty;
  }

  bool get _addressReady {
    return _paisCtrl.text.trim().isNotEmpty &&
        _provinciaCtrl.text.trim().isNotEmpty &&
        _ciudadCtrl.text.trim().isNotEmpty &&
        _direccionCtrl.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final bgTop = const Color(0xFF0B5ED7);
    final bgBottom = const Color(0xFFF5F8FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () {
            if (_step == 1) {
              setState(() => _step = 0);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _step == 0 ? "Registro de empleadores" : "Dirección",
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Fondo moderno
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    bgTop.withAlpha(20),
                    bgBottom,
                  ],
                ),
              ),
            ),
          ),

          // Contenido
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
              child: Column(
                children: [
                  _ProgressPills(step: _step),
                  const SizedBox(height: 14),

                  _step == 0 ? _companyCard(context) : _addressCard(context),

                  const SizedBox(height: 14),
                  _bottomHint(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomHint() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Text(
          "¿Ya tienes una cuenta? Inicia sesión",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _companyCard(BuildContext context) {
    return _GlassCard(
      child: Form(
        key: _formCompanyKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              title: "Datos de la empresa",
              subtitle: "Complete la información solicitada para crear la cuenta.",
            ),
            const SizedBox(height: 14),

            // Logo (opcional)
            _LogoPicker(
              bytes: _logoBytes,
              fileName: _logoName,
              onPick: _pickLogo,
              onClear: () => setState(() {
                _logoBytes = null;
                _logoName = null;
              }),
            ),

            const SizedBox(height: 18),

            _LabeledField(
              label: "Razón social",
              child: TextFormField(
                controller: _razonSocialCtrl,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Ingrese la razón social"
                    : null,
                decoration: _inputDeco(hint: "Ej: Bangara S.A."),
              ),
            ),

            const SizedBox(height: 12),

            _LabeledField(
              label: "Tipo institución",
              child: DropdownButtonFormField<String>(
                value: _tipoInstitucion,
                items: _tipoInstitucionItems
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _tipoInstitucion = v),
                validator: (v) => v == null ? "Seleccione una opción" : null,
                decoration: _inputDeco(hint: "Seleccione"),
              ),
            ),

            const SizedBox(height: 12),

            _LabeledField(
              label: "RUC",
              child: TextFormField(
                controller: _rucCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final t = (v ?? "").trim();
                  if (t.isEmpty) return "Ingrese el RUC";
                  if (t.length != 13) return "El RUC debe tener 13 dígitos";
                  return null;
                },
                decoration: _inputDeco(hint: "Ingrese RUC (13 dígitos)"),
              ),
            ),

            const SizedBox(height: 12),

            // Archivo RUC (requerido)
            _FilePickerRow(
              label: "Archivo RUC",
              fileName: _rucFileName,
              required: true,
              onPick: _pickRucFile,
              onClear: () => setState(() {
                _rucFileBytes = null;
                _rucFileName = null;
              }),
              helper: "Formatos: pdf, png, jpg, jpeg",
              errorText: (_rucFileBytes == null) ? "Debe adjuntar el RUC" : null,
            ),

            const SizedBox(height: 12),

            _LabeledField(
              label: "Correo",
              child: TextFormField(
                controller: _correoCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final t = (v ?? "").trim();
                  if (t.isEmpty) return "Ingrese el correo";
                  if (!t.contains("@")) return "Correo inválido";
                  return null;
                },
                decoration: _inputDeco(hint: "correo@dominio.com"),
              ),
            ),

            const SizedBox(height: 12),

            _LabeledField(
              label: "Correo alterno",
              child: TextFormField(
                controller: _correoAltCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final t = (v ?? "").trim();
                  if (t.isEmpty) return "Ingrese el correo alterno";
                  if (!t.contains("@")) return "Correo inválido";
                  return null;
                },
                decoration: _inputDeco(hint: "correoalterno@dominio.com"),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: "Teléfono convencional",
                    child: TextFormField(
                      controller: _telConvCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? "Requerido" : null,
                      decoration: _inputDeco(hint: "Ej: 042345678"),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LabeledField(
                    label: "Celular",
                    child: TextFormField(
                      controller: _celularCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? "Requerido" : null,
                      decoration: _inputDeco(hint: "Ej: 0999999999"),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _LabeledField(
              label: "Sector económico",
              child: DropdownButtonFormField<String>(
                value: _sectorEconomico,
                isExpanded: true,
                items: _sectorEconomicoItems
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _sectorEconomico = v),
                validator: (v) => v == null ? "Seleccione una opción" : null,
                decoration: _inputDeco(hint: "Seleccione"),
              ),
            ),

            const SizedBox(height: 12),

            _LabeledField(
              label: "Representante para contacto",
              child: TextFormField(
                controller: _repNombreCtrl,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Requerido" : null,
                decoration: _inputDeco(hint: "Nombre completo"),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: "Cargo representante",
                    child: TextFormField(
                      controller: _repCargoCtrl,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? "Requerido" : null,
                      decoration: _inputDeco(hint: "Ej: Gerente RRHH"),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LabeledField(
                    label: "Teléfono representante",
                    child: TextFormField(
                      controller: _repTelefonoCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? "Requerido" : null,
                      decoration: _inputDeco(hint: "Ej: 0999999999"),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _companyReady
                    ? () {
                        final ok = _formCompanyKey.currentState?.validate() ?? false;
                        if (!ok) return;
                        if (_rucFileBytes == null) {
                          setState(() {});
                          return;
                        }
                        setState(() => _step = 1);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B5ED7),
                  disabledBackgroundColor: const Color(0xFF0B5ED7).withAlpha(80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Siguiente",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressCard(BuildContext context) {
    return _GlassCard(
      child: Form(
        key: _formAddressKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              title: "Dirección",
              subtitle: "Ingrese la ubicación de la empresa.",
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: "País",
                    child: TextFormField(
                      controller: _paisCtrl,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? "Requerido" : null,
                      decoration: _inputDeco(hint: "Ej: Ecuador"),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LabeledField(
                    label: "Provincia",
                    child: TextFormField(
                      controller: _provinciaCtrl,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? "Requerido" : null,
                      decoration: _inputDeco(hint: "Ej: Guayas"),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _LabeledField(
              label: "Ciudad",
              child: TextFormField(
                controller: _ciudadCtrl,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Requerido" : null,
                decoration: _inputDeco(hint: "Ej: Guayaquil"),
              ),
            ),

            const SizedBox(height: 12),

            _LabeledField(
              label: "Dirección",
              child: TextFormField(
                controller: _direccionCtrl,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Requerido" : null,
                decoration: _inputDeco(hint: "Ingrese una dirección"),
              ),
            ),

            const SizedBox(height: 18),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                key: ValueKey(_addressReady),
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _addressReady
                      ? () {
                          final ok = _formAddressKey.currentState?.validate() ?? false;
                          if (!ok) return;
                          _showSubmittedDialog();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B5ED7),
                    disabledBackgroundColor: const Color(0xFF0B5ED7).withAlpha(80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Crear cuenta",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withAlpha(25)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withAlpha(25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0B5ED7), width: 1.4),
      ),
    );
  }

  Future<void> _pickLogo() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (res == null || res.files.isEmpty) return;

    final f = res.files.single;
    setState(() {
      _logoBytes = f.bytes;
      _logoName = f.name;
    });
  }

  Future<void> _pickRucFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (res == null || res.files.isEmpty) return;

    final f = res.files.single;
    setState(() {
      _rucFileBytes = f.bytes;
      _rucFileName = f.name;
    });
  }

  void _showSubmittedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text(
            "Solicitud enviada",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            "Su cuenta ha sido enviada para procesar los datos, en el transcurso de la semana se le notificará de que su cuenta ya está activa",
            style: TextStyle(height: 1.3),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // cierra dialog
                Navigator.pop(context); // vuelve
              },
              child: const Text(
                "Aceptar",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ===================== UI Helpers =====================

class _ProgressPills extends StatelessWidget {
  final int step;
  const _ProgressPills({required this.step});

  @override
  Widget build(BuildContext context) {
    Color active = const Color(0xFF0B5ED7);
    Color idle = Colors.black.withAlpha(35);

    Widget pill(bool on, String text) {
      return Expanded(
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? active.withAlpha(25) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: on ? active : idle),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: on ? active : Colors.black87,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        pill(step == 0, "Empresa"),
        const SizedBox(width: 10),
        pill(step == 1, "Dirección"),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withAlpha(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(color: Colors.black.withAlpha(140), height: 1.25),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _LogoPicker extends StatelessWidget {
  final Uint8List? bytes;
  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _LogoPicker({
    required this.bytes,
    required this.fileName,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Logo de la empresa (opcional)",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withAlpha(18)),
              ),
              clipBehavior: Clip.antiAlias,
              child: bytes == null
                  ? const Icon(Icons.apartment_rounded, size: 30)
                  : Image.memory(bytes!, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName ?? "Sin logo seleccionado",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: onPick,
                        icon: const Icon(Icons.upload_rounded, size: 18),
                        label: const Text("Subir logo"),
                      ),
                      const SizedBox(width: 10),
                      if (bytes != null)
                        TextButton(
                          onPressed: onClear,
                          child: const Text("Quitar"),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilePickerRow extends StatelessWidget {
  final String label;
  final String? fileName;
  final bool required;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final String helper;
  final String? errorText;

  const _FilePickerRow({
    required this.label,
    required this.fileName,
    required this.required,
    required this.onPick,
    required this.onClear,
    required this.helper,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = (fileName != null && fileName!.trim().isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (required)
              Text(
                " *",
                style: TextStyle(
                  color: Colors.red.withAlpha(200),
                  fontWeight: FontWeight.w900,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (errorText != null && !hasFile)
                  ? Colors.red.withAlpha(160)
                  : Colors.black.withAlpha(25),
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasFile ? Icons.description_rounded : Icons.attach_file_rounded,
                color: Colors.black.withAlpha(170),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  fileName ?? "Seleccione un archivo",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onPick,
                child: const Text("Elegir"),
              ),
              if (hasFile) ...[
                const SizedBox(width: 6),
                TextButton(
                  onPressed: onClear,
                  child: const Text("Quitar"),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 6),
        Text(
          helper,
          style: TextStyle(color: Colors.black.withAlpha(140), fontSize: 12),
        ),
        if (errorText != null && !hasFile) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: TextStyle(color: Colors.red.withAlpha(220), fontWeight: FontWeight.w700),
          ),
        ],
      ],
    );
  }
}
