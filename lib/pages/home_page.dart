import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretego/drawer/menu_drawer.dart';
import 'package:fretego/login/pages/email_verify_view.dart';
import 'package:fretego/login/services/auth.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/select_itens_page.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}


class HomePageState extends State<HomePage> {

  FirebaseAuth mAuth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;

  bool loggedIn = false;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        isLoggedIn(userModel);
        return Scaffold(
          floatingActionButton: FloatingActionButton(backgroundColor: Colors.blue, child: Icon(Icons.add_circle, size: 50.0,), onPressed: goToRegEntrepeneurPage,),
          appBar: AppBar(title: WidgetsConstructor().makeSimpleText("Página principal", Colors.white, 15.0),
            backgroundColor: Colors.blue,
            centerTitle: true,
          ),
          drawer: MenuDrawer(),
          body: Center(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: InkWell(
                      onTap: (){

                        //Navigator.of(context).pop();
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => SelectItensPage()));

                      },
                      child: Container(
                        width: 250.0,
                        height: 250.0,
                        padding: const EdgeInsets.all(20.0),//I used some padding without fixed width and height
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,// You can use like this way or like the below line
                          //borderRadius: new BorderRadius.circular(30.0),
                          color: Colors.redAccent,
                        ),
                        child: Center(
                            child: Text("Quero me mudar", textAlign: TextAlign.center, style:TextStyle(color: Colors.white, fontSize: 30.0),
                            )// You can add a Icon instead of text also, like below.
                          //child: new Icon(Icons.arrow_forward, size: 50.0, color: Colors.black38)),
                        ),//..........
                      ),
                    )
                  )
                ],
              ),
            ),
          )
        );
      },
    );
  }

  goToRegEntrepeneurPage(){



  }

  void isLoggedIn(UserModel userModel) async {

    firebaseUser = await AuthService(mAuth).isLoggedIn();
    if(firebaseUser != null){

      bool isVerify = await AuthService(mAuth).checkEmailVerify(firebaseUser);

      //verifica primeiro se já tem e-mail verificado
      if(isVerify == true){
        AuthService(mAuth).updateUserInfo(userModel); //carrega os dados
      } else {
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => EmailVerify()));
      }


    }

  }
}
