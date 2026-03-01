import 'package:flutter/material.dart';
import '../../models/vacancy.dart';
import '../../models/applicant.dart';
import 'applicant_detail_screen.dart';

class PostulantesScreen extends StatelessWidget {
  final Vacancy vacancy;

  const PostulantesScreen({
    super.key,
    required this.vacancy,
  });

  @override
  Widget build(BuildContext context) {
    // --- DATOS LOCALES (mock) ---
    final List<Applicant> localApplicants = [
      Applicant(
        id: '1',
        name: 'Angel Taffur',
        email: 'angel@gmail.com',
        skills: ['Flutter', 'Dart', 'Firebase'],
        description: 'Desarrollador con 5 años de experiencia en desarrollo móvil.',
      ),
      Applicant(
        id: '2',
        name: 'Kevin Mitnick',
        email: 'kevin@example.com',
        skills: ['Seguridad', 'Backend', 'Python'],
        description: 'Especialista en seguridad informática y desarrollo backend.',
      ),
      Applicant(
        id: '3',
        name: 'Maria Lopez',
        email: 'maria@example.com',
        skills: ['UI/UX', 'Figma', 'Prototyping'],
        description: 'Diseñadora con enfoque en experiencia de usuario.',
      ),
    ];
    // ---------------------------

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Postulantes"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          // Título de la vacante
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                vacancy.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
          ),

          // Barra de búsqueda (solo visual)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por facultad o carrera...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 10,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Lista de postulantes
          Expanded(
            child: ListView.builder(
              itemCount: localApplicants.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final applicant = localApplicants[index];

                return Card(
                  elevation: 0,
                  color: const Color(0xFFEDF7FC),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    title: Text(
                      applicant.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          applicant.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 5,
                          children: applicant.skills
                              .map(
                                (skill) => Chip(
                                  label: Text(
                                    skill,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ApplicantDetailScreen(
                            applicant: applicant,
                            vacancyTitle: vacancy.title,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
