import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final String cedula, nombres, apellidos;
  final String paisNac, nacionalidad, provNac, ciudadNac;
  final String estadoCivil, sexo, fechaNac, edad, telfConv, celular, correoInst, correoPers, etnia;
  final String discapTipo, discapPorc;
  final String referencia, direccion;

  const EditProfileScreen({
    super.key,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.paisNac,
    required this.nacionalidad,
    required this.provNac,
    required this.ciudadNac,
    required this.estadoCivil,
    required this.sexo,
    required this.fechaNac,
    required this.edad,
    required this.telfConv,
    required this.celular,
    required this.correoInst,
    required this.correoPers,
    required this.etnia,
    required this.discapTipo,
    required this.discapPorc,
    required this.referencia,
    required this.direccion,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _cedulaCtrl;
  late final TextEditingController _nombresCtrl;
  late final TextEditingController _apellidosCtrl;

  late final TextEditingController _fechaNacCtrl;
  late final TextEditingController _edadCtrl;

  late final TextEditingController _telfConvCtrl;
  late final TextEditingController _celularCtrl;
  late final TextEditingController _correoInstCtrl;
  late final TextEditingController _correoPersCtrl;

  late final TextEditingController _discapPorcCtrl;
  late final TextEditingController _referenciaCtrl;
  late final TextEditingController _direccionCtrl;

  String? _selPaisNac, _selNacionalidad, _selProvNac, _selCiudadNac;
  String? _selEstadoCivil, _selSexo, _selEtnia;
  String? _selDiscapTipo;

  final Set<String> _expanded = {"ident", "contact"};

  static const Color _bg = Color(0xFFF4F6FA);
  static const Color _muted = Color(0xFF64748B);
  static const Color _primary = Color(0xFF2563EB);
  static const Color _primary2 = Color(0xFF60A5FA);
  static const Color _cardBorder = Color(0xFFE7EEF8);

  static const double _gap = 14;
  static const double _gapH = 12;

  @override
  void initState() {
    super.initState();
    _cedulaCtrl = TextEditingController(text: widget.cedula);
    _nombresCtrl = TextEditingController(text: widget.nombres);
    _apellidosCtrl = TextEditingController(text: widget.apellidos);

    _selPaisNac = widget.paisNac;
    _selNacionalidad = widget.nacionalidad;
    _selProvNac = widget.provNac;
    _selCiudadNac = widget.ciudadNac;

    _selEstadoCivil = widget.estadoCivil;
    _selSexo = widget.sexo;

    _fechaNacCtrl = TextEditingController(text: widget.fechaNac);
    _edadCtrl = TextEditingController(text: widget.edad);

    _telfConvCtrl = TextEditingController(text: widget.telfConv);
    _celularCtrl = TextEditingController(text: widget.celular);
    _correoInstCtrl = TextEditingController(text: widget.correoInst);
    _correoPersCtrl = TextEditingController(text: widget.correoPers);

    _selEtnia = widget.etnia;
    _selDiscapTipo = widget.discapTipo;

    _discapPorcCtrl = TextEditingController(text: widget.discapPorc);
    _referenciaCtrl = TextEditingController(text: widget.referencia);
    _direccionCtrl = TextEditingController(text: widget.direccion);
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _fechaNacCtrl.dispose();
    _edadCtrl.dispose();
    _telfConvCtrl.dispose();
    _celularCtrl.dispose();
    _correoInstCtrl.dispose();
    _correoPersCtrl.dispose();
    _discapPorcCtrl.dispose();
    _referenciaCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? "Este campo es obligatorio" : null;

  String? _email(String? v) {
    if (v == null || v.trim().isEmpty) return "Este campo es obligatorio";
    final s = v.trim();
    if (!s.contains("@") || !s.contains(".")) return "Correo inválido";
    return null;
  }

  String? _number(String? v) {
    if (v == null || v.trim().isEmpty) return "Este campo es obligatorio";
    if (int.tryParse(v.trim()) == null) return "Debe ser numérico";
    return null;
  }

  String? _percent(String? v) {
    if (_selDiscapTipo == "Ninguna") return null;
    if (v == null || v.trim().isEmpty) return "Ingresa el porcentaje";
    final n = int.tryParse(v.trim());
    if (n == null) return "Debe ser numérico";
    if (n < 0 || n > 100) return "Debe estar entre 0 y 100";
    return null;
  }

  int _calcAge(DateTime birth) {
    final now = DateTime.now();
    int age = now.year - birth.year;
    final hadBirthday = (now.month > birth.month) || (now.month == birth.month && now.day >= birth.day);
    if (!hadBirthday) age--;
    return age < 0 ? 0 : age;
  }

  Future<void> _pickBirthDate() async {
    DateTime? initial;
    final txt = _fechaNacCtrl.text.trim();
    try {
      if (txt.contains("/")) {
        final p = txt.split("/");
        if (p.length == 3) {
          final d = int.parse(p[0]);
          final m = int.parse(p[1]);
          final y = int.parse(p[2]);
          initial = DateTime(y, m, d);
        }
      } else if (txt.contains("-")) {
        initial = DateTime.tryParse(txt);
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime(2005, 1, 1),
      firstDate: DateTime(1950, 1, 1),
      lastDate: DateTime.now(),
      helpText: "Selecciona tu fecha de nacimiento",
    );

    if (picked == null) return;

    final d = picked.day.toString().padLeft(2, "0");
    final m = picked.month.toString().padLeft(2, "0");
    final y = picked.year.toString();
    _fechaNacCtrl.text = "$d/$m/$y";
    _edadCtrl.text = _calcAge(picked).toString();
    setState(() {});
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_selPaisNac == null ||
        _selNacionalidad == null ||
        _selProvNac == null ||
        _selCiudadNac == null ||
        _selEstadoCivil == null ||
        _selSexo == null ||
        _selEtnia == null ||
        _selDiscapTipo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos de selección (dropdowns).")),
      );
      return;
    }

    Navigator.pop(context, {
      'cedula': _cedulaCtrl.text,
      'nombres': _nombresCtrl.text,
      'apellidos': _apellidosCtrl.text,
      'paisNac': _selPaisNac!,
      'nacionalidad': _selNacionalidad!,
      'provNac': _selProvNac!,
      'ciudadNac': _selCiudadNac!,
      'estadoCivil': _selEstadoCivil!,
      'sexo': _selSexo!,
      'fechaNac': _fechaNacCtrl.text,
      'edad': _edadCtrl.text,
      'telfConv': _telfConvCtrl.text,
      'celular': _celularCtrl.text,
      'correoInst': _correoInstCtrl.text,
      'correoPers': _correoPersCtrl.text,
      'etnia': _selEtnia!,
      'discapTipo': _selDiscapTipo!,
      'discapPorc': _discapPorcCtrl.text,
      'referencia': _referenciaCtrl.text,
      'direccion': _direccionCtrl.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: _bg,
        colorScheme: ColorScheme.fromSeed(seedColor: _primary),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(color: _muted),
          labelStyle: const TextStyle(color: _muted),
          helperStyle: const TextStyle(color: _muted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _primary, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
      child: Scaffold(
        body: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: _primary,
              foregroundColor: Colors.white,

              // ✅ Menos alto para acercar título y nombre
              expandedHeight: 145,
              collapsedHeight: 72,

              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                "Editar Perfil",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _HeaderBackground(
                  title: "${widget.apellidos} ${widget.nombres}",
                  subtitle: "Completa tus datos con calma ✨",
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      _SectionCard(
                        expanded: _expanded.contains("ident"),
                        onToggle: () => setState(() {
                          _expanded.contains("ident") ? _expanded.remove("ident") : _expanded.add("ident");
                        }),
                        title: "Datos de identificación",
                        icon: Icons.badge_rounded,
                        child: Column(
                          children: [
                            _Field.text(
                              label: "Cédula",
                              controller: _cedulaCtrl,
                              readOnly: true,
                              icon: Icons.credit_card_rounded,
                              validator: _required,
                            ),
                            const SizedBox(height: _gap),
                            Row(
                              children: [
                                Expanded(
                                  child: _Field.text(
                                    label: "Apellidos",
                                    controller: _apellidosCtrl,
                                    icon: Icons.person_rounded,
                                    textCapitalization: TextCapitalization.words,
                                    validator: _required,
                                  ),
                                ),
                                const SizedBox(width: _gapH),
                                Expanded(
                                  child: _Field.text(
                                    label: "Nombres",
                                    controller: _nombresCtrl,
                                    icon: Icons.person_rounded,
                                    textCapitalization: TextCapitalization.words,
                                    validator: _required,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      _SectionCard(
                        expanded: _expanded.contains("birth"),
                        onToggle: () => setState(() {
                          _expanded.contains("birth") ? _expanded.remove("birth") : _expanded.add("birth");
                        }),
                        title: "Lugar de nacimiento",
                        icon: Icons.public_rounded,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _Field.dropdown(
                                    label: "País",
                                    value: _selPaisNac,
                                    icon: Icons.flag_rounded,
                                    items: const ["ECUADOR", "PERU", "COLOMBIA"],
                                    onChanged: (v) => setState(() => _selPaisNac = v),
                                    validator: (v) => v == null ? "Selecciona un país" : null,
                                  ),
                                ),
                                const SizedBox(width: _gapH),
                                Expanded(
                                  child: _Field.dropdown(
                                    label: "Nacionalidad",
                                    value: _selNacionalidad,
                                    icon: Icons.verified_user_rounded,
                                    items: const ["ECUATORIANA", "PERUANA", "COLOMBIANA"],
                                    onChanged: (v) => setState(() => _selNacionalidad = v),
                                    validator: (v) => v == null ? "Selecciona nacionalidad" : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: _gap),
                            Row(
                              children: [
                                Expanded(
                                  child: _Field.dropdown(
                                    label: "Provincia",
                                    value: _selProvNac,
                                    icon: Icons.map_rounded,
                                    items: const ["GUAYAS", "PICHINCHA", "AZUAY"],
                                    onChanged: (v) => setState(() => _selProvNac = v),
                                    validator: (v) => v == null ? "Selecciona provincia" : null,
                                  ),
                                ),
                                const SizedBox(width: _gapH),
                                Expanded(
                                  child: _Field.dropdown(
                                    label: "Ciudad",
                                    value: _selCiudadNac,
                                    icon: Icons.location_city_rounded,
                                    items: const ["GUAYAQUIL", "QUITO", "CUENCA"],
                                    onChanged: (v) => setState(() => _selCiudadNac = v),
                                    validator: (v) => v == null ? "Selecciona ciudad" : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      _SectionCard(
                        expanded: _expanded.contains("contact"),
                        onToggle: () => setState(() {
                          _expanded.contains("contact") ? _expanded.remove("contact") : _expanded.add("contact");
                        }),
                        title: "Información personal y contacto",
                        icon: Icons.contact_page_rounded,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _Field.dropdown(
                                    label: "Estado civil",
                                    value: _selEstadoCivil,
                                    icon: Icons.favorite_rounded,
                                    items: const ["Soltero(a)", "Casado(a)", "Divorciado(a)"],
                                    onChanged: (v) => setState(() => _selEstadoCivil = v),
                                    validator: (v) => v == null ? "Selecciona estado civil" : null,
                                  ),
                                ),
                                const SizedBox(width: _gapH),
                                Expanded(
                                  child: _Field.dropdown(
                                    label: "Sexo",
                                    value: _selSexo,
                                    icon: Icons.wc_rounded,
                                    items: const ["Masculino", "Femenino"],
                                    onChanged: (v) => setState(() => _selSexo = v),
                                    validator: (v) => v == null ? "Selecciona sexo" : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: _gap),
                            Row(
                              children: [
                                Expanded(
                                  child: _Field.text(
                                    label: "Fecha de nacimiento",
                                    controller: _fechaNacCtrl,
                                    icon: Icons.calendar_month_rounded,
                                    readOnly: true,
                                    onTap: _pickBirthDate,
                                    validator: _required,
                                  ),
                                ),
                                const SizedBox(width: _gapH),
                                Expanded(
                                  child: _Field.text(
                                    label: "Edad",
                                    controller: _edadCtrl,
                                    icon: Icons.cake_rounded,
                                    keyboardType: TextInputType.number,
                                    validator: _number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: _gap),
                            Row(
                              children: [
                                Expanded(
                                  child: _Field.text(
                                    label: "Teléfono convencional",
                                    controller: _telfConvCtrl,
                                    icon: Icons.phone_rounded,
                                    keyboardType: TextInputType.phone,
                                    validator: _required,
                                  ),
                                ),
                                const SizedBox(width: _gapH),
                                Expanded(
                                  child: _Field.text(
                                    label: "Celular",
                                    controller: _celularCtrl,
                                    icon: Icons.smartphone_rounded,
                                    keyboardType: TextInputType.phone,
                                    validator: _required,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: _gap),
                            _Field.text(
                              label: "Correo institucional",
                              controller: _correoInstCtrl,
                              icon: Icons.business_rounded,
                              readOnly: true,
                              validator: _required,
                            ),
                            const SizedBox(height: _gap),
                            _Field.text(
                              label: "Correo personal",
                              controller: _correoPersCtrl,
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: _email,
                            ),
                            const SizedBox(height: _gap),
                            _Field.dropdown(
                              label: "Etnia",
                              value: _selEtnia,
                              icon: Icons.groups_rounded,
                              items: const ["Mestizo", "Blanco", "Afroecuatoriano", "Indígena"],
                              onChanged: (v) => setState(() => _selEtnia = v),
                              validator: (v) => v == null ? "Selecciona etnia" : null,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      _SectionCard(
                        expanded: _expanded.contains("discap"),
                        onToggle: () => setState(() {
                          _expanded.contains("discap") ? _expanded.remove("discap") : _expanded.add("discap");
                        }),
                        title: "Discapacidad",
                        icon: Icons.accessible_rounded,
                        child: Column(
                          children: [
                            _Field.dropdown(
                              label: "Tipo de discapacidad",
                              value: _selDiscapTipo,
                              icon: Icons.accessibility_new_rounded,
                              items: const ["Ninguna", "Física", "Auditiva", "Visual"],
                              onChanged: (v) => setState(() => _selDiscapTipo = v),
                              validator: (v) => v == null ? "Selecciona una opción" : null,
                            ),
                            const SizedBox(height: _gap),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: (_selDiscapTipo != null && _selDiscapTipo != "Ninguna")
                                  ? _Field.text(
                                      key: const ValueKey("porc"),
                                      label: "Porcentaje (%)",
                                      controller: _discapPorcCtrl,
                                      icon: Icons.percent_rounded,
                                      keyboardType: TextInputType.number,
                                      validator: _percent,
                                      helperText: "Ej: 30 (0 a 100)",
                                    )
                                  : const SizedBox.shrink(key: ValueKey("none")),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      _SectionCard(
                        expanded: _expanded.contains("address"),
                        onToggle: () => setState(() {
                          _expanded.contains("address") ? _expanded.remove("address") : _expanded.add("address");
                        }),
                        title: "Dirección domiciliaria",
                        icon: Icons.home_rounded,
                        child: Column(
                          children: [
                            _Field.text(
                              label: "Referencia",
                              controller: _referenciaCtrl,
                              icon: Icons.place_rounded,
                              validator: _required,
                            ),
                            const SizedBox(height: _gap),
                            _Field.text(
                              label: "Dirección / Calle principal",
                              controller: _direccionCtrl,
                              icon: Icons.signpost_rounded,
                              maxLines: 2,
                              validator: _required,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _cardBorder.withOpacity(.9))),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 20, offset: const Offset(0, -8)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text("Cancelar"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text("Guardar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- HEADER (ajustado: menos separación) ----------------

class _HeaderBackground extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderBackground({required this.title, required this.subtitle});

  static const Color _primary = Color(0xFF2563EB);
  static const Color _primary2 = Color(0xFF60A5FA);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, _primary2],
        ),
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 40, // un poco más pequeño
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(.20)),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.95),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2), // ✅ menos separación
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- UI WIDGETS ----------------

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  static const Color _primary = Color(0xFF2563EB);
  static const Color _cardBorder = Color(0xFFE7EEF8);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 22, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: _primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.2, letterSpacing: .2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more_rounded),
                  ),
                ],
              ),
            ),
          ),

          // ✅ FIX: espacio superior dentro del crossfade para que el label flotante NO se recorte
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 16), // ✅ top extra
              child: Column(
                children: [
                  Container(height: 1, color: _cardBorder.withOpacity(.9)), // separador visual
                  const SizedBox(height: 12), // ✅ aire antes del primer campo
                  child,
                ],
              ),
            ),
            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }
}

class _Field {
  static Widget text({
    Key? key,
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? helperText,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: icon == null ? null : Icon(icon),
        fillColor: readOnly ? const Color(0xFFF8FAFC) : Colors.white,
      ),
    );
  }

  static Widget dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: (value != null && value.isNotEmpty) ? value : null,
      validator: validator,
      isExpanded: true,
      menuMaxHeight: 320,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
    );
  }
}
