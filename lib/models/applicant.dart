class Applicant {
  final String id;
  final String name;
  final String email;
  final List<String> skills; // "Temas" según el PDF
  final String description;

  Applicant({
    required this.id,
    required this.name,
    required this.email,
    required this.skills,
    required this.description,
  });
}