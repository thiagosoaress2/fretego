import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/widgets/widgets_constructor.dart';

class MyBottomSheet {

  void settingModalBottomSheet(context, String title, String subTitle, String text, IconData topIcon, double height, double width, int options, bool isDismissible,
      //se for usar mais de uma 1 opção (não é só ok), vai precisar definir os elementos abaixo
      [IconData option1Icon, String option1Text, VoidCallback option1Click(),
        IconData option2Icon, String option2Text, VoidCallback option2Click(),
        IconData option3Icon, String option3Text, VoidCallback option3Click(),
        ] ) {

    showModalBottomSheet(
        isDismissible: false,
        barrierColor: Colors.black.withAlpha(1),
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            color: Colors.transparent,
            height: height*0.8,
            child: Stack(
              children: [

                Positioned(
                  top: 30.0,
                  child: Container(
                    height: height*0.8,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                          height: height*0.12,
                          width: width,
                          color: CustomColors.blue,
                          child: Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Column(
                              children: [
                                WidgetsConstructor().makeText(title, Colors.white, 17.0, 25.0, 0.0, 'no'),
                                WidgetsConstructor().makeText(subTitle, Colors.white54, 16.0, 0.5, 0.0, 'no'),
                              ],
                            ),
                          )
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(width: width*0.10,),
                          Container(
                            width: width*0.8,
                            child: WidgetsConstructor().makeText(text, CustomColors.blue, 15.0, 35.0, 20.0, 'center'),
                          ),
                          SizedBox(width: width*0.10),

                        ],
                      ),

                      Container(
                        height: 2.0,
                        width: width,
                        color: Colors.grey[300],
                      ),


                      SizedBox(height: height*0.02,),

                      options >= 2
                          ? GestureDetector(
                            onTap: (){
                              option1Click();
                            },
                            child: Row(
                              children: [
                                SizedBox(width: 10.0,),
                                Icon(option1Icon, color: CustomColors.blue, size: 50.0,),
                                SizedBox(width: 10.0,),
                                WidgetsConstructor().makeText(option1Text, CustomColors.blue, 20.0, 10.0, 0.0, 'no'),
                              ],
                            ),
                      ) : Container(),

                      SizedBox(height: height*0.01,),

                      options >= 2 ? Container(
                        height: 2.0,
                        width: width,
                        color: Colors.grey[300],
                      ) : Container(),

                      SizedBox(height: height*0.01,),

                      options >= 2
                          ? GestureDetector(
                          onTap: (){
                            option2Click();
                          },
                        child: Row(
                          children: [
                            SizedBox(width: 10.0,),
                            Icon(option2Icon, color: Colors.grey[500], size: 50.0,),
                            SizedBox(width: 10.0,),
                            WidgetsConstructor().makeText(option2Text, Colors.grey[500], 20.0, 10.0, 0.0, 'no'),
                          ],
                        ),
                      ) : Container(),

                      SizedBox(height: height*0.01,),

                      options >= 3
                          ?
                          GestureDetector(
                            onTap: (){
                              option3Click();
                            },
                            child: Row(
                              children: [
                                SizedBox(width: 10.0,),
                                Icon(option3Icon, color: Colors.grey[500], size: 50.0,),
                                SizedBox(width: 10.0,),
                                WidgetsConstructor().makeText(option3Text, Colors.grey[500], 20.0, 10.0, 0.0, 'no'),
                              ],
                            ),
                          )
                          : Container(),


                    ],
                  ),
                ),
                ),

                options==0 ? Positioned(
                  right: 20.0,
                  bottom: 20.0,
                  child: Container(
                    width: 100.0,
                    height: 50.0,
                    child: RaisedButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      splashColor: Colors.grey[200],
                      color: CustomColors.blue,
                      child: WidgetsConstructor().makeText('Ok', Colors.white, 18.0, 0.0, 0.0, 'center'),
                    ),
                  ),
                ) : Container(),



                Positioned(
                  top: 0.0,
                  right: 30.0,
                  child: Container(
                    height: 70.0,
                    width: 70.0,
                    child: Icon(topIcon, color: CustomColors.blue, size: 50.0,),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 0.1,
                          spreadRadius: 0.5,
                          offset: Offset(0.5, 0.5), // shadow direction: bottom right
                        )
                      ],
                      color: Colors.grey[100],
                      borderRadius:  BorderRadius.all(Radius.circular(360.0)),),

                  ),
                ),

              ],
            ),

          );
        });
  }

  /*
  Container(
                  width: 100.0,
                  height: 100.0,
                  color: Colors.brown,
                ),
                Container(
                  height: 200.0,
                  width: 500.0,
                  color: Colors.blue,
                ),
   */

}

