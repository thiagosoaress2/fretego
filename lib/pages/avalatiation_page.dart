import 'package:flutter/material.dart';
import 'package:fretego/classes/avaliation_class.dart';
import 'package:fretego/models/userModel.dart';
import 'package:scoped_model/scoped_model.dart';

AvaliationClass _avaliationClass = AvaliationClass();  //esta é a classe que será usada na activity

class AvaliationPage extends StatefulWidget {
  AvaliationClass avaliationClass = AvaliationClass();

  AvaliationPage(this.avaliationClass);

  @override
  _AvaliationPageState createState() => _AvaliationPageState();
}

class _AvaliationPageState extends State<AvaliationPage> {
  @override
  Widget build(BuildContext context) {

    _avaliationClass = widget.avaliationClass; //passando os dados que vieram da outra página para esta

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){

        return Scaffold(
          appBar: AppBar(
            title: Text('Avaliação do serviço'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Container(color: Colors.yellow,),
          ),
        );
      },
    );
  }
}
