import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../network/ug_client.dart';

import 'forgot_password_screen.dart';
import 'register_company_screen.dart';
import 'register_professional_screen.dart';
import 'login_gateway_screen.dart';

import '../professional/professional_main_screen.dart';
import '../company/company_main_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// ✅ 2 controllers => TickerProviderStateMixin
class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  static const Color _bgTop = Color(0xFFF7FAFF);
  static const Color _bgBottom = Color(0xFFF2F6FF);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _primary = Color(0xFF0B7BFF);
  static const Color _border = Color(0xFFE6EEF8);

  // Tono suave para el loader (azul/celeste/blanco)
  static const Color _softBlue = Color(0xFF4FA8FF);
  static const Color _softSky = Color(0xFFBFE9FF);

  late final AnimationController _bgCtrl;
  late final AnimationController _loadingCtrl;

  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String _loadingUser = '';

  bool get _isEmployer {
    final r = widget.role.trim().toLowerCase();
    return r.contains('emple') ||
        r.contains('emp') ||
        r.contains('company') ||
        r.contains('empresa');
  }

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
    _loadingCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _loadingCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ✅ Regresar al Gateway (NUNCA usar decodedLogin aquí)
  void _goBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginGatewayScreen()),
    );
  }

  Future<void> _login() async {
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa usuario/RUC y contraseña')),
      );
      return;
    }

    if (_isEmployer && !RegExp(r'^\d+$').hasMatch(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El RUC debe contener solo números')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _loadingUser = username;
    });

    // Pausamos la malla durante carga para estabilidad
    _bgCtrl.stop();
    if (!_loadingCtrl.isAnimating) _loadingCtrl.repeat();

    try {
      final tipo = _isEmployer ? 'E' : 'I';

      // ✅ Capturar respuesta de login para pasarla al main screen
      final loginData = await UgClient.instance.loginSesion(
        username: username,
        password: password,
        tipoUsuario: tipo,
        ip: '127.0.0.1',
      );

      if (!mounted) return;

      _loadingCtrl.stop();
      _loadingCtrl.reset();
      setState(() => _loading = false);

      _bgCtrl.repeat();

      if (_isEmployer) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CompanyMainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfessionalMainScreen(loginData: loginData)),
        );
      }
    } catch (e) {
      if (!mounted) return;

      _loadingCtrl.stop();
      _loadingCtrl.reset();
      setState(() => _loading = false);

      _bgCtrl.repeat();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;

    final s = (w / 410.0).clamp(0.85, 1.28);
    final padX = 18.0 * s;
    final padTop = 18.0 * s;
    final padBottom = 22.0 * s;
    final maxCardW = min(720.0, w - (padX * 2));
    final logoH = ((w < 360 ? 92.0 : 110.0) * s).clamp(84.0, 170.0);

    final title = _isEmployer ? "Empleadores" : "Bolsa de prácticas pre profesionales, pasantías y empleo";
    final subtitle = "Por favor ingresa las credenciales de acceso";

    Offset meshParallax(double t) {
      final dx = sin(t * 2 * pi) * 0.55;
      final dy = cos(t * 2 * pi) * 0.42;
      return Offset(dx, dy);
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_bgTop, _bgBottom],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, __) {
                return _MeshBackground(parallax: meshParallax(_bgCtrl.value));
              },
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(padX, padTop, padX, padBottom),
                child: Column(
                  children: [
                    SizedBox(height: 10 * s),
                    Image.asset('assets/UG.png', height: logoH, fit: BoxFit.contain),
                    SizedBox(height: 18 * s),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxCardW),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22 * s),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(240),
                              borderRadius: BorderRadius.circular(22 * s),
                              border: Border.all(color: _border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(26),
                                  blurRadius: 30,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.fromLTRB(20 * s, 18 * s, 20 * s, 18 * s),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: (_isEmployer ? 22 : 18) * s,
                                    fontWeight: FontWeight.w900,
                                    color: _ink,
                                    height: 1.15,
                                  ),
                                ),
                                SizedBox(height: 6 * s),
                                Text(
                                  subtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.5 * s,
                                    fontWeight: FontWeight.w700,
                                    color: _muted,
                                  ),
                                ),
                                SizedBox(height: 18 * s),

                                if (_isEmployer) ...[
                                  _fieldLabel("Ruc:", s),
                                  SizedBox(height: 8 * s),
                                  _InputRow(
                                    scale: s,
                                    icon: Icons.badge_outlined,
                                    controller: _userCtrl,
                                    hintText: "Ingrese Ruc (solo números)",
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(13),
                                    ],
                                    enabled: !_loading,
                                  ),
                                  SizedBox(height: 14 * s),
                                ] else ...[
                                  _fieldLabel("Correo institucional", s),
                                  SizedBox(height: 8 * s),
                                  _InputRow(
                                    scale: s,
                                    icon: Icons.email_outlined,
                                    controller: _userCtrl,
                                    hintText: "Ingrese Correo Institucional",
                                    keyboardType: TextInputType.emailAddress,
                                    enabled: !_loading,
                                  ),
                                  SizedBox(height: 14 * s),
                                ],

                                _fieldLabel("Contraseña:", s),
                                SizedBox(height: 8 * s),
                                _InputRow(
                                  scale: s,
                                  icon: Icons.lock_outline_rounded,
                                  controller: _passCtrl,
                                  hintText: "Ingrese Contraseña",
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: _obscure,
                                  enabled: !_loading,
                                  trailing: IconButton(
                                    onPressed: _loading ? null : () => setState(() => _obscure = !_obscure),
                                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                    color: _muted,
                                  ),
                                ),

                                SizedBox(height: 18 * s),

                                SizedBox(
                                  height: 48 * s,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12 * s),
                                      ),
                                    ),
                                    onPressed: _loading ? null : _login,
                                    child: Text(
                                      _loading ? "Conectando..." : "Iniciar Sesión",
                                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14 * s),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 10 * s),

                                if (_isEmployer) ...[
                                  Center(
                                    child: GestureDetector(
                                      onTap: _loading
                                          ? null
                                          : () => Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                              ),
                                      child: Text(
                                        "¿Olvidaste la contraseña?",
                                        style: TextStyle(
                                          color: const Color(0xFFE11D48),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12.5 * s,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10 * s),
                                  Center(
                                    child: GestureDetector(
                                      onTap: _loading
                                          ? null
                                          : () => Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (_) => const RegisterCompanyScreen()),
                                              ),
                                      child: Text(
                                        "¿No tienes una cuenta? Regístrate aquí",
                                        style: TextStyle(
                                          color: const Color(0xFF2563EB),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12.5 * s,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8 * s),
                                ],

                                SizedBox(height: 6 * s),

                                Center(
                                  child: TextButton(
                                    onPressed: _loading ? null : _goBack,
                                    style: TextButton.styleFrom(
                                      foregroundColor: _ink,
                                      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 10 * s),
                                      textStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 14 * s),
                                    ),
                                    child: const Text("Regresar"),
                                  ),
                                ),

                                if (!_isEmployer) ...[
                                  SizedBox(height: 10 * s),
                                  Center(
                                    child: GestureDetector(
                                      onTap: _loading
                                          ? null
                                          : () => Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (_) => const RegisterProfessionalScreen()),
                                              ),
                                      child: Text(
                                        "¿No tienes una cuenta? Regístrate aquí",
                                        style: TextStyle(
                                          color: const Color(0xFF2563EB),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12.5 * s,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 18 * s),
                  ],
                ),
              ),
            ),
          ),

          // ===== Overlay de carga (UG con logo.png y tonos suaves) =====
          if (_loading)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _loadingCtrl,
                builder: (_, __) {
                  final t = _loadingCtrl.value; // 0..1
                  final pulse = 0.96 + 0.06 * sin(2 * pi * t);
                  final fade = 0.35 + 0.65 * (0.5 - 0.5 * cos(2 * pi * t));

                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      color: Colors.white.withAlpha(235),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.scale(
                              scale: pulse,
                              child: Container(
                                width: 130 * s,
                                height: 130 * s,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFFFFFF),
                                      _softSky, // ✅ ya se usa
                                      Color(0xFF93D0FF),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: _softBlue.withAlpha(70),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _softBlue.withAlpha(60),
                                      blurRadius: 26,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(18 * s),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: Image.asset(
                                      'assets/logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 26 * s),
                            SizedBox(
                              width: 56 * s,
                              height: 56 * s,
                              child: RotationTransition(
                                turns: _loadingCtrl,
                                child: CustomPaint(
                                  size: Size(56 * s, 56 * s),
                                  painter: _GradientArcPainter(
                                    color: _softBlue,
                                    strokeWidth: 4 * s,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 22 * s),
                            Opacity(
                              opacity: fade.clamp(0.0, 1.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Iniciando sesión',
                                    style: TextStyle(
                                      fontSize: 20 * s,
                                      fontWeight: FontWeight.w800,
                                      color: _ink,
                                    ),
                                  ),
                                  SizedBox(height: 6 * s),
                                  Text(
                                    'Usuario: $_loadingUser',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13.5 * s,
                                      fontWeight: FontWeight.w700,
                                      color: _muted,
                                    ),
                                  ),
                                  SizedBox(height: 8 * s),
                                  Text(
                                    _isEmployer
                                        ? 'Validando credenciales empresariales...'
                                        : 'Conectando con el sistema académico...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14 * s,
                                      fontWeight: FontWeight.w600,
                                      color: _muted,
                                    ),
                                  ),
                                  SizedBox(height: 10 * s),
                                  _Dots(t: t, scale: s, color: _softBlue),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text, double s) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5 * s,
        fontWeight: FontWeight.w900,
        color: _ink,
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final double t; // 0..1
  final double scale;
  final Color color;
  const _Dots({required this.t, required this.scale, required this.color});

  double _dotOpacity(int i) {
    final delay = i * 0.18;
    final v = (t - delay) % 1.0;
    final o = v < 0.5 ? v * 2 : (1 - v) * 2;
    return o.clamp(0.25, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final a = (_dotOpacity(i) * 255).round();
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 3 * scale),
          width: 6 * scale,
          height: 6 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(a),
          ),
        );
      }),
    );
  }
}

class _GradientArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _GradientArcPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - strokeWidth) / 2,
    );

    final gradient = SweepGradient(
      colors: [
        color.withAlpha(40),
        color.withAlpha(210),
        color.withAlpha(40),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 1.55 * pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientArcPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

// ======================= INPUT RESPONSIVO =======================

class _InputRow extends StatelessWidget {
  static const Color _muted = Color(0xFF64748B);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _border = Color(0xFFE6EEF8);

  final double scale;
  final IconData icon;
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Widget? trailing;
  final bool enabled;

  const _InputRow({
    required this.scale,
    required this.icon,
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.trailing,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final h = (48.0 * s).clamp(44.0, 58.0);
    final iconBox = h;
    final radius = 12.0 * s;

    return Container(
      height: h,
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.white.withAlpha(179),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FF),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: _border),
            ),
            child: Icon(icon, color: _muted, size: (20 * s).clamp(18.0, 28.0)),
          ),
          Expanded(
            child: TextField(
              enabled: enabled,
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              obscureText: obscureText,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: _ink,
                fontSize: (13.5 * s).clamp(12.5, 17.0),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w700,
                  fontSize: (13.0 * s).clamp(12.0, 16.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 14 * s),
              ),
            ),
          ),
          if (trailing != null)
            SizedBox(width: iconBox, height: iconBox, child: Center(child: trailing)),
        ],
      ),
    );
  }
}

// ======================= MALLA =======================

class _MeshBackground extends StatefulWidget {
  final Offset parallax;
  const _MeshBackground({required this.parallax});

  @override
  State<_MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<_MeshBackground> {
  Size _lastSize = Size.zero;
  List<Offset> _pts = const [];

  static const int _minPts = 45;
  static const int _maxPts = 115;

  void _ensurePoints(Size size) {
    if (size == _lastSize && _pts.isNotEmpty) return;
    _lastSize = size;

    final area = size.width * size.height;
    final target = (area / 14000).round();
    final count = target.clamp(_minPts, _maxPts);

    _pts = _stratifiedPoints(count, seed: 42);
  }

  List<Offset> _stratifiedPoints(int n, {int seed = 0}) {
    final r = Random(seed);
    final grid = sqrt(n).ceil();
    final pts = <Offset>[];

    for (int y = 0; y < grid; y++) {
      for (int x = 0; x < grid; x++) {
        if (pts.length >= n) break;
        final px = (x + r.nextDouble()) / grid;
        final py = (y + r.nextDouble()) / grid;
        pts.add(Offset(px, py));
      }
    }

    pts.shuffle(Random(seed + 7));
    return pts.take(n).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final size = Size(c.maxWidth, c.maxHeight);
        _ensurePoints(size);
        return CustomPaint(painter: _MeshPainter(points: _pts, parallax: widget.parallax));
      },
    );
  }
}

class _MeshPainter extends CustomPainter {
  final List<Offset> points;
  final Offset parallax;
  _MeshPainter({required this.points, required this.parallax});

  double _edgeDist01(Offset p01) {
    final a = min(p01.dx, 1 - p01.dx);
    final b = min(p01.dy, 1 - p01.dy);
    return min(a, b);
  }

  int _lerpInt(int a, int b, double t) => (a + (b - a) * t).round();

  @override
  void paint(Canvas canvas, Size size) {
    final minSide = min(size.width, size.height);
    final maxDist = (minSide * 0.22).clamp(90.0, 200.0);
    final dotRadius = (minSide * 0.004).clamp(1.8, 3.0);
    final baseStroke = (minSide * 0.0012).clamp(0.8, 1.2);

    final dotPaint = Paint()..color = const Color(0xFF0B5ED7).withAlpha(45);
    final shift = Offset(parallax.dx * 18, parallax.dy * 14);

    final screenPts = <Offset>[];
    for (final p in points) {
      final base = Offset(p.dx * size.width, p.dy * size.height);
      final depth = 0.6 + (p.dy * 0.8);
      screenPts.add(base + shift * depth);
    }

    for (int i = 0; i < screenPts.length; i++) {
      final a = screenPts[i];
      final p01 = points[i];
      final ed = _edgeDist01(p01);
      final tCenter = (ed / 0.5).clamp(0.0, 1.0);
      final maxLinks = _lerpInt(6, 2, tCenter);

      final candidates = <({int j, double d})>[];
      for (int j = 0; j < screenPts.length; j++) {
        if (j == i) continue;
        final b = screenPts[j];
        final dx = a.dx - b.dx;
        final dy = a.dy - b.dy;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist < maxDist) candidates.add((j: j, d: dist));
      }

      candidates.sort((x, y) => x.d.compareTo(y.d));
      final take = min(maxLinks, candidates.length);

      for (int k = 0; k < take; k++) {
        final j = candidates[k].j;
        final dist = candidates[k].d;
        final alpha = (1 - dist / maxDist);
        final paint = Paint()
          ..color = const Color(0xFF0B5ED7).withAlpha((10 + alpha * 30).round())
          ..strokeWidth = baseStroke;

        canvas.drawLine(a, screenPts[j], paint);
      }
    }

    for (final p in screenPts) {
      canvas.drawCircle(p, dotRadius, dotPaint);
    }

    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black.withAlpha(2));
  }
   @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) {
    return oldDelegate.parallax != parallax || oldDelegate.points != points;
  }
}