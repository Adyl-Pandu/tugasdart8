import 'package:firebase_core/firebase_core.dart'; 
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'pages/splash_page.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Latihan Firebase',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo, 
      ),
      home: const SplashPage(), 
    );
  }
}