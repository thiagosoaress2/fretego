import 'package:flutter/material.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class ResponsiveTextCustomWithMargin extends StatelessWidget {
  final BuildContext context;
  final String txt;
  final Color color;
  final double size;
  final double marginTop;
  final double marginBottom;
  final double marginLeft;
  final double marginRight;
  final String aligment;

  const ResponsiveTextCustomWithMargin(this.txt, this.context, this.color, this.size, this.marginTop, this.marginBottom, this.marginLeft, this.marginRight, this.aligment);


  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: aligment=="center" ? Alignment.center : Alignment.centerLeft,
      margin: EdgeInsets.fromLTRB(marginLeft, marginTop, marginRight, marginBottom),
      child: Text(txt,
        style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(size), color: color),

      ),
    );
  }
}
