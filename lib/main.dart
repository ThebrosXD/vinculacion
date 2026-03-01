import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/auth/login_gateway_screen.dart';

void main() {
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
