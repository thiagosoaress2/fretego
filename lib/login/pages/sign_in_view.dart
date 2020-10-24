import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretego/login/pages/sign_up_view.dart';
import 'package:fretego/login/services/auth.dart';
import 'package:fretego/login/services/new_auth_service.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/widgets/widgets_auth_widgets.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:fretego/widgets/widgets_loading.dart';
import 'package:scoped_model/scoped_model.dart';

class SignInView extends StatefulWidget {
  @override
  _SignInViewState createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {

  final _formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController = TextEditingController();

  bool isLoading = false;

  bool _obscureText = true;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  final FirebaseAuth mAuth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {
            return Scaffold(
                appBar: AppBar(title: WidgetsConstructor().makeSimpleText("Registro usuário", Colors.white, 18.0), backgroundColor: Colors.blue,),
                key: _scaffoldKey,
                body: ListView(
                  children: [
                    Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(20.0),
                              child: WidgetsAuth().editTextForEmail(emailController, "E-mail", null),
                            ),
                            Padding(
                              padding: EdgeInsets.all(20.0),
                              child: WidgetsAuth().editTextForPassword(passwordController, "Senha", null),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  child: WidgetsConstructor().makeText("Novo usuário", Colors.blue, 18.0, 10.0, 30.0, "no"),
                                  onTap: (){


                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignUpView()),
                                );


                                  },
                                ),

                                GestureDetector(
                                  child: WidgetsConstructor().makeText("Esqueceu a senha?", Colors.blue[300], 18.0, 10.0, 30.0, "no"),
                                  onTap: (){
                                    setState(() {
                                      //_page = "recover";
                                      if(emailController.text.isNotEmpty){
                                        if(emailController.text.contains("@") && emailController.text.contains(".")){
                                          //AuthRotines().recoverPass(emailController.text);
                                          //AuthRotines().recoverPass(emailController.text);
                                          //LoginModel().recoverPass(emailController.text);

                                          _displaySnackBar(context, "Enviamos um e-mail. Verifique e siga as instruções para recuperar a senha.");

                                        } else {
                                          _displaySnackBar(context, "Ops, tem algo errado no e-mail informado.");
                                        }

                                      } else {
                                        _displaySnackBar(context, "Informe o e-mail para reenviarmos sua senha.");
                                      }

                                    });
                                  },
                                ),

                              ],
                            ),

                            SizedBox(height: 30.0,),
                            Container(
                              child: RaisedButton(
                                color: Colors.lightBlue,
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {

                                    setState(() {
                                      isLoading = true;
                                    });

                                    //firebaseUser =  AuthService(mAuth).signIn(emailController.text, passwordController.text, userModel, () {_onSucess(); }, () {_onFailure(erro); });
                                    newAuthService.SignInWithEmailAndPassword(emailController.text, passwordController.text, () {_onSucess(); }, () {_onFailure(); });

                                  }
                                },
                                child: Text('Entrar'),
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                    isLoading==true ? WidgetsLoading().Loading() : Container()
                  ],
                )
            );
          },
        );
      },
    );
  }

  void _onSucess(){
    isLoading = false;
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Você está logado."), backgroundColor: Theme.of(context).primaryColor, duration: Duration(seconds: 2),)
    );
    Future.delayed(Duration(seconds: 2)).then((_){
      Navigator.of(context).pop();

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage())
      );

    });

  }

  void _onFailure(){
    isLoading = false;
    _scaffoldKey.currentState.showSnackBar(
       SnackBar(content: Text("Usuário ou senha errado"), backgroundColor: Colors.red, duration: Duration(seconds: 5),)
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

