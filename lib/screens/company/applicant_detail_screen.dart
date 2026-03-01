import 'package:flutter/material.dart';
import 'package:proto_segui/screens/professional/cv_preview_screen.dart';
import '../../models/applicant.dart';

class ApplicantDetailScreen extends StatelessWidget {
  final Applicant applicant;
  final String vacancyTitle;

  const ApplicantDetailScreen({
    super.key, 
    required this.applicant, 
    required this.vacancyTitle
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Postulante ${applicant.name}"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Foto grande
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person_outline, size: 60, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Campo "Vacante a la que aplica" [cite: 633]
            _buildReadOnlyField("Vacante a la que aplica", vacancyTitle),
            const SizedBox(height: 20),

            // Campo "Descripción del Postulante" [cite: 635]
            _buildReadOnlyField("Descripción del Postulante", applicant.description, maxLines: 3),
            
            const SizedBox(height: 40),

            // Botones de Acción [cite: 637-639]
            _buildActionButton("Descargar CV", const Color(0xFF2C3E50), Colors.white, () {
                // Navegar a la previsualización
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CvPreviewScreen(name: applicant.name),
                  ),
                );
            }),
            const SizedBox(height: 12),
            _buildActionButton("Aceptar", const Color(0xFFFFF9C4), Colors.black, () {
               // Lógica para aceptar
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Candidato Aceptado")));
               Navigator.pop(context); // Regresa a la lista
            }),
            const SizedBox(height: 12),
            _buildActionButton("Rechazar", const Color(0xFFEF9A9A), Colors.black, () {
               // Lógica para rechazar
               Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(value, maxLines: maxLines, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, Color bg, Color textCol, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: textCol,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.black12),
          ),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}