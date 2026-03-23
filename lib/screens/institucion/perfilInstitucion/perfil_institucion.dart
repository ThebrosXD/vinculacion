import 'package:flutter/material.dart';
import 'package:proto_segui/data/controllers/institucion_perfil_data.dart';
import 'package:proto_segui/models/institucion_perfil.dart';

class PerfilInstitucion extends StatefulWidget {
  final InstitucionPerfil? initialData;

  const PerfilInstitucion({super.key, this.initialData});

  @override
  State<PerfilInstitucion> createState() => _PerfilInstitucionState();
}

class _PerfilInstitucionState extends State<PerfilInstitucion> {
  final InstitucionPerfilData _controller = InstitucionPerfilData();

  static const Color _bg = Color(0xFFF4F6FA);
  static const Color _primary = Color(0xFF2563EB);
  static const Color _primary2 = Color(0xFF60A5FA);
  static const Color _cardBorder = Color(0xFFE7EEF8);
  static const Color _muted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _controller.initData(widget.initialData);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
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
        ),
      ),
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  expandedHeight: 145,
                  collapsedHeight: 72,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: const Text(
                    "Perfil de Institución",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: _HeaderBackground(
                      title: _controller.razonSocialCtrl.text.isEmpty
                          ? "Nueva Institución"
                          : _controller.razonSocialCtrl.text,
                      subtitle: "Actualiza los datos de tu empresa",
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
                    child: Form(
                      key: _controller.formKey,
                      child: Column(
                        children: [
                          // --- FOTO DE PERFIL ---
                          Center(
                            child: InkWell(
                              onTap: _controller.pickLogo,
                              borderRadius: BorderRadius.circular(50),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _cardBorder,
                                        width: 4,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.business_rounded,
                                      size: 50,
                                      color: _muted.withOpacity(0.5),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: _primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- SECCIÓN 1: DATOS DE LA INSTITUCIÓN ---
                          _SectionCard(
                            expanded: _controller.expandedSections.contains(
                              "institucion",
                            ),
                            onToggle: () =>
                                _controller.toggleSection("institucion"),
                            title: "Datos de la Institución",
                            icon: Icons.apartment_rounded,
                            child: Column(
                              children: [
                                _Field.text(
                                  label: "Razón Social *",
                                  controller: _controller.razonSocialCtrl,
                                  validator: (v) =>
                                      v!.isEmpty ? "Requerido" : null,
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _Field.dropdown(
                                        label: "Tipo Institución *",
                                        value: _controller.tipoInstitucion,
                                        items: _controller.tiposInstitucion,
                                        onChanged: (v) =>
                                            _controller.tipoInstitucion = v,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _Field.text(
                                        label: "RUC *",
                                        controller: _controller.rucCtrl,
                                        validator: (v) =>
                                            v!.isEmpty ? "Requerido" : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                _Field.dropdown(
                                  label: "Sector Económico *",
                                  value: _controller.sectorEconomico,
                                  items: _controller.sectores,
                                  onChanged: (v) =>
                                      _controller.sectorEconomico = v,
                                ),
                                const SizedBox(height: 14),
                                // Subida de Archivo RUC
                                _buildFilePickerRow(
                                  "Archivo RUC *",
                                  _controller.rucFileName,
                                  _controller.pickRucFile,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- SECCIÓN 2: CONTACTO ---
                          _SectionCard(
                            expanded: _controller.expandedSections.contains(
                              "contacto",
                            ),
                            onToggle: () =>
                                _controller.toggleSection("contacto"),
                            title: "Contacto y Representante",
                            icon: Icons.contact_page_rounded,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _Field.text(
                                        label: "Correo *",
                                        controller: _controller.correoCtrl,
                                        validator: (v) =>
                                            v!.isEmpty ? "Requerido" : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _Field.text(
                                        label: "Correo Alterno",
                                        controller: _controller.correoAltCtrl,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _Field.text(
                                        label: "Teléfono *",
                                        controller: _controller.telConvCtrl,
                                        validator: (v) =>
                                            v!.isEmpty ? "Requerido" : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _Field.text(
                                        label: "Celular",
                                        controller: _controller.celularCtrl,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                _Field.text(
                                  label: "Representante para contacto *",
                                  controller: _controller.repNombreCtrl,
                                  validator: (v) =>
                                      v!.isEmpty ? "Requerido" : null,
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _Field.text(
                                        label: "Cargo *",
                                        controller: _controller.repCargoCtrl,
                                        validator: (v) =>
                                            v!.isEmpty ? "Requerido" : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _Field.text(
                                        label: "Teléfono Rep. *",
                                        controller: _controller.repTelefonoCtrl,
                                        validator: (v) =>
                                            v!.isEmpty ? "Requerido" : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- SECCIÓN 3: DIRECCIÓN ---
                          _SectionCard(
                            expanded: _controller.expandedSections.contains(
                              "direccion",
                            ),
                            onToggle: () =>
                                _controller.toggleSection("direccion"),
                            title: "Dirección",
                            icon: Icons.location_on_rounded,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _Field.dropdown(
                                        label: "País *",
                                        value: _controller.pais,
                                        items: _controller.paises,
                                        onChanged: (v) => _controller.pais = v,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _Field.text(
                                        label: "Provincia *",
                                        controller: _controller.provinciaCtrl,
                                        validator: (v) =>
                                            v!.isEmpty ? "Requerido" : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                _Field.text(
                                  label: "Ciudad *",
                                  controller: _controller.ciudadCtrl,
                                  validator: (v) =>
                                      v!.isEmpty ? "Requerido" : null,
                                ),
                                const SizedBox(height: 14),
                                _Field.text(
                                  label: "Dirección *",
                                  controller: _controller.direccionCtrl,
                                  maxLines: 2,
                                  validator: (v) =>
                                      v!.isEmpty ? "Requerido" : null,
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
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: _cardBorder.withOpacity(.9)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.06),
                  blurRadius: 20,
                  offset: const Offset(0, -8),
                ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _controller.saveProfile(context),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text("Guardar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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

  // Botón para adjuntar archivo (estilo del login_gateway)
  Widget _buildFilePickerRow(
    String label,
    String? fileName,
    VoidCallback onPick,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: _muted),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: _cardBorder),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(
                  fileName != null
                      ? Icons.picture_as_pdf_rounded
                      : Icons.attach_file_rounded,
                  color: _muted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fileName ?? "Ningún archivo seleccionado...",
                    style: TextStyle(
                      color: fileName != null ? Colors.black87 : _muted,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Icon(Icons.file_upload_outlined, color: _primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  final String title;
  final String subtitle;
  const _HeaderBackground({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(.20)),
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
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
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.85),
                          fontSize: 12,
                        ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7EEF8)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
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
                      color: const Color(0xFF2563EB).withOpacity(.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: const Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.2,
                        letterSpacing: .2,
                      ),
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
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
              child: Column(
                children: [
                  Container(
                    height: 1,
                    color: const Color(0xFFE7EEF8).withOpacity(.9),
                  ),
                  const SizedBox(height: 12),
                  child,
                ],
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }
}

class _Field {
  static Widget text({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }

  static Widget dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }
}
