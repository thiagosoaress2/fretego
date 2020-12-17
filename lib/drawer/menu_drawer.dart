import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretego/login/pages/login_choose_view.dart';
import 'package:fretego/login/services/new_auth_service.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/mercadopago.dart';
import 'package:fretego/pages/payment_page.dart';
import 'package:fretego/pages/move_day_page.dart';
import 'package:fretego/pages/my_moves.dart';
import 'package:fretego/pages/select_itens_page.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class MenuDrawer extends StatefulWidget {

  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}



class _MenuDrawerState extends State<MenuDrawer> {


  Map<String, dynamic> userData = Map();


  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService){
            return Drawer(
                child: ListView(
                  //padding:EdgeInsets.only(top: 16.0),
                    children: [
                      DrawerHeader(  //cabeçalho
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          //child:Text(userModel.Uid != "" ? userModel.FullName : "Você não está logado"),
                          child: WidgetsConstructor().makeSimpleText(userModel.Uid != "" ? userModel.FullName : "Você não está logado", Colors.white, 15.0),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                        ),
                      ),
                      InkWell( //só exibir o botão de loggin se não estiver logado
                        onTap: (){ //click

                          Navigator.of(context).pop();
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => LoginChooseView()));


                        },
                        child: Container(

                          child: _drawLine(Icons.person, "Login", Theme.of(context).primaryColor, context),
                        ),
                      ),
                      InkWell( //toque com animação
                        onTap: (){ //click

                          /*
                      Navigator.of(context).pop();
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => SelectItensPage()));

                       */

                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 20.0),
                          child: _drawLine(Icons.airport_shuttle, "Quero me mudar", Theme.of(context).primaryColor, context),
                        ),
                      ),

                      InkWell( //toque com animação
                        onTap: (){ //click


                          Navigator.of(context).pop();
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => MyMoves()));


                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 20.0),
                          child: _drawLine(Icons.airport_shuttle, "Minhas mudanças", Theme.of(context).primaryColor, context),
                        ),
                      ),

                      InkWell( //toque com animação
                        onTap: (){ //click
                          setState(() {

                            Navigator.of(context).pop();
                            newAuthService.SignOut();
                            newAuthService.updateAuthStatus(false);

                            /*
                        //LoginModel().signOut();
                        AuthService(mAuth).signOut(userModel);
                        Navigator.of(context).pop();

                         */
                          });
                        },
                        child: userModel.Uid != "" ? Container(margin: EdgeInsets.only(left: 20.0), child:_drawLine(Icons.exit_to_app, "Sair da conta", Theme.of(context).primaryColor, context),) : Container(),

                      ),


                    ]
                )
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    //isLoggedIn();
  }



}


Widget _drawLine(IconData icon, String text, Color color, BuildContext context){

  return Material(
    color: Colors.transparent,
    child: Column(
      children: <Widget>[
        Container(
          height: 60.0,
          child: Row(
            children: <Widget>[
              Icon(
                icon, size: 32.0,
                color : Theme.of(context).primaryColor,
              ),
              SizedBox(width: 32.0,),
              Text(
                text, style: TextStyle(fontSize: 16.0,
                color : Theme.of(context).primaryColor,

              ),
              ),
            ],
          ),
        ),
        Divider(),
      ],
    ),
  );

}
