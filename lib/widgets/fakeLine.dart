import 'package:flutter/material.dart';

class FakeLine extends StatelessWidget {
  final Color color;
  const FakeLine(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      height: 2.0,
    );
  }
}
