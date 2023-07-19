import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:honey/admin/admin_screens/about_admin_screen.dart';
import 'package:honey/screens/user_profile_screen.dart';
import '../../screens/products_grid.dart';

class TabButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onPressed;

  const TabButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? const Color.fromARGB(255, 255, 179, 0)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isActive ? Colors.transparent : Colors.white, width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'MA',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<UserMainScreen>
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
                if (_selectedTabIndex == 0) const UserProfileScreen(),
                if (_selectedTabIndex == 0) const ProductGrid(isHoney: true),
                if (_selectedTabIndex == 0) const AboutAdminScreen(),
                // if (_selectedTabIndex == 0)
                //   const EditOverViewScreen(isHoney: true),
                // if (_selectedTabIndex == 0) const AdminOrdersScreen(),
                if (_selectedTabIndex == 1) const UserProfileScreen(),
                if (_selectedTabIndex == 1) const ProductGrid(isHoney: false),
                // if (_selectedTabIndex == 1)
                //   const EditOverViewScreen(isHoney: false),
                // if (_selectedTabIndex == 1) const AdminOrdersScreen(),
                if (_selectedTabIndex == 1) const AboutAdminScreen(),
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
            child: _selectedBottomNavBarIndex == 1
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
              Icons.person_outlined,
            ),
            label: 'Профіль',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Головна',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Про магазин',
          ),
        ],
      ),
    );
  }
}
