import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'config/theme.dart';
import 'screens/auth/login_gateway_screen.dart';
=======
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:proto_segui/routes/pages.dart';
import 'package:proto_segui/routes/router.dart';
import 'utils/theme.dart';
>>>>>>> Stashed changes

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Seguimiento Graduados',
      theme: AppTheme.getTheme(),
      home: const LoginGatewayScreen(),
    );
  }
}
