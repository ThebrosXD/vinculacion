import 'package:flutter/material.dart';

class OfertasTrabajoModel {
  final String cargo;
  final String tipoOferta;
  final DateTime expiracion;
  final String areaDepartamento;
  final String descripcion;
  final int numPostulantes;
  final TimeOfDay horarioEntrada;
  final TimeOfDay horarioSalida;
  final String? salario;
  final String modalidad;
  final String estadoVacante;
  final bool conExperiencia;

  OfertasTrabajoModel({
    required this.cargo,
    required this.tipoOferta,
    required this.expiracion,
    required this.areaDepartamento,
    required this.descripcion,
    required this.numPostulantes,
    required this.horarioEntrada,
    required this.horarioSalida,
    this.salario,
    required this.modalidad,
    required this.estadoVacante,
    required this.conExperiencia,
  });
}
