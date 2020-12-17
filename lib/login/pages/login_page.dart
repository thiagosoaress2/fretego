import 'package:after_layout/after_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretego/login/pages/sign_up_view.dart';
import 'package:fretego/login/services/new_auth_service.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with AfterLayoutMixin<LoginPage> {


  double heightPercent;
  double widthPercent;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailRecoveryController = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar
  final FirebaseAuth mAuth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;

  FocusNode emailFocusNode;
  FocusNode passwordFocusNode;
  final _formKey = GlobalKey<FormState>();

  bool emailIsOk=false;
  String emailMsg='no';
  bool passwordIsOk=false;

  bool isLoading=false;

  bool _showPassRecoveryPage=false;

  @override
  void afterFirstLayout(BuildContext context) {

  }


  @override
  void initState() {
    super.initState();

    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();

    _placeListeners();

  }

  void _placeListeners(){

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
      if(passwordController.text.length==6){
        setState(() {
          passwordIsOk=true;
          print('foi');
        });
      } else {
        setState(() {
          print('n foi');
          passwordIsOk=false;
        });
      }
    });
  }


  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;

    return SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          body: Container(
            color: Colors.white,
            height: heightPercent,
            width: widthPercent,
            child: Stack(
              children: [

                //fundo mais profundo
                Positioned(
                    top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      color: CustomColors.blue,
                      width: widthPercent,
                      height: heightPercent*0.35,
                    )
                ),
                //imagem
                Positioned(
                    top: heightPercent*0.07,

                    right: widthPercent*0.15,
                    child: Container(
                      child: Image.asset('images/home_couple.png', fit: BoxFit.fill,),
                      width: widthPercent,
                      height: heightPercent*0.35,
                    )
                ),
                //capa semitransparente
                Positioned(
                    top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      color: CustomColors.blue.withOpacity(0.6),
                      width: widthPercent,
                      height: heightPercent*0.35,
                    )
                ),
                //fundo branco inferior
                Positioned(
                    top: heightPercent*0.35,
                    child:
                    Container(
                      width: widthPercent,
                      height: heightPercent*0.65,
                      color: Colors.white,)
                ),
                //textinho
                Positioned(
                    top: heightPercent*0.16,
                    left: widthPercent*0.05,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetsConstructor().makeResponsiveText(context, 'Bem vindo', Colors.white, 4, 0.0, 5.0, 'no'),
                        WidgetsConstructor().makeResponsiveText(context, 'Nós queremos ajudar na sua mudança', Colors.white, 1.5, 0.0, 5.0, 'no'),
                      ],
                    )),
                //fundo flutuante
                Positioned(
                  top: heightPercent*0.28,
                  left: widthPercent*0.05,
                  right: widthPercent*0.05,
                  child: Container(
                    width: widthPercent*0.95,
                    height: heightPercent*0.60,
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 10,
                          blurRadius: 10,
                          offset: Offset(0, 10), // changes position of shadow
                        ),
                      ],
                    ),
                    child: _showPassRecoveryPage == false ? _loginElements(widthPercent*0.95, widthPercent*0.55) : _passRecoveryPage(),
                    ),
                ),


                //appbar
                Positioned(
                  top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child:fakeAppBar(),
                ),

                isLoading==true ? Center(child: CircularProgressIndicator(),) : Container(),

              ],
            ),
          ),
        ),
    );
  }

  Widget fakeAppBar(){

    void _customBackButton() {

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => HomePage()));

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
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 35,),
                    onPressed: () {
                      _customBackButton();
                    },),
                  //WidgetsConstructor().makeText(appBarText, Colors.grey[400], 9.0, 0.0, 0.0, 'center'),
                  Text('Início', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
                ],
              ),
            ),
            Container(
              width: widthPercent*0.5,
              child: WidgetsConstructor().makeResponsiveText(context, 'Login', Colors.white, 3, 0.0, 0.0, 'center'),
            ),
            Container(width: widthPercent*0.25),

          ],
      ),
    );
  }

  Widget _loginElements(double maxWidth, double maxHeight){

    //tudo tem que caber em 55%

    return ScopedModelDescendant<NewAuthService>(
      builder: (BuildContext context, Widget child, NewAuthService newAuthService){

        //procedimento de entrar e callbacks aqui dentro da função
        void _entrarClick(){

          void _onSucess(){
            isLoading = false;
            _scaffoldKey.currentState.showSnackBar(
                SnackBar(content: Text("Achamos você! Redirecionando"), backgroundColor: Theme.of(context).primaryColor, duration: Duration(seconds: 1),)
            );
            Future.delayed(Duration(seconds: 1)).then((_){
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage())
              );

            });

          }

          void _onFailure(){
            setState(() {
              isLoading = false;
            });
            _scaffoldKey.currentState.showSnackBar(
                SnackBar(content: Text("Usuário ou senha errado"), backgroundColor: Colors.red, duration: Duration(seconds: 5),)
            );

          }


          if (_formKey.currentState.validate()) {

            if(emailIsOk==true && passwordIsOk==true){

              setState(() {
                isLoading = true;
              });

              //firebaseUser =  AuthService(mAuth).signIn(emailController.text, passwordController.text, userModel, () {_onSucess(); }, () {_onFailure(erro); });
              newAuthService.SignInWithEmailAndPassword(emailController.text, passwordController.text, () {_onSucess(); }, () {_onFailure(); });


            } else {
              if(emailIsOk==false){
                emailFocusNode.requestFocus();
              } else {
                passwordFocusNode.requestFocus();
              }

            }

          }
        }

        return Column(
          children: [

            //form elements
            Form(
              key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      SizedBox(height: maxHeight*0.05,),
                      //email textfield
                      Container(
                        height: maxHeight*0.29,
                        width: maxWidth*0.75,
                        child: Focus(
                          child: TextFormField(

                            controller: emailController,
                            focusNode: emailFocusNode,
                            validator: (value){
                              if(value.isEmpty){
                                return 'Informe o e-mail';
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'E-mail cadastrado',
                              labelText: 'E-mail',
                              suffixIcon: emailIsOk==true ? Icon(Icons.done, color: CustomColors.yellow,) : null,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: CustomColors.yellow, width: 2.0),

                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,

                          ),
                          onFocusChange: (hasFocus) {
                            if(hasFocus) {

                              print('ganhou focus');
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
                        //editTextForEmail(emailController, 'E-mail', null),
                      ),
                      //mensagem de erro do email
                      Container(
                        width: maxWidth*0.75,
                        child: emailMsg != 'no' ? WidgetsConstructor().makeResponsiveText(context, emailMsg, Colors.red, 1.5, 5.0, 0.0, 'no') : Container(),
                      ),

                      SizedBox(height:  maxHeight*0.05,),
                      //senha txtfield
                      Container(
                        height: maxHeight*0.29,
                        width: maxWidth*0.75,
                        child: TextFormField(
                            controller: passwordController,
                            focusNode: passwordFocusNode,
                            obscureText: true,
                            validator: (value){
                              if(value.isEmpty){
                                return 'Informe a senha';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Sua senha deve ter 6 dígitos',
                              labelText: 'Senha',
                              suffixIcon: passwordIsOk==true ? Icon(Icons.done, color: CustomColors.yellow,) : null,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: CustomColors.yellow, width: 2.0)
                              ),
                            ),
                            textInputAction: TextInputAction.done
                        )
                      ),


                    ],
                  ),
                )),
            //btn login
            SizedBox(height: maxHeight*0.15,),
            Container(
              width: maxWidth*0.5,
                height: maxHeight*0.225,

              child: RaisedButton(
                color: CustomColors.yellow,
                child: WidgetsConstructor().makeResponsiveText(context, 'Entrar', Colors.white, 2.8, 0.0, 0.0, 'center'),
                splashColor: Colors.yellow,
                onPressed: (){
                  _entrarClick();
                },
              ),
            ),
            emailMsg == 'no' ? SizedBox(height: maxHeight*0.20,) : SizedBox(height: maxHeight*0.10,),
            WidgetsConstructor().makeResponsiveText(context, 'ou entre com', Colors.grey[500], 1.8, 0.0, 0.0, 'center'),
            SizedBox(height: maxHeight*0.05,),
            Container(
              width: maxWidth*0.5,
              height: maxHeight*0.225,

              child: RaisedButton(
                color: CustomColors.faceblue,
                child: WidgetsConstructor().makeResponsiveText(context, 'Facebook', Colors.white, 2.8, 0.0, 0.0, 'center'),
                splashColor: Colors.blue,
                onPressed: (){
                  _facebookClick();
                },
              ),
            ),
            SizedBox(height: maxHeight*0.07,),

            //linha divisório
            Container(height: 2.0, width: widthPercent*0.85, color: Colors.grey[300],),
            //botoes inferiores
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: maxWidth*0.47,
                  height: maxHeight*0.30,
                  color: Colors.white,
                  child: FlatButton(onPressed: (){
                    _novoUsuarioClick();
                  }, child: WidgetsConstructor().makeResponsiveText(context, 'Novo usuário', CustomColors.blue, 2.2, 0.0, 0.0, 'center'),)
                ),
                Container(
                  width: maxWidth*0.47,
                  height: maxHeight*0.30,
                  color: Colors.white,
                  child: FlatButton(onPressed: (){

                    setState(() {
                      _showPassRecoveryPage=true;
                    });

                  }, child: WidgetsConstructor().makeResponsiveText(context, 'Recuperar senha', CustomColors.blue, 2.0, 0.0, 0.0, 'center')),
                ),
              ],
            )


          ],
        );

      },
    );

  }

  Widget _passRecoveryPage(){


    return ScopedModelDescendant<NewAuthService>(
      builder: (BuildContext context, Widget child, NewAuthService newAuthService){

        void _perdeuSenhaClick(String email){

          void _onSucess(){
            isLoading = false;
            _scaffoldKey.currentState.showSnackBar(
                SnackBar(content: Text("Um e-mail com instruções foi enviado para "+emailRecoveryController.text), backgroundColor: Theme.of(context).primaryColor, duration: Duration(seconds: 5),)
            );
            setState(() {
              _showPassRecoveryPage=false;
            });

          }

          void _onFailure(){
            setState(() {
              isLoading = false;
            });
            _scaffoldKey.currentState.showSnackBar(
                SnackBar(content: Text("Ops, algo deu errado. Verifique se o e-mail está correto."), backgroundColor: Colors.red, duration: Duration(seconds: 5),)
            );

          }

          setState(() {
            isLoading=true;
          });

          newAuthService.recoverPassword(emailRecoveryController.text, () {_onSucess(); }, () {_onFailure();});

        }

        return Column(
          children: [
            Row(
              children: [
                IconButton(icon: Icon(Icons.arrow_back), color: CustomColors.blue, iconSize: 35.0, onPressed: (){
                  setState(() {
                    _showPassRecoveryPage=false;
                  });
                }),
                Text('Login', style: TextStyle(color: Colors.grey[400], fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
              ],
            ),

            Padding(padding: EdgeInsets.all(10.0), child: WidgetsConstructor().makeResponsiveText(context, 'Informe o e-mail para o qual enviaremos a nova senha', Colors.black, 2, 0.0, 10.0, 'center'),),
            //textview
            Container(
              height: heightPercent*0.10,
              width: widthPercent*0.75,
              child: TextFormField(

                controller: emailRecoveryController,
                validator: (value){
                  if(value.isEmpty){
                    return 'Informe o e-mail';
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'E-mail cadastrado',
                  suffixIcon: emailIsOk==true ? Icon(Icons.done, color: CustomColors.yellow,) : null,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.yellow, width: 2.0),

                  ),
                ),
                textInputAction: TextInputAction.done,

              ),
              //editTextForEmail(emailController, 'E-mail', null),
            ),
            SizedBox(height: heightPercent*0.05,),
            Container(
              width: widthPercent*0.5,
              height: heightPercent*0.10,

              child: RaisedButton(
                color: CustomColors.blue,
                child: WidgetsConstructor().makeResponsiveText(context, 'Redefinir senha', Colors.white, 2, 0.0, 0.0, 'center'),
                splashColor: Colors.blue,
                onPressed: (){
                  if(emailRecoveryController.text.isNotEmpty){
                    _perdeuSenhaClick(emailRecoveryController.text);
                  } else {
                    _scaffoldKey.currentState.showSnackBar(
                        SnackBar(content: Text("Informe o e-mail"), backgroundColor: Theme.of(context).primaryColor, duration: Duration(seconds: 4),)
                    );
                  }

                },
              ),
            ),



          ],
        );

      },
    );
  }

  void _facebookClick(){

  }

  void _novoUsuarioClick(){

    Navigator.of(context).push(_createRoute(SignUpView()));

  }

  Route _createRoute(Widget Page) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) => Page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        //var tween = Tween(begin: begin, end: end); //comente este para usar o final suave

        var curve = Curves.easeInOut; // - use este para final suave

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve)); //- use estepara final suave
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }


}
