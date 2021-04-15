
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fretego/login/pages/login_page.dart';
import 'package:fretego/login/services/new_auth_service.dart';
import 'package:fretego/models/home_page_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/widgets/widgets_auth_widgets.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:fretego/widgets/widgets_loading.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';


class SignUpView extends StatefulWidget {
  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {

  static const int _sizeOfPassword=8;

  final FirebaseAuth mAuth = FirebaseAuth.instance;
  //FirebaseUser firebaseUser;
  User firebaseuser = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController = TextEditingController();

  bool isLoading = false;

  bool passwordIsOk = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  double heightPercent;
  double widthPercent;

  String yellowBaloonText=' Vamos nos conhecer ';
  bool showFullBallon=true;
  bool emailIsOk=false;
  String emailMsg = 'no';
  bool passWordIsOk=false;
  bool passWordConfirmIsOk=false;

  bool passIsObscure=true;

  bool btnIsEnable=true;


  @override
  void initState() {
    _setupListeners();

    super.initState();
  }

  void _setupListeners(){


    nameController.addListener(() {
      if(nameController.text.isEmpty){
        setState(() {
          yellowBaloonText=' Vamos nos conhecer ';
          showFullBallon=true;
        });

      } else {
        setState(() {
          yellowBaloonText=' Precisamos de poucas informações ';
          showFullBallon=false;
        });
      }
    });

    emailController.addListener(() {
      if(emailController.text.contains('@') && emailController.text.contains('.com')){
        setState(() {
          emailIsOk=true;
        });
      } else {
        setState(() {
          emailIsOk=false;
        });
      }
    });

    passwordController.addListener(() {
      if(passwordController.text.length==_sizeOfPassword){
        setState(() {
          passwordIsOk=true;
          print('foi');
        });
      } else {
        setState(() {
          passwordIsOk=false;
        });
      }
    });

    passwordConfirmationController.addListener((){
      if(passwordController.text.length==_sizeOfPassword ){

        passWordConfirmIsOk=true;

      }else{

        passWordConfirmIsOk=false;

      }

    });

  }

  @override
  Widget build(BuildContext context) {

    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService){

            return SafeArea(child: Scaffold(
              key: _scaffoldKey,
              body: Container(
                width: widthPercent,
                height: heightPercent,
                color: Colors.white,
                child: Stack(
                  children: [

                    Positioned(
                      top: heightPercent*0.12,
                      left: -1.0,

                      child: Container(
                        height: showFullBallon==true ? heightPercent*0.20 : heightPercent*0.08,
                        decoration: WidgetsConstructor().myBoxDecoration(CustomColors.yellow, CustomColors.yellow, 1.0, 4.0),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            showFullBallon == true ? WidgetsConstructor().makeResponsiveText(context, 'Novo por aqui?', CustomColors.brown, 2.5, 5.0, 0.0, 'no') : Container(),
                            WidgetsConstructor().makeResponsiveText(context, yellowBaloonText, Colors.white, 2.5, 15.0, 0.0, 'no'),
                            showFullBallon == true ? WidgetsConstructor().makeResponsiveText(context, 'MELHOR? ', Colors.white , 5.5, 0.0, 0.0, 'no') : Container(),

                          ],
                        ),
                      ),),

                    Positioned(
                      top: showFullBallon==true ? heightPercent*0.34 : heightPercent*0.23,
                      left: widthPercent*0.05,
                      right: widthPercent*0.05,
                      bottom: 0.0,
                      child: _loginElements(),
                    ),

                    //appbar
                    Positioned(
                      top: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child:fakeAppBar(),
                    ),

                    isLoading==true
                        ? Center(child: CircularProgressIndicator(),)
                        : Container(),

                  ],
                ),
              ),
            ));

          },
        );
      },
    );
  }

  Widget fakeAppBar(){

    void _customBackButton() {

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => LoginPage()));

    }

    return Container(
      width: widthPercent,
      height: heightPercent*0.10,
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          Container(
            alignment: Alignment.center,
            width: widthPercent*0.25,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.blue, size: 35,),
                  onPressed: () {
                    _customBackButton();
                  },),
                //WidgetsConstructor().makeText(appBarText, Colors.grey[400], 9.0, 0.0, 0.0, 'center'),
                Text('Login', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
              ],
            ),
          ),
          Container(
            width: widthPercent*0.5,
            child: WidgetsConstructor().makeResponsiveText(context, 'Novo usuário', Colors.blue, 3, 0.0, 0.0, 'center'),
          ),
          Container(width: widthPercent*0.25),

        ],
      ),
    );
  }

  Widget _loginElements(){

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget widget, NewAuthService newAuthService){

            return ScopedModelDescendant<HomePageModel>(
              builder: (BuildContext context, Widget widget, HomePageModel homePageModel){

                return ListView(
                  children: [

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [

                          //nome
                          Container(
                            height: heightPercent*0.09,
                            width: widthPercent*0.85,
                            child: TextFormField(

                              controller: nameController,
                              validator: (value){
                                if(value.isEmpty){
                                  return 'Informe o nome';
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Nome completo',
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: CustomColors.yellow, width: 2.0),

                                ),
                              ),
                              textInputAction: TextInputAction.next,

                            ),
                          ),

                          SizedBox(height: heightPercent*0.02,),

                          //email
                          Container(
                            height: heightPercent*0.09,
                            width: widthPercent*0.85,
                            child: Focus(
                              child: TextFormField(

                                controller: emailController,
                                validator: (value){
                                  if(value.isEmpty){
                                    return 'Informe o e-mail';
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: 'E-mail',
                                  suffixIcon: emailIsOk==true ? Icon(Icons.done, color: CustomColors.yellow,) : null,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: CustomColors.yellow, width: 2.0),

                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,

                              ),

                              onFocusChange: (hasFocus) {
                                if(hasFocus) {

                                } else {

                                  if(!emailController.text.contains('@')){
                                    emailMsg = 'Ops, falta o simbolo @';
                                  } else if(!emailController.text.contains('.com')){
                                    emailMsg = 'Algo errado com o e-mail';
                                  } else {
                                    emailMsg = 'no';
                                  }

                                }
                              },
                            ),
                          ),
                          Container(
                            width: widthPercent*0.85,
                            child: emailMsg != 'no' ? WidgetsConstructor().makeResponsiveText(context, emailMsg, Colors.red, 1.5, 5.0, 0.0, 'no') : Container(),
                          ),

                          SizedBox(height: heightPercent*0.02,),

                          //senha txtfield
                          Container(
                              height: heightPercent*0.09,
                              width: widthPercent*0.85,
                              child: TextFormField(
                                  controller: passwordController,
                                  obscureText: passIsObscure,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(_sizeOfPassword),
                                  ],
                                  validator: (value){
                                    if(value.isEmpty){
                                      return 'Informe a senha';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Senha',
                                    suffixIcon: passwordIsOk==true ? Icon(Icons.done, color: CustomColors.yellow,) : null,
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: CustomColors.yellow, width: 2.0)
                                    ),
                                  ),
                                  textInputAction: TextInputAction.next
                              )
                          ),

                          Row(
                            children: [

                              Checkbox(value: !passIsObscure, onChanged: (value) {
                                setState(() {
                                  passIsObscure=!passIsObscure;
                                });}),
                              WidgetsConstructor().makeResponsiveText(context,
                                  'Mostrar', Colors.black, 2, 5.0, 0.0, 'no'),
                            ],
                          ),

                          /*
                      SizedBox(height: heightPercent*0.02,),

                      //senha confirmação txtfield
                      Container(
                          height: heightPercent*0.09,
                          width: widthPercent*0.85,
                          child: TextFormField(
                              controller: passwordConfirmationController,
                              obscureText: true,
                              validator: (value){
                                if(value.isEmpty){
                                  return 'Confirme a senha';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Confirme a senha',
                                suffixIcon: passWordConfirmIsOk==true ? Icon(Icons.done, color: CustomColors.yellow,) : null,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: CustomColors.yellow, width: 2.0)
                                ),
                              ),
                              textInputAction: TextInputAction.done
                          )
                      ),
                       */
                          SizedBox(height: heightPercent*0.06,),

                          Container(
                            width: widthPercent*0.5,
                            height: heightPercent*0.08,
                            child: RaisedButton(
                              onPressed: (){

                                if(btnIsEnable==true){

                                  if (_formKey.currentState.validate()) {
                                    if (passwordIsOk==false){
                                      _displaySnackBar(context, "Verifique a senha");

                                    } else if(emailIsOk==false){
                                      _displaySnackBar(context, "Email inválido");

                                    } else if(nameController.text.isEmpty){
                                      _displaySnackBar(context, "Informe o nome");
                                    } else {
                                      if (passwordController.text.length==_sizeOfPassword){

                                        setState(() {
                                          isLoading=false;
                                        });
                                        btnIsEnable=false;

                                        newAuthService.SignUpNewUserWithEmailAndPassword(userModel, nameController.text, emailController.text, passwordController.text, () {_onSucess(homePageModel); }, () {_onFailure();});

                                      } else {

                                        _displaySnackBar(context, "As senhas informadas não são iguais");
                                      }
                                    }

                                  }

                                } else{
                                  //faça nada, btn esta desabilitado
                                }


                              },
                              splashColor: Colors.blue,
                              color: CustomColors.blue,
                              child: WidgetsConstructor().makeResponsiveText(context, 'Registrar', Colors.white, 2, 0.0, 0.0, 'center'),
                            ),
                          ),

                          SizedBox(height: heightPercent*0.01,),




                        ],
                      ),
                    ),
                  ],
                );

              },
            );
          },
        );
      },
    );
  }

  //https://firebase.flutter.dev/docs/overview/


  void _onSucess(HomePageModel homePageModel){
    /*
    setState(() {
      isLoading = false;
    });
   */

    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Usuário criado com sucesso! Redirecionando"), backgroundColor: Theme.of(context).primaryColor, duration: Duration(seconds: 2),)
    );
    Future.delayed(Duration(seconds: 1)).then((_){

      homePageModel.updateFirstLoad(true);
      homePageModel.updateShouldForceVerify(true);
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => HomePage()));

      /*
      Navigator.of(context).pop();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage())
      );

       */

    });

  }

  void _onFailure(){
    setState(() {
      isLoading = false;
    });
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Ocorreu um erro na identificação. Verifique os dados fornecidos."), backgroundColor: Colors.red, duration: Duration(seconds: 5),)
    );

  }


  _displaySnackBar(BuildContext context, String msg) {

    final snackBar = SnackBar(
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

}

