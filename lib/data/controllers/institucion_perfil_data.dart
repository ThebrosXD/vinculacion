import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:proto_segui/models/institucion_perfil.dart';

class InstitucionPerfilData extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final razonSocialCtrl = TextEditingController();
  final rucCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final correoAltCtrl = TextEditingController();
  final telConvCtrl = TextEditingController();
  final celularCtrl = TextEditingController();
  final repNombreCtrl = TextEditingController();
  final repCargoCtrl = TextEditingController();
  final repTelefonoCtrl = TextEditingController();
  final paisCtrl = TextEditingController();
  final provinciaCtrl = TextEditingController();
  final ciudadCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();

  String? tipoInstitucion;
  String? sectorEconomico;
  String? pais;

  String? logoFileName;
  String? rucFileName;

  final Set<String> expandedSections = {"institucion", "contacto", "direccion"};

  final List<String> tiposInstitucion = ["Pública", "Privada"];
  final List<String> sectores = [
    "Tecnología",
    "Finanzas",
    "Educación",
    "Salud",
    "Comercio",
    "Otro",
  ];
  final List<String> paises = ["Ecuador", "Colombia", "Perú", "Otro"];

  void toggleSection(String section) {
    if (expandedSections.contains(section)) {
      expandedSections.remove(section);
    } else {
      expandedSections.add(section);
    }
    notifyListeners();
  }

  void initData(InstitucionPerfil? initialData) {
    if (initialData == null) return;
    razonSocialCtrl.text = initialData.razonSocial;
    rucCtrl.text = initialData.ruc;
    correoCtrl.text = initialData.correo;
    correoAltCtrl.text = initialData.correoAlterno;
    telConvCtrl.text = initialData.telefonoConvencional;
    celularCtrl.text = initialData.celular;
    repNombreCtrl.text = initialData.representanteContacto;
    repCargoCtrl.text = initialData.cargoRepresentante;
    repTelefonoCtrl.text = initialData.telefonoRepresentante;
    provinciaCtrl.text = initialData.provincia;
    ciudadCtrl.text = initialData.ciudad;
    direccionCtrl.text = initialData.direccion;

    tipoInstitucion = initialData.tipoInstitucion;
    sectorEconomico = initialData.sectorEconomico;
    pais = initialData.pais;
  }

  @override
  void dispose() {
    razonSocialCtrl.dispose();
    rucCtrl.dispose();
    correoCtrl.dispose();
    correoAltCtrl.dispose();
    telConvCtrl.dispose();
    celularCtrl.dispose();
    repNombreCtrl.dispose();
    repCargoCtrl.dispose();
    repTelefonoCtrl.dispose();
    paisCtrl.dispose();
    provinciaCtrl.dispose();
    ciudadCtrl.dispose();
    direccionCtrl.dispose();
    super.dispose();
  }

  Future<void> pickLogo() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res != null && res.files.isNotEmpty) {
      logoFileName = res.files.single.name;
      notifyListeners();
    }
  }

  Future<void> pickRucFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg'],
    );
    if (res != null && res.files.isNotEmpty) {
      rucFileName = res.files.single.name;
      notifyListeners();
    }
  }

  void saveProfile(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) return;

    if (tipoInstitucion == null || sectorEconomico == null || pais == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa los campos desplegables.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Perfil actualizado correctamente ✅")),
    );
    Navigator.pop(context);
  }
}
