import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class CleanPopUp extends StatelessWidget {
  bool oneButton;
  bool isDismissible;
  double heightPercent;
  double widthPercent;
  String title;
  String text;
  String btnTextAction;
  String btnTextCancel;
  final Function closeCallback;
  final Function actionCallBack;
  final Function action2CallBack;
  CleanPopUp(this.heightPercent, this.widthPercent, this.oneButton, this.isDismissible, this.title, this.text, this.btnTextAction, this.btnTextCancel, this.closeCallback, this.actionCallBack, this.action2CallBack);


  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthPercent,
      height: heightPercent,
      color: Colors.black.withOpacity(0.5),
      child: window(context)

    );
  }

  Widget window(BuildContext context){
    return Padding(
        padding: EdgeInsets.fromLTRB(widthPercent*0.05, heightPercent*0.25, widthPercent*0.05, heightPercent*0.20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: Container(
            child: Elements(context),
            //height: heightPercent*0.50,
            width: widthPercent*0.85,
            margin: const EdgeInsets.only(bottom: 6.0), //Same as `blurRadius` i guess
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget Elements(BuildContext context){
    return Column(
      children: [
        //linha titulo e para fechar
        Padding(
            padding: EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2.5), color: Colors.grey),),
                CloseButton(
                  color: Colors.grey,
                  onPressed: (){
                    closeCallback();
                  },
                )
              ],
            ),
        ),
        //linha divisória
        Container(
          width: widthPercent*0.80,
          height: heightPercent*0.003,
          color: Colors.grey[300],
        ),
        SizedBox(height: heightPercent*0.01,),
        Icon(
          Icons.help,
          color: Colors.lightBlue[200],
          size: 75.0,
        ),
        Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: Text(text, textAlign: TextAlign.center ,style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2), color: CustomColors.blue),),
        ),
        oneButton==false ? SizedBox(height: heightPercent*0.03,) : Container(),
        oneButton==false ? Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: Text('Pressione $btnTextAction para prosseguir ou $btnTextCancel para permanecer na página atual', textAlign: TextAlign.center ,style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(1.6), color: Colors.grey[300]),),
        ) : Container(),
        SizedBox(height: heightPercent*0.04,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: widthPercent*0.35,
              height: heightPercent*0.07,
              child: RaisedButton(
                color: CustomColors.blue,
                onPressed: (){
                    actionCallBack();
                },
                child: Text(btnTextAction, textAlign: TextAlign.center,style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2), color: Colors.white)),
              ),
            ),
            oneButton==false ? SizedBox(width: widthPercent*0.05,) : Container(),
            oneButton==false ? Container(
              width: widthPercent*0.35,
              height: heightPercent*0.07,
              child: RaisedButton(
                color: Colors.lightBlue[50],
                onPressed: (){
                    action2CallBack();
                },
                child: Text(btnTextCancel, textAlign: TextAlign.center, style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2), color: CustomColors.blue))
              ),
            ) : Container(),
          ],
        )



      ],
    );
  }
}
