import 'package:flutter/material.dart';

class CvSimulationScreen extends StatelessWidget {
  final String nombres, apellidos, nacionalidad, correo;
  final String cedula, telf, celular, ciudad, pais, fechaNac, edad;

  const CvSimulationScreen({
    super.key,
    required this.nombres,
    required this.apellidos,
    required this.nacionalidad,
    required this.correo,
    required this.cedula,
    required this.telf,
    required this.celular,
    required this.ciudad,
    required this.pais,
    required this.fechaNac,
    required this.edad,
  });

  @override
  Widget build(BuildContext context) {
    const Color azulCabecera = Color(0xFF1CB1DA);
    const Color azulLateral = Color(0xFF0F98C3);
    const Color textoBlanco = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vista Previa PDF"),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // Cabecera Azul Superior Izquierda (Nombre y Título)
          Expanded(
            flex: 65,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: azulCabecera,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$apellidos $nombres".toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textoBlanco,
                            letterSpacing: 1.1,
                          ),
                        ),

                        // const SizedBox(height: 5),
                        // const Text(
                        //   "CIENCIAS MATEMÁTICAS Y FÍSICAS - SOFTWARE",
                        //   style: TextStyle(
                        //     fontSize: 11,
                        //     color: textoBlanco,
                        //     letterSpacing: 1.2,
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        // Secciones de contenido principal
                        _buildLeftSection("FORMACIÓN ACADÉMICA", azulLateral, [
                          _buildLeftItem(
                            "Tercer Nivel",
                            "UNIVERSIDAD DE GUAYAQUIL",
                            "Ingeniería en Software / Ciencias Matemáticas y Físicas",
                          ),
                        ]),

                        _buildLeftSection("EXPERIENCIA", azulLateral, [
                          _buildLeftItem(
                            "Desarrollador / Puesto",
                            "NOMBRE DE LA EMPRESA",
                            "Fecha Inicio - Fecha Fin",
                          ),
                        ]),

                        _buildLeftSection("IDIOMAS", azulLateral, [
                          // Estructura de tabla para los idiomas basada en el PDF
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2.5),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1.5),
                            },
                            children: [
                              const TableRow(
                                children: [
                                  Text(
                                    "Idioma",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    "Escritura",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    "Lectura",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    "Conversación",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "Inglés",
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                  _buildTableValueCell("Medio"),
                                  _buildTableValueCell("Alto"),
                                  _buildTableValueCell("Medio"),
                                ],
                              ),
                            ],
                          ),
                        ]),

                        _buildLeftSection("REFERENCIAS", azulLateral, [
                          _buildLeftItem(
                            "Nombre de Referencia",
                            "Institución / Empresa",
                            "Teléfono de contacto",
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // COLUMNA DERECHA FOTO
          Expanded(
            flex: 35,
            child: Container(
              color: azulLateral,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 120,
                    color: azulCabecera,
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: textoBlanco, width: 1),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "DATOS PERSONALES",
                            style: TextStyle(
                              color: textoBlanco,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Divider(color: textoBlanco, thickness: 1),
                          const SizedBox(height: 15),

                          _buildRightItem(
                            Icons.public,
                            nacionalidad,
                            textoBlanco,
                          ),
                          _buildRightItem(Icons.email, correo, textoBlanco),
                          _buildRightItem(
                            Icons.smartphone,
                            celular,
                            textoBlanco,
                          ),
                          if (cedula.isNotEmpty)
                            _buildRightItem(Icons.badge, cedula, textoBlanco),
                          if (telf.isNotEmpty)
                            _buildRightItem(Icons.phone, telf, textoBlanco),
                          _buildRightItem(
                            Icons.location_on,
                            "$ciudad, $pais",
                            textoBlanco,
                          ),
                          if (fechaNac.isNotEmpty)
                            _buildRightItem(
                              Icons.calendar_today,
                              fechaNac,
                              textoBlanco,
                            ),
                          if (edad.isNotEmpty)
                            _buildRightItem(
                              Icons.person,
                              "$edad Años",
                              textoBlanco,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
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
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF003366),
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 5),
        const Divider(color: Colors.grey, thickness: 0.5),
        const SizedBox(height: 10),
        ...children,
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildLeftItem(String title, String subtitle, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTableValueCell(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildRightItem(IconData icon, String text, Color color) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 10, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
