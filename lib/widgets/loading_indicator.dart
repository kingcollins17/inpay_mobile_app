// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.color = Colors.blueAccent,
    this.backgroundColor = const Color.fromARGB(255, 53, 53, 53),
    this.dimension = 25,
  });
  final Color color, backgroundColor;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: dimension,
        child: CircularProgressIndicator(
          strokeWidth: 1,
          color: color,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}
