import 'package:flutter/material.dart';

class InpayTheme {
  static final dark = ThemeData(
      useMaterial3: true,
      colorScheme:
          const ColorScheme.dark(secondary: Color.fromARGB(255, 6, 67, 172)),
      textTheme: const TextTheme(
          bodySmall: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'Quicksand',
              decoration: TextDecoration.none),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontFamily: 'Quicksand',
            // fontWeight: FontWeight.bold,
            color: Colors.white,
            decoration: TextDecoration.none,
          )));
}
