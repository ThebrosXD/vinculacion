import 'package:flutter/material.dart';
import '../../models/company.dart';

class CompanyDetailScreen extends StatefulWidget {
  final Company company;

  const CompanyDetailScreen({super.key, required this.company});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  double _userRating = 0; // Para guardar la calificación seleccionada

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Empresa"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera Empresa
            Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: const BoxDecoration(color: Colors.blueGrey, shape: BoxShape.circle),
                  child: Center(
                    child: Text(widget.company.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.company.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        Text(widget.company.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),

            // Detalles (Pág 19) [cite: 366-369]
            _buildInfoRow("Industria:", widget.company.industry),
            const SizedBox(height: 10),
            _buildInfoRow("Ubicación:", widget.company.location),
            const SizedBox(height: 24),

            // Descripción [cite: 370]
            const Text("Descripción:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(widget.company.description, style: const TextStyle(color: Colors.black87, height: 1.5)),
            
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            // SECCIÓN CALIFICACIÓN (Pág 20) [cite: 408-416]
            const Text("Calificación", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            
            // Estrellas interactivas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _userRating = index + 1;
                    });
                  },
                  icon: Icon(
                    index < _userRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                _userRating > 0 ? "Has calificado con $_userRating estrellas" : "Toca las estrellas para calificar",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Botón Calificar [cite: 411]
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _userRating > 0 ? () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Calificación enviada!")));
                  Navigator.pop(context);
                } : null, // Deshabilitado si no ha seleccionado estrellas
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Calificar", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        Text(value, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }
}