import 'package:flutter/material.dart';
import 'package:honey/admin/admin_screens/admin_profile_edit_screen.dart';
import 'package:honey/admin/admin_widgets/cashback_form_dialog.dart';

import 'package:honey/widgets/products_grid.dart';
import 'package:honey/widgets/tab_button.dart';
import 'admin_profile_screen.dart';
import 'admin_orders_screen.dart';
import 'edit_products_overview_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  int _selectedBottomNavBarIndex = 1;

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
      appBar: AppBar(
        toolbarHeight: _selectedBottomNavBarIndex != 2 ? 100 : 70,
        elevation: 0,
        leadingWidth: 93,
        title: _selectedBottomNavBarIndex == 2
            ? const Text('Замовлення',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24))
            : null,
        bottom: PreferredSize(
          preferredSize:
              Size.fromHeight(_selectedBottomNavBarIndex == 2 ? 0 : 30),
          child: Padding(
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
        leading: _selectedBottomNavBarIndex != 2
            ? Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 10),
                child: Image.asset('./assets/img/logo.png'),
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
                icon: Icon(
                  _selectedBottomNavBarIndex == 0
                      ? Icons.person
                      : _selectedBottomNavBarIndex == 1
                          ? Icons.edit_note_outlined
                          : Icons.ballot_outlined,
                  size: 35,
                  color: Colors.white,
                ),
                onPressed: _selectedBottomNavBarIndex == 2
                    ? () {
                        showDialog(
                            context: context,
                            builder: (context) => const CashbackForm());
                      }
                    : _selectedBottomNavBarIndex == 1
                        ? () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const AdminProfileEditScreen(),
                            ));
                          }
                        : () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const AdminProfileScreen(),
                            ));
                          }),
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


// child: DropdownButton(
//               underline: Container(),
//               icon: const Icon(
//                 Icons.person,
//                 color: Colors.white,
//                 size: 40,
//               ),
//               items: const [
//                 DropdownMenuItem(
//                   value: 'logout',
//                   child: Row(
//                     children: [
//                       Icon(Icons.exit_to_app),
//                       SizedBox(width: 8),
//                       Text(
//                         'Logout',
//                         style: TextStyle(color: Colors.black),
//                       )
//                     ],
//                   ),
//                 )
//               ],
//               onChanged: (itemIdentifier) {
//                 if (itemIdentifier == 'logout') {
//                   FirebaseAuth.instance.signOut();
//                 }
//               },
//             ),
