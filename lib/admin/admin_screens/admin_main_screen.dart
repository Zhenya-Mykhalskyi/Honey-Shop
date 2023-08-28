import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:honey/admin/admin_widgets/cashback_form_dialog.dart';
import 'package:honey/widgets/badge.dart';
import 'package:honey/widgets/products_grid.dart';
import 'package:honey/widgets/tab_button.dart';
import 'package:honey/widgets/title_appbar.dart';
import 'admin_profile_screen.dart';
import 'admin_orders_screen.dart';
import 'edit_products_overview_screen.dart';
import 'admin_profile_edit_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  int _selectedBottomNavBarIndex = 0;
  int _unfinishedOrderCount = 0;

  @override
  void initState() {
    _countUnfinishedOrders();
    super.initState();
  }

  Future<void> _countUnfinishedOrders() async {
    FirebaseFirestore.instance
        .collection('orders')
        .where('isFinished', isEqualTo: false)
        .where('isVisibleForAdmin', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _unfinishedOrderCount = snapshot.docs.length;
        });
      }
    });
  }

  void _onBottomNavBarTapped(int index) {
    setState(() {
      _selectedBottomNavBarIndex = index;
      _selectedTabIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData currentTheme = Theme.of(context);
    return Scaffold(
      appBar: _selectedBottomNavBarIndex == 2
          ? TitleAppBar(
              title: 'Замовлення',
              showIconButton: true,
              icon: Icons.ballot_outlined,
              action: () {
                showDialog(
                    context: context,
                    builder: (context) => const CashbackFormDialog());
              },
            )
          : AppBar(
              toolbarHeight: 100,
              elevation: 0,
              leadingWidth: 93,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
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
                  ),
                ),
              ),
              leading: Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 10),
                child: Image.asset('./assets/img/logo.png'),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: IconButton(
                      icon: Icon(
                        _selectedBottomNavBarIndex == 0
                            ? Icons.person
                            : Icons.edit_note_outlined,
                        size: 35,
                        color: currentTheme.primaryColor,
                      ),
                      onPressed: _selectedBottomNavBarIndex == 1
                          ? () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const AdminProfileEditScreen(),
                              ));
                            }
                          : () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const AdminProfileScreen(),
                              ));
                            }),
                )
              ],
            ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedBottomNavBarIndex,
              children: [
                if (_selectedTabIndex == 0) const ProductsGrid(isHoney: true),
                if (_selectedTabIndex == 0)
                  const EditProductsOverviewScreen(isHoney: true),
                if (_selectedTabIndex == 0) const AdminOrdersScreen(),
                if (_selectedTabIndex == 1) const ProductsGrid(isHoney: false),
                if (_selectedTabIndex == 1)
                  const EditProductsOverviewScreen(isHoney: false),
                if (_selectedTabIndex == 1) const AdminOrdersScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 30,
        currentIndex: _selectedBottomNavBarIndex,
        onTap: _onBottomNavBarTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Домашня',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Редагувати',
          ),
          BottomNavigationBarItem(
            icon: Badgee(
              value: _unfinishedOrderCount.toString(),
              child: const Padding(
                  padding: EdgeInsets.only(right: 5, top: 5),
                  child: Icon(
                    Icons.shopping_bag,
                  )),
            ),
            label: 'Замовлення',
          ),
        ],
      ),
    );
  }
}
