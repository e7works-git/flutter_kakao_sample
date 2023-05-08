import 'package:flutter/material.dart';

class FooterArea extends StatelessWidget {
  const FooterArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Text(
        "E7works & Joytune",
        style: TextStyle(
          color: const Color(0x4dffffff).withOpacity(0.3),
          fontSize: 12.0,
        ),
      ),
    );
  }
}
