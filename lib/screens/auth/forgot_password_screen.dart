import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Título "Contraseña" [cite: 119]
            const SizedBox(height: 10),
            const Text(
              "Contraseña",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 40),

            // 2. Ilustración (Simulada con Iconos) [cite: 122]
            // En el PDF se ve una persona con un signo de interrogación
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Container(
                     width: 120,
                     height: 120,
                     decoration: BoxDecoration(
                       color: Colors.grey[200],
                       shape: BoxShape.circle,
                     ),
                     child: const Icon(Icons.person, size: 80, color: Color(0xFF2C3E50)),
                   ),
                   const Positioned(
                     top: 0,
                     right: 80,
                     child: Icon(Icons.question_mark, size: 50, color: Color(0xFF5DADE2)),
                   ),
                   // Simulación de los puntitos de contraseña del dibujo
                   Positioned(
                     right: 40,
                     top: 40,
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(10),
                         border: Border.all(color: Colors.grey.shade300)
                       ),
                       child: const Text("••••", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                     ),
                   )
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 3. Texto de instrucción [cite: 123]
            const Text(
              "Ingrese su correo electrónico para\nrecuperar su contraseña.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),

            const SizedBox(height: 30),

            // 4. Input de Correo [cite: 125, 126]
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Correo Electrónico", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "angel@example.com",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // 5. Botón Recuperar [cite: 127]
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  _showCheckEmailDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  "Recuperar contraseña",
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Diálogo de éxito ("Revise su Correo Electrónico") [cite: 129, 130]
  void _showCheckEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mail_outline, size: 50, color: Colors.black87),
            const SizedBox(height: 16),
            const Text(
              "Revise su Correo Electrónico",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra diálogo
                  Navigator.pop(context); // Regresa al Login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B2631),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Aceptar", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}