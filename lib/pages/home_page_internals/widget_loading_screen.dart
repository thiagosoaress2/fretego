import 'package:flutter/material.dart';
import 'package:fretego/models/home_page_model.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class WidgetLoadingScreeen extends StatelessWidget {
  String title;
  String text;
  WidgetLoadingScreeen(this.title, this.text);

  double heightPercent;
  double widthPercent;

  @override
  Widget build(BuildContext context) {

    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;

    return ScopedModelDescendant<HomePageModel>(
      builder: (BuildContext context, Widget child, HomePageModel homePageModel){

        return Container(
          width: widthPercent,
          height: heightPercent,
          color: Colors.black87.withOpacity(0.5),
          child: Center(
            child: Container(
                decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 3.0, 7.0),
                width: widthPercent*0.90,
                height: heightPercent*0.25,
                //color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      height: heightPercent*0.07,
                      child: ResponsiveTextCustom(title, context, Colors.white, 2, 0.0, 0.0, 'center'),
                      width: widthPercent*0.89, color: CustomColors.blue,
                    ),
                    SizedBox(height: heightPercent*0.05,),
                    Row(
                      children: [
                        SizedBox(width: widthPercent*0.05,),
                        CircularProgressIndicator(),
                        SizedBox(width: widthPercent*0.05,),
                        ResponsiveTextCustom(text, context, CustomColors.blue, 2.5, 0.0, 0.0, 'no'),
                      ],
                    )
                  ],
                )
            ),
          ),
        );

      },
    );
  }
}
