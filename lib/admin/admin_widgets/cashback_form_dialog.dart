import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:honey/services/check_internet_connection.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/custom_button.dart';
import 'package:honey/widgets/custom_text_field.dart';

class CashbackForm extends StatefulWidget {
  const CashbackForm({super.key});

  @override
  State<CashbackForm> createState() => _CashbackFormState();
}

class _CashbackFormState extends State<CashbackForm> {
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
    _fetchCashbackValues();
    super.initState();
  }

  void _fetchCashbackValues() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final docSnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .doc('cashback')
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
            .collection('admin')
            .doc('cashback')
            .set({
          'percentages': percentages,
          'amounts': amounts,
        });

        scaffoldContext.showSnackBar(
          const SnackBar(content: Text('Сітка кешбеку успішно збережена')),
        );
        navContext.pop();
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
  void dispose() {
    for (var controller in _percentageControllers) {
      controller.dispose();
    }
    for (var controller in _amountControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: const Color.fromARGB(255, 27, 27, 27),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.48,
          child: _isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryColor),
                )
              : Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Tooltip(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            textStyle: const TextStyle(fontSize: 16),
                            triggerMode: TooltipTriggerMode.tap,
                            showDuration: const Duration(seconds: 10),
                            message:
                                'Заповніть таблицю у порядку зростання. Тобто зверху повинні бути менші пари значень (наприклад, 5% - 500 грн), і зростати донизу (наприклад, 15% - 3000 грн)',
                            child: const Icon(Icons.info_outline,
                                color: Colors.white, size: 28),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close,
                                color: Colors.white, size: 28),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Form(
                        key: _formKey,
                        child: Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        showHintText: false,
                                        isTextAlignCenter: true,
                                        maxLength: 2,
                                        sufixText: '%',
                                        controller:
                                            _percentageControllers[index],
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
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: CustomTextField(
                                        showHintText: false,
                                        isTextAlignCenter: true,
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
                                          if (percentage == null ||
                                              percentage < 0) {
                                            return 'Будь ласка, введіть коректну загальну суму покупок';
                                          }
                                          return null;
                                        },
                                      ),
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
        ));
  }
}

// class CashbackTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String? Function(String?)? validator;
//   final int maxLength;
//   final String sufixText;
//   const CashbackTextField(
//       {super.key,
//       required this.controller,
//       this.validator,
//       required this.maxLength,
//       required this.sufixText});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Container(
//           decoration: BoxDecoration(
//             border: Border.all(
//               color: AppColors.primaryColor,
//             ),
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           child: TextFormField(
//             textAlign: TextAlign.center,
//             controller: controller,
//             style: const TextStyle(
//                 color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
//             decoration: InputDecoration(
//               contentPadding: const EdgeInsets.all(8),
//               border: InputBorder.none,
//               counterText: '',
//               suffixText: sufixText,
//               suffixStyle: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w500),
//             ),
//             keyboardType: TextInputType.number,
//             cursorColor: AppColors.primaryColor,
//             validator: validator,
//             maxLength: maxLength,
//           ),
//         ),
//       ),
//     );
//   }
// }
