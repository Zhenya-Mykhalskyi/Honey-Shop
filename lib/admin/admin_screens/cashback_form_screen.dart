import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_main_screen.dart';
import 'package:honey/services/check_internet_connection.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/custom_button.dart';

class CashbackScreen extends StatefulWidget {
  const CashbackScreen({super.key});

  @override
  _CashbackScreenState createState() => _CashbackScreenState();
}

class _CashbackScreenState extends State<CashbackScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<TextEditingController> _percentageControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _amountControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCashbackValues();
  }

  @override
  void dispose() {
    _percentageControllers.forEach((controller) => controller.dispose());
    _amountControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveCashbackValues() async {
    final scaffoldContext = ScaffoldMessenger.of(context);
    final navContext = Navigator.of(context);

    final hasInternetConnection =
        await CheckConnectivityUtil.checkInternetConnectivity(context);
    if (!hasInternetConnection) {
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      if (_formKey.currentState!.validate()) {
        List<String> percentages = _percentageControllers
            .map((controller) => controller.text)
            .toList();
        List<String> amounts =
            _amountControllers.map((controller) => controller.text).toList();

        await FirebaseFirestore.instance
            .collection('cashback')
            .doc('values')
            .set({
          'percentages': percentages,
          'amounts': amounts,
        });

        scaffoldContext.showSnackBar(
          const SnackBar(content: Text('Сітка кешбеку успішно збережена')),
        );
        navContext.push(
            MaterialPageRoute(builder: (context) => const AdminMainScreen()));
      }
    } catch (e) {
      print('Error fetching cashback values: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchCashbackValues() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final docSnapshot = await FirebaseFirestore.instance
          .collection('cashback')
          .doc('values')
          .get();
      final data = docSnapshot.data();
      if (data != null) {
        final List<String> percentages = (data['percentages'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
        final List<String> amounts = (data['amounts'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();

        for (int i = 0; i < 4; i++) {
          _percentageControllers[i].text = percentages[i];
          _amountControllers[i].text = amounts[i];
        }
      }
    } catch (e) {
      print('Error fetching cashback values: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Система бонусів'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 40, bottom: 15),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Expanded(
                      child: ListView.builder(
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                CashbackTextField(
                                  maxLength: 2,
                                  sufixText: '%',
                                  controller: _percentageControllers[index],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Введіть відсотки';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Повинні бути цілим числом';
                                    }
                                    int? percentage = int.tryParse(value);
                                    if (percentage == null ||
                                        percentage < 0 ||
                                        percentage > 99) {
                                      return '(0-99)%';
                                    }
                                    return null;
                                  },
                                ),
                                CashbackTextField(
                                  maxLength: 5,
                                  sufixText: 'грн',
                                  controller: _amountControllers[index],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Введіть суму';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Повинна бути цілим числом';
                                    }
                                    int? percentage = int.tryParse(value);
                                    if (percentage == null || percentage < 0) {
                                      return 'Будь ласка, введіть коректну загальну суму покупок';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  CustomButton(
                      action: () async {
                        await _saveCashbackValues();
                      },
                      text: 'Зберегти')
                ],
              ),
            ),
    );
  }
}

class CashbackTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLength;
  final String sufixText;
  const CashbackTextField(
      {super.key,
      required this.controller,
      this.validator,
      required this.maxLength,
      required this.sufixText});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.primaryColor,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextFormField(
            textAlign: TextAlign.center,
            controller: controller,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(8),
              border: InputBorder.none,
              counterText: '',
              suffixText: sufixText,
              suffixStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            keyboardType: TextInputType.number,
            cursorColor: AppColors.primaryColor,
            validator: validator,
            maxLength: maxLength,
          ),
        ),
      ),
    );
  }
}
