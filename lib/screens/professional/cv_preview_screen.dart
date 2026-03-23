import 'package:flutter/material.dart';

class CvPreviewScreen extends StatelessWidget {
  final String name;

  const CvPreviewScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    const Color darkColor = Color(0xFF2C3E50);
    const Color accentColor = Color(0xFF4CAAC9);

    return Scaffold(
      backgroundColor: Colors.grey[200],
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
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(35.0),
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
                Text(
                  name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "CIENCIAS MATEMÁTICAS Y FÍSICAS - SOFTWARE",
                  style: TextStyle(
                    fontSize: 14,
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 15),

                //  DATOS PERSONALES
                Wrap(
                  spacing: 15,
                  runSpacing: 8,
                  children: [
                    _buildContactRow(Icons.badge, "0941492829"),
                    _buildContactRow(Icons.public, "Ecuatoriana"),
                    _buildContactRow(Icons.email, "allan.garciadec@ug.edu.ec"),
                    _buildContactRow(Icons.smartphone, "0998944795"),
                    _buildContactRow(Icons.phone, "4605599"),
                    _buildContactRow(Icons.location_on, "Guayaquil, Ecuador"),
                    _buildContactRow(Icons.cake, "2003-02-25 (23 Años)"),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(thickness: 2, color: Colors.grey),
                const SizedBox(height: 20),

                _buildSectionTitle("FORMACIÓN ACADÉMICA", darkColor),
                const SizedBox(height: 15),
                _buildEducationItem(
                  degree: "Tercer Nivel - Software",
                  institution: "Universidad de Guayaquil",
                  dates: "Periodo Académico",
                ),

                const SizedBox(height: 25),

                _buildSectionTitle("EXPERIENCIA", darkColor),
                const SizedBox(height: 15),
                const Text(
                  "Detalla aquí tu experiencia profesional...",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 25),

                _buildSectionTitle("IDIOMAS", darkColor),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLangColumn("Idioma", "Inglés", isHeader: true),
                      _buildLangColumn("Escritura", "Medio", isHeader: true),
                      _buildLangColumn("Lectura", "Alto", isHeader: true),
                      _buildLangColumn("Conversación", "Medio", isHeader: true),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // --- REFERENCIAS ---
                _buildSectionTitle("REFERENCIAS", darkColor),
                const SizedBox(height: 15),
                const Text(
                  "Añade tus referencias laborales o personales aquí.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          color: const Color(0xFF4CAAC9),
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
      ],
    );
  }

  Widget _buildEducationItem({
    required String degree,
    required String institution,
    required String dates,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.school, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                degree,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                institution,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ),
        Text(dates, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildLangColumn(
    String header,
    String value, {
    bool isHeader = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isHeader ? Colors.black87 : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
      ],
    );
  }
}
