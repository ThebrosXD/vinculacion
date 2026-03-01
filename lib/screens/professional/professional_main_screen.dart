import 'dart:ui';
import 'package:flutter/material.dart';

import '../../models/vacancy.dart';
import '../../models/company.dart';
import '../auth/login_gateway_screen.dart';
import 'vacancy_detail_screen.dart';
import 'company_detail_screen.dart';
import 'cv_simulation_screen.dart';

//  Network (UG)
import '../../network/ug_client.dart';
import '../../network/ug/ug_models.dart';

import 'professional_profile_screen.dart';

class ProfessionalMainScreen extends StatefulWidget {
  final Map<String, dynamic>? loginData;

  const ProfessionalMainScreen({super.key, this.loginData});

  @override
  State<ProfessionalMainScreen> createState() => _ProfessionalMainScreenState();
}

class _ProfessionalMainScreenState extends State<ProfessionalMainScreen> {
  int _selectedIndex = 0;

  bool _showVacanciesTab = true;
  bool _showFavVacancies = true;

  final TextEditingController _searchController = TextEditingController();

  static const Color _bg = Color(0xFFF4F6FA);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _primary = Color(0xFF2563EB);
  static const Color _cardBorder = Color(0xFFE7EEF8);

  // ======================= DATA DUMMY (temporal) =======================

  final List<Vacancy> _allVacancies = [
    Vacancy(
      id: '1',
      title: 'Desarrollador Backend',
      companyName: 'Bangara S.A',
      location: 'Guayaquil, Guayas',
      modality: 'Presencial',
      description:
          '¿Te apasiona la tecnología? Buscamos experto en Node.js, bases de datos SQL y arquitectura de microservicios.',
      rating: 4.2,
      postedDate: 'Hace 3 días',
    ),
    Vacancy(
      id: '2',
      title: 'Desarrollador Java',
      companyName: 'Banco Pichincha',
      location: 'Quito, Pichincha',
      modality: 'Híbrido',
      description:
          'Buscamos un desarrollador Full Stack con conocimientos sólidos en Java Spring Boot y Angular.',
      rating: 4.5,
      postedDate: 'Hace 1 día',
    ),
    Vacancy(
      id: '3',
      title: 'Analista QA',
      companyName: 'TATA Consultancy',
      location: 'Guayaquil',
      modality: 'Remoto',
      description:
          'Responsable de la ejecución de pruebas manuales y automatizadas. Conocimientos en Selenium.',
      rating: 3.8,
      postedDate: 'Hace 5 días',
    ),
  ];

  final List<Company> _allCompanies = [
    Company(
      id: 'c1',
      name: 'Bangara S.A',
      industry: 'Financiera',
      location: 'Guayaquil',
      description: 'Empresa líder en tecnología financiera...',
      rating: 4.2,
      employeeCount: 50,
    ),
    Company(
      id: 'c2',
      name: 'Banco Pichincha',
      industry: 'Banca',
      location: 'Quito',
      description: 'El banco más grande del Ecuador...',
      rating: 4.5,
      employeeCount: 5000,
    ),
  ];

  List<Vacancy> _foundVacancies = [];
  List<Company> _foundCompanies = [];

  final List<Vacancy> _favoriteVacancies = [];
  final List<Company> _followedCompanies = [];
  final List<Vacancy> _applications = [];

  // ======================= PERFIL (fallback desde login) =======================

  String _pCedula = "092085173";
  String _pNombres = "Usuario";
  String _pApellidos = "";
  String _pCelular = "";
  String _pCorreoInst = "";
  String _pPaisRes = "ECUADOR";
  String _pCiudadRes = "GUAYAQUIL";

  // ======================= NAV DINÁMICA (SUBMENU) =======================

  bool _navLoading = false;
  String? _navError;

  String? _sessionUsuario; // cedula del login
  int? _sessionSistema; // sistemaId del login (22)

  List<UgMenuItem> _menus = [];
  UgMenuItem? _activeMenu;

  List<UgSubMenuItem> _subMenus = [];
  List<_NavItem> _navItems = const [];

  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();

    _foundVacancies = _allVacancies;
    _foundCompanies = _allCompanies;

    _applyLoginData(widget.loginData);
    _bootstrapNavigation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyLoginData(Map<String, dynamic>? login) {
    if (login == null) return;

    final cedula = (login["cedula"] ?? login["username"])?.toString();
    final sistemaId = int.tryParse((login["sistemaId"] ?? "").toString());

    if (cedula != null && cedula.isNotEmpty) {
      _pCedula = cedula;
      _sessionUsuario = cedula;
    }
    if (sistemaId != null) _sessionSistema = sistemaId;

    final nombre = login["nombre"]?.toString();
    final apellidos = login["apellidos"]?.toString();
    final correo = login["emailAddress"]?.toString();

    if (nombre != null && nombre.isNotEmpty) _pNombres = nombre;
    if (apellidos != null && apellidos.isNotEmpty) _pApellidos = apellidos;
    if (correo != null && correo.isNotEmpty) _pCorreoInst = correo;
  }

  Future<void> _bootstrapNavigation() async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    if (_sessionUsuario == null || _sessionSistema == null) {
      _navItems = _fallbackNavItems();
      return;
    }

    setState(() {
      _navLoading = true;
      _navError = null;
    });

    try {
      final menus = await UgClient.instance.obtenerMenu(
        usuario: _sessionUsuario!,
        sistema: _sessionSistema!,
      );

      UgMenuItem? active = menus.where((m) => m.moduloId == 1091).isNotEmpty
          ? menus.firstWhere((m) => m.moduloId == 1091)
          : (menus.isNotEmpty ? menus.first : null);

      if (active == null) {
        throw Exception("No hay módulos disponibles para este usuario.");
      }

      final sub = await UgClient.instance.obtenerSubMenu(
        usuario: _sessionUsuario!,
        sistema: _sessionSistema!,
        moduloId: active.moduloId,
      );

      final nav = _navItemsFromSubMenu(sub);

      setState(() {
        _menus = menus;
        _activeMenu = active;
        _subMenus = sub;
        _navItems = nav.isEmpty ? _fallbackNavItems() : nav;
        _selectedIndex = 0;
        _navLoading = false;
      });
    } catch (e) {
      setState(() {
        _navError = e.toString();
        _navLoading = false;
        _navItems = _fallbackNavItems();
      });
    }
  }

  Future<void> _setActiveMenu(UgMenuItem menu) async {
    if (_sessionUsuario == null || _sessionSistema == null) return;

    setState(() {
      _navLoading = true;
      _navError = null;
      _activeMenu = menu;
      _selectedIndex = 0;
    });

    try {
      final sub = await UgClient.instance.obtenerSubMenu(
        usuario: _sessionUsuario!,
        sistema: _sessionSistema!,
        moduloId: menu.moduloId,
      );

      final nav = _navItemsFromSubMenu(sub);

      setState(() {
        _subMenus = sub;
        _navItems = nav.isEmpty ? _fallbackNavItems() : nav;
        _navLoading = false;
      });
    } catch (e) {
      setState(() {
        _navError = e.toString();
        _navLoading = false;
        _navItems = _fallbackNavItems();
      });
    }
  }

  // ======================= NAV ITEMS =======================

  List<_NavItem> _fallbackNavItems() {
    return [
      _NavItem(label: "Home", icon: Icons.home_rounded, builder: _buildHomeTab),
      _NavItem(label: "Postulación", icon: Icons.people_alt_rounded, builder: _buildApplicationsTab),
      _NavItem(label: "Favoritos", icon: Icons.bookmark_rounded, builder: _buildFavoritesTab),
      _NavItem(label: "Perfil", icon: Icons.person_rounded, builder: _buildProfileTab),
    ];
  }

  List<_NavItem> _navItemsFromSubMenu(List<UgSubMenuItem> items) {
    final out = <_NavItem>[];

    for (final it in items) {
      final label = it.nombre;
      final icon = _iconFromFa(it.icono, fallback: Icons.circle_outlined);

      final routeKey = it.rutaForma.split('|').first.trim();
      final isIframe = it.iframe.trim() == "1";

      Widget builder() {
        if (isIframe) {
          return _buildPlaceholderTab(title: label, subtitle: "iframe=1 • $routeKey");
        }

        final rk = routeKey.toLowerCase();

        if (rk == "menuestudiante/index") return _buildHomeTab();
        if (rk == "mispostulaciones/mispostulaciones") return _buildApplicationsTab();
        if (rk == "informacionpersonal/index") return _buildProfileTab();

        return _buildPlaceholderTab(title: label, subtitle: routeKey);
      }

      out.add(_NavItem(label: label, icon: icon, builder: builder));
    }

    return out;
  }

  IconData _iconFromFa(String fa, {required IconData fallback}) {
    final s = fa.toLowerCase();

    if (s.contains("paper-plane")) return Icons.send_rounded;
    if (s.contains("id-card")) return Icons.badge_outlined;
    if (s.contains("check-square")) return Icons.check_box_outlined;
    if (s.contains("building")) return Icons.apartment_rounded;
    if (s.contains("tasks")) return Icons.task_alt_rounded;
    if (s.contains("list-alt")) return Icons.fact_check_rounded;

    return fallback;
  }

  // ======================= UI HELPERS =======================

  String _greetingTitle() => "Hola, $_pNombres";

  void _runFilter(String keyword) {
    setState(() {
      final k = keyword.trim().toLowerCase();
      if (_showVacanciesTab) {
        _foundVacancies = k.isEmpty
            ? _allVacancies
            : _allVacancies.where((v) => v.title.toLowerCase().contains(k)).toList();
      } else {
        _foundCompanies = k.isEmpty
            ? _allCompanies
            : _allCompanies.where((c) => c.name.toLowerCase().contains(k)).toList();
      }
    });
  }

  void _toggleFavVacancy(Vacancy v) {
    setState(() {
      if (_favoriteVacancies.contains(v)) {
        _favoriteVacancies.remove(v);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Eliminado de favoritos"), duration: Duration(milliseconds: 650)),
        );
      } else {
        _favoriteVacancies.add(v);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Agregado a favoritos"), duration: Duration(milliseconds: 650)),
        );
      }
    });
  }

  void _toggleFollowCompany(Company c) {
    setState(() {
      if (_followedCompanies.contains(c)) {
        _followedCompanies.remove(c);
      } else {
        _followedCompanies.add(c);
      }
    });
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginGatewayScreen()),
      (route) => false,
    );
  }

  void _visualizeCV() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CvSimulationScreen(
          nombres: _pNombres,
          apellidos: _pApellidos,
          nacionalidad: "ECUATORIANA",
          correo: _pCorreoInst,
          telf: "",
          celular: _pCelular,
          ciudad: _pCiudadRes,
          pais: _pPaisRes,
          fechaNac: "",
          edad: "",
        ),
      ),
    );
  }

  double _safeClamp(double v, double min, double max) {
    if (max < min) return min;
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }

  // ======================= APP BAR (IZQUIERDA + SUBTÍTULO) =======================

  SliverAppBar _buildSolidSliverAppBar({
    required String title,
    String? subtitle,
    List<Widget> actions = const [],
  }) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 6,
      backgroundColor: _bg,
      surfaceTintColor: _bg,
      shadowColor: Colors.black.withOpacity(.12),

      automaticallyImplyLeading: false,
      leading: const SizedBox.shrink(),

      centerTitle: false,
      titleSpacing: 16,

      title: Align(
        alignment: Alignment.centerLeft,
        child: subtitle == null
            ? Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: _ink))
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: _ink)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _muted.withOpacity(.95),
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
      ),
      actions: [...actions, const SizedBox(width: 6)],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _cardBorder),
      ),
    );
  }

  // ======================= MENÚ MÓDULOS (GLASS + ANIMACIÓN) =======================

  Widget _buildModulePickerAction() {
    if (_menus.isEmpty || _activeMenu == null) return const SizedBox.shrink();

    return Builder(
      builder: (btnCtx) {
        return IconButton(
          tooltip: "Cambiar módulo",
          icon: const Icon(Icons.dashboard_customize_rounded, color: _ink),
          onPressed: _navLoading ? null : () => _openGlassModuleMenu(btnCtx),
        );
      },
    );
  }

  Future<void> _openGlassModuleMenu(BuildContext anchorContext) async {
    if (_menus.isEmpty || _activeMenu == null) return;

    final overlayState = Overlay.of(anchorContext);
    if (overlayState == null) return;

    final overlayBox = overlayState.context.findRenderObject();
    final buttonBox = anchorContext.findRenderObject();

    if (overlayBox is! RenderBox || buttonBox is! RenderBox) return;

    const double menuWidth = 320;
    const double menuMaxHeight = 360;

    final overlaySize = overlayBox.size;

    final buttonBottomLeft = buttonBox.localToGlobal(
      Offset(0, buttonBox.size.height),
      ancestor: overlayBox,
    );
    final buttonBottomRight = buttonBox.localToGlobal(
      buttonBox.size.bottomRight(Offset.zero),
      ancestor: overlayBox,
    );

    final desiredLeft = buttonBottomRight.dx - menuWidth;
    final desiredTop = buttonBottomLeft.dy + 8;

    final left = _safeClamp(desiredLeft, 12, overlaySize.width - menuWidth - 12);
    final top = _safeClamp(desiredTop, 12, overlaySize.height - menuMaxHeight - 12);

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "moduleMenu",
      barrierColor: Colors.black.withOpacity(.08),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (ctx, a1, a2) {
        return SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                child: _GlassModuleMenu(
                  menus: _menus,
                  activeId: _activeMenu!.moduloId,
                  iconResolver: (fa) => _iconFromFa(fa, fallback: Icons.dashboard_rounded),
                  onPick: (m) {
                    Navigator.of(ctx).pop();
                    _setActiveMenu(m);
                  },
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (ctx, anim, sec, child) {
        final fade = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);

        final dy = Tween<double>(begin: -12, end: 0).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
        );

        final scale = Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        );

        return FadeTransition(
          opacity: fade,
          child: Transform.translate(
            offset: Offset(0, dy.value),
            child: Transform.scale(
              scale: scale.value,
              alignment: Alignment.topRight,
              child: child,
            ),
          ),
        );
      },
    );
  }

  // ======================= BUILD =======================

  @override
  Widget build(BuildContext context) {
    final items = _navItems.isEmpty ? _fallbackNavItems() : _navItems;
    final safeIndex = (_selectedIndex >= 0 && _selectedIndex < items.length) ? _selectedIndex : 0;

    return WillPopScope(
      onWillPop: () async => false, // 🔒 no retroceder con back
      child: Theme(
        data: Theme.of(context).copyWith(
          useMaterial3: true,
          scaffoldBackgroundColor: _bg,
          colorScheme: ColorScheme.fromSeed(seedColor: _primary),
        ),
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                IndexedStack(
                  index: safeIndex,
                  children: items.map((e) => e.builder()).toList(),
                ),
                if (_navLoading)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.white.withOpacity(.55),
                        child: const Center(
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_navError != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 92,
                    child: Material(
                      color: Colors.red.withOpacity(.92),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _navError!,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: _bootstrapNavigation,
                              child: const Text("Reintentar", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: _DynamicIslandNavBar(
            selectedIndex: safeIndex,
            onSelect: (i) => setState(() => _selectedIndex = i),
            items: items,
          ),
        ),
      ),
    );
  }

  // ======================= PAGES =======================

  Widget _buildHomeTab() {
    final moduleName = _activeMenu?.nombre.trim().isNotEmpty == true ? _activeMenu!.nombre : "Inicio";
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        _buildSolidSliverAppBar(
          title: _greetingTitle(),
          subtitle: moduleName,
          actions: [
            _buildModulePickerAction(),
            IconButton(
              onPressed: () => ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("No tienes notificaciones nuevas"))),
              icon: const Icon(Icons.notifications_none_rounded, color: _ink),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchBar(
                  controller: _searchController,
                  hintText: _showVacanciesTab ? "Buscar vacante..." : "Buscar empresa...",
                  onChanged: _runFilter,
                ),
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text("Vacantes"), icon: Icon(Icons.work_outline_rounded)),
                    ButtonSegment(value: false, label: Text("Empresas"), icon: Icon(Icons.apartment_rounded)),
                  ],
                  selected: {_showVacanciesTab},
                  onSelectionChanged: (s) {
                    final v = s.first;
                    setState(() {
                      _showVacanciesTab = v;
                      _searchController.clear();
                      _runFilter("");
                    });
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      _GhostChip(icon: Icons.place_rounded, label: "Ubicación"),
                      SizedBox(width: 10),
                      _GhostChip(icon: Icons.laptop_mac_rounded, label: "Modalidad"),
                      SizedBox(width: 10),
                      _GhostChip(icon: Icons.schedule_rounded, label: "Tiempo"),
                      SizedBox(width: 10),
                      _GhostChip(icon: Icons.star_rounded, label: "Mejor valoradas"),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _showVacanciesTab ? "Recomendadas para ti" : "Empresas destacadas",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: _ink),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        if (_showVacanciesTab)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildVacancyCard(_foundVacancies[index]),
              childCount: _foundVacancies.length,
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCompanyCard(_foundCompanies[index]),
              childCount: _foundCompanies.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }

  Widget _buildApplicationsTab() {
    return CustomScrollView(
      slivers: [
        _buildSolidSliverAppBar(
          title: _greetingTitle(),
          subtitle: "Mis postulaciones",
          actions: [_buildModulePickerAction()],
        ),
        if (_applications.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: const _EmptyState(
              icon: Icons.folder_open_rounded,
              title: "Aún no tienes postulaciones",
              subtitle: "Cuando te postules a una vacante, aparecerá aquí.",
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildVacancyCard(_applications[index]),
                childCount: _applications.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    return CustomScrollView(
      slivers: [
        _buildSolidSliverAppBar(
          title: _greetingTitle(),
          subtitle: "Favoritos",
          actions: [_buildModulePickerAction()],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text("Vacantes"), icon: Icon(Icons.bookmark_outline_rounded)),
                ButtonSegment(value: false, label: Text("Empresas"), icon: Icon(Icons.corporate_fare_rounded)),
              ],
              selected: {_showFavVacancies},
              onSelectionChanged: (s) => setState(() => _showFavVacancies = s.first),
            ),
          ),
        ),
        if (_showFavVacancies)
          (_favoriteVacancies.isEmpty
              ? const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    icon: Icons.star_border_rounded,
                    title: "Sin vacantes favoritas",
                    subtitle: "Marca una vacante con ⭐ y aparecerá aquí.",
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildVacancyCard(_favoriteVacancies[i]),
                      childCount: _favoriteVacancies.length,
                    ),
                  ),
                ))
        else
          (_followedCompanies.isEmpty
              ? const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    icon: Icons.groups_2_rounded,
                    title: "No sigues empresas",
                    subtitle: "Pulsa “Seguir” en una empresa y aparecerá aquí.",
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildCompanyCard(_followedCompanies[i]),
                      childCount: _followedCompanies.length,
                    ),
                  ),
                )),
      ],
    );
  }

  Widget _buildProfileTab() {
    return ProfessionalProfileScreen(
      cedula: _pCedula,
      fallbackNombres: _pNombres,
      fallbackApellidos: _pApellidos,
      fallbackCelular: _pCelular,
      fallbackCorreoInst: _pCorreoInst,
      fallbackPais: _pPaisRes,
      fallbackCiudad: _pCiudadRes,
      modulePickerAction: _buildModulePickerAction(),
      onLogout: _logout,
      onViewCv: _visualizeCV,
    );
  }

  Widget _buildPlaceholderTab({required String title, required String subtitle}) {
    return CustomScrollView(
      slivers: [
        _buildSolidSliverAppBar(
          title: _greetingTitle(),
          subtitle: title,
          actions: [_buildModulePickerAction()],
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyState(
            icon: Icons.construction_rounded,
            title: "Pantalla pendiente",
            subtitle: subtitle,
          ),
        )
      ],
    );
  }

  // ======================= Cards existentes =======================

  Widget _buildVacancyCard(Vacancy vacancy) {
    final isFav = _favoriteVacancies.contains(vacancy);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VacancyDetailScreen(
                  vacancy: vacancy,
                  onPostulate: () {
                    if (!_applications.contains(vacancy)) {
                      setState(() => _applications.add(vacancy));
                    }
                  },
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _cardBorder),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Tag(text: vacancy.modality, icon: Icons.laptop_mac_rounded),
                    const SizedBox(width: 8),
                    _Tag(text: vacancy.postedDate, icon: Icons.schedule_rounded),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _toggleFavVacancy(vacancy),
                      icon: Icon(
                        isFav ? Icons.star_rounded : Icons.star_border_rounded,
                        color: isFav ? Colors.amber : _muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  vacancy.title,
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: _ink),
                ),
                const SizedBox(height: 4),
                Text(
                  vacancy.companyName,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: _primary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: _muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        vacancy.location,
                        style: const TextStyle(color: _muted, fontSize: 12.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _RatingPill(rating: vacancy.rating),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyCard(Company company) {
    final isFollowed = _followedCompanies.contains(company);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CompanyDetailScreen(company: company)),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _cardBorder),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _primary.withOpacity(.15)),
                  ),
                  child: Center(
                    child: Text(
                      company.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, color: _primary, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(company.name, style: const TextStyle(fontWeight: FontWeight.w900, color: _ink)),
                      const SizedBox(height: 2),
                      Text(
                        "${company.employeeCount} empleados • ${company.location}",
                        style: const TextStyle(color: _muted, fontSize: 12.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _Tag(text: company.industry, icon: Icons.business_rounded),
                          const SizedBox(width: 8),
                          _RatingPill(rating: company.rating),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: () => _toggleFollowCompany(company),
                  style: FilledButton.styleFrom(
                    backgroundColor: isFollowed ? Colors.white : _ink,
                    foregroundColor: isFollowed ? _ink : Colors.white,
                    side: isFollowed ? BorderSide(color: _cardBorder) : BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(isFollowed ? "Siguiendo" : "Seguir"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================= MENÚ GLASS (módulos) =======================

class _GlassModuleMenu extends StatelessWidget {
  final List<UgMenuItem> menus;
  final int activeId;
  final IconData Function(String fa) iconResolver;
  final ValueChanged<UgMenuItem> onPick;

  const _GlassModuleMenu({
    required this.menus,
    required this.activeId,
    required this.iconResolver,
    required this.onPick,
  });

  static const Color _muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 320,
          constraints: const BoxConstraints(maxHeight: 360),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.14),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: menus.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.black.withOpacity(.08)),
              itemBuilder: (context, i) {
                final m = menus[i];
                final selected = m.moduloId == activeId;

                return InkWell(
                  onTap: () => onPick(m),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Icon(iconResolver(m.icono), size: 20, color: selected ? Colors.black : _muted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            m.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: selected ? FontWeight.w900 : FontWeight.w800,
                              color: Colors.black.withOpacity(.88),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (selected) const Icon(Icons.check_rounded, size: 20, color: Colors.green),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ======================= NAV ITEM =======================

class _NavItem {
  final String label;
  final IconData icon;
  final Widget Function() builder;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.builder,
  });
}

// ======================= NAVBAR DINÁMICA =======================

class _DynamicIslandNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final List<_NavItem> items;

  const _DynamicIslandNavBar({
    required this.selectedIndex,
    required this.onSelect,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final destinations = items
        .map((e) => NavigationDestination(icon: Icon(e.icon), label: e.label))
        .toList(growable: false);

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
                border: Border.all(color: Colors.black.withOpacity(.85), width: 1.2),
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
                    return IconThemeData(color: Colors.black.withOpacity(.70), size: 24);
                  }),
                  labelTextStyle: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return TextStyle(color: cs.primary, fontWeight: FontWeight.w900);
                    }
                    return TextStyle(color: Colors.black.withOpacity(.65), fontWeight: FontWeight.w700);
                  }),
                ),
                child: NavigationBar(
                  height: 74,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onSelect,
                  labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
                  destinations: destinations,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================= Widgets =======================

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
  static const Color _cardBorder = Color(0xFFE7EEF8);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant _SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 18, offset: const Offset(0, 10)),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

class _GhostChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GhostChip({required this.icon, required this.label});

  static const Color _cardBorder = Color(0xFFE7EEF8);
  static const Color _muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _muted),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: _muted, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(width: 2),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _muted),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Tag({required this.text, required this.icon});

  static const Color _muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE7EEF8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _muted),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: _muted)),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;
  const _RatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    final r = rating.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.amber.withOpacity(.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
          const SizedBox(width: 6),
          Text(r, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({required this.icon, required this.title, required this.subtitle});

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
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: _muted, height: 1.35), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}