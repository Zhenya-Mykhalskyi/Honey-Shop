import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:honey/providers/theme_provider.dart';
import 'package:honey/providers/products_provider.dart';
import 'package:honey/providers/cart_provider.dart';
import 'package:honey/admin/admin_screens/admin_main_screen.dart';
import 'package:honey/screens/user_main_screen.dart';
import 'package:honey/screens/auth_screen.dart';
import 'package:honey/screens/splash_screen.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: MyThemes.lightTheme,
          darkTheme: MyThemes.darkTheme,
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
              if (userSnapshot.hasData) {
                if (user!.phoneNumber == '+380987332919') {
                  return const AdminMainScreen();
                } else {
                  return const UserMainScreen();
                }
              } else {
                return const AuthScreen();
              }
            },
          ),
        );
      }),
    );
  }
}
