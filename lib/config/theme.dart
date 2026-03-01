import 'package:flutter/material.dart';

class AppTheme {
  // Color aproximado extraído de los botones del PDF (ej. Login [cite: 2])
  static const Color primaryColor = Color(0xFF2C3E50); 
  static const Color secondaryColor = Color(0xFF4CAAC9); // Tonos azul claro del logo
  
  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primaryColor,
      scaffoldBackgroundColor: Colors.grey[50], // Fondo claro visto en las pantallas
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(double.infinity, 50), // Botones anchos como en el diseño [cite: 32]
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}