import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:honey/screens/cart_screen.dart';
import 'package:honey/screens/products_grid.dart';
import 'package:honey/widgets/tab_button.dart';
import 'edit_overview_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  int _selectedBottomNavBarIndex = 0;

  void _onBottomNavBarTapped(int index) {
    setState(() {
      _selectedBottomNavBarIndex = index;
      _selectedTabIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedBottomNavBarIndex,
              children: [
                if (_selectedTabIndex == 0) const ProductGrid(isHoney: true),
                if (_selectedTabIndex == 0)
                  const EditOverViewScreen(isHoney: true),
                // if (_selectedTabIndex == 0) const AdminOrdersScreen(),
                if (_selectedTabIndex == 0) const CartScreen(),
                if (_selectedTabIndex == 1) const ProductGrid(isHoney: false),
                if (_selectedTabIndex == 1)
                  const EditOverViewScreen(isHoney: false),
                // if (_selectedTabIndex == 1) const AdminOrdersScreen(),
                if (_selectedTabIndex == 1) const CartScreen(),
              ],
            ),
          ),
        ],
      ),
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize:
              Size.fromHeight(_selectedBottomNavBarIndex == 2 ? 0 : 50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: _selectedBottomNavBarIndex != 2
                ? Row(
                    children: [
                      TabButton(
                        text: 'мед',
                        isActive: _selectedTabIndex == 0,
                        onPressed: () {
                          setState(() {
                            _selectedTabIndex = 0;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      TabButton(
                        text: 'інше',
                        isActive: _selectedTabIndex == 1,
                        onPressed: () {
                          setState(() {
                            _selectedTabIndex = 1;
                          });
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        toolbarHeight: 100,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 20, top: 20),
          child: Image.asset('./assets/img/logo.png'),
        ),
        leadingWidth: 95,
        actions: [
          Container(
            margin: const EdgeInsets.only(top: 35, right: 10),
            child: DropdownButton(
              underline: Container(),
              icon: const Icon(
                Icons.person,
                color: Colors.white,
                size: 40,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                )
              ],
              onChanged: (itemIdentifier) {
                if (itemIdentifier == 'logout') {
                  FirebaseAuth.instance.signOut();
                }
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: const Color(0xFF1B1B1B),
        iconSize: 30,
        unselectedItemColor: const Color.fromARGB(255, 88, 88, 88),
        selectedItemColor: const Color.fromARGB(255, 217, 217, 217),
        currentIndex: _selectedBottomNavBarIndex,
        onTap: _onBottomNavBarTapped,
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
}
