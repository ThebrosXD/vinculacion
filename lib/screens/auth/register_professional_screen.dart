import 'package:flutter/material.dart';

class RegisterProfessionalScreen extends StatelessWidget {
  const RegisterProfessionalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco como en el diseño
      appBar: AppBar(
        title: const Text(
          "Registro", 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ), 
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            // Campos del formulario según Página 3 [cite: 20-29]
            _buildTextField(label: "Nombre", hint: "Angel"),
            const SizedBox(height: 16),
            
            _buildTextField(
              label: "Cédula de Identidad", 
              hint: "1234567890", 
              keyboardType: TextInputType.number
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              label: "Teléfono", 
              hint: "0987654321", 
              keyboardType: TextInputType.phone
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              label: "Correo", 
              hint: "angel@example.com", 
              keyboardType: TextInputType.emailAddress
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              label: "Contraseña", 
              hint: "***********", 
              isPassword: true
            ),

            const SizedBox(height: 40),

            // Botón Registrar [cite: 30]
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Al hacer clic, mostramos el mensaje de éxito [cite: 32]
                  _showSuccessDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50), // Color oscuro del botón
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text(
                  "Registrar", 
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Enlace al Login [cite: 31]
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: RichText(
                text: const TextSpan(
                  text: "¿Ya tienes una cuenta? ",
                  style: TextStyle(color: Colors.black54),
                  children: [
                    TextSpan(
                      text: "Inicia sesión",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para los campos de texto
  Widget _buildTextField({
    required String label, 
    required String hint, 
    bool isPassword = false, 
    TextInputType keyboardType = TextInputType.text
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
          child: Text(
            label, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
          ),
        ),
        TextField(
          obscureText: isPassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // Modal de éxito tal como se muestra al final de la Página 3 [cite: 34]
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Obliga al usuario a dar clic en Aceptar
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            // Icono de usuario o check
            const Icon(Icons.person_outline, size: 48, color: Colors.black87),
            const SizedBox(height: 16),
            // Mensaje [cite: 34]
            const Text(
              "Registrado exitosamente",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Botón Aceptar [cite: 34]
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el diálogo
                  Navigator.pop(context); // Regresa a la pantalla de Login [cite: 35]
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B2631), // Color casi negro del modal
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