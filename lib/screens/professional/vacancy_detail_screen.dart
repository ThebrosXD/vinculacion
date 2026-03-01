import 'package:flutter/material.dart';
import '../../models/vacancy.dart';

class VacancyDetailScreen extends StatelessWidget {
  final Vacancy vacancy;
  final VoidCallback? onPostulate;

  const VacancyDetailScreen({
    super.key,
    required this.vacancy,
    this.onPostulate,
  });

  static const Color _bg = Color(0xFFF4F6FA);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _primary = Color(0xFF2563EB);
  static const Color _primary2 = Color(0xFF60A5FA);
  static const Color _cardBorder = Color(0xFFE7EEF8);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: _bg,
        colorScheme: ColorScheme.fromSeed(seedColor: _primary),
      ),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildHeader(context),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _Chip(icon: Icons.schedule_rounded, text: "Publicado ${vacancy.postedDate}"),
                        _Chip(icon: Icons.laptop_mac_rounded, text: vacancy.modality),
                        _Chip(icon: Icons.location_on_rounded, text: vacancy.location),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Text(
                      vacancy.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _ink,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _CompanyCard(
                      companyName: vacancy.companyName,
                      rating: vacancy.rating,
                    ),

                    const SizedBox(height: 16),

                    const _SectionTitle("Descripción"),
                    const SizedBox(height: 10),
                    _Card(
                      child: Text(
                        vacancy.description,
                        style: const TextStyle(color: _muted, height: 1.5, fontSize: 14),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const _SectionTitle("Detalles"),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const [
                        _DetailPill(icon: Icons.work_outline_rounded, title: "Experiencia", value: "1 año"),
                        _DetailPill(icon: Icons.group_outlined, title: "Vacantes", value: "5 disponibles"),
                        _DetailPill(icon: Icons.access_time_rounded, title: "Jornada", value: "Full-time"),
                        _DetailPill(icon: Icons.verified_rounded, title: "Contrato", value: "A convenir"),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const _HintCard(
                      title: "Tip",
                      text: "Asegúrate de tener tu perfil completo antes de postular para aumentar tus posibilidades.",
                    ),
                  ],
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
            child: SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () => _showSuccessDialog(context),
                style: FilledButton.styleFrom(
                  backgroundColor: _ink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.send_rounded),
                label: const Text(
                  "Postular",
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ HEADER compacto, alineado y centrado (sin espacios extra)
  SliverAppBar _buildHeader(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 8,
      backgroundColor: _bg,
      surfaceTintColor: _bg,
      shadowColor: Colors.black.withOpacity(.12),
      expandedHeight: 86,
      collapsedHeight: 86,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primary, _primary2],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _RoundIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Center(
                    child: Text(
                      "Vacante",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.96),
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        letterSpacing: .2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),
                _RoundIconButton(
                  icon: Icons.notifications_none_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Sin notificaciones nuevas")),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(.14),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF22C55E).withOpacity(.25)),
              ),
              child: const Icon(Icons.check_rounded, color: Color(0xFF16A34A), size: 28),
            ),
            const SizedBox(height: 12),
            const Text(
              "¡Postulación exitosa!",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: const Text(
          "Ya eres parte de los profesionales postulados a esta oferta laboral.",
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, height: 1.35),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () {
                if (onPostulate != null) onPostulate!();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _ink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("Aceptar", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          )
        ],
      ),
    );
  }
}

// ----------------- UI COMPONENTS -----------------

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.18),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(.22)),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Chip({required this.icon, required this.text});

  static const Color _muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE7EEF8)),
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
              style: const TextStyle(fontWeight: FontWeight.w800, color: _muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  static const Color _ink = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w900, color: _ink, fontSize: 14.5),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EEF8)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 18, offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final String companyName;
  final double rating;

  const _CompanyCard({
    required this.companyName,
    required this.rating,
  });

  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _primary = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _primary.withOpacity(.18)),
            ),
            child: const Icon(Icons.business_rounded, color: _primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(companyName, style: const TextStyle(fontWeight: FontWeight.w900, color: _ink)),
                const SizedBox(height: 3),
                const Text(
                  "Empresa verificada",
                  style: TextStyle(color: _muted, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.amber.withOpacity(.22)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                const SizedBox(width: 6),
                Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w900, color: _ink)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailPill({
    required this.icon,
    required this.title,
    required this.value,
  });

  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE7EEF8);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width - 16 * 2 - 12) / 2; // 2 columnas

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _cardBorder),
            ),
            child: Icon(icon, color: _muted, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: _muted, fontWeight: FontWeight.w800, fontSize: 11.5)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: _ink, fontWeight: FontWeight.w900, fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  final String title;
  final String text;

  const _HintCard({required this.title, required this.text});

  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE7EEF8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.tips_and_updates_rounded, color: _ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: _ink)),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(color: _muted, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
