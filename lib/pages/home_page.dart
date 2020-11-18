import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/drawer/menu_drawer.dart';
import 'package:fretego/login/pages/email_verify_view.dart';
import 'package:fretego/login/services/auth.dart';
import 'package:fretego/login/services/new_auth_service.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/mercadopago.dart';
import 'package:fretego/pages/mercadopago2.dart';
import 'package:fretego/pages/move_day_page.dart';
import 'package:fretego/pages/my_moves.dart';
import 'package:fretego/pages/select_itens_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/date_utils.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}


class HomePageState extends State<HomePage> {

  bool userIsLoggedIn;
  bool needCheck=true;

  bool userHasAlert=false;

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  MoveClass moveClass = MoveClass();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        //isLoggedIn(userModel);
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {

            if(needCheck==true){
              needCheck=false;
              //se nao está logado n precisa verificar nada. Pois ele pode fazer login quando quiser
              if(userIsLoggedIn==true){
                checkEmailVerified(userModel, newAuthService);
              }
            }

              return Scaffold(
                key: _scaffoldKey,
                  floatingActionButton: FloatingActionButton(backgroundColor: Colors.blue, child: Icon(Icons.add_circle, size: 50.0,), onPressed: goToRegEntrepeneurPage,),
                  appBar: AppBar(title: WidgetsConstructor().makeSimpleText("Página principal", Colors.white, 15.0),
                    backgroundColor: Colors.blue,
                    centerTitle: true,
                    actions: [
                      IconButton(color: userModel.Alert == false ? Colors.grey[50] : Colors.red, icon: Icon(Icons.add_alert_outlined, color: userModel.Alert == false ? Colors.grey[50] : Colors.red,), onPressed: (){

                        if(userModel.Alert==true){
                          Navigator.of(context).pop();
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => MyMoves()));
                        }

                      },)
                    ],
                  ),
                  drawer: MenuDrawer(),
                  body: Center(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          userIsLoggedIn == true ? Text("Logado") : Text("Nao logado"),
                          Center(
                              child: InkWell(
                                onTap: (){


                                  if(userIsLoggedIn == true){
                                    Navigator.of(context).pop();
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => SelectItensPage()));

                                  } else {
                                    _displaySnackBar(context, "Você precisa fazer login para acessar");
                                  }


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
    checkFBconnection();

    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => MercadoPago2()));

  }

  /*
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
   */




  //NOVOS METODOS LOGIN
  Future<void> checkEmailVerified(UserModel userModel, NewAuthService newAuthService) async {

    //load data in model
    await newAuthService.loadUser();

    await newAuthService.loadUserBasicDataInSharedPrefs(userModel);

    //check if email is verified
    bool isUserEmailVerified = false;
    isUserEmailVerified = await newAuthService.isUserEmailVerified();
    if(isUserEmailVerified==true){

      //now check if there is basic data in sharedPrefs
      bool existsDataInSharedPrefs = await SharedPrefsUtils().thereIsBasicInfoSavedInShared();
      if(existsDataInSharedPrefs==true){
        //if there is data, load it

        //obs: Nao precisa do metodo abaixo pois o user comum so precisa do email e id...q é pego automático no login do fb no método acima loadUserBasicDataInSharedPrefs
       //userModel = await SharedPrefsUtils().loadBasicInfoFromSharedPrefs();

      } else {
        //if there is not, load it from FB
        //await newAuthService.loadUserBasicDataInSharedPrefs(userModel);
        //the rest will be done on another metch to check what need to be done in case of more info required

        //ESTE MÉTODO ABAIXO FOI UTILIZADO NO FRETEIRO MAS AQUI APARENTEMENTE N PRECISA POIS O USER N TEM MAIS NADA A CARREGAR
        //await FirestoreServices().loadUserInfos(userModel, () {_onSucessLoadInfos(userModel);}, () {_onFailureLoadInfos(userModel);});

      }

      //verifica se tem alerta
      FirestoreServices().checkIfThereIsAlert(userModel.Uid, () { _AlertExists(userModel);});

      //verifica se tem uma mudança acontecendo agora
      checkIfExistMovegoingNow(userModel);

    } else{

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => EmailVerify()));

    }
  }

  void checkFBconnection() async {

    //SharedPrefsUtils().deletePageOneInfo();

    FirebaseAuth.instance
        .authStateChanges()
        .listen((User user) {
      if (user == null) {

        setState(() {
          userIsLoggedIn=false;
        });


      } else {

        setState(() {
          userIsLoggedIn=true;
          needCheck=true;
        });

      }
    });
  }

  void _AlertExists(UserModel userModel) {
    setState(() {
      userModel.updateAlert(true);
    });
  }

  Future<void> checkIfExistMovegoingNow(UserModel userModel) async {

    bool shouldCheckMove = await SharedPrefsUtils().checkIfThereIsScheduledMove();
    if(shouldCheckMove==true){

      await FirestoreServices().loadScheduledMoveSituationAndDateTime(moveClass, userModel, () { _ExistAmovegoinOnNow(userModel, moveClass);});

    }

  }

  Future<void> _ExistAmovegoinOnNow(UserModel userModel, MoveClass moveClass) async {

    if(moveClass.situacao == 'accepted'){

      DateTime scheduledDate = DateUtils().convertDateFromString(moveClass.dateSelected);
      DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, moveClass.timeSelected);
      final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

      if(dif.isNegative) {
        //a data já expirou


        moveClass = await FirestoreServices().loadScheduledMoveInFb(moveClass, userModel);

        Future.delayed(Duration(seconds: 5)).then((_) {

          /*
            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => AvaliationPage(_moveClass)));
          */

        });

      } else if(dif<=60 && dif>15){

        _displaySnackBar(context, "Você possui uma mudança agendada às "+moveClass.timeSelected);

      } else if(dif<=15){

        Future<void> _onSucessLoadScheduledMoveInFb() async {

          moveClass = await MoveClass().getTheCoordinates(moveClass, moveClass.enderecoOrigem, moveClass.enderecoDestino).whenComplete(() {

            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => MoveDayPage(moveClass)));

          });
        }

        //ta na hora da mudança. Abrir a pagina de mudança
        await FirestoreServices().loadScheduledMoveInFb(moveClass, userModel, (){ _onSucessLoadScheduledMoveInFb();});


      } else {

        //do nothing, falta mt ainda

      }

    }
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

