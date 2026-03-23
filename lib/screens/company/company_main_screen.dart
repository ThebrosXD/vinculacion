import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:proto_segui/screens/institucion/perfilInstitucion/perfil_institucion.dart';

import '../../models/vacancy.dart';
import '../auth/login_gateway_screen.dart';
import 'create_vacancy_screen.dart';
import 'postulantes_screen.dart';
import 'edit_vacancy_screen.dart';

class CompanyMainScreen extends StatefulWidget {
  const CompanyMainScreen({super.key});

  @override
  State<CompanyMainScreen> createState() => _CompanyMainScreenState();
}

class _CompanyMainScreenState extends State<CompanyMainScreen> {
  int _selectedIndex = 1;

  static const Color _bg = Color(0xFFF3F7FB);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE7EEF8);

  static const Color _primary = Color(0xFF4CAAC9);
  static const Color _primary2 = Color(0xFF60A5FA);

  final String _companyName = "Bangara S.A";
  final TextEditingController _searchCtrl = TextEditingController();

  int _newApplicantsCount = 3;

  final List<Vacancy> _companyVacancies = [
    Vacancy(
      id: '1',
      title: 'Desarrollador Backend',
      companyName: 'Bangara S.A',
      location: 'Guayaquil, Guayas',
      modality: 'Presencial',
      description: 'Experiencia en Node.js, SQL y NoSQL.',
      rating: 4.2,
      postedDate: 'Hace 3 días',
    ),
    Vacancy(
      id: '2',
      title: 'Analista de Datos',
      companyName: 'Bangara S.A',
      location: 'Quito',
      modality: 'Híbrido',
      description: 'Python, PowerBI y análisis financiero.',
      rating: 4.5,
      postedDate: 'Hace 1 día',
    ),
  ];

  List<Vacancy> _foundVacancies = [];

  @override
  void initState() {
    super.initState();
    _foundVacancies = List.of(_companyVacancies);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginGatewayScreen()),
      (route) => false,
    );
  }

  void _runVacancyFilter(String keyword) {
    final k = keyword.trim().toLowerCase();
    setState(() {
      if (k.isEmpty) {
        _foundVacancies = List.of(_companyVacancies);
      } else {
        _foundVacancies = _companyVacancies.where((v) {
          return v.title.toLowerCase().contains(k) ||
              v.location.toLowerCase().contains(k) ||
              v.modality.toLowerCase().contains(k);
        }).toList();
      }
    });
  }

  Future<void> _openCreateVacancy() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateVacancyScreen(companyName: _companyName),
      ),
    );

    if (result is Vacancy) {
      setState(() {
        _companyVacancies.insert(0, result);
        _runVacancyFilter(_searchCtrl.text);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Text("Vacante creada y publicada ✅"),
        ),
      );
    }
  }

  void _openNotifications() {
    if (_newApplicantsCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text("Tienes $_newApplicantsCount nuevos postulantes"),
          duration: const Duration(milliseconds: 1400),
        ),
      );
      setState(() => _newApplicantsCount = 0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Text("Sin notificaciones nuevas"),
          duration: const Duration(milliseconds: 1200),
        ),
      );
    }
  }

  void _deleteVacancy(Vacancy v) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Eliminar vacante",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text("¿Seguro que deseas eliminar '${v.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: _muted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              setState(() {
                _companyVacancies.removeWhere((x) => x.id == v.id);
                _runVacancyFilter(_searchCtrl.text);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 1200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  content: const Text("Vacante eliminada"),
                ),
              );
            },
            child: const Text(
              "Eliminar",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editVacancy(Vacancy v) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditVacancyScreen(vacancy: v)),
    );

    if (result is Vacancy) {
      setState(() {
        final i = _companyVacancies.indexWhere((x) => x.id == v.id);
        if (i != -1) _companyVacancies[i] = result;
        _runVacancyFilter(_searchCtrl.text);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Text("Vacante actualizada ✨"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: _bg,
        colorScheme: ColorScheme.fromSeed(seedColor: _primary),
      ),
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeTab(),
              _buildVacanciesTab(),
              _buildProfileTab(),
            ],
          ),
        ),
        bottomNavigationBar: _DynamicIslandNavBar(
          selectedIndex: _selectedIndex,
          onSelect: (i) => setState(() => _selectedIndex = i),
          homeBadge: _newApplicantsCount,
          vacanciesBadge: _companyVacancies.length,
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        _solidSliverAppBar(
          title: "Panel",
          actions: [
            IconButton(
              tooltip: "Notificaciones",
              icon: _BadgeIcon(
                icon: Icons.notifications_none_rounded,
                count: _newApplicantsCount,
              ),
              onPressed: _openNotifications,
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GradientHero(
                  title: _companyName,
                  subtitle: "Gestiona vacantes con un estilo profesional.",
                  icon: Icons.business_rounded,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: "Vacantes",
                        value: "${_companyVacancies.length}",
                        icon: Icons.work_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: "Postulantes",
                        value:
                            "${_newApplicantsCount == 0 ? 3 : _newApplicantsCount}",
                        icon: Icons.people_alt_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  "Acciones rápidas",
                  style: TextStyle(fontWeight: FontWeight.w900, color: _ink),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _openCreateVacancy,
                        style: FilledButton.styleFrom(
                          backgroundColor: _primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text(
                          "Crear vacante",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _selectedIndex = 1),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.list_alt_rounded, color: _ink),
                        label: const Text(
                          "Ver vacantes",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: _ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVacanciesTab() {
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        _solidSliverAppBar(
          title: "Vacantes",
          actions: [
            IconButton(
              tooltip: "Notificaciones",
              icon: _BadgeIcon(
                icon: Icons.notifications_none_rounded,
                count: _newApplicantsCount,
              ),
              onPressed: _openNotifications,
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchBar(
                  controller: _searchCtrl,
                  hintText: "Buscar por título, modalidad o ubicación…",
                  onChanged: _runVacancyFilter,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Mis vacantes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _ink,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _openCreateVacancy,
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
                        "Crear",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "${_foundVacancies.length} resultado(s)",
                  style: const TextStyle(
                    color: _muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_foundVacancies.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: Icons.work_off_rounded,
              title: "No hay vacantes",
              subtitle: "Crea una vacante o ajusta tu búsqueda.",
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final v = _foundVacancies[index];
                return _VacancyCard(
                  vacancy: v,
                  onOpen: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostulantesScreen(vacancy: v),
                    ),
                  ),
                  onEdit: () => _editVacancy(v),
                  onDelete: () => _deleteVacancy(v),
                );
              }, childCount: _foundVacancies.length),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return CustomScrollView(
      slivers: [
        _solidSliverAppBar(
          title: "Perfil",
          actions: [
            IconButton(
              tooltip: "Editar Perfil",
              icon: const Icon(Icons.edit_rounded, color: _ink),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PerfilInstitucion()),
                );
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            child: Column(
              children: [
                _GradientHero(
                  title: _companyName,
                  subtitle: "Financiera • Cuenta empresa",
                  icon: Icons.apartment_rounded,
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.04),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Configuración",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: _ink,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Administra tu cuenta y vacantes publicadas.",
                        style: TextStyle(color: _muted, height: 1.25),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _logout,
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

  SliverAppBar _solidSliverAppBar({
    required String title,
    List<Widget> actions = const [],
  }) {
    return SliverAppBar(
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
      actions: [...actions, const SizedBox(width: 6)],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _border),
      ),
    );
  }
}

class _DynamicIslandNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final int homeBadge;
  final int vacanciesBadge;

  const _DynamicIslandNavBar({
    required this.selectedIndex,
    required this.onSelect,
    required this.homeBadge,
    required this.vacanciesBadge,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.90),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: Colors.black.withOpacity(.85),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.14),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  indicatorColor: cs.primary.withOpacity(.14),
                  iconTheme: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return IconThemeData(color: cs.primary, size: 26);
                    }
                    return IconThemeData(
                      color: Colors.black.withOpacity(.70),
                      size: 24,
                    );
                  }),
                  labelTextStyle: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w900,
                      );
                    }
                    return TextStyle(
                      color: Colors.black.withOpacity(.65),
                      fontWeight: FontWeight.w800,
                    );
                  }),
                ),
                child: NavigationBar(
                  height: 74,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onSelect,
                  labelBehavior:
                      NavigationDestinationLabelBehavior.onlyShowSelected,
                  destinations: [
                    NavigationDestination(
                      icon: _BadgeIcon(
                        icon: Icons.home_rounded,
                        count: homeBadge,
                      ),
                      label: "Home",
                    ),
                    NavigationDestination(
                      icon: _BadgeIcon(
                        icon: Icons.work_rounded,
                        count: vacanciesBadge,
                      ),
                      label: "Vacantes",
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.person_rounded),
                      label: "Perfil",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;

  const _BadgeIcon({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    final show = count > 0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (show)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.6),
              ),
              child: Text(
                count > 99 ? "99+" : "$count",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  static const Color _border = Color(0xFFE7EEF8);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listen);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listen);
    super.dispose();
  }

  void _listen() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: !hasText
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged("");
                  },
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _GradientHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _GradientHero({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  static const Color _primary = Color(0xFF4CAAC9);
  static const Color _primary2 = Color(0xFF60A5FA);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, _primary2],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(.22)),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.98),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.88),
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE7EEF8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FAFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Icon(icon, color: _muted),
          ),
          const SizedBox(width: 12),
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _muted,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VacancyCard extends StatelessWidget {
  final Vacancy vacancy;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VacancyCard({
    required this.vacancy,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE7EEF8);
  static const Color _primary = Color(0xFF4CAAC9);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onOpen,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.03),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Tag(
                      icon: Icons.schedule_rounded,
                      text: vacancy.postedDate,
                    ),
                    _Tag(
                      icon: Icons.laptop_mac_rounded,
                      text: vacancy.modality,
                    ),
                    _Tag(
                      icon: Icons.location_on_rounded,
                      text: vacancy.location,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  vacancy.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _ink,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vacancy.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, height: 1.3),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.amber.withOpacity(.22),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            vacancy.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: _ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_rounded, color: _primary),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_rounded,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Tag({required this.icon, required this.text});

  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE7EEF8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _muted),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: _muted,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  static const Color _muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 62, color: _muted.withOpacity(.55)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: _muted, height: 1.35),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
