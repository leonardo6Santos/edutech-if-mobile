import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper.instance.database;
  runApp(const EduTechIfApp());
}

class EduTechIfApp extends StatelessWidget {
  const EduTechIfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduTechIF Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1B5E20),
      ),
      home: const LoginScreen(),
    );
  }
}