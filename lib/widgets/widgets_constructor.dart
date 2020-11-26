import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class WidgetsConstructor {

  Widget makeEditText(TextEditingController controller, String labelTxt, FocusNode focusNode){

    //passe null em focusnode caso não tenha. Isto serve para dar focus.

    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(labelText: labelTxt),
    );

  }
  //versão form
  Widget makeFormEditText(TextEditingController controller, String labelTxt, String errorMsg){

    return TextFormField(
      validator: (value) {
        if(value.isEmpty){
          return errorMsg;
        } else {
          return null;
        }
      },
      controller: controller,
      decoration: InputDecoration(labelText: labelTxt),
    );

  }

  Widget makeFormEditTextNumberOnly(TextEditingController controller, String labelTxt, String errorMsg){

    return TextFormField(
        validator: (value) {
          if(value.isEmpty){
            return errorMsg;
          } else {
            return null;
          }
        },
        controller: controller,
        decoration: InputDecoration(labelText: labelTxt),
        keyboardType: TextInputType.number
    );

  }

  Widget makeEditTextNumberOnly(TextEditingController controller, String labelTxt){

    return TextField(
        controller: controller,
        decoration: InputDecoration(labelText: labelTxt),
        keyboardType: TextInputType.number
    );

  }

  /* obs nao usar este. Existe uma classe especifica pra isso. Ver nos documentos */
  /*
 Widget makeEditTextForCurrency(MoneyMaskedTextController controller, String labelTxt){

   //instrução
   //biblioteca para pubspec flutter_masked_text: ^0.7.0
   //O controller precisa ser deste tipo aqui: final _custoController = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');

   return TextField(
     controller: controller,
     decoration: InputDecoration(labelText: labelTxt, counterText: ''), //counterText é o contador que aparece no canto direito. Aqui n aparece nada. Se qusier exibir remvoa este item e ele voltará ao padrão
     maxLength: 12,  //limitado a 9,999 milhões. aumente aqui se precisar mais.
     keyboardType: TextInputType.number,
   );

 }
  */

  Widget makeFormEditTextForCurrency(MoneyMaskedTextController controller, String labelTxt, String errorMsg){

    //instrução
    //biblioteca para pubspec flutter_masked_text: ^0.7.0
    //O controller precisa ser deste tipo aqui: final _custoController = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');

    return TextFormField(
      validator: (value) {
        if(value.isEmpty){
          return errorMsg;
        } else {
          return null;
        }
      },
      controller: controller,
      decoration: InputDecoration(labelText: labelTxt, counterText: ''), //counterText é o contador que aparece no canto direito. Aqui n aparece nada. Se qusier exibir remvoa este item e ele voltará ao padrão
      maxLength: 12,  //limitado a 9,999 milhões. aumente aqui se precisar mais.
      keyboardType: TextInputType.number,
    );

  }

  Widget makeEditTextForDateFormat(TextEditingController controller, String labelTxt, MaskTextInputFormatter maskFormatter){

    //instrução: Para usar você declara um controller tradicional.
    //adicione esta biblioteca: mask_text_input_formatter: ^1.0.7
    //Mas você precisa de um maskformatter assim> var maskFormatterDataCompra = new MaskTextInputFormatter(mask: '##/##/####', filter: { "#": RegExp(r'[0-9]') });
    //também precisa de um controller. ex: final TextEditingController _dateController = TextEditingController();
    //obs: Você pode editar este elemento de várias formas e não apenas para máscara

    return TextField(
      controller: controller,
      inputFormatters: [maskFormatter],
      autocorrect: false,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: labelTxt),
    );

  }

  Widget makeFormEditTextForDateFormat(TextEditingController controller, String labelTxt, MaskTextInputFormatter maskFormatter, String errorMsg){

    //instrução: Para usar você declara um controller tradicional.
    //adicione esta biblioteca: mask_text_input_formatter: ^1.0.7
    //Mas você precisa de um maskformatter assim> var maskFormatterDataCompra = new MaskTextInputFormatter(mask: '##/##/####', filter: { "#": RegExp(r'[0-9]') });
    //obs: Você pode editar este elemento de várias formas e não apenas para máscara

    return TextFormField(
      validator: (value) {
        if(value.isEmpty){
          return errorMsg;
        } else {
          return null;
        }
      },
      controller: controller,
      inputFormatters: [maskFormatter],
      autocorrect: false,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: labelTxt),
    );

  }

  Widget makeText(String msg, Color color, double Size, double marginTop, double marginBottom, String aligment){

    //sample
    //WidgetsConstructor().makeText("informe moeda da compra", Theme.of(context).primaryColor, 18.0, 16.0, 0.0, "center"),

    return Container(
      alignment: aligment=="center" ? Alignment.center : Alignment.topLeft,
      margin: EdgeInsets.fromLTRB(0.0, marginTop, 0.0, marginBottom),
      child: Text(
        msg,
        style: TextStyle(fontSize: Size, color: color),
      ),
    );
  }

  Widget makeSimpleText(String msg, Color color, double Size){
    return Text(msg, style: TextStyle(color: color, fontSize: Size) ,);
  }

  BoxDecoration myBoxDecoration(Color backgroundColor, Color borderColor, double width, double radius) {

    //use assim: no container adicione a linha decoration: WidgetsConstructor().myBoxDecoration(Colors.yellow, Colors.blue, 1.0, 0.0),

    //obs: Use 0.0 para nao colocar borda redonda

    return BoxDecoration(
      color: backgroundColor,
      border: Border.all(
        color: borderColor,
        width: width, //                   <--- border width here
      ),

      borderRadius: BorderRadius.all(Radius.circular(radius)),


    );
  }

  Widget makeButton(@required Color backgroundColor, @required Color borderColor, @required double width, @required double height, @required double borderWidth, @required double radius, @required String text, @required Color textColor, @required textSize){
    return Container(
      height: height,
      width: width,
      decoration: myBoxDecoration(backgroundColor, borderColor , borderWidth, radius),

      child: RaisedButton(
        child: makeText(text, textColor, textSize, 10.0, 10.0, "center"),
      ),

    );

  }

  Widget makeButtonWithCallBack(@required Color backgroundColor, @required Color borderColor, @required double width, @required double height, @required double borderWidth, @required double radius, @required String text, @required Color textColor, @required textSize, @required VoidCallback onPressBtn()){

    return RaisedButton(
      color: backgroundColor,
      splashColor: Colors.grey[100],
      onPressed: (){
        onPressBtn();
      },
      child: makeText(text, textColor, textSize, 10.0, 10.0, "center"),
    );
  }

  Widget customPopUp(String title, String text, String btnOk, String btnCancel, double widthPercent, double heightPercent, @required VoidCallback onPressBtn(), @required VoidCallback onPressCancel()){

    //USE ASSIM
    //CRIA FUNÇÕES DE CALLBACK PARA CANCEL E OK
    //WidgetsConstructor().customPopUp('title', 'text', widthPercent,  () {_onPressPopup();}, () {_onPressPopupCancel();})

    return Positioned(
        top: heightPercent*0.25,
        right: 0.5,
        left: 0.5,
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: widthPercent*0.05,),
        Container(
          width: widthPercent*0.85,
          //decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            border: Border.all(
              color: Colors.blue,
              width: 2.0, //                   <--- border width here
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey[400],
                blurRadius: 4.0,
                spreadRadius: 1.0,
                offset: Offset(2.0, 2.0), // shadow direction: bottom right
              )
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [

                WidgetsConstructor().makeText(title, Colors.blue, 20.0, 20.0, 20.0, 'center'),
                WidgetsConstructor().makeText(text, Colors.black, 16.0, 0.0, 30.0, 'center'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    Container(
                      width: widthPercent*0.35,
                      height: 60.0,
                      child: RaisedButton(
                        onPressed: (){
                          onPressCancel();
                        },
                        color: Colors.red,
                        splashColor: Colors.red[200], //onclick
                        elevation: 4.0,
                        child: makeText(btnCancel, Colors.white, 16.0, 0.5, 0.5, 'center'),),

                    ),

                    Container(
                      width: widthPercent*0.35,
                      height: 60.0,
                      child: RaisedButton(
                          onPressed: (){
                            onPressBtn();
                          },
                          elevation: 4.0,
                          splashColor: Colors.blue[200],
                          color: Colors.blue,
                          child: makeText(btnOk, Colors.white, 16.0, 0.5, 0.5, 'center'))
                      ,
                    ),


                  ],
                )
              ],
            ),
          ),
        ),
        SizedBox(width: widthPercent*0.05,),
      ],
    )
    );

  }

  //eexemplo de botao
  /*

                      new CupertinoButton (
                        onPressed: ()=>{},
                        color: Colors.orange,
                        borderRadius: new BorderRadius.circular(30.0),
                        child:
                        new Text("Get Started",
                          textAlign: TextAlign.center,
                          style: new TextStyle(color: Colors.white),
                        ),
                      ),
   */
}

