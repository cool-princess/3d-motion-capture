import 'dart:math';
import 'customClipper.dart';
import 'package:flutter/material.dart';



class BezierContainer extends StatelessWidget {
  const BezierContainer({Key ?key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Transform.rotate(
        angle: -pi / 3.5, 
        child: ClipPath(
        clipper: ClipPainter(),
        child: Container(
          height: MediaQuery.of(context).size.height *.5,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.fromARGB(255, 72, 194, 251),Color.fromARGB(255, 16, 150, 228)]
              )
            ),
        ),
      ),
      )
    );
  }
}