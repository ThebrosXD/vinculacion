import 'dart:math';
import 'package:flutter/material.dart';

// Ajusta este import si tu ruta es distinta:
import 'login_screen.dart';

class LoginGatewayScreen extends StatefulWidget {
  const LoginGatewayScreen({super.key});

  @override
  State<LoginGatewayScreen> createState() => _LoginGatewayScreenState();
}

class _LoginGatewayScreenState extends State<LoginGatewayScreen> {
  Offset _parallaxTarget = Offset.zero;

  void _onPanUpdate(DragUpdateDetails d) {
    final next = _parallaxTarget + Offset(d.delta.dx * 0.002, d.delta.dy * 0.002);
    setState(() {
      _parallaxTarget = Offset(
        next.dx.clamp(-1.0, 1.0),
        next.dy.clamp(-1.0, 1.0),
      );
    });
  }

  void _onPanEnd(_) {
    setState(() => _parallaxTarget = Offset.zero);
  }

  void _goToLogin(String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(role: role), // 'ug' | 'employer'
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;

    final s = (w / 410.0).clamp(0.85, 1.25);
    final isSmall = w < 380;

    final padX = 18.0 * s;
    final padTop = (isSmall ? 10.0 : 18.0) * s;
    final padBottom = 24.0 * s;

    final maxContentWidth = min(600.0, w - (padX * 2));
    final logoH = ((isSmall ? 90.0 : 120.0) * s).clamp(70.0, 130.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Stack(
          children: [
            Positioned.fill(
              child: TweenAnimationBuilder<Offset>(
                tween: Tween(begin: Offset.zero, end: _parallaxTarget),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                builder: (_, value, __) {
                  return _MeshBackground(parallax: value);
                },
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(padX, padTop, padX, padBottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 8 * s),

                        SizedBox(
                          height: logoH,
                          child: Image.asset(
                            'assets/UG.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(height: 18 * s),

                        Text(
                          "Bolsa de prácticas pre profesionales, pasantías y empleo",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (isSmall ? 18 : 20) * s,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),

                        SizedBox(height: 8 * s),

                        Text(
                          "Por favor elija qué tipo de usuario es",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (isSmall ? 13 : 14) * s,
                            color: Colors.black.withAlpha(150),
                            height: 1.2,
                          ),
                        ),

                        SizedBox(height: 18 * s),

                        _ChoiceCard(
                          scale: s,
                          title: "Soy UG",
                          subtitle:
                              "Toda persona que pertenezca a la Universidad de Guayaquil y posea correo institucional activo",
                          icon: Icons.badge_outlined,
                          highlight: true,
                          onTap: () => _goToLogin('ug'),
                        ),

                        SizedBox(height: 14 * s),

                        _ChoiceCard(
                          scale: s,
                          title: "Empleadores",
                          subtitle:
                              "Instituciones que deseen publicar ofertas de prácticas pre profesionales y de trabajo para la Universidad de Guayaquil",
                          icon: Icons.business_center_outlined,
                          highlight: false,
                          onTap: () => _goToLogin('employer'),
                        ),

                        // ✅ BOTÓN "REGRESAR" ELIMINADO COMPLETAMENTE
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= CARD GRANDE RESPONSIVA =======================

class _ChoiceCard extends StatelessWidget {
  final double scale;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool highlight;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.scale,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.highlight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;

    final borderColor = highlight
        ? const Color(0xFF0B5ED7).withAlpha(140)
        : Colors.black.withAlpha(35);

    final bg = highlight
        ? const Color(0xFF0B5ED7).withAlpha(14)
        : Colors.white.withAlpha(240);

    final radius = 16.0 * s;

    return _DashedBorder(
      color: borderColor,
      radius: radius,
      dash: 8.0 * s,
      gap: 6.0 * s,
      strokeWidth: (1.4 * s).clamp(1.0, 2.0),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 14 * s,
              vertical: 16 * s,
            ),
            child: Row(
              children: [
                Container(
                  width: 44 * s,
                  height: 44 * s,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14 * s),
                    border: Border.all(color: Colors.black.withAlpha(25)),
                  ),
                  child: Icon(
                    icon,
                    size: (22 * s).clamp(18.0, 28.0),
                    color: const Color(0xFF0B5ED7),
                  ),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6 * s),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: (12.8 * s).clamp(11.5, 16.0),
                          color: Colors.black.withAlpha(150),
                          height: 1.25,
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

// ======================= MALLA FULLSCREEN =======================

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

        return CustomPaint(
          painter: _MeshPainter(points: _pts, parallax: widget.parallax),
        );
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
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

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

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withAlpha(2),
    );
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) {
    return oldDelegate.parallax != parallax || oldDelegate.points != points;
  }
}

// ======================= BORDE PUNTEADO (dashed) =======================

class _DashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  final double dash;
  final double gap;
  final double strokeWidth;

  const _DashedBorder({
    required this.child,
    required this.color,
    required this.radius,
    required this.dash,
    required this.gap,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        radius: radius,
        dash: dash,
        gap: gap,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dash;
  final double gap;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.dash,
    required this.gap,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()..addRRect(rrect);

    for (final m in path.computeMetrics()) {
      double distance = 0;
      while (distance < m.length) {
        final len = min(dash, m.length - distance);
        final extract = m.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.dash != dash ||
        oldDelegate.gap != gap ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
