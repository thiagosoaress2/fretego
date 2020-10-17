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

    //use assim: no container adicione a linha decoration: WidgetsConstructor().myBoxDecoration(Theme.of(context).primaryColor, 1.0, 0.0),

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


}

