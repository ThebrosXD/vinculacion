import 'package:flutter/material.dart';

class CvPreviewScreen extends StatelessWidget {
  final String name;

  const CvPreviewScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    // Colores para el diseño del CV
    const Color darkColor = Color(0xFF2C3E50);
    const Color accentColor = Color(0xFF4CAAC9);

    return Scaffold(
      backgroundColor: Colors.grey[200], // Fondo gris para resaltar la "hoja"
      appBar: AppBar(
        title: Text("CV de $name", style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Descargando PDF...")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            // Simulación de hoja de papel A4
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CABECERA ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(color: accentColor, width: 2),
                      ),
                      child: Icon(Icons.person, size: 50, color: Colors.grey[400]),
                    ),
                    const SizedBox(width: 20),
                    // Nombre y Título
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: darkColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Text(
                            "DESARROLLADOR FULL STACK",
                            style: TextStyle(
                              fontSize: 14,
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Contacto rápido
                          _buildContactRow(Icons.email, "angel.taffur@email.com"),
                          _buildContactRow(Icons.phone, "+593 99 123 4567"),
                          _buildContactRow(Icons.location_on, "Guayaquil, Ecuador"),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                const Divider(thickness: 2, color: Colors.grey),
                const SizedBox(height: 20),

                // --- PERFIL PROFESIONAL ---
                _buildSectionTitle("PERFIL", darkColor),
                const SizedBox(height: 10),
                const Text(
                  "Ingeniero de software proactivo con más de 3 años de experiencia en el desarrollo de aplicaciones móviles y web. Apasionado por crear interfaces intuitivas y código limpio. Capacidad demostrada para liderar equipos pequeños y resolver problemas complejos bajo presión.",
                  style: TextStyle(height: 1.5, color: Colors.black87),
                  textAlign: TextAlign.justify,
                ),
                
                const SizedBox(height: 30),

                // --- EXPERIENCIA ---
                _buildSectionTitle("EXPERIENCIA LABORAL", darkColor),
                const SizedBox(height: 15),
                _buildExperienceItem(
                  role: "Desarrollador Senior Flutter",
                  company: "Tech Solutions S.A.",
                  dates: "Ene 2022 - Presente",
                  description: "Lideré la migración de la app principal a Flutter 3.0. Reduje el tiempo de carga en un 40%.",
                ),
                const SizedBox(height: 15),
                _buildExperienceItem(
                  role: "Desarrollador Web Junior",
                  company: "Agencia Digital Creativa",
                  dates: "Jun 2020 - Dic 2021",
                  description: "Desarrollo de landing pages y mantenimiento de e-commerce usando React y Node.js.",
                ),

                const SizedBox(height: 30),

                // --- EDUCACIÓN ---
                _buildSectionTitle("EDUCACIÓN", darkColor),
                const SizedBox(height: 15),
                _buildEducationItem(
                  degree: "Ingeniería en Ciencias Computacionales",
                  institution: "Escuela Superior Politécnica del Litoral",
                  dates: "2016 - 2020",
                ),

                const SizedBox(height: 30),

                // --- HABILIDADES ---
                _buildSectionTitle("HABILIDADES", darkColor),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildSkillChip("Flutter"),
                    _buildSkillChip("Dart"),
                    _buildSkillChip("Firebase"),
                    _buildSkillChip("Git & GitHub"),
                    _buildSkillChip("Figma"),
                    _buildSkillChip("Scrum"),
                    _buildSkillChip("Inglés B2"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets Auxiliares para el diseño del CV ---

  Widget _buildSectionTitle(String title, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1.5,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 40,
          height: 3,
          color: const Color(0xFF4CAAC9), // Color acento
        )
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildExperienceItem({required String role, required String company, required String dates, required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(role, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(dates, style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
        Text(company, style: const TextStyle(color: Color(0xFF4CAAC9), fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(height: 4),
        Text(description, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
      ],
    );
  }

  Widget _buildEducationItem({required String degree, required String institution, required String dates}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.school, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(degree, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(institution, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            ],
          ),
        ),
        Text(dates, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF7FC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4CAAC9).withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF2C3E50), fontWeight: FontWeight.w600),
      ),
    );
  }
}