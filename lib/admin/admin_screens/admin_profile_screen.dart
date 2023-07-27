import 'package:flutter/material.dart';

import 'package:honey/widgets/title_appbar.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(title: 'Інформація про нас'),
      body: const Center(
        child: Text('Профіль Адміна'),
      ),
    );
  }
}
