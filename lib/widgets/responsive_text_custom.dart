import 'package:flutter/material.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class ResponsiveTextCustom extends StatelessWidget {
  final BuildContext context;
  final String txt;
  final Color color;
  final double size;
  final double marginTop;
  final double marginBottom;
  final String aligment;

  const ResponsiveTextCustom(this.txt, this.context, this.color, this.size, this.marginTop, this.marginBottom, this.aligment);


  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: aligment=="center" ? Alignment.center : Alignment.centerLeft,
      margin: EdgeInsets.fromLTRB(0.0, marginTop, 0.0, marginBottom),
      child: Text(txt,
        style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(size), color: color),

      ),
    );
  }
}
