import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretego/login/services/new_auth_service.dart';
import 'package:fretego/models/home_page_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:fretego/widgets/widgets_loading.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';



class EmailVerify extends StatefulWidget {
  @override
  _EmailVerifyState createState() => _EmailVerifyState();
}


class _EmailVerifyState extends State<EmailVerify> {


  bool isLoading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;

    double heightPercent = height * 0.65;
    double widthPercent = width * 95;


    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child,
              NewAuthService newAuthService) {
            return Scaffold(
              key: _scaffoldKey,
              body: Container(
                  color: CustomColors.blue,
                  height: height,
                  width: width,
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.10),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          SizedBox(height: heightPercent * 0.05,),
                          Text('Verificação pendente', style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveFlutter.of(context).fontSize(
                                  3))),
                          SizedBox(height: heightPercent * 0.05,),
                          Container(
                            height: heightPercent * 0.15,
                            width: widthPercent * 0.35,
                            child: Stack(
                              children: [
                                Positioned(
                                  child: Icon(
                                    Icons.email_outlined, color: Colors.white,
                                    size: 100,),
                                  top: 0.0,
                                  bottom: 0.0,
                                  left: 0.0,
                                  right: 0.0,
                                ),
                                Positioned(
                                    top: 0.0,
                                    right: 0.0,
                                    left: widthPercent * 0.0024,
                                    child: Icon(
                                      Icons.error, color: Colors.redAccent,))
                              ],
                            ),
                          ),
                          SizedBox(height: heightPercent * 0.10,),
                          isLoading == true ? Center(
                            child: CircularProgressIndicator(),) :
                          Text(
                              'Você precisa verificar seu e-mail para completar o registro',
                              style: TextStyle(color: Colors.white,
                                  fontSize: ResponsiveFlutter.of(context)
                                      .fontSize(2))),
                          SizedBox(height: heightPercent * 0.05,),
                          Text("Um e-mail foi enviado para " + userModel.Email +
                              " com um link para verificar sua conta. Geralmente o envio é imediato, mas se você não tiver recebido este e-mail dentro de poucos minutos, por favor verifique sua caixa de spam.",
                              style: TextStyle(color: Colors.white,
                                  fontSize: ResponsiveFlutter.of(context)
                                      .fontSize(1.5))),
                          SizedBox(height: heightPercent * 0.2,),
                          Container(
                            height: heightPercent * 0.1,
                            width: widthPercent * 0.4,
                            child: RaisedButton(
                              color: Colors.blue,
                              onPressed: () {
                                newAuthService.sendUserVerifyMail();
                                _displaySnackBar(context,
                                    "Um novo e-mail foi enviado. Caso não encontre, verifique a caixa de spam.",
                                    Colors.blue);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceAround,
                                children: [
                                  Text('Reenviar e-mail', style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ResponsiveFlutter.of(context)
                                          .fontSize(2))),
                                  Icon(Icons.refresh, color: Colors.white,),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: heightPercent * 0.05,),
                          Container(
                            height: heightPercent * 0.15,
                            width: widthPercent * 0.4,
                            child: RaisedButton(
                              color: CustomColors.yellow,
                              onPressed: () {
                                _displaySnackBar(
                                    context, "Verificando...", Colors.blue);
                                newAuthService.loadUser();
                                setState(() {
                                  isLoading = true;
                                });

                                _verify(newAuthService);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceAround,
                                children: [
                                  Text('Já confirmei', style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ResponsiveFlutter.of(context)
                                          .fontSize(3))),
                                  Icon(
                                    Icons.done, color: Colors.white, size: 35,),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  )
              ),
            );
          },
        );
      },
    );
  }

  void _verify(NewAuthService newAuthService) {
    newAuthService.loadUser();
    Future.delayed(Duration(seconds: 3)).then((_) {
      if (newAuthService.isUserEmailVerified() == true) {
        _displaySnackBar(context, 'Confirmado! Redirecionando', Colors.blue);
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomePage()));
      } else {
        //repetir o processo pra evitar o erro recorrente
        //antes dava erro mas ao clicar novamente ele encontrava . Agora vai fazer automático
        newAuthService.loadUser();

        if (newAuthService.isUserEmailVerified() == true) {
          _displaySnackBar(context, 'Confirmado! Redirecionando', Colors.blue);
          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => HomePage()));
        } else {
          _displaySnackBar(context,
              "O e-mail ainda não foi verificado. Verifique a caixa de spam caso não tenha recebido. Caso você já tenha confirmado, aguardo uns instantes e tente novamente'",
              Colors.red);
        }
      }
    });
  }


  _displaySnackBar(BuildContext context, String msg, Color color) {
    final snackBar = SnackBar(
      backgroundColor: color,
      content: Text(msg),
      action: SnackBarAction(
        label: "Ok",
        onPressed: () {
          _scaffoldKey.currentState.hideCurrentSnackBar();
        },
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

}

/*

class EmailVerify extends StatefulWidget {
  @override
  _EmailVerifyState createState() => _EmailVerifyState();
}

double widthPercent;
double heightPercent;


class _EmailVerifyState extends State<EmailVerify> {

  bool isLoading=false;

  @override
  Widget build(BuildContext context) {

    widthPercent = MediaQuery.of(context).size.width;
    heightPercent = MediaQuery.of(context).size.height;

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
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {
            return ScopedModelDescendant<HomePageModel>(
              builder: (BuildContext context, Widget widget, HomePageModel homePageModel){

                return SafeArea(
                  child: Scaffold(
                    key: _scaffoldKey,
                    body: Container(
                        color: Colors.white,
                        height: heightPercent,
                        width: widthPercent,
                        child: Stack(
                          children: [

                            //icone
                            Positioned(
                              top: heightPercent*0.25,
                              left: 0.0,
                              right: 0.0,
                              child:Container(
                                width: widthPercent*0.35,
                                height: heightPercent*0.15,
                                decoration: new BoxDecoration(
                                  shape: BoxShape.circle,// You can use like this way or like the below line
                                  //borderRadius: new BorderRadius.circular(4.0),
                                  color: CustomColors.blue,
                                ),
                                child: Icon(Icons.email, color: Colors.white, size: 80,),
                              ),
                            ),

                            //btn reenviar
                            Positioned(
                              top: heightPercent*0.45,
                              left: 10.0,
                              right: 10.0,
                              child: Container(
                                width: widthPercent*0.90,
                                child: Text('Obrigado pela inscrição! Enviamos um e-mail de confirmação para '+userModel.Email+'. Verifique também em sua pasta de spam.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2), color: Colors.black, ),

                                ),
                              ),
                            ),


                            //botao ja verifiquei
                            Positioned(
                              top: heightPercent*0.65,
                              left: widthPercent*0.20,
                              right: widthPercent*0.20,
                              child: Container(
                                  height: heightPercent*0.08,
                                  width: widthPercent*0.60,
                                  child: RaisedButton(
                                    color: CustomColors.blue,
                                    onPressed: (){

                                      setState(() {
                                        isLoading=true;
                                      });

                                      _displaySnackBar(context, "Verificando...", Colors.blue);
                                      newAuthService.loadUser();

                                      if(newAuthService.isUserEmailVerified()==true){

                                        homePageModel.updateFirstLoad(true);

                                        Navigator.of(context).pop();
                                        Navigator.push(context, MaterialPageRoute(
                                            builder: (context) => HomePage()));
                                      } else {
                                        setState(() {
                                          isLoading=false;
                                        });
                                        _displaySnackBar(context, "O e-mail ainda não foi confirmado. Caso você já tenha feito, aguarde um instantes e tente novamente'", Colors.red);

                                      }

                                    },
                                    child: WidgetsConstructor()
                                        .makeResponsiveText(context, 'Já verifiquei', Colors.white, 2.5, 0.0, 0.0, 'center'),
                                  )
                              ),
                            ),

                            //botoes
                            Positioned(
                              left: widthPercent*0.20,
                              right: widthPercent*0.20,
                              bottom: heightPercent*0.05,
                              child: Container(
                                  height: heightPercent*0.08,
                                  width: widthPercent*0.60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: CustomColors.blue,
                                      width: 2.0, //                   <--- border width here
                                    ),

                                    borderRadius: BorderRadius.all(Radius.circular(4.0)),


                                  ),

                                  child: RaisedButton(
                                    onPressed: (){


                                      newAuthService.sendUserVerifyMail();
                                      _displaySnackBar(context, 'Um novo e-mail foi enviado para ${userModel.Email}. Caso não encontre, verifique a caixa de spam.', Colors.blue);


                                    },
                                    color: Colors.white,
                                    child: WidgetsConstructor()
                                        .makeResponsiveText(context, 'Reenviar e-mail', CustomColors.blue, 2, 0.0, 0.0, 'center'),
                                  )
                              ),
                            ),


                            //appbar fake
                            Positioned(
                              top: 0.0,
                              left: 0.0,
                              right: 0.0,
                              child:fakeAppBar(),
                            ),

                            isLoading==true ? Center(child: CircularProgressIndicator(),) : Container(),



                          ],
                        )
                    ),
                  ),
                );

              },
            );
          },
        );
      },
    );
  }

  Widget fakeAppBar(){

    return Container(
      width: widthPercent,
      height: heightPercent*0.10,
      alignment: Alignment.center,
      color: Colors.transparent,
      child:
      Text('Verificação de segurança', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.5))),

    );
  }



  /*
  Padding(
                        padding: EdgeInsets.all(widthPercent*0.10),
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

                                          newAuthService.sendUserVerifyMail();
                                          _displaySnackBar(context, "Um novo e-mail foi enviado. Caso não encontre, verifique a caixa de spam.", Colors.blue);
                                          /*
                                  FirebaseUser firebase = await _auth.currentUser().then((value) {
                                    try{
                                      value.sendEmailVerification();
                                      _displaySnackBar(context, "Um novo e-mail foi enviado", Colors.blue);
                                    } catch(e){
                                      _displaySnackBar(context, "Um erro ocorreu.", Colors.red);
                                    }

                                  });
                                   */

                                        },
                                        child: Container(
                                          child: Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: WidgetsConstructor().makeSimpleText("Reenviar", Colors.white, 17.0),
                                          ),
                                          width: widthPercent*0.30,
                                          height: 50.0,
                                          decoration: WidgetsConstructor().myBoxDecoration(Colors.blueAccent, Colors.blueAccent, 2.0, 1.0),
                                        ),
                                      ),
                                      SizedBox(width: widthPercent*0.10,),
                                      InkWell(
                                        onTap: (){
                                          _displaySnackBar(context, "Função indisponível", Colors.red);
                                        },
                                        child: Container(
                                          width: widthPercent*0.30,
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

                                      _displaySnackBar(context, "Verificando...", Colors.blue);
                                      newAuthService.loadUser();

                                      if(newAuthService.isUserEmailVerified()==true){
                                        Navigator.of(context).pop();
                                        Navigator.push(context, MaterialPageRoute(
                                            builder: (context) => HomePage()));
                                      } else {
                                        _displaySnackBar(context, "O e-mail ainda não foi verificado. Verifique a caixa de spam caso não tenha recebido. Caso você já tenha confirmado, aguardo uns instantes e tente novamente'", Colors.red);
                                      }
                                      /*
                                  FirebaseUser firebaseUser = await _auth.currentUser();
                                  bool isVerify = await AuthService(_auth).checkEmailVerify(firebaseUser);

                                  if (isVerify==true){
                                    Navigator.of(context).pop();
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => HomePage()));
                                  }  else {
                                    _displaySnackBar(context, "O e-mail ainda não foi verificado", Colors.red);
                                  }
                                   */

                                    },
                                    child: Container(
                                      width: widthPercent,
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
   */


}





 */