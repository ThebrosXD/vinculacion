import 'package:flutter/material.dart';

class CvSimulationScreen extends StatelessWidget {
  final String nombres, apellidos, nacionalidad, correo, telf, celular, ciudad, pais, fechaNac, edad;

  const CvSimulationScreen({
    super.key, required this.nombres, required this.apellidos, required this.nacionalidad, 
    required this.correo, required this.telf, required this.celular, required this.ciudad, 
    required this.pais, required this.fechaNac, required this.edad
  });

  @override
  Widget build(BuildContext context) {
    // Definimos los colores del diseño
    const Color azulLateral = Color(0xFF5B9BD5);
    const Color textoBlanco = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vista Previa PDF"),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // --- COLUMNA IZQUIERDA (BLANCA - 65%) ---
          Expanded(
            flex: 65,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: ListView(
                children: [
                  // Header
                  Text("$apellidos $nombres".toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: azulLateral)),
                  const SizedBox(height: 5),
                  const Text("DESARROLLADOR DE SOFTWARE", style: TextStyle(fontSize: 14, color: Colors.grey, letterSpacing: 2)),
                  const SizedBox(height: 10),
                  const Divider(color: azulLateral, thickness: 2),
                  const SizedBox(height: 30),

                  // Bloques
                  _buildLeftSection("FORMACION ACADÉMICA", azulLateral, [
                    _buildLeftItem("Tercer Nivel", "UNIVERSIDAD DE GUAYAQUIL", "Ingeniería en Software"),
                  ]),
                  
                  _buildLeftSection("EXPERIENCIA", azulLateral, [
                    _buildLeftItem("Desarrollador Junior", "TECH SOLUTIONS", "Ene 2024 - Presente"),
                    _buildLeftItem("Pasante TICS", "BANCO LOCAL", "Jun 2023 - Dic 2023"),
                  ]),

                  _buildLeftSection("IDIOMAS", azulLateral, [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [Text("Inglés", style: TextStyle(fontWeight: FontWeight.bold)), Text("Intermedio (B2)")],
                    )
                  ]),

                  _buildLeftSection("REFERENCIAS", azulLateral, [
                    _buildLeftItem("Ing. Pablo Moncayo", "Universidad de Guayaquil", "0993293743"),
                  ]),
                ],
              ),
            ),
          ),

          // --- COLUMNA DERECHA (AZUL - 35%) ---
          Expanded(
            flex: 35,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
              color: azulLateral,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const Text("DATOS PERSONALES", style: TextStyle(color: textoBlanco, fontWeight: FontWeight.bold, fontSize: 14)),
                    const Divider(color: textoBlanco),
                    const SizedBox(height: 15),
                    
                    _buildRightItem(Icons.public, nacionalidad, textoBlanco),
                    _buildRightItem(Icons.email, correo, textoBlanco),
                    _buildRightItem(Icons.phone, telf, textoBlanco),
                    _buildRightItem(Icons.smartphone, celular, textoBlanco),
                    _buildRightItem(Icons.location_on, "$ciudad, $pais", textoBlanco),
                    _buildRightItem(Icons.calendar_today, fechaNac, textoBlanco),
                    _buildRightItem(Icons.person, "$edad Años", textoBlanco),
              
                    const SizedBox(height: 40),
                    const Text("HABILIDADES", style: TextStyle(color: textoBlanco, fontWeight: FontWeight.bold, fontSize: 14)),
                    const Divider(color: textoBlanco),
                    const SizedBox(height: 10),
                    const Text("• Flutter / Dart", style: TextStyle(color: textoBlanco, fontSize: 11)),
                    const SizedBox(height: 5),
                    const Text("• Firebase", style: TextStyle(color: textoBlanco, fontSize: 11)),
                    const SizedBox(height: 5),
                    const Text("• Git / GitHub", style: TextStyle(color: textoBlanco, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSection(String title, Color color, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        const Divider(),
        ...children,
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildLeftItem(String title, String subtitle, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text(subtitle, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
          Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRightItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 10))),
        ],
      ),
    );
  }
}