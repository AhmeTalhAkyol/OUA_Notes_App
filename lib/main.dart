import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oua_notes_app/auth/login_or_register.dart';
import 'package:oua_notes_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginOrRegister(),
    );
  }
}
