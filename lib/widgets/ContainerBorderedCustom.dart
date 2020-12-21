import 'package:flutter/material.dart';
import 'package:fretego/utils/colors.dart';

class ContainerBorderedCustom extends StatelessWidget {
  final double widthInformed;
  final double heightPercent;

  const ContainerBorderedCustom({
    Key key,
    Widget child,
    this.widthInformed,
    this.heightPercent
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthInformed,
      height: heightPercent,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: CustomColors.blue,
          width: 2.0, //                   <--- border width here
        ),
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      ),

    );
  }
}
