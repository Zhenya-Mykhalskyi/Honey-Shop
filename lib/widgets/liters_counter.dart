import 'package:flutter/material.dart';
import 'package:honey/providers/product.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class LitersCounter extends StatefulWidget {
  // final double liters;
  final Product product;
  const LitersCounter({
    super.key,
    // required this.liters,
    required this.product,
  });

  @override
  State<LitersCounter> createState() => _LitersCounterState();
}

class _LitersCounterState extends State<LitersCounter> {
  late double _liters;

  @override
  void initState() {
    super.initState();
    _liters = widget.product.liters;
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.04,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color.fromARGB(255, 65, 65, 65),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              productsProvider.subtractHalfLiter(widget.product);
              setState(() {
                if (_liters > 0) {
                  _liters -= 0.5;
                }
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.093,
              decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 255, 179, 0).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(15)),
              child: const Center(
                child: Icon(Icons.remove, size: 20.0, color: Colors.black),
              ),
            ),
          ),
          Text(
            _liters.toString(),
            style: const TextStyle(
              fontSize: 13.0,
            ),
          ),
          GestureDetector(
            onTap: () {
              productsProvider.addHalfLiter(widget.product);
              setState(() {
                _liters += 0.5;
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.093,
              decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 255, 179, 0).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(15)),
              child: const Center(
                child: Icon(Icons.add, size: 20.0, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
