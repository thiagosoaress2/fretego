import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/globals_strings.dart';
import 'package:fretego/widgets/widgets_constructor.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {


  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    Future.delayed(Duration(seconds: 4)).then((_){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
    });
  }


  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CustomColors.blue,
      child: Center(
        child: WidgetsConstructor().makeText(GlobalsStrings.appName, Colors.white, 25.0, 0.0, 0.0, 'center'),
      ),
    );
  }


}
