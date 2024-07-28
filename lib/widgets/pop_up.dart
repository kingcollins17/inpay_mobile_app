// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element, unused_field

import 'package:flutter/material.dart';

class PopUpMessage extends AnimatedWidget {
  PopUpMessage({
    Key? key,
    required Animation<double> animation,
    required this.message,
  }) : super(key: key, listenable: animation);
  final String message;
  //
  final translation = Tween<Offset>(begin: Offset(0, 40), end: Offset.zero)
      .chain(CurveTween(curve: Curves.easeOutQuad));
  final scale = Tween<double>(begin: 0.9, end: 1)
      .chain(CurveTween(curve: Curves.easeOutQuart));

  @override
  build(BuildContext context) {
    Animation<double> animation = listenable as Animation<double>;
    return Opacity(
      opacity: animation.value,
      child: Transform.translate(
          offset: animation.drive(translation).value,
          child: Transform.scale(
              scale: animation.drive(scale).value,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 29, 29, 29),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outlined,
                        size: 20, color: Color(0xFFBEBEBE)),
                    const SizedBox(width: 6),
                    Text(
                      message,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: const Color.fromARGB(255, 226, 226, 226),
                          decoration: TextDecoration.none),
                    ),
                  ],
                ),
              ))),
    );
  }
}
