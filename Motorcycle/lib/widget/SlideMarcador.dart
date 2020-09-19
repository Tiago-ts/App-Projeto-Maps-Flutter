import 'package:flutter/material.dart';

class SlideMarcador extends StatelessWidget {
  bool isActive;
  SlideMarcador(this.isActive);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: isActive ? 12 : 8,
      width: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context). primaryColor : Colors.grey,
        //color: isActive ? Theme.of(context). disabledColor : Colors.yellow,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}