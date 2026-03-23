import 'package:flutter/material.dart';
import 'package:proto_segui/data/controllers/ofertas_data.dart';

import 'package:proto_segui/screens/institucion/Ofertas/publicar_Oferta_screen.dart';
import 'package:proto_segui/screens/institucion/perfilInstitucion/perfil_institucion.dart';
import '../../institucion/Ofertas/Widgets/widget_ofertas.dart';

class OfertasMainScreen extends StatefulWidget {
  final String institutionName;

  const OfertasMainScreen({
    super.key,
    this.institutionName = "Universidad de Guayaquil",
  });

  @override
  State<OfertasMainScreen> createState() => _InstitutionMainScreenState();
}

class _InstitutionMainScreenState extends State<OfertasMainScreen> {
  final OfertasData _controller = OfertasData();
  final TextEditingController _searchCtrl = TextEditingController();

  static const Color _bg = Color(0xFFF3F7FB);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE7EEF8);
  static const Color _primary = Color(0xFF2563EB);

  @override
  void dispose() {
    _searchCtrl.dispose();
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
      ),
      // AnimatedBuilder escucha los cambios del _controller y redibuja la UI
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Scaffold(
            body: SafeArea(
              child: IndexedStack(
                index: _controller.selectedIndex,
                children: [_buildOffersTab(), _buildProfileTab()],
              ),
            ),
            bottomNavigationBar: InstitutionNavBar(
              selectedIndex: _controller.selectedIndex,
              onSelect: _controller.setIndex,
              offersCount: _controller.foundOffers.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildOffersTab() {
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        _solidSliverAppBar(title: "Ofertas Institucionales"),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InstitutionSearchBar(
                  controller: _searchCtrl,
                  hintText: "Buscar vinculación, ayudantía...",
                  onChanged: _controller.runFilter,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Proyectos y Vacantes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _ink,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        final nuevaOferta = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PublicarOfertaScreen(),
                          ),
                        );

                        if (nuevaOferta != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Oferta agregada a la lista local"),
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _ink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text(
                        "Publicar",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "${_controller.foundOffers.length} resultado(s)",
                  style: const TextStyle(
                    color: _muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_controller.foundOffers.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: InstitutionEmptyState(
              icon: Icons.school_outlined,
              title: "No hay ofertas publicadas",
              subtitle:
                  "Crea un nuevo proyecto de vinculación o práctica interna.",
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                // Ahora usamos nuestro modelo fuertemente tipado
                final oferta = _controller.foundOffers[index];
                return OfferCard(oferta: oferta);
              }, childCount: _controller.foundOffers.length),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return CustomScrollView(
      slivers: [
        _solidSliverAppBar(
          title: "Perfil Institucional",
          actions: [
            IconButton(
              tooltip: "Editar Perfil",
              icon: const Icon(Icons.edit_rounded, color: _ink),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PerfilInstitucion()),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Abriendo edición de perfil..."),
                  ),
                );
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primary, Color(0xFF60A5FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          size: 40,
                          color: _primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.institutionName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Cuenta Académica Autorizada",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSettingsTile(
                  Icons.bar_chart_rounded,
                  "Estadísticas de Postulantes",
                  "Ver rendimiento de las ofertas",
                ),
                const SizedBox(height: 12),
                _buildSettingsTile(
                  Icons.settings_rounded,
                  "Configuración",
                  "Administra permisos y accesos",
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: () => _controller.logout(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      "Cerrar sesión",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _ink),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _muted),
        ],
      ),
    );
  }

  SliverAppBar _solidSliverAppBar({
    required String title,
    List<Widget> actions = const [],
  }) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 8,
      backgroundColor: _bg,
      surfaceTintColor: _bg,
      shadowColor: Colors.black.withOpacity(.12),
      titleSpacing: 16,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900, color: _ink),
      ),
      actions: [
        ...actions,
        const SizedBox(width: 6),
      ], // <--- Agregamos las acciones aquí
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _border),
      ),
    );
  }
}
