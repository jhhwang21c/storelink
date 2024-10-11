import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:storelink/pages/find.dart';
import 'package:storelink/pages/landing.dart';
import 'package:storelink/pages/lend.dart';
import 'package:storelink/pages/signup.dart';
import 'firebase_options.dart';

void main() async {
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
      title: 'StoreLink',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(),
        '/signup': (context) => SignUpPage(),
        '/find': (context) => FindStoragePage(),
        '/lend': (context) => LendStoragePage(),
      },
    );
  }
}
