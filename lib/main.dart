import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:honey/admin/admin_screens/products_edit_screen.dart';
import 'package:honey/screens/auth_screen.dart';
import 'package:honey/screens/products_overview_screen.dart';
import 'package:honey/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Color backColor = const Color(0xFF1B1B1B);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(backgroundColor: backColor),
        scaffoldBackgroundColor: backColor,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Colors.white, fontFamily: 'MA'),
          headlineMedium: TextStyle(color: Colors.white, fontFamily: 'MA'),
          headlineSmall: TextStyle(color: Colors.white, fontFamily: 'MA'),
          titleLarge: TextStyle(color: Colors.white, fontFamily: 'MA'),
          titleMedium: TextStyle(color: Colors.white, fontFamily: 'MA'),
          titleSmall: TextStyle(color: Colors.white, fontFamily: 'MA'),
          bodyLarge: TextStyle(color: Colors.white, fontFamily: 'MA'),
          bodyMedium: TextStyle(color: Colors.white, fontFamily: 'MA'),
          bodySmall: TextStyle(color: Colors.white, fontFamily: 'MA'),
        ),
      ),
      home: ProductsEditScreen(),

      // StreamBuilder(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (ctx, userSnapshot) {
      //     if (userSnapshot.connectionState == ConnectionState.waiting) {
      //       return SplashScreen();
      //     }
      //     if (userSnapshot.hasData) {
      //       //if we have a token
      //       return ProductScreen();
      //     }
      //     return AuthScreen();
      //   },
      // ),
    );
  }
}
