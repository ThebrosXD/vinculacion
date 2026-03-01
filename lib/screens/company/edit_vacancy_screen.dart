import 'package:flutter/material.dart';
import '../../models/vacancy.dart';

class EditVacancyScreen extends StatefulWidget {
  final Vacancy vacancy;

  const EditVacancyScreen({super.key, required this.vacancy});

  @override
  State<EditVacancyScreen> createState() => _EditVacancyScreenState();
}

class _EditVacancyScreenState extends State<EditVacancyScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedLocation;
  String? _selectedModality;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.vacancy.title);
    _descriptionController = TextEditingController(text: widget.vacancy.description);
    
    _selectedLocation = ["Quito", "Guayaquil", "Remoto"].contains(widget.vacancy.location) 
        ? widget.vacancy.location 
        : "Guayaquil";
    _selectedModality = ["Presencial", "Híbrido", "Remoto"].contains(widget.vacancy.modality)
        ? widget.vacancy.modality
        : "Presencial";
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Editar Vacante", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Título", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Ej. Desarrollador Backend",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            const Text("Ubicación", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              items: ["Quito", "Guayaquil", "Remoto"].map((String val) {
                return DropdownMenuItem(value: val, child: Text(val));
              }).toList(),
              onChanged: (val) => setState(() => _selectedLocation = val),
            ),
            const SizedBox(height: 20),

            const Text("Modalidad", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedModality,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              items: ["Presencial", "Híbrido", "Remoto"].map((String val) {
                return DropdownMenuItem(value: val, child: Text(val));
              }).toList(),
              onChanged: (val) => setState(() => _selectedModality = val),
            ),
            const SizedBox(height: 20),

            const Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "El trabajo consiste en...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 40),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final updatedVacancy = Vacancy(
                    id: widget.vacancy.id,
                    title: _titleController.text,
                    companyName: widget.vacancy.companyName,
                    location: _selectedLocation!,
                    modality: _selectedModality!,
                    description: _descriptionController.text,
                    rating: widget.vacancy.rating,
                    postedDate: widget.vacancy.postedDate,
                  );

                  // 1. PRIMERO mostramos mensaje
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Vacante actualizada exitosamente"))
                  );

                  // 2. LUEGO cerramos
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (context.mounted) Navigator.pop(context, updatedVacancy);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Guardar", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}