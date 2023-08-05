import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:honey/admin/admin_screens/admin_main_screen.dart';
import 'package:honey/screens/user_main_screen.dart';
import 'package:honey/providers/cart.dart';
import 'package:honey/screens/auth_screen.dart';
import 'package:honey/screens/splash_screen.dart';
import 'package:honey/providers/products.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    Color backColor = const Color(0xFF1B1B1B);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
      ],
      child: MaterialApp(
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
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, userSnapshot) {
              final hasInternet =
                  userSnapshot.connectionState != ConnectionState.none;
              if (hasInternet &&
                  userSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              final user = userSnapshot.data;
              if (userSnapshot.hasData &&
                  user!.phoneNumber == '+380987332919') {
                return const AdminMainScreen();
              } else if (user != null) {
                return const UserMainScreen();
              }
              // if (userSnapshot.hasData) {
              //   // return const AdminMainScreen();
              //   // return const UserMainScreen();
              // }
              else {
                return const AuthScreen();
              }
            },
          )),
    );
  }
}
