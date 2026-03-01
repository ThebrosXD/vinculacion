import '../models/vacancy.dart';
import '../models/applicant.dart';

final List<Vacancy> dummyVacancies = [
  Vacancy(
    id: '1',
    title: 'Desarrollador Backend',
    companyName: 'Bangara S.A',
    location: 'Guayaquil, Guayas',
    modality: 'Presencial',
    description: 'Te apasiona la tecnología y tienes experiencia en desarrollo backend...',
    rating: 4.2,
    postedDate: 'Hace 3 días',
  ),
  Vacancy(
    id: '2',
    title: 'Analista de Datos',
    companyName: 'Banco Pichincha',
    location: 'Quito, Pichincha',
    modality: 'Híbrido',
    description: 'Buscamos un experto en análisis de datos financieros...',
    rating: 4.5,
    postedDate: 'Hace 1 día',
  ),
  Vacancy(
    id: '3',
    title: 'Desarrollador Flutter',
    companyName: 'DevSolutions',
    location: 'Remoto',
    modality: 'Remoto',
    description: 'Creación de aplicaciones móviles multiplataforma...',
    rating: 4.8,
    postedDate: 'Hace 5 días',
  ),
];
final List<Applicant> dummyApplicants = [
  Applicant(
    id: '1',
    name: 'Angel Taffur',
    email: 'angel@gmail.com',
    skills: ['Flutter', 'Dart', 'Firebase'],
    description: 'Desarrollador con 5 años de experiencia en desarrollo móvil...',
  ),
  Applicant(
    id: '2',
    name: 'Kevin Mitnick',
    email: 'kevin@example.com',
    skills: ['Seguridad', 'Backend', 'Python'],
    description: 'Especialista en seguridad informática y desarrollo backend...',
  ),
];