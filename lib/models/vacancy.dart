// Archivo: lib/models/vacancy.dart
class Vacancy {
  final String id;
  final String title;
  final String companyName;
  final String location;
  final String modality;
  final String description;
  final double rating;
  final String postedDate;

  Vacancy({
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.modality,
    required this.description,
    required this.rating,
    required this.postedDate,
  });
}