import 'package:flutter/material.dart';
import '../../models/ofertas_trabajo_model.dart';
import 'package:intl/intl.dart';

class OfertasTrabajoData extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController cargoCtrl = TextEditingController();
  final TextEditingController areaCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  String? tipoOferta;
  DateTime? expiracion;
  int? numPostulantes = 1;
  TimeOfDay? horarioEntrada;
  TimeOfDay? horarioSalida;
  String? salario;
  String? modalidad;
  String? estadoVacante = "Disponible";
  bool conExperiencia = false;

  final List<String> tiposOferta = [
    "Pasantía",
    "Práctica Pre Profesional",
    "Empleo Fijo",
    "Ayudantía",
  ];
  final List<int> postulantesOpciones = [1, 2, 3, 4, 5, 10, 20, 50];
  final List<String> salarios = [
    "No remunerado",
    "Básico (\$460)",
    "\$500 - \$800",
    "+\$800",
  ];
  final List<String> modalidades = ["Presencial", "Remoto", "Híbrido"];
  final List<String> estados = ["Disponible", "Pausada", "Cerrada"];

  @override
  void dispose() {
    cargoCtrl.dispose();
    areaCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  void toggleExperiencia(bool? value) {
    conExperiencia = value ?? false;
    notifyListeners();
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      expiracion = picked;
      notifyListeners();
    }
  }

  Future<void> pickTime(BuildContext context, bool isEntrada) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isEntrada
          ? const TimeOfDay(hour: 8, minute: 0)
          : const TimeOfDay(hour: 17, minute: 0),
    );
    if (picked != null) {
      if (isEntrada) {
        horarioEntrada = picked;
      } else {
        horarioSalida = picked;
      }
      notifyListeners();
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return "dd/mm/aaaa";
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return "--:--";
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  OfertasTrabajoModel? saveOffer() {
    if (!formKey.currentState!.validate()) return null;
    if (expiracion == null || horarioEntrada == null || horarioSalida == null)
      return null;

    return OfertasTrabajoModel(
      cargo: cargoCtrl.text.trim(),
      tipoOferta: tipoOferta!,
      expiracion: expiracion!,
      areaDepartamento: areaCtrl.text.trim(),
      descripcion: descCtrl.text.trim(),
      numPostulantes: numPostulantes!,
      horarioEntrada: horarioEntrada!,
      horarioSalida: horarioSalida!,
      salario: salario,
      modalidad: modalidad!,
      estadoVacante: estadoVacante!,
      conExperiencia: conExperiencia,
    );
  }
}
