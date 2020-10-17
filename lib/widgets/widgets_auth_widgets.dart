import 'package:flutter/material.dart';

class WidgetsAuth {

  Widget editTextForEmail(TextEditingController controller, String labelTxt, FocusNode focusNode){
    //passe null para focusNode caso não tenha
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: (value){
        if(value.isEmpty){
          return 'Informe o e-mail';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
          hintText: 'Seu e-mail cadastrado',
          labelText: labelTxt,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.pink, width: 2.0)
          )
      ),
    );
  }

  Widget editTextForPassword(TextEditingController controller, String labelTxt, FocusNode focusNode){
    //passe null para focusNode caso não tenha

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: true,
      maxLength: 6,
      validator: (value){
        if(value.isEmpty){
          return 'Informe a senha';
        }
        return null;
      },
      decoration: InputDecoration(
          hintText: 'Sua senha deve ter 6 dígitos',
          labelText: labelTxt,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.pink, width: 2.0)
          ),
        )
    );
  }


}
