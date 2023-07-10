import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:honey/admin/admin_screens/admin_orders_screen.dart';
import '../../screens/products_overview_screen.dart';
import 'edit_overview_screen.dart';

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
                if (_selectedTabIndex == 0) const AdminOrdersScreen(),
                if (_selectedTabIndex == 1) const ProductGrid(isHoney: false),
                if (_selectedTabIndex == 1)
                  const EditOverViewScreen(isHoney: false),
                if (_selectedTabIndex == 1) const AdminOrdersScreen(),
              ],
            ),
          ),
        ],
      ),
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
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
                : null,
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
      // body: TabBarView(
      //   controller: _tabController,
      //   children: [
      //     activeIndex == 0
      //         ? const ProductGrid(
      //             isHoney: true,
      //           )
      //         : const ProductGrid(
      //             isHoney: false,
      //           ),
      //   ],
      // ),
    );
  }
}
