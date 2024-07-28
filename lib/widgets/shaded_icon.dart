// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class ShadedIcon extends StatelessWidget {
  const ShadedIcon({
    super.key,
    this.icon,
    this.shade,
    this.width,
  });
  final Icon? icon;
  final Color? shade;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Ink(
      width: width,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: shade ?? const Color.fromARGB(68, 158, 158, 158)),
      padding: EdgeInsets.all(15),
      child: icon ??
          Icon(Icons.lock_open_outlined,
              size: 40, color: Color.fromARGB(255, 35, 101, 214)),
    );
  }
}
