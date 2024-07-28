// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures, unused_element

import 'package:flutter/material.dart';

class CopyRight extends StatelessWidget {
  const CopyRight({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '\u00A9 KingCollins ',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: Colors.white),
    );
  }
}
