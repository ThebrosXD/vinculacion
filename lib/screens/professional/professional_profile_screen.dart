import 'dart:ui';
import 'package:flutter/material.dart';

import '../../network/ug_client.dart';
import '../../network/ug/ug_models.dart';

class ProfessionalProfileScreen extends StatefulWidget {
  final String cedula;

  // Fallback mientras carga API
  final String fallbackNombres;
  final String fallbackApellidos;
  final String fallbackCelular;
  final String fallbackCorreoInst;
  final String fallbackPais;
  final String fallbackCiudad;

  // Acciones desde main
  final Widget modulePickerAction;
  final VoidCallback onLogout;
  final VoidCallback onViewCv;

  const ProfessionalProfileScreen({
    super.key,
    required this.cedula,
    required this.fallbackNombres,
    required this.fallbackApellidos,
    required this.fallbackCelular,
    required this.fallbackCorreoInst,
    required this.fallbackPais,
    required this.fallbackCiudad,
    required this.modulePickerAction,
    required this.onLogout,
    required this.onViewCv,
  });

  @override
  State<ProfessionalProfileScreen> createState() => _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState extends State<ProfessionalProfileScreen> {
  static const Color _bg = Color(0xFFF4F6FA);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE7EEF8);

  bool _loading = true;
  String? _error;
  String? _errorDetails;

  UgDatosPersonales? _dp;
  List<UgEducacion> _educ = [];
  List<UgIdioma> _idiomas = [];

  // Extras manuales
  final List<_ProfileExperience> _experiences = [];
  final List<_ProfileReference> _references = [];
  final List<UgEducacion> _educExtra = [];
  final List<UgIdioma> _idiomasExtra = [];

  int _loadSeq = 0;

  Color _op(Color c, double a) => c.withValues(alpha: a.clamp(0.0, 1.0));

  String _short(String s, {int max = 240}) {
    final t = s.trim();
    if (t.length <= max) return t;
    return "${t.substring(0, max)}…";
  }

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final seq = ++_loadSeq;

    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
      _errorDetails = null;
    });

    try {
      final dp = await UgClient.instance.obtenerDatosPersonalesPrimero(
        codEstudiante: widget.cedula,
        usuarioTrx: widget.cedula,
      );

      if (!mounted || seq != _loadSeq) return;
      if (dp == null) throw Exception("No se encontró información personal para esta cédula.");

      final idDp = dp.idDatoPersonal;

      final results = await Future.wait([
        UgClient.instance.obtenerEducacion(idDatoPersonal: idDp, usuarioTrx: widget.cedula),
        UgClient.instance.obtenerIdiomas(idDatoPersonal: idDp, usuarioTrx: widget.cedula),
      ]);

      if (!mounted || seq != _loadSeq) return;

      setState(() {
        _dp = dp;
        _educ = (results[0] as List<UgEducacion>);
        _idiomas = (results[1] as List<UgIdioma>);
        _loading = false;
      });
    } catch (e) {
      if (!mounted || seq != _loadSeq) return;
      setState(() {
        _loading = false;
        _error = "No se pudo cargar tu perfil.";
        _errorDetails = e.toString();
      });
    }
  }

  Future<void> _logoutFull() async {
    try {
      await UgClient.instance.clearToken();
    } catch (_) {}
    if (!mounted) return;
    widget.onLogout();
  }

  String _greetingTitle() {
    final n = _dp?.nombres.trim().isNotEmpty == true ? _dp!.nombres : widget.fallbackNombres;
    return "Hola, $n";
  }

  String _fullName() {
    final fromApi = _dp?.nombreCompleto.trim();
    if (fromApi != null && fromApi.isNotEmpty) return fromApi;
    return "${widget.fallbackNombres} ${widget.fallbackApellidos}".trim();
  }

  String _cell() {
    final s = _dp?.celular.trim();
    if (s != null && s.isNotEmpty) return s;
    return widget.fallbackCelular;
  }

  String _correoInst() {
    final s = _dp?.correoInstitucional?.trim();
    if (s != null && s.isNotEmpty) return s;
    return widget.fallbackCorreoInst;
  }

  String _paisCiudad() {
    final pais = (_dp?.paisDomicilio.trim().isNotEmpty == true) ? _dp!.paisDomicilio : widget.fallbackPais;
    final ciudad = (_dp?.ciudadDomicilio.trim().isNotEmpty == true) ? _dp!.ciudadDomicilio : widget.fallbackCiudad;
    return "$pais • $ciudad";
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r"\s+")).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return "U";
    final a = parts.first.isNotEmpty ? parts.first[0] : "U";
    final b = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : "";
    return (a + b).toUpperCase();
  }

  Future<void> _openEditDatosPersonales() async {
    final dp = _dp;
    if (dp == null) return;

    final updated = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditDatosPersonalesSheet(initial: Map<String, dynamic>.from(dp.raw)),
    );

    if (!mounted) return;
    if (updated != null) {
      setState(() => _dp = UgDatosPersonales.fromJson(updated));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Datos actualizados (local)")),
      );
    }
  }

  Future<void> _addExperience() async {
    final r = await showModalBottomSheet<_ProfileExperience>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddExperienceSheet(),
    );
    if (!mounted) return;
    if (r != null) setState(() => _experiences.add(r));
  }

  Future<void> _addReference() async {
    final r = await showModalBottomSheet<_ProfileReference>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddReferenceSheet(),
    );
    if (!mounted) return;
    if (r != null) setState(() => _references.add(r));
  }

  Future<void> _addIdioma() async {
    final r = await showModalBottomSheet<UgIdioma>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddIdiomaSheet(),
    );
    if (!mounted) return;
    if (r != null) setState(() => _idiomasExtra.add(r));
  }

  Future<void> _addEducacion() async {
    final r = await showModalBottomSheet<UgEducacion>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddEducacionSheet(),
    );
    if (!mounted) return;
    if (r != null) setState(() => _educExtra.add(r));
  }

  SliverAppBar _appBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 6,
      backgroundColor: _bg,
      surfaceTintColor: _bg,
      shadowColor: _op(Colors.black, .12),
      automaticallyImplyLeading: false,
      leading: const SizedBox.shrink(),
      centerTitle: false,
      titleSpacing: 16,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greetingTitle(), style: const TextStyle(fontWeight: FontWeight.w900, color: _ink)),
            const SizedBox(height: 2),
            Text("Perfil", style: TextStyle(color: _op(_muted, .95), fontWeight: FontWeight.w800, fontSize: 12.5)),
          ],
        ),
      ),
      actions: [
        widget.modulePickerAction,
        IconButton(
          tooltip: "Editar",
          onPressed: _dp == null ? null : _openEditDatosPersonales,
          icon: const Icon(Icons.edit_rounded, color: _ink),
        ),
        const SizedBox(width: 6),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _cardBorder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = _fullName();
    final initials = _initials(fullName);

    return CustomScrollView(
      slivers: [
        _appBar(),
        if (_loading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.6)),
          )
        else if (_error != null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _cardBorder),
                    boxShadow: [BoxShadow(color: _op(Colors.black, .06), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 46, color: Colors.red),
                      const SizedBox(height: 10),
                      Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      if (_errorDetails != null)
                        Text(_short(_errorDetails!), textAlign: TextAlign.center, style: const TextStyle(color: _muted, height: 1.25)),
                      const SizedBox(height: 12),
                      if (_errorDetails != null)
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: const Text("Ver detalles", style: TextStyle(fontWeight: FontWeight.w800)),
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _cardBorder),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: SelectableText(_errorDetails!, style: const TextStyle(fontSize: 12, color: _muted)),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _loadAll,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text("Reintentar"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(
                    initials: initials,
                    fullName: fullName,
                    phone: _cell(),
                    emailInst: _correoInst(),
                    location: _paisCiudad(),
                    op: _op,
                  ),
                  const SizedBox(height: 14),
                  _CvBigButton(onTap: widget.onViewCv, op: _op),
                  const SizedBox(height: 16),
                  _SectionHeader(title: "Experiencia profesional", onAdd: _addExperience),
                  const SizedBox(height: 10),
                  if (_experiences.isEmpty)
                    const _EmptyMini(icon: Icons.work_outline_rounded, text: "Agrega tu experiencia profesional.")
                  else
                    ..._experiences.map((e) => _ExperienceTile(e)),
                  const SizedBox(height: 16),
                  _SectionHeader(title: "Estudios realizados", onAdd: _addEducacion),
                  const SizedBox(height: 10),
                  _EducationBlock(educFromApi: _educ, educExtra: _educExtra),
                  const SizedBox(height: 16),
                  _SectionHeader(title: "Idiomas", onAdd: _addIdioma),
                  const SizedBox(height: 10),
                  _IdiomasBlock(idiomasFromApi: _idiomas, idiomasExtra: _idiomasExtra),
                  const SizedBox(height: 16),
                  _SectionHeader(title: "Referencias", onAdd: _addReference),
                  const SizedBox(height: 10),
                  if (_references.isEmpty)
                    const _EmptyMini(icon: Icons.groups_2_rounded, text: "Agrega referencias profesionales.")
                  else
                    ..._references.map((r) => _ReferenceTile(r)),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: _logoutFull,
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    label: const Text("Cerrar sesión", style: TextStyle(color: Colors.redAccent)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ======================= HEADER PERFIL =======================

class _ProfileHeader extends StatelessWidget {
  final String initials;
  final String fullName;
  final String phone;
  final String emailInst;
  final String location;
  final Color Function(Color, double) op;

  const _ProfileHeader({
    required this.initials,
    required this.fullName,
    required this.phone,
    required this.emailInst,
    required this.location,
    required this.op,
  });

  static const Color _primary = Color(0xFF2563EB);
  static const Color _primary2 = Color(0xFF60A5FA);

  @override
  Widget build(BuildContext context) {
    final w = Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_primary, _primary2]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: op(Colors.black, .10), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: op(w, .18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: op(w, .20)),
            ),
            child: Center(
              child: Text(initials, style: TextStyle(color: op(w, .98), fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fullName, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: op(w, .98), fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 10),
                _MiniInfo(icon: Icons.phone_android_rounded, text: phone.isEmpty ? "Sin celular" : phone, op: op),
                const SizedBox(height: 6),
                _MiniInfo(icon: Icons.email_rounded, text: emailInst.isEmpty ? "Sin correo institucional" : emailInst, op: op),
                const SizedBox(height: 6),
                _MiniInfo(icon: Icons.place_rounded, text: location, op: op),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color Function(Color, double) op;

  const _MiniInfo({required this.icon, required this.text, required this.op});

  @override
  Widget build(BuildContext context) {
    final w = Colors.white;
    return Row(
      children: [
        Icon(icon, size: 14, color: op(w, .92)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: op(w, .92), fontWeight: FontWeight.w700, fontSize: 12)),
        ),
      ],
    );
  }
}

// ======================= BOTÓN CV =======================

class _CvBigButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color Function(Color, double) op;

  const _CvBigButton({required this.onTap, required this.op});

  static const Color _cardBorder = Color(0xFFE7EEF8);
  static const Color _ink = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _cardBorder),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: op(Colors.black, .04), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: op(_ink, .06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: op(_ink, .10)),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: _ink),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hoja de vida", style: TextStyle(fontWeight: FontWeight.w900)),
                    SizedBox(height: 4),
                    Text("Visualiza tu CV en formato PDF.", style: TextStyle(color: Color(0xFF64748B), height: 1.2)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.visibility_rounded),
                label: const Text("Ver"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================= SECTION HEADER =======================

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;
  const _SectionHeader({required this.title, required this.onAdd});

  static const Color _ink = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: _ink))),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text("Agregar"),
          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        ),
      ],
    );
  }
}

class _EmptyMini extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyMini({required this.icon, required this.text});

  static const Color _muted = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE7EEF8);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _cardBorder)),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, color: _muted),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: _muted, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

// ======================= EDUCACIÓN =======================

class _EducationBlock extends StatelessWidget {
  final List<UgEducacion> educFromApi;
  final List<UgEducacion> educExtra;

  const _EducationBlock({required this.educFromApi, required this.educExtra});

  @override
  Widget build(BuildContext context) {
    final list = [...educFromApi, ...educExtra];
    if (list.isEmpty) return const _EmptyMini(icon: Icons.school_rounded, text: "No hay estudios registrados.");
    return Column(children: list.map((e) => _EducationTile(e)).toList());
  }
}

class _EducationTile extends StatelessWidget {
  final UgEducacion e;
  const _EducationTile(this.e);

  static const Color _cardBorder = Color(0xFFE7EEF8);
  static const Color _muted = Color(0xFF64748B);
  static const Color _ink = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final titulo = (e.titulo ?? "").trim().isEmpty ? "Sin título" : e.titulo!.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _cardBorder)),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.nivelEstudio, style: const TextStyle(fontWeight: FontWeight.w900, color: _ink)),
          const SizedBox(height: 6),
          Text(e.institucion, style: const TextStyle(color: _muted, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text("Nivel instrucción: ${e.nivelInstruccion}", style: const TextStyle(color: _muted)),
          Text("Título: $titulo", style: const TextStyle(color: _muted)),
        ],
      ),
    );
  }
}

// ======================= IDIOMAS =======================

class _IdiomasBlock extends StatelessWidget {
  final List<UgIdioma> idiomasFromApi;
  final List<UgIdioma> idiomasExtra;

  const _IdiomasBlock({required this.idiomasFromApi, required this.idiomasExtra});

  @override
  Widget build(BuildContext context) {
    final list = [...idiomasFromApi, ...idiomasExtra];
    if (list.isEmpty) return const _EmptyMini(icon: Icons.language_rounded, text: "No hay idiomas registrados.");
    return Column(children: list.map((i) => _IdiomaTile(i)).toList());
  }
}

class _IdiomaTile extends StatelessWidget {
  final UgIdioma i;
  const _IdiomaTile(this.i);

  static const Color _cardBorder = Color(0xFFE7EEF8);
  static const Color _muted = Color(0xFF64748B);
  static const Color _ink = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final idioma = i.idioma.trim().isEmpty ? "Idioma" : i.idioma.trim();
    final nivel = i.nivel.trim().isEmpty ? "Sin nivel" : i.nivel.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _cardBorder)),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.language_rounded, color: _muted),
          const SizedBox(width: 10),
          Expanded(child: Text("$idioma • $nivel", style: const TextStyle(fontWeight: FontWeight.w900, color: _ink))),
        ],
      ),
    );
  }
}

// ======================= EXPERIENCIA / REFERENCIAS =======================

class _ProfileExperience {
  final String cargo;
  final String empresa;
  final String periodo;
  final String descripcion;

  const _ProfileExperience({
    required this.cargo,
    required this.empresa,
    required this.periodo,
    required this.descripcion,
  });
}

class _ProfileReference {
  final String nombre;
  final String contacto;
  final String relacion;

  const _ProfileReference({
    required this.nombre,
    required this.contacto,
    required this.relacion,
  });
}

class _ExperienceTile extends StatelessWidget {
  final _ProfileExperience e;
  const _ExperienceTile(this.e);

  static const Color _cardBorder = Color(0xFFE7EEF8);
  static const Color _muted = Color(0xFF64748B);
  static const Color _ink = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _cardBorder)),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.cargo, style: const TextStyle(fontWeight: FontWeight.w900, color: _ink)),
          const SizedBox(height: 6),
          Text("${e.empresa} • ${e.periodo}", style: const TextStyle(color: _muted, fontWeight: FontWeight.w800)),
          if (e.descripcion.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(e.descripcion, style: const TextStyle(color: _muted, height: 1.3)),
          ],
        ],
      ),
    );
  }
}

class _ReferenceTile extends StatelessWidget {
  final _ProfileReference r;
  const _ReferenceTile(this.r);

  static const Color _cardBorder = Color(0xFFE7EEF8);
  static const Color _muted = Color(0xFF64748B);
  static const Color _ink = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _cardBorder)),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.person_pin_circle_rounded, color: _muted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.nombre, style: const TextStyle(fontWeight: FontWeight.w900, color: _ink)),
                const SizedBox(height: 4),
                Text("${r.relacion} • ${r.contacto}", style: const TextStyle(color: _muted, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= SHEET SHELL (FIX OVERFLOW) =======================

class _SheetShell extends StatelessWidget {
  final String title;
  final Widget child;

  /// Cuando expand=true, el sheet ocupa alto fijo y el body usa Expanded -> no overflow.
  final bool expand;

  const _SheetShell({
    required this.title,
    required this.child,
    this.expand = false,
  });

  static const Color _cardBorder = Color(0xFFE7EEF8);
  static const Color _ink = Color(0xFF0F172A);

  Color _op(Color c, double a) => c.withValues(alpha: a.clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * .92;

    final content = ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          color: _op(Colors.white, .92),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _op(Colors.black, .10),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _ink))),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                  Container(height: 1, color: _cardBorder),
                  const SizedBox(height: 12),
                  if (expand) Expanded(child: child) else child,
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!expand) return content;
    return SizedBox(height: maxH, child: content);
  }
}

// ======================= ADD SHEETS (SIN CAMBIOS) =======================

class _AddExperienceSheet extends StatefulWidget {
  const _AddExperienceSheet();

  @override
  State<_AddExperienceSheet> createState() => _AddExperienceSheetState();
}

class _AddExperienceSheetState extends State<_AddExperienceSheet> {
  final _cargo = TextEditingController();
  final _empresa = TextEditingController();
  final _periodo = TextEditingController();
  final _desc = TextEditingController();

  @override
  void dispose() {
    _cargo.dispose();
    _empresa.dispose();
    _periodo.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: "Agregar experiencia",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tf(_cargo, "Cargo / Puesto"),
          const SizedBox(height: 10),
          _tf(_empresa, "Empresa"),
          const SizedBox(height: 10),
          _tf(_periodo, "Periodo (Ej: 2023 - 2025)"),
          const SizedBox(height: 10),
          _tf(_desc, "Descripción (opcional)", maxLines: 3),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(
                context,
                _ProfileExperience(
                  cargo: _cargo.text.trim(),
                  empresa: _empresa.text.trim(),
                  periodo: _periodo.text.trim(),
                  descripcion: _desc.text.trim(),
                ),
              );
            },
            icon: const Icon(Icons.check_rounded),
            label: const Text("Guardar"),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}

class _AddReferenceSheet extends StatefulWidget {
  const _AddReferenceSheet();

  @override
  State<_AddReferenceSheet> createState() => _AddReferenceSheetState();
}

class _AddReferenceSheetState extends State<_AddReferenceSheet> {
  final _nombre = TextEditingController();
  final _contacto = TextEditingController();
  final _relacion = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _contacto.dispose();
    _relacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: "Agregar referencia",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tf(_nombre, "Nombre"),
          const SizedBox(height: 10),
          _tf(_relacion, "Relación (Ej: Jefe / Compañero)"),
          const SizedBox(height: 10),
          _tf(_contacto, "Contacto (teléfono o correo)"),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(
                context,
                _ProfileReference(
                  nombre: _nombre.text.trim(),
                  contacto: _contacto.text.trim(),
                  relacion: _relacion.text.trim(),
                ),
              );
            },
            icon: const Icon(Icons.check_rounded),
            label: const Text("Guardar"),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}

class _AddIdiomaSheet extends StatefulWidget {
  const _AddIdiomaSheet();

  @override
  State<_AddIdiomaSheet> createState() => _AddIdiomaSheetState();
}

class _AddIdiomaSheetState extends State<_AddIdiomaSheet> {
  final _idioma = TextEditingController();
  final _nivel = TextEditingController();

  @override
  void dispose() {
    _idioma.dispose();
    _nivel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: "Agregar idioma",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tf(_idioma, "Idioma"),
          const SizedBox(height: 10),
          _tf(_nivel, "Nivel (Ej: A2 / B1 / B2 / C1)"),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(
                context,
                UgIdioma.fromJson({
                  "IdIdioma": 0,
                  "IdDatoPersonal": 0,
                  "Idioma": _idioma.text.trim(),
                  "Nivel": _nivel.text.trim(),
                }),
              );
            },
            icon: const Icon(Icons.check_rounded),
            label: const Text("Guardar"),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}

class _AddEducacionSheet extends StatefulWidget {
  const _AddEducacionSheet();

  @override
  State<_AddEducacionSheet> createState() => _AddEducacionSheetState();
}

class _AddEducacionSheetState extends State<_AddEducacionSheet> {
  final _nivelEstudio = TextEditingController();
  final _nivelInstruccion = TextEditingController();
  final _institucion = TextEditingController();
  final _titulo = TextEditingController();

  @override
  void dispose() {
    _nivelEstudio.dispose();
    _nivelInstruccion.dispose();
    _institucion.dispose();
    _titulo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: "Agregar estudio",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tf(_nivelEstudio, "Nivel de estudio (Ej: Tercer Nivel)"),
          const SizedBox(height: 10),
          _tf(_institucion, "Institución"),
          const SizedBox(height: 10),
          _tf(_nivelInstruccion, "Nivel instrucción (Ej: Cursando)"),
          const SizedBox(height: 10),
          _tf(_titulo, "Título (opcional)"),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(
                context,
                UgEducacion.fromJson({
                  "IdEducacion": 0,
                  "IdDatoPersonal": 0,
                  "NivelEstudio": _nivelEstudio.text.trim(),
                  "NivelInstruccion": _nivelInstruccion.text.trim(),
                  "Institucion": _institucion.text.trim(),
                  "Titulo": _titulo.text.trim().isEmpty ? null : _titulo.text.trim(),
                  "Facultad": "",
                  "Carrera": "",
                  "Semestre": "",
                }),
              );
            },
            icon: const Icon(Icons.check_rounded),
            label: const Text("Guardar"),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}

Widget _tf(TextEditingController c, String hint, {int maxLines = 1}) {
  return TextField(
    controller: c,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      isDense: true,
    ),
  );
}

// ======================= EDIT DATOS PERSONALES (EXPAND + NO OVERFLOW) =======================

class _EditDatosPersonalesSheet extends StatefulWidget {
  final Map<String, dynamic> initial;
  const _EditDatosPersonalesSheet({required this.initial});

  @override
  State<_EditDatosPersonalesSheet> createState() => _EditDatosPersonalesSheetState();
}

class _EditDatosPersonalesSheetState extends State<_EditDatosPersonalesSheet> {
  static const Color _cardBorder = Color(0xFFE7EEF8);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);

  static const Set<String> _locked = {
    "COD_ESTUDIANTE", "NOMBRE", "APELLIDO", "FECHA_NACIMIENTO", "EDAD", "CORREO_INSTITUCIONAL",
  };

  late final Map<String, dynamic> _data;

  late final TextEditingController _cedulaCtrl;
  late final TextEditingController _apellidosCtrl;
  late final TextEditingController _nombresCtrl;

  late final TextEditingController _fechaNacCtrl;
  late final TextEditingController _edadCtrl;
  late final TextEditingController _telConvCtrl;
  late final TextEditingController _celularCtrl;
  late final TextEditingController _correoInstCtrl;
  late final TextEditingController _correoPersonalCtrl;

  late final TextEditingController _direccionCtrl;
  late final TextEditingController _referenciaCtrl;

  late final TextEditingController _provNacManualCtrl;
  late final TextEditingController _ciudadNacManualCtrl;
  late final TextEditingController _provResManualCtrl;
  late final TextEditingController _ciudadResManualCtrl;
  late final TextEditingController _parroquiaResManualCtrl;

  String? _paisNacimiento;
  String? _nacionalidad;
  String? _provNacimiento;
  String? _ciudadNacimiento;

  String? _estadoCivil;
  String? _sexo;

  String? _etnia;

  String? _discapacidad; // null / SI / NO
  String? _tipoDiscapacidad;
  int? _porcentajeDiscapacidad;

  String? _paisResidencia;
  String? _provResidencia;
  String? _ciudadResidencia;
  String? _parroquiaResidencia;

  static const List<String> _paises = [
    "Ecuador", "Colombia", "Perú", "Chile", "Argentina", "Brasil", "Bolivia",
    "Paraguay", "Uruguay", "Venezuela", "México", "Estados Unidos", "Canadá",
    "España", "Portugal", "Francia", "Italia", "Alemania", "Reino Unido",
    "Irlanda", "Países Bajos", "Bélgica", "Suiza", "Austria", "Suecia",
    "Noruega", "Dinamarca", "Finlandia", "Polonia", "República Checa",
    "Grecia", "Turquía", "Rusia", "China", "Japón", "Corea del Sur", "India",
    "Australia", "Nueva Zelanda", "Sudáfrica", "Panamá",
  ];

  static const List<String> _nacionalidades = [
    "ECUATORIANA", "COLOMBIANA", "PERUANA", "CHILENA", "ARGENTINA", "BRASILEÑA",
    "VENEZOLANA", "MEXICANA", "ESTADOUNIDENSE", "CANADIENSE", "ESPAÑOLA",
    "ITALIANA", "FRANCESA", "ALEMANA", "OTRA",
  ];

  static const List<String> _estadoCivilOpts = [
    "Soltero(a)", "Casado(a)", "Divorciado(a)", "Viudo(a)", "Unión de hecho", "Otro",
  ];

  static const List<String> _sexoOpts = ["MASCULINO", "FEMENINO", "OTRO"];

  static const List<String> _etniaOpts = [
    "AfroEcuatoriano", "Blanco", "Indigena", "Mestizo", "Montubio",
    "Mulato", "Negra", "Otro",
  ];

  static const List<String> _tipoDiscapacidadOpts = [
    "Auditiva", "Física", "Intelectual", "Lenguaje", "Psicosocial",
    "Sensorial", "Visual", "Otra",
  ];

  static const List<String> _provinciasEcuador = [
    "Azuay", "Bolívar", "Cañar", "Carchi", "Chimborazo", "Cotopaxi", "El Oro",
    "Esmeraldas", "Galápagos", "Guayas", "Imbabura", "Loja", "Los Ríos", "Manabí",
    "Morona Santiago", "Napo", "Orellana", "Pastaza", "Pichincha", "Santa Elena",
    "Santo Domingo de los Tsáchilas", "Sucumbíos", "Tungurahua", "Zamora Chinchipe",
  ];

  static const Map<String, List<String>> _ciudadesPorProvinciaEC = {
    "Guayas": ["Guayaquil", "Durán", "Samborondón", "Daule", "Milagro", "Playas"],
    "Pichincha": ["Quito", "Cayambe", "Rumiñahui", "Mejía"],
    "Azuay": ["Cuenca", "Gualaceo", "Paute"],
    "Manabí": ["Portoviejo", "Manta", "Chone", "Jipijapa"],
    "El Oro": ["Machala", "Pasaje", "Santa Rosa"],
    "Tungurahua": ["Ambato", "Baños", "Pelileo"],
    "Los Ríos": ["Babahoyo", "Quevedo", "Ventanas"],
    "Esmeraldas": ["Esmeraldas", "Atacames", "Quinindé"],
    "Santa Elena": ["Santa Elena", "La Libertad", "Salinas"],
    "Santo Domingo de los Tsáchilas": ["Santo Domingo"],
    "Loja": ["Loja", "Catamayo"],
    "Chimborazo": ["Riobamba", "Guano"],
    "Cotopaxi": ["Latacunga", "Saquisilí"],
  };

  static const Map<String, List<String>> _parroquiasPorCiudad = {
    "Guayaquil": ["Tarqui", "Ximena", "Febres Cordero", "Urdaneta", "Letamendi", "Pascuales", "Chongón", "Posorja"],
    "Quito": ["Iñaquito", "La Mariscal", "Centro Histórico", "Chillogallo", "Calderón"],
    "Cuenca": ["El Vecino", "Totoracocha", "Yanuncay", "San Sebastián"],
  };

  bool _isLocked(String key) => _locked.contains(key);

  String _s(String key) => (_data[key] ?? "").toString().trim();

  String? _normEmpty(String? v) {
    final t = (v ?? "").trim();
    return t.isEmpty ? null : t;
  }

  String _fold(String s) {
    var t = s.trim().toLowerCase();
    t = t.replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u');
    t = t.replaceAll('ä', 'a').replaceAll('ë', 'e').replaceAll('ï', 'i').replaceAll('ö', 'o').replaceAll('ü', 'u');
    t = t.replaceAll('ñ', 'n');
    t = t.replaceAll(RegExp(r'\s+'), ' ');
    return t;
  }

  String? _matchOption(String? raw, List<String> options) {
    final r = _normEmpty(raw);
    if (r == null) return null;
    final fr = _fold(r);
    for (final o in options) {
      if (_fold(o) == fr) return o;
    }
    return r; // si no existe, lo dejamos para insertarlo
  }

  List<String> _withCurrent(List<String> base, String? currentRaw) {
    final cur = _normEmpty(currentRaw);
    if (cur == null) return base;
    final exists = base.any((e) => _fold(e) == _fold(cur));
    if (exists) return base;
    return [cur, ...base];
  }

  String? _parseDiscapacidad(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v ? "SI" : "NO";
    final s = v.toString().trim().toUpperCase();
    if (s.isEmpty || s == "NULL") return null;
    if (s == "SI" || s == "S" || s == "TRUE" || s == "1") return "SI";
    if (s == "NO" || s == "N" || s == "FALSE" || s == "0") return "NO";
    return null;
  }

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.initial);

    _cedulaCtrl = TextEditingController(text: _s("COD_ESTUDIANTE"));
    _apellidosCtrl = TextEditingController(text: _s("APELLIDO"));
    _nombresCtrl = TextEditingController(text: _s("NOMBRE"));

    _fechaNacCtrl = TextEditingController(text: _s("FECHA_NACIMIENTO"));
    _edadCtrl = TextEditingController(text: _s("EDAD"));

    _telConvCtrl = TextEditingController(text: _s("TELEFONO_CONVENCIONAL"));
    _celularCtrl = TextEditingController(text: _s("CELULAR"));

    _correoInstCtrl = TextEditingController(text: _s("CORREO_INSTITUCIONAL"));
    _correoPersonalCtrl = TextEditingController(text: _s("CORREO_PERSONAL"));

    _direccionCtrl = TextEditingController(text: _s("DIRECCION"));
    _referenciaCtrl = TextEditingController(text: _s("REFERENCIA_DOMICILIARIA"));

    _provNacManualCtrl = TextEditingController(text: _s("PROVINCIA_NACIMIENTO"));
    _ciudadNacManualCtrl = TextEditingController(text: _s("CIUDAD_NACIMIENTO"));
    _provResManualCtrl = TextEditingController(text: _s("PROVINCIA_DOMICILIO"));
    _ciudadResManualCtrl = TextEditingController(text: _s("CIUDAD_DOMICILIO"));
    _parroquiaResManualCtrl = TextEditingController(text: _s("PARROQUIA_RESIDENCIA"));

    _paisNacimiento = _matchOption(_s("PAIS_NACIMIENTO"), _paises);
    _nacionalidad = _matchOption(_s("NACIONALIDAD"), _nacionalidades);

    _provNacimiento = _matchOption(_s("PROVINCIA_NACIMIENTO"), _provinciasEcuador);
    _ciudadNacimiento = _normEmpty(_s("CIUDAD_NACIMIENTO"));

    _estadoCivil = _matchOption(_s("ESTADO_CIVIL"), _estadoCivilOpts);

    _sexo = _matchOption(_s("SEXO"), _sexoOpts);
    if ((_sexo ?? "").isEmpty) {
      final cod = _s("CODIGO_SEXO").toUpperCase();
      if (cod == "M") _sexo = "MASCULINO";
      if (cod == "F") _sexo = "FEMENINO";
    }

    _etnia = _matchOption(_s("ETNIA"), _etniaOpts);

    _discapacidad = _parseDiscapacidad(_data["DISCAPACIDAD"]);
    _tipoDiscapacidad = _matchOption(_s("TIPO_DISCAPACIDAD"), _tipoDiscapacidadOpts);

    final p = int.tryParse(_s("PORCENTAJE_DISCAPACIDAD"));
    _porcentajeDiscapacidad = (p != null && p >= 1 && p <= 10) ? p : null;

    _paisResidencia = _matchOption(_s("PAIS_DOMICILIO"), _paises);
    _provResidencia = _matchOption(_s("PROVINCIA_DOMICILIO"), _provinciasEcuador);

    _ciudadResidencia = _normEmpty(_s("CIUDAD_DOMICILIO"));
    _parroquiaResidencia = _normEmpty(_s("PARROQUIA_RESIDENCIA"));
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _apellidosCtrl.dispose();
    _nombresCtrl.dispose();

    _fechaNacCtrl.dispose();
    _edadCtrl.dispose();
    _telConvCtrl.dispose();
    _celularCtrl.dispose();
    _correoInstCtrl.dispose();
    _correoPersonalCtrl.dispose();

    _direccionCtrl.dispose();
    _referenciaCtrl.dispose();

    _provNacManualCtrl.dispose();
    _ciudadNacManualCtrl.dispose();
    _provResManualCtrl.dispose();
    _ciudadResManualCtrl.dispose();
    _parroquiaResManualCtrl.dispose();

    super.dispose();
  }

  // UI helpers
  Widget _groupCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: _ink)),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }

  Widget _twoCol(BuildContext context, Widget a, Widget b) {
    final w = MediaQuery.of(context).size.width;
    if (w < 430) return Column(children: [a, const SizedBox(height: 10), b]);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: a), const SizedBox(width: 12), Expanded(child: b)]);
  }

  InputDecoration _dec(String label, {String? hint, bool locked = false}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      isDense: true,
      filled: locked,
      fillColor: locked ? const Color(0xFFF8FAFC) : null,
    );
  }

  Widget _tfield(TextEditingController c, String key, String label, {String? hint, int maxLines = 1}) {
    final locked = _isLocked(key);
    return TextField(
      controller: c,
      enabled: !locked,
      maxLines: maxLines,
      decoration: _dec(label, hint: locked ? "No editable" : hint, locked: locked),
    );
  }

  DropdownMenuItem<String> _ddItem(String v) => DropdownMenuItem(value: v, child: Text(v, overflow: TextOverflow.ellipsis));

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? hint,
    bool enabled = true,
  }) {
    final options = _withCurrent(items, value);
    final selected = _matchOption(value, options);
    final initial = (selected != null && options.any((e) => _fold(e) == _fold(selected)))
        ? options.firstWhere((e) => _fold(e) == _fold(selected))
        : null;

    return DropdownButtonFormField<String>(
      initialValue: initial,
      decoration: _dec(label, hint: hint),
      isExpanded: true,
      items: options.map(_ddItem).toList(),
      onChanged: enabled ? onChanged : null,
    );
  }

  Widget _triDropdown({
    required String label,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    final items = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(value: null, child: Text("—")),
      const DropdownMenuItem<String?>(value: "SI", child: Text("SI")),
      const DropdownMenuItem<String?>(value: "NO", child: Text("NO")),
    ];
    final v = (value == "SI" || value == "NO") ? value : null;

    return DropdownButtonFormField<String?>(
      initialValue: v,
      decoration: _dec(label, hint: "Selecciona"),
      items: items,
      onChanged: onChanged,
    );
  }

  List<String> _ciudadesForProv(String? prov) {
    if ((_paisResidencia ?? "") != "Ecuador") return const [];
    if (prov == null || prov.trim().isEmpty) return const [];
    final list = _ciudadesPorProvinciaEC[prov] ?? const <String>[];
    return _withCurrent(list, _ciudadResidencia);
  }

  List<String> _ciudadesNacForProv(String? prov) {
    if ((_paisNacimiento ?? "") != "Ecuador") return const [];
    if (prov == null || prov.trim().isEmpty) return const [];
    final list = _ciudadesPorProvinciaEC[prov] ?? const <String>[];
    return _withCurrent(list, _ciudadNacimiento);
  }

  List<String> _parroquiasForCiudad(String? ciudad) {
    if (ciudad == null || ciudad.trim().isEmpty) return const [];
    final list = _parroquiasPorCiudad[ciudad] ?? const <String>[];
    return _withCurrent(list, _parroquiaResidencia);
  }

  void _saveAndClose() {
    _data["COD_ESTUDIANTE"] = _normEmpty(_cedulaCtrl.text);
    _data["APELLIDO"] = _normEmpty(_apellidosCtrl.text);
    _data["NOMBRE"] = _normEmpty(_nombresCtrl.text);

    _data["FECHA_NACIMIENTO"] = _normEmpty(_fechaNacCtrl.text);
    _data["EDAD"] = _normEmpty(_edadCtrl.text);

    _data["TELEFONO_CONVENCIONAL"] = _normEmpty(_telConvCtrl.text);
    _data["CELULAR"] = _normEmpty(_celularCtrl.text);

    _data["CORREO_INSTITUCIONAL"] = _normEmpty(_correoInstCtrl.text);
    _data["CORREO_PERSONAL"] = _normEmpty(_correoPersonalCtrl.text);

    _data["PAIS_NACIMIENTO"] = _normEmpty(_paisNacimiento);
    _data["NACIONALIDAD"] = _normEmpty(_nacionalidad);

    if ((_paisNacimiento ?? "") == "Ecuador") {
      _data["PROVINCIA_NACIMIENTO"] = _normEmpty(_provNacimiento);
      _data["CIUDAD_NACIMIENTO"] = _normEmpty(_ciudadNacimiento);
    } else {
      _data["PROVINCIA_NACIMIENTO"] = _normEmpty(_provNacManualCtrl.text);
      _data["CIUDAD_NACIMIENTO"] = _normEmpty(_ciudadNacManualCtrl.text);
    }

    _data["ESTADO_CIVIL"] = _normEmpty(_estadoCivil);

    _data["SEXO"] = _normEmpty(_sexo);
    if (_sexo == "MASCULINO") _data["CODIGO_SEXO"] = "M";
    if (_sexo == "FEMENINO") _data["CODIGO_SEXO"] = "F";

    _data["ETNIA"] = _normEmpty(_etnia);

    _data["DISCAPACIDAD"] = _discapacidad;
    if (_discapacidad == "SI") {
      _data["TIPO_DISCAPACIDAD"] = _normEmpty(_tipoDiscapacidad);
      _data["PORCENTAJE_DISCAPACIDAD"] = _porcentajeDiscapacidad?.toString();
    } else {
      _data["TIPO_DISCAPACIDAD"] = null;
      _data["PORCENTAJE_DISCAPACIDAD"] = null;
    }

    _data["PAIS_DOMICILIO"] = _normEmpty(_paisResidencia);

    if ((_paisResidencia ?? "") == "Ecuador") {
      _data["PROVINCIA_DOMICILIO"] = _normEmpty(_provResidencia);
      _data["CIUDAD_DOMICILIO"] = _normEmpty(_ciudadResidencia);
      _data["PARROQUIA_RESIDENCIA"] = _normEmpty(_parroquiaResidencia);
    } else {
      _data["PROVINCIA_DOMICILIO"] = _normEmpty(_provResManualCtrl.text);
      _data["CIUDAD_DOMICILIO"] = _normEmpty(_ciudadResManualCtrl.text);
      _data["PARROQUIA_RESIDENCIA"] = _normEmpty(_parroquiaResManualCtrl.text);
    }

    _data["DIRECCION"] = _normEmpty(_direccionCtrl.text);
    _data["REFERENCIA_DOMICILIARIA"] = _normEmpty(_referenciaCtrl.text);

    Navigator.pop(context, _data);
  }

  @override
  Widget build(BuildContext context) {
    final birthIsEc = (_paisNacimiento ?? "") == "Ecuador";
    final resIsEc = (_paisResidencia ?? "") == "Ecuador";

    final ciudadesRes = resIsEc ? _ciudadesForProv(_provResidencia) : const <String>[];
    final ciudadesNac = birthIsEc ? _ciudadesNacForProv(_provNacimiento) : const <String>[];
    final parroquiasRes = _parroquiasForCiudad(_ciudadResidencia);

    return _SheetShell(
      title: "Editar datos personales",
      expand: true, // ✅ FIX OVERFLOW
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  _groupCard(
                    title: "Identificación",
                    child: Column(
                      children: [
                        _twoCol(
                          context,
                          _tfield(_cedulaCtrl, "COD_ESTUDIANTE", "Cédula", hint: "Ej: 094..."),
                          _tfield(_apellidosCtrl, "APELLIDO", "Apellidos", hint: "Ej: García"),
                        ),
                        const SizedBox(height: 10),
                        _tfield(_nombresCtrl, "NOMBRE", "Nombres", hint: "Ej: Allan Fernando"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _groupCard(
                    title: "Lugar de nacimiento",
                    child: Column(
                      children: [
                        _twoCol(
                          context,
                          _dropdown(
                            label: "País",
                            value: _paisNacimiento,
                            items: _paises,
                            onChanged: (v) {
                              setState(() {
                                _paisNacimiento = v;
                                if (_paisNacimiento != "Ecuador") {
                                  _provNacimiento = null;
                                  _ciudadNacimiento = null;
                                }
                              });
                            },
                            hint: "Selecciona",
                          ),
                          _dropdown(
                            label: "Nacionalidad",
                            value: _nacionalidad,
                            items: _nacionalidades,
                            onChanged: (v) => setState(() => _nacionalidad = v),
                            hint: "Selecciona",
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (birthIsEc) ...[
                          _twoCol(
                            context,
                            _dropdown(
                              label: "Provincia",
                              value: _provNacimiento,
                              items: _withCurrent(_provinciasEcuador, _provNacimiento),
                              onChanged: (v) {
                                setState(() {
                                  _provNacimiento = v;
                                  _ciudadNacimiento = null;
                                });
                              },
                              hint: "Selecciona",
                            ),
                            _dropdown(
                              label: "Ciudad",
                              value: _ciudadNacimiento,
                              items: ciudadesNac,
                              onChanged: (v) => setState(() => _ciudadNacimiento = v),
                              hint: "Selecciona",
                              enabled: (_provNacimiento != null && _provNacimiento!.isNotEmpty),
                            ),
                          ),
                        ] else ...[
                          _twoCol(
                            context,
                            TextField(controller: _provNacManualCtrl, decoration: _dec("Provincia", hint: "Provincia")),
                            TextField(controller: _ciudadNacManualCtrl, decoration: _dec("Ciudad", hint: "Ciudad")),
                          ),
                          const SizedBox(height: 8),
                          const Text("Para países fuera de Ecuador: provincia/ciudad quedan manuales.",
                              style: TextStyle(color: _muted, fontSize: 12)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _groupCard(
                    title: "Datos generales",
                    child: Column(
                      children: [
                        _twoCol(
                          context,
                          _dropdown(
                            label: "Estado civil",
                            value: _estadoCivil,
                            items: _estadoCivilOpts,
                            onChanged: (v) => setState(() => _estadoCivil = v),
                            hint: "Selecciona",
                          ),
                          _dropdown(
                            label: "Sexo",
                            value: _sexo,
                            items: _sexoOpts,
                            onChanged: (v) => setState(() => _sexo = v),
                            hint: "Selecciona",
                          ),
                        ),
                        const SizedBox(height: 10),
                        _twoCol(
                          context,
                          _tfield(_fechaNacCtrl, "FECHA_NACIMIENTO", "Fecha nacimiento"),
                          _tfield(_edadCtrl, "EDAD", "Edad"),
                        ),
                        const SizedBox(height: 10),
                        _twoCol(
                          context,
                          _tfield(_telConvCtrl, "TELEFONO_CONVENCIONAL", "Teléfono convencional", hint: "Ej: 04xxxxxxx"),
                          _tfield(_celularCtrl, "CELULAR", "Celular", hint: "Ej: 09xxxxxxxx"),
                        ),
                        const SizedBox(height: 10),
                        _twoCol(
                          context,
                          _tfield(_correoInstCtrl, "CORREO_INSTITUCIONAL", "Correo institucional"),
                          _tfield(_correoPersonalCtrl, "CORREO_PERSONAL", "Correo personal", hint: "ej: correo@gmail.com"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _groupCard(
                    title: "Etnia y discapacidad",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _twoCol(
                          context,
                          _dropdown(
                            label: "Etnia",
                            value: _etnia,
                            items: _etniaOpts,
                            onChanged: (v) => setState(() => _etnia = v),
                            hint: "Selecciona",
                          ),
                          _triDropdown(
                            label: "Discapacidad",
                            value: _discapacidad,
                            onChanged: (v) {
                              setState(() {
                                _discapacidad = v;
                                if (_discapacidad != "SI") {
                                  _tipoDiscapacidad = null;
                                  _porcentajeDiscapacidad = null;
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Opacity(
                          opacity: _discapacidad == "SI" ? 1 : .45,
                          child: IgnorePointer(
                            ignoring: _discapacidad != "SI",
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Tipo", style: TextStyle(fontWeight: FontWeight.w900, color: _ink)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _tipoDiscapacidadOpts.map((t) {
                                    final selected = _fold(_tipoDiscapacidad ?? "") == _fold(t);
                                    return ChoiceChip(
                                      label: Text(t),
                                      selected: selected,
                                      onSelected: (_) => setState(() => _tipoDiscapacidad = selected ? null : t),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 12),
                                const Text("Porcentaje (1 a 10)", style: TextStyle(fontWeight: FontWeight.w900, color: _ink)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(10, (i) => i + 1).map((n) {
                                    final selected = _porcentajeDiscapacidad == n;
                                    return ChoiceChip(
                                      label: Text("$n"),
                                      selected: selected,
                                      onSelected: (_) => setState(() => _porcentajeDiscapacidad = selected ? null : n),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _groupCard(
                    title: "Lugar de residencia",
                    child: Column(
                      children: [
                        _twoCol(
                          context,
                          _dropdown(
                            label: "País",
                            value: _paisResidencia,
                            items: _paises,
                            onChanged: (v) {
                              setState(() {
                                _paisResidencia = v;
                                _provResidencia = null;
                                _ciudadResidencia = null;
                                _parroquiaResidencia = null;
                              });
                            },
                            hint: "Selecciona",
                          ),
                          resIsEc
                              ? _dropdown(
                                  label: "Provincia",
                                  value: _provResidencia,
                                  items: _withCurrent(_provinciasEcuador, _provResidencia),
                                  onChanged: (v) {
                                    setState(() {
                                      _provResidencia = v;
                                      _ciudadResidencia = null;
                                      _parroquiaResidencia = null;
                                    });
                                  },
                                  hint: "Selecciona",
                                )
                              : TextField(controller: _provResManualCtrl, decoration: _dec("Provincia", hint: "Provincia")),
                        ),
                        const SizedBox(height: 10),
                        _twoCol(
                          context,
                          resIsEc
                              ? _dropdown(
                                  label: "Ciudad",
                                  value: _ciudadResidencia,
                                  items: ciudadesRes,
                                  onChanged: (v) {
                                    setState(() {
                                      _ciudadResidencia = v;
                                      _parroquiaResidencia = null;
                                    });
                                  },
                                  hint: "Selecciona",
                                  enabled: (_provResidencia != null && _provResidencia!.isNotEmpty),
                                )
                              : TextField(controller: _ciudadResManualCtrl, decoration: _dec("Ciudad", hint: "Ciudad")),
                          (resIsEc && parroquiasRes.isNotEmpty)
                              ? _dropdown(
                                  label: "Parroquia",
                                  value: _parroquiaResidencia,
                                  items: parroquiasRes,
                                  onChanged: (v) => setState(() => _parroquiaResidencia = v),
                                  hint: "Selecciona",
                                )
                              : TextField(controller: _parroquiaResManualCtrl, decoration: _dec("Parroquia", hint: "Parroquia")),
                        ),
                        const SizedBox(height: 10),
                        TextField(controller: _direccionCtrl, decoration: _dec("Dirección", hint: "Ej: Cdla..., Mz..., Villa...")),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _referenciaCtrl,
                          maxLines: 2,
                          decoration: _dec("Referencia domiciliaria", hint: "Ej: Frente a..., cerca de..."),
                        ),
                        if (!resIsEc) ...[
                          const SizedBox(height: 8),
                          const Text("Para países fuera de Ecuador: provincia/ciudad/parroquia quedan manuales.",
                              style: TextStyle(color: _muted, fontSize: 12)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text("Cancelar"),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _saveAndClose,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text("Guardar"),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}