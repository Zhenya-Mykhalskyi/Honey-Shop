import 'package:flutter/material.dart';
import 'package:honey/widgets/title_appbar.dart';
import 'package:provider/provider.dart';

import 'package:honey/admin/admin_screens/about_admin_screen.dart';
import 'package:honey/providers/cart.dart';
import 'package:honey/widgets/badge.dart';
import 'package:honey/widgets/tab_button.dart';
import '../widgets/products_grid.dart';
import 'user_profile_screen.dart';
import 'cart_screen.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen>
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
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedBottomNavBarIndex,
              children: [
                if (_selectedTabIndex == 0) const UserProfileScreen(),
                if (_selectedTabIndex == 0) const ProductsGrid(isHoney: true),
                if (_selectedTabIndex == 0) const AboutAdminScreen(),
                if (_selectedTabIndex == 1) const UserProfileScreen(),
                if (_selectedTabIndex == 1) const ProductsGrid(isHoney: false),
                if (_selectedTabIndex == 1) const AboutAdminScreen(),
              ],
            ),
          ),
        ],
      ),
      appBar: _selectedBottomNavBarIndex == 1
          ? AppBar(
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${cartProvider.totalAmountOfCart.toStringAsFixed(0)} грн',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 22,
                        ),
                      ),
                      Consumer<CartProvider>(
                        builder: (_, cart, child) => Badgee(
                          value: cart.itemCount.toString(),
                          child: child!,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CartScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          : TitleAppBar(
              title: _selectedBottomNavBarIndex == 0
                  ? 'Особистий кабінет'
                  : 'Інформація про магазин'),
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
