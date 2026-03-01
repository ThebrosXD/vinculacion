import 'package:flutter/material.dart';
import '../models/vacancy.dart'; // Asegúrate de importar tu modelo

class VacancyCard extends StatelessWidget {
  final Vacancy vacancy;
  final VoidCallback? onTap;
  final bool isProfessionalView; // Para saber si mostramos la estrella o no

  const VacancyCard({
    super.key,
    required this.vacancy,
    this.onTap,
    this.isProfessionalView = true, // Por defecto es vista de profesional
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEDF7FC), // Color azulito claro del fondo de la tarjeta según PDF
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Fecha de publicación (Texto pequeño gris)
            Text(
              "Publicado ${vacancy.postedDate}",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 8),

            // 2. Título del puesto
            Text(
              vacancy.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),

            // 3. Fila de Empresa (Logo, Nombre, Rating)
            Row(
              children: [
                // Placeholder para el logo (Círculo con inicial)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      vacancy.companyName[0], // Primera letra de la empresa
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  vacancy.companyName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                const Icon(Icons.people_alt_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  vacancy.rating.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 4. Descripción (Limitada a 3 líneas)
            Text(
              vacancy.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis, // Pone "..." si es muy largo
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 16),

            // 5. Pie de tarjeta: Ubicación, Modalidad y Acción
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIconText(Icons.location_on_outlined, vacancy.location),
                      const SizedBox(height: 4),
                      _buildIconText(Icons.person_outline, vacancy.modality),
                    ],
                  ),
                ),
                // Icono de Favorito (Solo si es vista profesional)
                if (isProfessionalView)
                  InkWell(
                    onTap: () {
                      // Aquí iría la lógica para guardar en favoritos
                      print("Agregado a favoritos: ${vacancy.title}");
                    },
                    child: const Icon(
                      Icons.star_border, // Usa Icons.star si ya es favorito
                      size: 30,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper pequeño para los iconos con texto (Ubicación, Modalidad)
  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF2C3E50)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}