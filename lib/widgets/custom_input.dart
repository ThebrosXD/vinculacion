import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final bool isPassword;
  final TextInputType keyboardType;

  const CustomInput({
    super.key, 
    required this.label, 
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          obscureText: isPassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: label, // Opcional
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}