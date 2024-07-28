// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../util.dart';

class CopyToClipboard extends StatelessWidget {
  const CopyToClipboard({
    super.key,
    this.onPress,
    required this.data,
  });
  final VoidCallback? onPress;
  final String data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: data)).then((value) {
          onPress == null ? null : onPress!();
          showSnackBar('Text copied', context);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
            color: Color.fromARGB(50, 9, 62, 153),
            borderRadius: BorderRadius.circular(25)),
        child: Row(
          children: [
            Text(
              'copy',
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Quicksand',
                  color: Colors.blueAccent),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.copy_rounded,
              size: 20,
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}
