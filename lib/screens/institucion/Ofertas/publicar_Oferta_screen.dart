import 'package:flutter/material.dart';
import 'package:proto_segui/data/controllers/ofertas_trabajo_data.dart';

class PublicarOfertaScreen extends StatefulWidget {
  const PublicarOfertaScreen({super.key});

  @override
  State<PublicarOfertaScreen> createState() => _PublicarOfertaScreenState();
}

class _PublicarOfertaScreenState extends State<PublicarOfertaScreen> {
  final OfertasTrabajoData _controller = OfertasTrabajoData();

  static const Color _bg = Color(0xFFF4F6FA);
  static const Color _primary = Color(0xFF2563EB);
  static const Color _textPrimary = Color(0xFF1E293B);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSave() {
    final offer = _controller.saveOffer();
    if (offer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Por favor, completa todos los campos obligatorios (*)",
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Oferta publicada exitosamente")),
    );
    Navigator.pop(context, offer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          "Publicación de oferta",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- CARGO ---
                    _buildLabel("Cargo", required: true),
                    TextFormField(
                      controller: _controller.cargoCtrl,
                      decoration: _inputDecoration(
                        "INGRESE UNA DESCRIPCIÓN DEL LA OFERTA",
                      ),
                      validator: (v) => v!.isEmpty ? "Campo requerido" : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Tipo de Oferta", required: true),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: _controller.tipoOferta,
                                decoration: _inputDecoration("SELECCIONE"),
                                items: _controller.tiposOferta
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => _controller.tipoOferta = v,
                                validator: (v) =>
                                    v == null ? "Requerido" : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Área/Departamento", required: true),
                              TextFormField(
                                controller: _controller.areaCtrl,
                                decoration: _inputDecoration(""),
                                validator: (v) =>
                                    v!.isEmpty ? "Requerido" : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildLabel(
                      "Descripción Acerca del Empleo",
                      required: true,
                    ),
                    TextFormField(
                      controller: _controller.descCtrl,
                      maxLines: 4,
                      decoration: _inputDecoration(
                        "INGRESE UNA DESCRIPCION ACERCA DEL LA OFERTA",
                      ),
                      validator: (v) => v!.isEmpty ? "Requerido" : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                "Expiración de Publicación",
                                required: true,
                              ),
                              InkWell(
                                onTap: () => _controller.pickDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _controller.expiracion == null
                                          ? _border
                                          : _primary,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _controller.formatDate(
                                          _controller.expiracion,
                                        ),
                                        style: TextStyle(
                                          color: _controller.expiracion == null
                                              ? _textSecondary
                                              : _textPrimary,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.calendar_today_rounded,
                                        size: 18,
                                        color: _textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("# de Postulantes", required: true),
                              DropdownButtonFormField<int>(
                                value: _controller.numPostulantes,
                                decoration: _inputDecoration(""),
                                items: _controller.postulantesOpciones
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e.toString()),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    _controller.numPostulantes = v,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("Horarios Laboral", required: true),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _primary.withOpacity(0.5),
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: _primary.withOpacity(0.02),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _buildTimePicker("Entrada", true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTimePicker("Salida", false)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Salario"),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: _controller.salario,
                                decoration: _inputDecoration("SELECCIONE"),
                                items: _controller.salarios
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => _controller.salario = v,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Modalidad", required: true),
                              DropdownButtonFormField<String>(
                                value: _controller.modalidad,
                                decoration: _inputDecoration("SELECCIONE"),
                                items: _controller.modalidades
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => _controller.modalidad = v,
                                validator: (v) =>
                                    v == null ? "Requerido" : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Estado Vacante", required: true),
                              DropdownButtonFormField<String>(
                                value: _controller.estadoVacante,
                                decoration: _inputDecoration(""),
                                items: _controller.estados
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => _controller.estadoVacante = v,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: CheckboxListTile(
                              title: const Text(
                                "Con Experiencia",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              value: _controller.conExperiencia,
                              onChanged: _controller.toggleExperiencia,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              activeColor: _primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _onSave,
                        style: FilledButton.styleFrom(
                          backgroundColor: _primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Publicar Oferta",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          children: required
              ? [
                  const TextSpan(
                    text: " *",
                    style: TextStyle(color: Colors.red),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: _textSecondary),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _primary),
      ),
      errorStyle: const TextStyle(height: 0),
    );
  }

  Widget _buildTimePicker(String label, bool isEntrada) {
    final time = isEntrada
        ? _controller.horarioEntrada
        : _controller.horarioSalida;
    return InkWell(
      onTap: () => _controller.pickTime(context, isEntrada),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Text(
                  _controller.formatTime(time),
                  style: TextStyle(
                    fontSize: 13,
                    color: time == null ? _textSecondary : _textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: _textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
