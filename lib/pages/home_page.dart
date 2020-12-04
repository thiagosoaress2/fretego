import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/drawer/menu_drawer.dart';
import 'package:fretego/login/pages/email_verify_view.dart';
import 'package:fretego/login/services/auth.dart';
import 'package:fretego/login/services/new_auth_service.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/mercadopago.dart';
import 'package:fretego/pages/payment_page.dart';
import 'package:fretego/pages/move_day_page.dart';
import 'package:fretego/pages/my_moves.dart';
import 'package:fretego/pages/select_itens_page.dart';
import 'package:fretego/pages/user_informs_bank_data_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/date_utils.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}


class HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage> {

  bool userIsLoggedIn;
  bool needCheck=true;

  bool userHasAlert=false;

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  MoveClass moveClassGlobal = MoveClass();

  double heightPercent;
  double widthPercent;

  bool showPayBtn=false;
  bool _showPayPopUp=false;

  bool _showMoveShortCutBtn=false;
  bool _showPayBtn=false; //somente se a situação for accepted

  UserModel userModelGLobal;
  NewAuthService _newAuthService;

  String popupCode='no';

  bool isLoading=false;

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    // isto é exercutado após todo o layout ser renderizado

    await checkFBconnection();
    if(userIsLoggedIn==true){
      checkEmailVerified(userModelGLobal, _newAuthService);
    }


  }

  @override
  Widget build(BuildContext context) {

    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;


    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        //isLoggedIn(userModel);

        userModelGLobal = userModel;


        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {

            _newAuthService = newAuthService;

            /*
            if(needCheck==true){
              needCheck=false;
              //se nao está logado n precisa verificar nada. Pois ele pode fazer login quando quiser
              if(userIsLoggedIn==true){
                checkEmailVerified(userModel, newAuthService);
              }
            }

             */

              return Scaffold(
                key: _scaffoldKey,
                  floatingActionButton: FloatingActionButton(backgroundColor: Colors.blue, child: Icon(Icons.add_circle, size: 50.0,), onPressed: (){print('click');},),
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
                  body: SafeArea(
                    child: Stack(
                      children: [

                        Center(
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
                                ),
                                SizedBox(height: 25.0,),

                                //botao com link pra mudança
                                Center(
                                  child: _showMoveShortCutBtn == true
                                  ? showShortCutToMove()
                                  : Container(),
                                ),

                                Center(
                                  child: _showPayBtn==true
                                  ?  showPayButtonInShortCutMode(userModel)
                                      : Container(),
                                ),


                              ],
                            ),
                          ),
                        ),

                        showPayBtn == true
                            ? WidgetsConstructor().customPopUp('Efetuar pagamento', 'Sua mudança ocorrerá em instantes. Efetue o pagamento para que o motorista inicie os procedimentos.', 'Pagar', 'Depois', widthPercent, heightPercent,  () {_onPressPopup();}, () {_onPressPopupCancel();})
                            : Container(),

                        _showPayPopUp==true
                        ? WidgetsConstructor().customPopUp('Chegou a hora', 'Você têm uma mudança agendada para às '+moveClassGlobal.timeSelected+". Efetue o pagamento para o profissional começar a se deslocar até o ponto combinado.", 'Pagar', 'Depois', widthPercent, heightPercent, () {_callbackPopupBtnPay(userModel);}, () {_callbackPopupBtnCancel();})
                            : Container(),

                        popupCode=='no'
                        ? Container()
                        : popupCode=='accepted_little_negative'
                          ? WidgetsConstructor().customPopUp('Atenção!', 'Você ainda pagou pela mudança. O profissional ainda não cancelou o serviço e caso decida pagar, ainda pode ocorrer.', 'Pagar', 'Depois', widthPercent, heightPercent,
                                  () {_aceppted_little_lateCallback_Pagar(userModel);}, () {_aceppted_little_lateCallback_Depois();})
                            : popupCode=='accepted_much_negative'
                            ? WidgetsConstructor().customPopUp1Btn('Atenção', 'Você possuia uma mudança agendada às'+moveClassGlobal.timeSelected+' na data '+moveClassGlobal.dateSelected+', no entanto não efetuou pagamento. Esta mudança foi cancelada pela falta de pagamento.', Colors.red, widthPercent, heightPercent,
                                  () {_aceppted_toMuch_lateCallback_Delete();})
                              : popupCode=='accepted_timeToMove'
                              ? WidgetsConstructor().customPopUp("Atenção", "Você tem uma mudança agendada para daqui a pouco. No entanto você ainda não efetuou o pagamento. Nesta situação o profissional não começa a se deslocar enquanto não houver pagamento.", 'Pagar', 'Depois', widthPercent, heightPercent, () {_acepted_almostTime(userModel);}, () {_setPopuoCodeToDefault();})
                                : popupCode=='pago_little_negative'
                                ? WidgetsConstructor().customPopUp('Sua mudança', "Você tem uma mudança que iniciou às "+moveClassGlobal.timeSelected+'.', 'Ir para mudança', 'Depois', widthPercent, heightPercent, () {_pago_little_lateCallback_IrParaMudanca(userModel);} , () {_setPopuoCodeToDefault();})
                                : popupCode == 'pago_much_negative'
                                  ? WidgetsConstructor().customPopUp('Sua mudança', "Você tem uma mudança que iniciou às "+moveClassGlobal.timeSelected+'.', 'Ir para mudança', 'Depois', widthPercent, heightPercent, () {_pago_toMuch_lateCallback_Finalizar(userModel);} , () {_setPopuoCodeToDefault();})
                                  : popupCode == 'pago_almost_time'
                                    ? WidgetsConstructor().customPopUp('Quase na hora', 'Você tem uma mudança agendada para daqui a pouco.', 'Ir para mudança', 'Fechar', widthPercent, heightPercent, () {_pago_almost_time(userModel);} , () {_setPopuoCodeToDefault();} )
                                    : popupCode=='pago_timeToMove'
                                      ? WidgetsConstructor().customPopUp('Hora da mudança', 'Você tem uma mudança agora.', 'Ir para mudança', 'Depois', widthPercent, heightPercent, () {_pago_almost_time(userModel);} , () {_setPopuoCodeToDefault();} )
                                      : popupCode=='sistem_canceled'
                                        ? WidgetsConstructor().customPopUp1Btn('Atenção', 'Você não efetuou o pagamento para uma mudança que estava agendada. Nós cancelamos este serviço.', Colors.red, widthPercent, heightPercent, () {_quit_systemQuitMove(userModel);})
                                        : popupCode=='trucker_quited_after_payment'
                                          ? WidgetsConstructor().customPopUp('Pedimos perdão', 'Infelizmente o profissional que você escolheu desistiu do serviço. Sabemos o quanto isso é chato e oferecemos as seguintes opções:', 'Escolher outro', 'Reaver dinheiro', widthPercent, heightPercent, () { _trucker_quitedAfterPayment_getNewTrucker();}, () { _trucker_quitedAfterPayment_cancel(userModel);})
                                          : Container(),
                      ],
                    ),
                  )
              );
          },
        );
      },
    );
  }

  /*
  CALBACKS DOS POPUPS
   */
  void _aceppted_little_lateCallback_Pagar(UserModel userModel){
    //levar pra página de pagar

    _openPaymentPageFromCallBacks(userModel);

  }

  void _aceppted_little_lateCallback_Depois(){
    //fechar popup
    _setPopuoCodeToDefault();
  }

  void _aceppted_toMuch_lateCallback_Delete(){
    //deletar do bd

    void _onSucess(){
      _displaySnackBar(context, 'A mudança foi cancelada');
      FirestoreServices().createTruckerAlertToInformMoveDeleted(moveClassGlobal, 'pagamento');
      _setPopuoCodeToDefault();
      moveClassGlobal = MoveClass();

    }

    void _onFail(){
      _displaySnackBar(context, 'Ocorreu um erro');
    }

    FirestoreServices().deleteAscheduledMove(moveClassGlobal, () {_onSucess();}, () {_onFail();});
  }

  void _acepted_almostTime(UserModel userModel){

    _openPaymentPageFromCallBacks(userModel);
  }

  void _openPaymentPageFromCallBacks(UserModel userModel){

    void _callback(){
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => PaymentPage(moveClassGlobal)));
      _setPopuoCodeToDefault();
    }

    setState(() {
      isLoading=true;
    });
    FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClassGlobal, userModel, () {_callback();} );

  }

  void _pago_little_lateCallback_IrParaMudanca(UserModel userModel){
    //ir para pagina de mudança
    _goToMovePage(userModel);

  }

  void _pago_toMuch_lateCallback_Finalizar(UserModel userModel){
    //deletar do bd

    _goToMovePage(userModel);
  }

  void _pago_almost_time(UserModel userModel){
      _goToMovePage(userModel);
  }

  void _quit_systemQuitMove(UserModel userModel){
    //notificar e apagar
    void _onSucess(){
      moveClassGlobal = MoveClass();
    }

    FirestoreServices().deleteAscheduledMove(moveClassGlobal, () {_onSucess();});
    _setPopuoCodeToDefault();

  }

  void _trucker_quitedAfterPayment_getNewTrucker(){
    //escolher novo trucker
    //a gerencia de saber em qual página abrir vai ser feita na página. Neste ponto já está atualizado no bd
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => SelectItensPage()));
  }

  //aqui foi o trucker que informou que n fez a mudança, n precisa verificar e pode cancelar direto.
  Future<void> _trucker_quitedAfterPayment_cancel(UserModel userModel) async {
    //aqui vai abrir uma pagina para informar dados bancários para ressarcir

    //codigo para abrir a mudança
    setState(() {
      isLoading=true;
    });

    Future<void> _onSucessLoadScheduledMoveInFb(UserModel userModel) async {

      moveClassGlobal = await MoveClass().getTheCoordinates(moveClassGlobal, moveClassGlobal.enderecoOrigem, moveClassGlobal.enderecoDestino).whenComplete(() {

        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => UserInformsBankDataPage(moveClassGlobal)));


        setState(() {
          isLoading=false;
        });

      });
    }

    //ta na hora da mudança. Abrir a pagina de mudança
    await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClassGlobal, userModel, (){ _onSucessLoadScheduledMoveInFb(userModel);});


  }



  Future<void> _goToMovePage(UserModel userModel) async {
    //codigo para abrir a mudança
    setState(() {
      isLoading=true;
    });

    Future<void> _onSucessLoadScheduledMoveInFb(UserModel userModel) async {

      moveClassGlobal = await MoveClass().getTheCoordinates(moveClassGlobal, moveClassGlobal.enderecoOrigem, moveClassGlobal.enderecoDestino).whenComplete(() {

        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => MoveDayPage(moveClassGlobal)));

        setState(() {
          isLoading=false;
        });

      });
    }

    //ta na hora da mudança. Abrir a pagina de mudança
    await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClassGlobal, userModel, (){ _onSucessLoadScheduledMoveInFb(userModel);});

  }

  void _setPopuoCodeToDefault(){
    setState(() {
      isLoading=false;
      popupCode='no';
    });
  }

  Future<void> _solvingProblems(UserModel userModel) async {
    //esta função é para o caso do user relatar que o trucker encerrou ou nao apareceu na mudança e fechou o app. Então vai abrir
    //direto a pagina de mudança aguardando o trucker resonder
    _displaySnackBar(context, "Ainda estamos buscando a solução do seu problema, aguarde.");

    Future<void> _onSucessLoadScheduledMoveInFb() async {

      moveClassGlobal = await MoveClass().getTheCoordinates(moveClassGlobal, moveClassGlobal.enderecoOrigem, moveClassGlobal.enderecoDestino).whenComplete(() {

        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => MoveDayPage(moveClassGlobal)));

      });
    }

    //ta na hora da mudança. Abrir a pagina de mudança
    await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClassGlobal, userModel, (){ _onSucessLoadScheduledMoveInFb();});
  }

  /*
  FIM DOS CALLBACKS DOS POPUPS
   */

  void _onPressPopup(){

    print(moveClassGlobal);
    print('preco'+moveClassGlobal.preco.toString());
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => PaymentPage(moveClassGlobal)));

  }

  void _onPressPopupCancel(){
        setState(() {
          showPayBtn=false;
        });
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
    //checkFBconnection();

    /*
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => MercadoPago2()));

     */

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



  Widget _showPayAlertScreen(){
    return Positioned(
      right: 10.0,
      top: heightPercent*0.55,
      child: GestureDetector(
        onTap: (){

          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => PaymentPage(moveClassGlobal)));

        },
        child: WidgetsConstructor().makeButton(Colors.blue, Colors.white, widthPercent*0.5, 60.0, 2.0, 4.0, "Realizar pagamento pendente", Colors.white, 17.0),
      ),
    );
  }

  //NOVOS METODOS LOGIN
  Future<void> checkEmailVerified(UserModel userModel, NewAuthService newAuthService) async {

    //load data in model
    await newAuthService.loadUser();

    await newAuthService.loadUserBasicDataInSharedPrefs(userModel);

    //carregar mais infos - at this time the name
    _loadMoreInfos(userModel);

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


      _everyProcedureAfterUserHasInfosLoaded(userModel);


    } else{

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => EmailVerify()));

    }
  }

  void _everyProcedureAfterUserHasInfosLoaded(UserModel userModel){


    //verifica se tem alerta
    FirestoreServices().checkIfThereIsAlert(userModel.Uid, () { _AlertExists(userModel);});

    //verifica se tem uma mudança acontecendo agora
    checkIfExistMovegoingNow(userModel);

  }

  Future<void> _loadMoreInfos(UserModel userModel) async {
    if(await SharedPrefsUtils().checkIfExistsMoreInfos()==true){
      String name = await SharedPrefsUtils().loadMoreInfoInSharedPrefs(); //update userModel with extra info (ps: At this time only the name)
      userModel.updateFullName(name);
    } else {

      void _onSucess(){
        SharedPrefsUtils().saveMoreInfos(userModel);
      }

      FirestoreServices().getUserInfoFromCloudFirestore(userModel, () {_onSucess();});
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

    await FirestoreServices().loadScheduledMoveSituationAndDateTime(moveClassGlobal, userModel, () { _ExistAmovegoinOnNow(userModel, moveClassGlobal);});

    /*
    bool shouldCheckMove = await SharedPrefsUtils().checkIfThereIsScheduledMove();
    if(shouldCheckMove==true){

      await FirestoreServices().loadScheduledMoveSituationAndDateTime(moveClass, userModel, () { _ExistAmovegoinOnNow(userModel, moveClass);});

    }

     */

  }

  Future<void> _ExistAmovegoinOnNow(UserModel userModel, MoveClass moveClass) async {

    DateTime scheduledDate = DateUtils().convertDateFromString(moveClass.dateSelected);
    DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, moveClass.timeSelected);
    final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

    if(moveClass.situacao == 'trucker_quited_after_payment'){

      setState(() {
        popupCode='trucker_quited_after_payment';
      });

    } else if(moveClass.situacao == 'user_informs_trucker_didnt_make_move' || moveClass.situacao == 'user_informs_trucker_didnt_finished_move'){
      //user relatou problrema como: Mudança nao feita ou finalizada pelo trucker sem ter concluido
      _solvingProblems(userModel);

    } else if(moveClass.situacao == 'accepted'){

      if(dif.isNegative) {
        //a data já expirou

        if (dif > -300) {  //5 horas
          setState(() {
            popupCode = 'accepted_little_negative';
          });

          //neste caso o user fechou o app e abriu novamente

        } else {
          //a mudança já se encerrou há tempos
          setState(() {
            popupCode = 'accepted_much_negative';
          });
        }

        /*
        moveClass = await FirestoreServices().loadScheduledMoveInFbReturnMoveClass(moveClass, userModel);
         */
        //WidgetsConstructor().customPopUp('Hora de mudança', 'Você tinha uma mudança agendada mas que ainda não foi paga.', btnOk, btnCancel, widthPercent, heightPercent, () => null, () => null)

        //setState(() {
        //  showPayBtn=true;
        //});

      } else if(dif<=150 && dif>15){

        //_displaySnackBar(context, "Você possui uma mudança agendada às "+moveClass.timeSelected);

        setState(() {
          _showPayPopUp=true;
        });

      } else if(dif<=15){

        setState(() {
          popupCode='accepted_timeToMove';
        });

        /*
        Future<void> _onSucessLoadScheduledMoveInFb() async {

          moveClass = await MoveClass().getTheCoordinates(moveClass, moveClass.enderecoOrigem, moveClass.enderecoDestino).whenComplete(() {

            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => MoveDayPage(moveClass)));

          });
        }

        //ta na hora da mudança. Abrir a pagina de mudança
        await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClass, userModel, (){ _onSucessLoadScheduledMoveInFb();});
         */

      } else {

        //do nothing, falta mt ainda

      }

    } else if(moveClass.situacao == 'pago'){

      if(dif.isNegative) {
        //a data já expirou

        if (dif > -300) {  //5 horas
          setState(() {
            popupCode = 'pago_little_negative';
          });

          //neste caso o user fechou o app e abriu novamente

        } else {
          //a mudança já se encerrou há tempos
          setState(() {
            popupCode = 'pago_much_negative';
          });
        }

      } else if(dif<=150 && dif>15){

        setState(() {
          popupCode = 'pago_almost_time';
        });


        /*
        //_displaySnackBar(context, "Você possui uma mudança agendada às "+moveClass.timeSelected);
        setState(() {
          _showPayPopUp=true;
        });

         */

      } else if(dif<=15){

        setState(() {
          popupCode='pago_timeToMove';
        });

        /*
        Future<void> _onSucessLoadScheduledMoveInFb() async {

          moveClass = await MoveClass().getTheCoordinates(moveClass, moveClass.enderecoOrigem, moveClass.enderecoDestino).whenComplete(() {

            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => MoveDayPage(moveClass)));

          });
        }

        //ta na hora da mudança. Abrir a pagina de mudança
        await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClass, userModel, (){ _onSucessLoadScheduledMoveInFb();});
         */

      } else {

        //do nothing, falta mt ainda

      }


    } else if(moveClass.situacao=='quit'){
      //significa que o sistema cancelou - agora vamso cancelar essa mudança
      setState(() {
        popupCode='sistem_canceled';
      });
    }

    moveClassGlobal = moveClass; //used in showShortCutToMove


    //exibe o botao para pagar
    if(moveClass.situacao=='accepted'){
      _showPayBtn=true;
    } else {
      _showPayBtn=false;
    }

    //exibe o botao de ir pra mudança
    setState(() {
      _showMoveShortCutBtn=true;
    });

  }

  Future<void> _callbackPopupBtnPay(UserModel userModel) async {

    setState(() {
      isLoading=true;
    });

    _displaySnackBar(context, 'Carregando informações, aguarde');
    await UserModel().getEmailFromFb();
    print(userModel.Email);
    moveClassGlobal = await FirestoreServices().loadScheduledMoveInFbReturnMoveClass(moveClassGlobal, userModel);

    setState(() {
      isLoading=false;
    });

    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => PaymentPage(moveClassGlobal)));
  }

  void _callbackPopupBtnCancel(){

    setState(() {
      _showPayPopUp=false;
    });
  }


  Widget showShortCutToMove(){

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Container(
            width: widthPercent*0.75,
            height: 65.0,
            child: RaisedButton(
                textColor: Colors.white,
                child: WidgetsConstructor().makeText('Você tem uma mudança', Colors.white, 17.0, 0.0, 0.0, 'center'),
                color: Colors.blue,
                splashColor: Colors.blueGrey,
                onPressed: (){

                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => MyMoves()));

                }),
          ),

          WidgetsConstructor().makeText(MoveClass().returnSituationWithNextAction(moveClassGlobal.situacao), Colors.blue, 18.0, 20.0, 10.0, 'center'),



        ],
      ),
    );
  }

  Widget showPayButtonInShortCutMode(UserModel userModel){

    return Container(
      width: widthPercent*0.75,
      height: 65.0,
      child: RaisedButton(
        color: Colors.blueAccent,
        textColor: Colors.white,
        splashColor: Colors.blueGrey,
        child: WidgetsConstructor().makeText('Pagar adiantado', Colors.white, 18.0, 0.0, 0.0, 'center'),
        onPressed: (){
          _openPaymentPageFromCallBacks(userModel);
        },
      ),
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

