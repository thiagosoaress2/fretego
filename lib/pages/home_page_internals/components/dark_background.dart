import 'package:flutter/material.dart';

class DarkBackground extends StatelessWidget {
  double heightPercent;
  double widthPercent;
  DarkBackground({this.heightPercent, this.widthPercent});

  @override
  Widget build(BuildContext context) {
    return Container(height: heightPercent, width: widthPercent,
        color: Colors.black54.withOpacity(0.6));
  }
}
