import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:honey/providers/products.dart';
import 'package:provider/provider.dart';

import 'package:honey/admin/admin_screens/admin_orders_screen.dart';
import 'package:honey/admin/admin_screens/edit_overview_screen.dart';
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
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ProductScreen(),
    const EditOverViewScreen(),
    const AdminOrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    Color backColor = const Color(0xFF1B1B1B);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductsProvider(),
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
        // home: const EditOverViewScreen(),

        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            final hasInternet =
                userSnapshot.connectionState != ConnectionState.none;
            if (hasInternet &&
                userSnapshot.connectionState == ConnectionState.waiting) {
              // Виконуємо перевірку на присутність з'єднання з Інтернетом
              return const SplashScreen();
            }
            if (userSnapshot.hasData) {
              //if we have a token
              return Scaffold(
                body: _pages[_currentIndex],
                bottomNavigationBar: BottomNavigationBar(
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  backgroundColor: backColor,
                  iconSize: 30,
                  unselectedItemColor: const Color.fromARGB(255, 88, 88, 88),
                  selectedItemColor: const Color.fromARGB(255, 217, 217, 217),
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.home,
                      ),
                      label: 'Домашня',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.edit),
                      label: 'Редагувати',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_bag),
                      label: 'Замовлення',
                    ),
                  ],
                ),
              );
            }
            return const AuthScreen();
          },
        ),
      ),
    );
  }
}
