import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretego/drawer/menu_drawer.dart';
import 'package:fretego/login/pages/email_verify_view.dart';
import 'package:fretego/login/services/auth.dart';
import 'package:fretego/login/services/new_auth_service.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/select_itens_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}


class HomePageState extends State<HomePage> {

  //FirebaseAuth mAuth = FirebaseAuth.instance;
  //FirebaseUser firebaseUser;

  FirebaseAuth auth = FirebaseAuth.instance;
  bool userIsLoggedIn=false;
  bool loadingController=false;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        //isLoggedIn(userModel);
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {

            if(loadingController==false){
              checkUserStatus(userModel, newAuthService);
            }

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

                          userModel.Uid != "" ? Text("Logado") : Text("Nao logado"),
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
      },
    );
  }

  goToRegEntrepeneurPage(){



  }

  void isLoggedIn(UserModel userModel) async {

    /*
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

     */

  }

  @override
  void initState() {
    super.initState();

  }

  void isUserLoggedIn() {
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User user) {
      if (user == null) {

          userIsLoggedIn=false;

      } else {

        userIsLoggedIn = true;


      }
    });
  }

  void loadUserData(UserModel userModel, NewAuthService newAuthService){

    if(newAuthService.AuthStatus==true){
      if(newAuthService.isUserEmailVerified()==true){
        updateUserInfo(userModel, newAuthService);
      } else {
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => EmailVerify()));
      }
    }
  }

  Future<void> checkUserStatus(UserModel userModel, NewAuthService newAuthService) async {

    await newAuthService.checkFBconnection();
    if(newAuthService.AuthStatus==true){
      newAuthService.loadUser(); //carrega o firebase user na model. Para acessar use getFirebaseUser
    }
    loadUserData(userModel, newAuthService);
    loadingController=true;

  }

}

void updateUserInfo(UserModel userModel, NewAuthService newAuthService) async {
  var _uid = userModel.Uid;
  if(_uid !=""){
    //ja foram carregados os dados.
    print("valor uid é "+userModel.Uid);
  } else {
    User user = newAuthService.getFirebaseUser;
    userModel.updateUid(user.uid);
    FirestoreServices().getUserInfoFromCloudFirestore(userModel);
    //aqui precisa carregar o resto dos dados mas ainda n to mexendo no firestore
    //precisamos carregar os dados do user. Inicialmente pegamos do firestore...depois talvez pegaremos do sharedprefs
    //FirebaseUser firebaseUser = await _auth.currentUser();
    //FirestoreServices().loadCurrentUserData(firebaseUser, _auth, userModel);
  }
}