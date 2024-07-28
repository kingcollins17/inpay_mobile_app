// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.radius = 50,
    this.onPress,
    this.width,
    this.height,
    this.enabled = true,
    this.labelColor,
    this.backgroundColor,
    this.overlayColor,
    this.disabledColor,
  });
  final bool enabled;
  final String label;
  final double radius;
  final double? width, height;
  final VoidCallback? onPress;
  final Color? labelColor, backgroundColor, disabledColor, overlayColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        borderRadius: BorderRadius.circular(radius),
        overlayColor: MaterialStatePropertyAll(
            overlayColor ?? Color.fromARGB(255, 12, 60, 143)),
        onTap: enabled ? onPress : null,
        child: Ink(
          height: height ?? 52,
          width: width ?? MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: enabled
                ? backgroundColor ?? Color(0xFF1E5FCF)
                : disabledColor ?? Color.fromARGB(148, 59, 59, 59),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: labelColor ?? const Color.fromARGB(255, 236, 236, 236),
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ));
  }
}
