import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretego/login/services/auth.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:fretego/widgets/widgets_loading.dart';
import 'package:scoped_model/scoped_model.dart';

class EmailVerify extends StatefulWidget {
  @override
  _EmailVerifyState createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerify> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading=false;

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double heightPercent = height*0.65;
    double widthPercent = width*85;

    final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar


    _displaySnackBar(BuildContext context, String msg, Color color) {

      final snackBar = SnackBar(
        backgroundColor: color,
        content: Text(msg),
        action: SnackBarAction(
          label: "Ok",
          onPressed: (){
            _scaffoldKey.currentState.hideCurrentSnackBar();
          },
        ),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        return Scaffold(
          key: _scaffoldKey,
          body: Container(
              color: Colors.blue,
              height: height,
              width: width,
              child: Padding(
                padding: EdgeInsets.all(width*0.10),
                child:  Container(
                    decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.white, 0.0, 10.0),
                    height: heightPercent,  //85% da tela
                    width: widthPercent,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child:  Column(
                        children: [
                          SizedBox(height: 35.0,),
                          WidgetsConstructor().makeText("Verifique seu e-mail", Colors.blueGrey, 25.0, 0.0, 10.0, "center"),
                          SizedBox(height: 35.0,),
                          WidgetsConstructor().makeText("Você precisa verificar seu e-mail para completar o registro", Colors.blueGrey, 15.0, 10.0, 10.0, "center"),
                          isLoading==true ? WidgetsLoading().Loading() : Container(),
                          SizedBox(height: 50.0,),
                          WidgetsConstructor().makeText("Um e-mail foi enviado para "+userModel.Email+" com um link para verificar sua conta. Geralmente o envio é imediato, mas se você não tiver recebido este e-mail dentro de poucos minutos, por favor verifique sua caixa de spam.", Colors.blueGrey, 10.0, 10.0, 10.0, "center"),
                          SizedBox(height: 25.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () async {
                                  setState(() {
                                    isLoading==true;
                                  });
                                  FirebaseUser firebase = await _auth.currentUser().then((value) {
                                    try{
                                      value.sendEmailVerification();
                                      _displaySnackBar(context, "Um novo e-mail foi enviado", Colors.blue);
                                    } catch(e){
                                      _displaySnackBar(context, "Um erro ocorreu.", Colors.red);
                                    }

                                  });
                                  setState(() {
                                    isLoading==false;
                                  });

                                },
                                child: Container(
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: WidgetsConstructor().makeSimpleText("Reenviar", Colors.white, 17.0),
                                  ),
                                  width: width*0.30,
                                  height: 50.0,
                                  decoration: WidgetsConstructor().myBoxDecoration(Colors.blueAccent, Colors.blueAccent, 2.0, 1.0),
                                ),
                              ),
                              SizedBox(width: width*0.10,),
                              InkWell(
                                onTap: (){
                                  _displaySnackBar(context, "Função indisponível", Colors.red);
                                },
                                child: Container(
                                  width: width*0.30,
                                  height: 50.0,
                                  child:Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: WidgetsConstructor().makeSimpleText("Ajuda", Colors.blueAccent, 17.0),
                                  ),
                                  decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blueAccent, 2.0, 1.0),

                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10.0,),
                          InkWell(
                            onTap: () async {

                              setState(() {
                                isLoading=true;
                              });

                              FirebaseUser firebaseUser = await _auth.currentUser();
                              bool isVerify = await AuthService(_auth).checkEmailVerify(firebaseUser);

                              if (isVerify==true){
                                Navigator.of(context).pop();
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => HomePage()));
                              }  else {
                                _displaySnackBar(context, "O e-mail ainda não foi verificado", Colors.red);
                              }


                              setState(() {
                                isLoading=false;
                              });


                            },
                            child: Container(
                              width: width,
                              height: 50.0,
                              child:Padding(
                                padding: EdgeInsets.all(10.0),
                                child: WidgetsConstructor().makeSimpleText("Já verifiquei", Colors.white, 17.0),
                              ),
                              decoration: WidgetsConstructor().myBoxDecoration(Colors.blueAccent, Colors.blueAccent, 2.0, 1.0),

                            ),
                          )

                        ],
                      ),
                    )
                ),
              )
          ),
        );
      },
    );
  }




}


