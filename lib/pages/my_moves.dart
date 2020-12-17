import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:fretego/classes/avaliation_class.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/payment_page.dart';
import 'package:fretego/pages/select_itens_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/date_utils.dart';
import 'package:fretego/utils/globals_strings.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:fretego/utils/notificationMeths.dart';
import 'package:fretego/utils/popup.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class MyMoves extends StatefulWidget {
  @override
  _MyMovesState createState() => _MyMovesState();
}

class _MyMovesState extends State<MyMoves> with AfterLayoutMixin<MyMoves> {

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  Map mapSelected;
  int indexSelected;

  bool isLoading = false;

  bool showPopUp = false;

  bool isMovesLoadedFromFb = false;

  MoveClass _moveClass = MoveClass();

  double heightPercent;
  double widthPercent;

  UserModel _userModelGlobal = UserModel();

  bool _showDarkerBackground=false;

  bool popupAck=false;

  bool _showHistoricPage=false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  @override
  void afterFirstLayout(BuildContext context) {
    loadInfoFromFb(_userModelGlobal);

  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {

        _userModelGlobal = userModel; //update userModelGlobal that will be used everywhere every rebuild

        heightPercent = MediaQuery
            .of(context)
            .size
            .height;
        widthPercent = MediaQuery
            .of(context)
            .size
            .width;

        //Query query = FirebaseFirestore.instance.collection("agendamentos_aguardando").where('moveId', isEqualTo: userModel.Uid);
        return Scaffold(
          key: _scaffoldKey,
          appBar: (
              AppBar(
                title: Text("Minhas mudanças"),
                backgroundColor: Colors.blue,
                centerTitle: true,
              )
          ),
          body: SingleChildScrollView(
              child: Stack(
                children: [

                  //listview
                  _showHistoricPage==false
                  ? Column(
                    children: [

                      _moveClass.moveId != null
                          ? ListLine2(userModel)
                          : Text("Nao tem mudança"),

                      SizedBox(height: 10.0,),

                      _moveClass.moveId != null && _moveClass.situacao == GlobalsStrings.sitAguardando ||
                          _moveClass.moveId != null && _moveClass.situacao == GlobalsStrings.sitAccepted ||
                          _moveClass.moveId != null && _moveClass.situacao == GlobalsStrings.sitTruckerQuitAfterPayment ||
                          _moveClass.moveId != null && _moveClass.situacao == GlobalsStrings.sitDeny
                          ? LineDeleteMove(userModel): Container(),

                      SizedBox(height: 20.0,),

                      _moveClass.moveId != null && _moveClass.situacao == GlobalsStrings.sitAguardando ||
                        _moveClass.moveId != null && _moveClass.situacao == GlobalsStrings.sitTruckerQuitAfterPayment ||
                        _moveClass.moveId != null && _moveClass.situacao == GlobalsStrings.sitAccepted ||
                        _moveClass.moveId != null && _moveClass.situacao == GlobalsStrings.sitPago ||
                          _moveClass.moveId != null && _moveClass.situacao == GlobalsStrings.sitDeny
                        ? LineChangeTruckerMove(userModel) : Container(),

                      SizedBox(height: 20.0,),

                        _moveClass.moveId != null && _moveClass.situacao == GlobalsStrings.sitAccepted
                          ? LinePayMove(userModel) : Container(),

                      _moveClass.situacao == GlobalsStrings.sitAccepted
                          ? GestureDetector(
                        onTap: () {
                          sendWhatsAppMsg();
                        },
                        child: WidgetsConstructor().makeButton(
                            Colors.blue,
                            Colors.white,
                            widthPercent * 0.8,
                            80.0,
                            2.0,
                            4.0,
                            "Enviar mensagem",
                            Colors.white,
                            16.0),
                      ) : Container(),

                      SizedBox(height: 50.0,),

                      Container(
                        color: Colors.brown,
                        width: widthPercent*0.95,
                        height: 70.0,
                        child: RaisedButton(
                          child: WidgetsConstructor().makeText('Ver histórico', Colors.white, 30.0, 0.0, 0.0, 'center'),
                          onPressed: (){
                            setState(() {
                              _showHistoricPage=true;
                            });
                          },
                        ),
                      ),

                      /*
                    //list
                    Container(
                      height: 300.0,
                      child: ListOfMoves(userModel),
                    ),
                     */
                    ],

                  ) : Container(),

                  _showHistoricPage==true
                      ? historic_page() : Container(),

                  showPopUp == true
                      ? popUp(userModel)
                      : Container(),

                  _showDarkerBackground==true
                      ? Container(height: heightPercent, width: widthPercent,
                      color: Colors.black54.withOpacity(0.6)): Container(),

                  _moveClass.situacao == GlobalsStrings.sitDeny && popupAck==false
                  ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Desistência', 'Ops, o profissional que você escolheu negou o serviço. Você pode escolher outro.', 'Ok', () { _popupClose(); }) : Container(),

                ],
              )
          ),
        );
      },
    );
  }

  void _popupClose(){
    setState(() {
      popupAck=true;
    });
  }

  Future<void> sendWhatsAppMsg() async {
    //fazer query e pegar o n do trucker
    setState(() {
      isLoading = true;
    });
    String phone;
    phone = await FirestoreServices().getTruckerPhone(_moveClass.freteiroId);
    //FlutterOpenWhatsapp.sendSingleMessage("918179015345", "Olá");
    setState(() {
      isLoading = false;
    });
    FlutterOpenWhatsapp.sendSingleMessage(
        "55" + phone, "Olá, escolhi você no fretesGo. Tudo bem?");
  }

  void loadInfoFromFb(UserModel userModel) {
    if (isMovesLoadedFromFb == false) {
      isMovesLoadedFromFb = true;
      FirestoreServices().checkIfExistsAmoveScheduled(userModel.Uid, () {
        _onSucessExistsMove(userModel);
      }, () {
        _onFailExistsMove();
      });
    }
  }

  Future<void> _onSucessExistsMove(UserModel userModel) async {
    //existe uma mudança para você
    _moveClass = await FirestoreServices().loadScheduledMoveInFbWithCallBack(
        _moveClass, userModel, () {
      _onSucessLoadScheduledMoveInFb(userModel);
    });
  }

  void _onFailExistsMove() {
    _displaySnackBar(context, "Você não possui mudança agendada");
  }

  void _onSucessLoadScheduledMoveInFb(UserModel userModel) {
    //update the screen
    setState(() {
      _moveClass = _moveClass;
    });
  }

  /* DESCONTINUADO POIS NAO USAMOS MAIS LISTA
  Widget ListOfMoves(UserModel userModel){ //metodo descontinuado pois retornava uma lista. Mas nosso usuário vai ter apenas uma mudança por vez, entao n precisa lista.

    Query query = FirebaseFirestore.instance.collection("agendamentos_aguardando").where('moveId', isEqualTo: userModel.Uid);

    return  StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, stream){
          if (stream.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (stream.hasError) {
            return Center(child: Text(stream.error.toString()));
          }

          QuerySnapshot querySnapshot = stream.data;

          return
            querySnapshot.size == 0
                ? Center(child: Text("Sem mudança agendada"),)
                : Expanded(child: ListView.builder(
                itemCount: querySnapshot.size,
                //itemBuilder: (context, index) => Trucker(querySnapshot.docs[index]),
                itemBuilder: (context, index) {


                  Map<String, dynamic> map = querySnapshot.docs[index].data();
                  return GestureDetector(
                    onTap: (){

                      indexSelected = index;
                      mapSelected = map;
                      //calculateDistance();
                      setState(() {
                        showPopUp=true;
                      });

                    },
                    //child: Text(map['name']),
                    child: ListLine(map),
                  );
                  //return Trucker(querySnapshot.docs[index]);

                } ),);

        }
    );

  }

  Widget ListLine(Map map){

    return Padding(padding: EdgeInsets.all(10.0),
      child: Container(
          decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 3.0),
          child: Column(
            children: [
              Row(
                children: [
                  WidgetsConstructor().makeText("Situação: ", Colors.blue, 15.0, 10.0, 5.0, null),
                  //WidgetsConstructor().makeText(returnSituation(map['situacao']), Colors.blue, 15.0, 10.0, 15.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Origem: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['endereco_origem'], Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Destino: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['endereco_destino'], Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Data: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['selectedDate'], Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Horário: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['selectedTime'], Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Valor: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText("R\$ "+map['valor'].toStringAsFixed(2), Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),

            ],
          )
      ),
    );
  }
   */

  void _clickCancelMove(UserModel userModel){

    setState(() {
      isLoading = true;
    });
    SharedPrefsUtils().clearScheduledMove();
    FirestoreServices().deleteAscheduledMove(
        _moveClass, () {
      _onSucessDelete(userModel);
    }, () {
      _onFailureDelete();
    });


  }

  void _toogleDarkScreen(){
    if(_showDarkerBackground==true){
      setState(() {
        _showDarkerBackground=false;
      });
    } else {
      setState(() {
        _showDarkerBackground=true;
      });
    }
  }

  Widget ListLine2(UserModel userModel) {
    return GestureDetector(
      onTap: () {

        if(_moveClass.situacao == GlobalsStrings.sitAguardando){
          setState(() {
            _showDarkerBackground=true;
          });
          MyBottomSheet().settingModalBottomSheet(context, 'Cancelamento', 'Você está cancelando', 'Você tem certeza que deseja cancelar esta mudança?',
              Icons.cancel_outlined, heightPercent, widthPercent, 2, false,
              Icons.cancel, 'Sim, cancelar', () {_clickCancelMove(userModel);_toogleDarkScreen();},
              Icons.arrow_downward, 'Manter mudança', () {Navigator.pop(context); _toogleDarkScreen();}

          );
        }

        /*
        setState(() {
          showPopUp = true;
          if (_moveClass.alert.contains('user') &&
              _moveClass.alertSaw == false) {
            FirestoreServices().updateAlertView(
                _moveClass.moveId); //coloca como visto e remove o alerta
          }
        });
         */
      },
      child: Padding(padding: EdgeInsets.all(10.0),
        child: Container(
            decoration: WidgetsConstructor().myBoxDecoration(
                Colors.white, Colors.blue, 2.0, 3.0),
            child: Column(
              children: [

                //alerta
                //icone notificação
                _moveClass.alert.contains('user') &&
                    _moveClass.alertSaw == false
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.add_alert,
                      color: Colors.pink,
                      size: 24.0,
                      semanticLabel: 'Novidades',
                    ),
                  ],
                ) : Container(),

                Row(
                  children: [
                    WidgetsConstructor().makeText(
                        "Situação: ", Colors.blue, 15.0, 10.0, 5.0, null),
                    WidgetsConstructor().makeText(
                        MoveClass().returnSituation(_moveClass.situacao),
                        Colors.blue, 15.0, 10.0, 15.0, null),
                  ],
                ),
                Row(
                  children: [
                    WidgetsConstructor().makeText(
                        "Origem: ", Colors.black, 15.0, 0.0, 5.0, null),
                    WidgetsConstructor().makeText(
                        _moveClass.enderecoOrigem, Colors.black, 15.0, 0.0, 5.0,
                        null),
                  ],
                ),
                Row(
                  children: [
                    WidgetsConstructor().makeText(
                        "Destino: ", Colors.black, 15.0, 0.0, 5.0, null),
                    WidgetsConstructor().makeText(
                        _moveClass.enderecoDestino, Colors.black, 15.0, 0.0,
                        5.0, null),
                  ],
                ),
                Row(
                  children: [
                    WidgetsConstructor().makeText(
                        "Data: ", Colors.black, 15.0, 0.0, 5.0, null),
                    WidgetsConstructor().makeText(
                        _moveClass.dateSelected, Colors.black, 15.0, 0.0, 5.0,
                        null),
                  ],
                ),
                Row(
                  children: [
                    WidgetsConstructor().makeText(
                        "Horário: ", Colors.black, 15.0, 0.0, 5.0, null),
                    WidgetsConstructor().makeText(
                        _moveClass.timeSelected, Colors.black, 15.0, 0.0, 5.0,
                        null),
                  ],
                ),
                Row(
                  children: [
                    WidgetsConstructor().makeText(
                        "Valor: ", Colors.black, 15.0, 0.0, 5.0, null),
                    WidgetsConstructor().makeText(
                        "R\$ " + _moveClass.preco.toStringAsFixed(2),
                        Colors.black, 15.0, 0.0, 5.0, null),
                  ],
                ),

              ],
            )
        ),
      ),
    );
  }

  Widget LineDeleteMove(UserModel userModel){

    return Column(
      children: [
        Row(
          children: [

            SizedBox(width: widthPercent*0.05,),
            Container(width: widthPercent*0.70,
              child: WidgetsConstructor().makeText('Cancelar mudança', CustomColors.brown, 16.0, 15.0, 10.0, 'no'),
            ),
            Container(
              width: widthPercent*0.20,
              height: 50.0,
              child: RaisedButton(
                color: Colors.red,
                splashColor: Colors.grey,
                child: Icon(Icons.cancel_outlined, color: Colors.white, size: 25.0,),
                onPressed: (){

                  setState(() {
                    _showDarkerBackground=true;
                  });
                  MyBottomSheet().settingModalBottomSheet(context, 'Cancelamento', 'Você está cancelando', 'Você tem certeza que deseja cancelar esta mudança?',
                      Icons.cancel_outlined, heightPercent, widthPercent, 2, false,
                      Icons.cancel, 'Sim, cancelar', () {_clickCancelMove(userModel);Navigator.pop(context);_toogleDarkScreen();},
                      Icons.arrow_downward, 'Manter mudança', () {Navigator.pop(context); _toogleDarkScreen();}

                  );

                },
              ),
            ),
            SizedBox(width: widthPercent*0.05,),

          ],
        ),
        Container(
          color: Colors.grey[300],
          width: widthPercent,
          height: 2.0,
        ),
      ],
    );
  }

  Widget LineChangeTruckerMove(UserModel userModel){


    void _sucess(){
      _changeTrucker(userModel.Uid, _moveClass.freteiroId);

    }

    return Column(
      children: [
        Row(
          children: [

            SizedBox(width: widthPercent*0.05,),
            Container(width: widthPercent*0.70,
              child: WidgetsConstructor().makeText('Mudar profissional', CustomColors.brown, 16.0, 15.0, 10.0, 'no'),
            ),
            Container(
              width: widthPercent*0.20,
              height: 50.0,
              child: RaisedButton(
                color: Colors.blue,
                splashColor: Colors.grey,
                child: Icon(Icons.account_box_sharp, color: Colors.white, size: 25.0,),
                onPressed: (){

                  setState(() {
                    _showDarkerBackground=true;
                  });
                  MyBottomSheet().settingModalBottomSheet(context, 'Mudança', 'Você está mudando de profissional', 'Você tem certeza que deseja trocar o profissional?',
                      Icons.assignment_ind_outlined, heightPercent, widthPercent, 2, false,
                      Icons.assignment_ind_outlined, 'Sim, trocar', () {_sucess();Navigator.pop(context);_toogleDarkScreen();},
                      Icons.arrow_downward, 'Manter profissional', () {Navigator.pop(context); _toogleDarkScreen();}

                  );

                },
              ),
            ),
            SizedBox(width: widthPercent*0.05,),

          ],
        ),
        Container(
          color: Colors.grey[300],
          width: widthPercent,
          height: 2.0,
        ),
      ],
    );
  }

  Widget LinePayMove(UserModel userModel){

    return Column(
      children: [
        Row(
          children: [

            SizedBox(width: widthPercent*0.05,),
            Container(width: widthPercent*0.70,
              child: WidgetsConstructor().makeText('Pagar', CustomColors.brown, 16.0, 15.0, 10.0, 'no'),
            ),
            Container(
              width: widthPercent*0.20,
              height: 50.0,
              child: RaisedButton(
                color: CustomColors.yellow,
                splashColor: Colors.grey[200],
                child: Icon(Icons.credit_card, color: Colors.white, size: 25.0,),
                onPressed: (){

                  if(_moveClass.situacao == GlobalsStrings.sitAguardando){
                    setState(() {
                      _showDarkerBackground=true;
                    });
                    MyBottomSheet().settingModalBottomSheet(context, 'Pagamento', 'Você está pagando', 'Você deseja pagar este serviço?',
                        Icons.credit_card, heightPercent, widthPercent, 2, false,
                        Icons.credit_card, 'Pagar', () {_openPaymentPage(userModel);Navigator.pop(context);_toogleDarkScreen();},
                        Icons.arrow_downward, 'Pagar depois', () {Navigator.pop(context); _toogleDarkScreen();}

                    );
                  }

                },
              ),
            ),
            SizedBox(width: widthPercent*0.05,),

          ],
        ),
        Container(
          color: Colors.grey[300],
          width: widthPercent,
          height: 2.0,
        ),
      ],
    );
  }

  void _openPaymentPage(UserModel userModel){

    void _callback(){
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => PaymentPage(_moveClass)));
    }

    setState(() {
      isLoading=true;
    });
    FirestoreServices().loadScheduledMoveInFbWithCallBack(_moveClass, userModel, () {_callback();} );

  }

  Widget popUp(UserModel userModel) {
    return Container(
      width: widthPercent,
      height: heightPercent,
      child: Center(
        child: Container(
          decoration: WidgetsConstructor().myBoxDecoration(
              Colors.white, Colors.blue, 4.0, 4.0),
          height: heightPercent * 0.5,
          width: widthPercent * 0.8,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CloseButton(
                      onPressed: () {
                        setState(() {
                          showPopUp = false;
                        });
                      },
                    )
                  ],
                ),

                WidgetsConstructor().makeText(
                    "Atenção", Colors.black, 18.0, 20.0, 20.0, "center"),
                WidgetsConstructor().makeText(
                    "Você tem certeza que deseja cancelar esta mudança?",
                    Colors.black, 16.0, 0.0, 25.0, null),
                SizedBox(height: heightPercent * 0.05,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //botao de cancelar
                    GestureDetector(
                      onTap: () {
                        _displaySnackBar(
                            context, "O agendamento está sendo cancelado.");
                        setState(() {
                          isLoading = true;
                        });
                        SharedPrefsUtils().clearScheduledMove();
                        FirestoreServices().deleteAscheduledMove(
                            _moveClass, () {
                          _onSucessDelete(userModel);
                        }, () {
                          _onFailureDelete();
                        });
                      },
                      child: WidgetsConstructor().makeButton(
                          Colors.red,
                          Colors.white,
                          _moveClass.situacao == GlobalsStrings.sitAguardando ? widthPercent *
                              0.3 : widthPercent * 0.7,
                          60.0,
                          2.0,
                          4.0,
                          "Cancelar",
                          Colors.white,
                          18.0),
                    ),

                    //botao de trocar motorista
                    _moveClass.situacao == GlobalsStrings.sitAguardando
                        ? GestureDetector(
                      onTap: () {
                        //trocar a situação do motorista no firestore e no shared.
                        _changeTrucker(userModel.Uid, _moveClass.freteiroId);
                      },
                      child: WidgetsConstructor().makeButton(
                          Colors.blue,
                          Colors.white,
                          widthPercent * 0.3,
                          60.0,
                          2.0,
                          4.0,
                          "Trocar motorista",
                          Colors.white,
                          18.0),
                    )
                        : Container(),

                  ],
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget historic_page(){

    return Container(
      constraints: BoxConstraints.expand(),
      color: Colors.white,
      child: SingleChildScrollView(
        child:Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CloseButton(
                  onPressed: (){
                    setState(() {
                      _showHistoricPage=false;
                    });
                  },
                ),
              ],
            ),
            WidgetsConstructor().makeText('Não disponível ainda', Colors.black, 25.0, 30.0, 0.0, 'center'),

          ],
        ),
      ),
    );

  }

  void _changeTrucker(String id, String idFreteiro) {
    setState(() {
      isLoading = true;
    });
    FirestoreServices().changeTrucker(id, () {
      _onSucessChangeTrucker(idFreteiro, id);
    }, () {
      _onFailureChangeTrucker();
    });
  }

  void _onSucessDelete(UserModel userModel) {
    userModel.updateThisUserHasAmove(false);

    FirestoreServices().notifyTruckerThatHeWasChanged(_moveClass.freteiroId, _moveClass.moveId); //alerta ao freteiro que ele foi cancelado na mudança. No freteiro vai recuperar isso para cancelar as notificações locais.

    //cancelar as notificações neste caso
    NotificationMeths().turnOffNotification(flutterLocalNotificationsPlugin); //apaga todas as notificações deste user


    void _onFinishSaveNewAvaliation(){
      _displaySnackBar(context, "Pronto, o agendamento foi cancelado.");
      _moveClass = MoveClass();

      setState(() {
        isLoading = false;
      });
    }

    void _onFinishLoadAvaliation(double userRate){

      double finalRate;

      if(userRate!=0.0){
        if(userRate<1.0){
          finalRate=0.0;
        } else {
          finalRate=userRate-1.0;
        }

        FirestoreServices().saveOwnAvaliation(userModel.Uid, finalRate, () {_onFinishSaveNewAvaliation();});

      } else {
        _onFinishSaveNewAvaliation();
      }

    }


    double rate;
    //pega a rate do user pra punir
    FirestoreServices().loadOwnAvaliation(userModel.Uid, rate, (rate) {_onFinishLoadAvaliation(rate);});


  }

  void _onFailureDelete() {
    _displaySnackBar(context,
        "Ocorreu um erro. O agendamento não foi cancelado. Tente novamente em instantes.");
  }

  Future<void> _onSucessChangeTrucker(String idFreteiro, String moveId) async {
    FirestoreServices().notifyTruckerThatHeWasChanged(idFreteiro,
        moveId); //alerta ao freteiro que ele foi cancelado na mudança. No freteiro vai recuperar isso para cancelar as notificações locais.

    await SharedPrefsUtils().updateSituation("sem motorista");
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => SelectItensPage()));
  }

  void _onFailureChangeTrucker() {
    setState(() {
      isLoading = false;
    });
    _displaySnackBar(context, "Ocorreu um erro. Tente novamente");
  }

  _displaySnackBar(BuildContext context, String msg) {
    final snackBar = SnackBar(
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
class MyMoves extends StatefulWidget {
  @override
  _MyMovesState createState() => _MyMovesState();
}

class _MyMovesState extends State<MyMoves> {

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  Map mapSelected;
  int indexSelected;

  bool isLoading=false;

  bool showPopUp=false;

  bool isMovesLoadedFromFb=false;

  MoveClass _moveClass = MoveClass();

  double heightPercent;
  double widthPercent;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel){

        loadInfoFromFb(userModel);

        heightPercent = MediaQuery.of(context).size.height;
        widthPercent = MediaQuery.of(context).size.width;

        //Query query = FirebaseFirestore.instance.collection("agendamentos_aguardando").where('moveId', isEqualTo: userModel.Uid);
        return Scaffold(
          key: _scaffoldKey,
          appBar: (
              AppBar(
                title: Text("Minhas mudanças"),
                backgroundColor: Colors.blue,
                centerTitle: true,
              )
          ),
          body: SingleChildScrollView(
            child: Stack(
              children: [

                //listview
                Column(
                  children: [

                    _moveClass.moveId != null
                    ? ListLine2()
                    : Text("Nao tem mudança"),

                    SizedBox(height: 10.0,),

                    _moveClass.situacao == 'deny'
                    ? GestureDetector(
                      onTap: (){
                        _changeTrucker(userModel.Uid, _moveClass.freteiroId);
                      },
                      child: WidgetsConstructor().makeButton(Colors.blue, Colors.white, widthPercent*0.8, 80.0, 2.0, 4.0, "Escolher outro\profissional", Colors.white, 16.0),
                    ) : Container(),

                    _moveClass.situacao == 'accepted'
                        ? GestureDetector(
                      onTap: (){
                        sendWhatsAppMsg();
                      },
                      child: WidgetsConstructor().makeButton(Colors.blue, Colors.white, widthPercent*0.8, 80.0, 2.0, 4.0, "Enviar mensagem", Colors.white, 16.0),
                    ) : Container(),

                    SizedBox(height: heightPercent*0.30,),

                    Positioned(
                      child: WidgetsConstructor().makeButton(Colors.red, Colors.white, widthPercent*0.95, 60.0, 3.0, 4.0, "Ver histórico", Colors.white, 17.0),
                      bottom: 0.5,
                      left: 0.5,
                      right: 0.5,
                    ),

                    /*
                    //list
                    Container(
                      height: 300.0,
                      child: ListOfMoves(userModel),
                    ),
                     */
                  ],

                ),


                showPopUp==true
                ? popUp(userModel)
                : Container(),

              ],
            )
          ),
        );
      },
    );
  }

  Future<void> sendWhatsAppMsg() async {
    //fazer query e pegar o n do trucker
    setState(() {
      isLoading=true;
    });
    String phone;
    phone = await FirestoreServices().getTruckerPhone(_moveClass.freteiroId);
    //FlutterOpenWhatsapp.sendSingleMessage("918179015345", "Olá");
    setState(() {
      isLoading=false;
    });
    FlutterOpenWhatsapp.sendSingleMessage("55"+phone, "Olá, escolhi você no fretesGo. Tudo bem?");
  }

  void loadInfoFromFb(UserModel userModel){
    if(isMovesLoadedFromFb==false){
      isMovesLoadedFromFb=true;
      FirestoreServices().checkIfExistsAmoveScheduled(userModel.Uid, () {_onSucessExistsMove(userModel);}, () {_onFailExistsMove(); });
    }
  }

  Future<void> _onSucessExistsMove(UserModel userModel) async {
    //existe uma mudança para você
    _moveClass = await FirestoreServices().loadScheduledMoveInFbWithCallBack(_moveClass, userModel, () {_onSucessLoadScheduledMoveInFb(userModel);});
  }

  void _onFailExistsMove(){
    _displaySnackBar(context, "Você não possui mudança agendada");
  }

  void _onSucessLoadScheduledMoveInFb(UserModel userModel){

    //update the screen
    setState(() {
      _moveClass = _moveClass;
    });
  }

  /* DESCONTINUADO POIS NAO USAMOS MAIS LISTA
  Widget ListOfMoves(UserModel userModel){ //metodo descontinuado pois retornava uma lista. Mas nosso usuário vai ter apenas uma mudança por vez, entao n precisa lista.

    Query query = FirebaseFirestore.instance.collection("agendamentos_aguardando").where('moveId', isEqualTo: userModel.Uid);

    return  StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, stream){
          if (stream.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (stream.hasError) {
            return Center(child: Text(stream.error.toString()));
          }

          QuerySnapshot querySnapshot = stream.data;

          return
            querySnapshot.size == 0
                ? Center(child: Text("Sem mudança agendada"),)
                : Expanded(child: ListView.builder(
                itemCount: querySnapshot.size,
                //itemBuilder: (context, index) => Trucker(querySnapshot.docs[index]),
                itemBuilder: (context, index) {


                  Map<String, dynamic> map = querySnapshot.docs[index].data();
                  return GestureDetector(
                    onTap: (){

                      indexSelected = index;
                      mapSelected = map;
                      //calculateDistance();
                      setState(() {
                        showPopUp=true;
                      });

                    },
                    //child: Text(map['name']),
                    child: ListLine(map),
                  );
                  //return Trucker(querySnapshot.docs[index]);

                } ),);

        }
    );

  }

  Widget ListLine(Map map){

    return Padding(padding: EdgeInsets.all(10.0),
      child: Container(
          decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 3.0),
          child: Column(
            children: [
              Row(
                children: [
                  WidgetsConstructor().makeText("Situação: ", Colors.blue, 15.0, 10.0, 5.0, null),
                  //WidgetsConstructor().makeText(returnSituation(map['situacao']), Colors.blue, 15.0, 10.0, 15.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Origem: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['endereco_origem'], Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Destino: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['endereco_destino'], Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Data: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['selectedDate'], Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Horário: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['selectedTime'], Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Valor: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText("R\$ "+map['valor'].toStringAsFixed(2), Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),

            ],
          )
      ),
    );
  }
   */

  Widget ListLine2(){

    return GestureDetector(
      onTap: (){
        setState(() {
          showPopUp=true;
          if(_moveClass.alert.contains('user')  && _moveClass.alertSaw == false){
            FirestoreServices().updateAlertView(_moveClass.moveId); //coloca como visto e remove o alerta
          }
        });
      },
      child: Padding(padding: EdgeInsets.all(10.0),
        child: Container(
            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 3.0),
            child: Column(
              children: [

                //alerta
                //icone notificação
                _moveClass.alert.contains('user')  && _moveClass.alertSaw == false
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.add_alert,
                      color: Colors.pink,
                      size: 24.0,
                      semanticLabel: 'Novidades',
                    ),
                  ],
                ) : Container(),

                Row(
                  children: [
                    WidgetsConstructor().makeText("Situação: ", Colors.blue, 15.0, 10.0, 5.0, null),
                    WidgetsConstructor().makeText(MoveClass().returnSituation(_moveClass.situacao), Colors.blue, 15.0, 10.0, 15.0, null),
                  ],
                ),
                Row(
                  children: [
                    WidgetsConstructor().makeText("Origem: ", Colors.black, 15.0, 0.0, 5.0, null),
                    WidgetsConstructor().makeText(_moveClass.enderecoOrigem, Colors.black, 15.0, 0.0, 5.0, null),
                  ],
                ),
                Row(
                  children: [
                    WidgetsConstructor().makeText("Destino: ", Colors.black, 15.0, 0.0, 5.0, null),
                    WidgetsConstructor().makeText(_moveClass.enderecoDestino, Colors.black, 15.0, 0.0, 5.0, null),
                  ],
                ),
                Row(
                  children: [
                    WidgetsConstructor().makeText("Data: ", Colors.black, 15.0, 0.0, 5.0, null),
                    WidgetsConstructor().makeText(_moveClass.dateSelected, Colors.black, 15.0, 0.0, 5.0, null),
                  ],
                ),
                Row(
                  children: [
                    WidgetsConstructor().makeText("Horário: ", Colors.black, 15.0, 0.0, 5.0, null),
                    WidgetsConstructor().makeText(_moveClass.timeSelected, Colors.black, 15.0, 0.0, 5.0, null),
                  ],
                ),
                Row(
                  children: [
                    WidgetsConstructor().makeText("Valor: ", Colors.black, 15.0, 0.0, 5.0, null),
                    WidgetsConstructor().makeText("R\$ "+_moveClass.preco.toStringAsFixed(2), Colors.black, 15.0, 0.0, 5.0, null),
                  ],
                ),

              ],
            )
        ),
      ),
    );
  }

  Widget popUp(UserModel userModel){

    return Container(
      width: widthPercent,
        height: heightPercent,
      child: Center(
        child: Container(
          decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 4.0, 4.0),
          height: heightPercent*0.5,
          width: widthPercent*0.8,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CloseButton(
                      onPressed: (){
                        setState(() {
                          showPopUp=false;
                        });
                      },
                    )
                  ],
                ),

                WidgetsConstructor().makeText("Atenção", Colors.black, 18.0, 20.0, 20.0, "center"),
                WidgetsConstructor().makeText("Você tem certeza que deseja cancelar esta mudança?", Colors.black, 16.0, 0.0, 25.0, null),
                SizedBox(height: heightPercent*0.05,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //botao de cancelar
                    GestureDetector(
                      onTap: (){

                        _displaySnackBar(context, "O agendamento está sendo cancelado.");
                        setState(() {
                          isLoading=true;
                        });
                        SharedPrefsUtils().clearScheduledMove();
                        FirestoreServices().deleteAscheduledMove(_moveClass, () {_onSucessDelete(userModel); }, () { _onFailureDelete(); });

                      },
                      child: WidgetsConstructor().makeButton(Colors.red, Colors.white, _moveClass.situacao == "aguardando" ? widthPercent*0.3 : widthPercent*0.7, 60.0, 2.0, 4.0, "Cancelar", Colors.white, 18.0),
                    ),

                    //botao de trocar motorista
                    _moveClass.situacao == "aguardando"
                    ? GestureDetector(
                      onTap: (){
                        //trocar a situação do motorista no firestore e no shared.
                        _changeTrucker(userModel.Uid, _moveClass.freteiroId);
                        
                      },
                      child: WidgetsConstructor().makeButton(Colors.blue, Colors.white, widthPercent*0.3, 60.0, 2.0, 4.0, "Trocar motorista", Colors.white, 18.0),
                    )
                        : Container(),
                    
                  ],
                )

              ],
            ),
          ),
        ),
      ),
    );

  }

  void _changeTrucker(String id, String idFreteiro){

    setState(() {
      isLoading=true;
    });
    FirestoreServices().changeTrucker(id, () {_onSucessChangeTrucker(idFreteiro, id); }, () {_onFailureChangeTrucker(); });

  }
  
  void _onSucessDelete(UserModel userModel){

    userModel.updateThisUserHasAmove(false);

    FirestoreServices().notifyTruckerThatHeWasChanged(_moveClass.freteiroId, _moveClass.moveId); //alerta ao freteiro que ele foi cancelado na mudança. No freteiro vai recuperar isso para cancelar as notificações locais.

    //cancelar as notificações neste caso
    NotificationMeths().turnOffNotification(flutterLocalNotificationsPlugin); //apaga todas as notificações deste user

    _displaySnackBar(context, "Pronto, o agendamento foi cancelado.");
    _moveClass= MoveClass();

    setState(() {
      isLoading=false;
    });
  }

  void _onFailureDelete(){
    _displaySnackBar(context, "Ocorreu um erro. O agendamento não foi cancelado. Tente novamente em instantes.");
  }

  Future<void> _onSucessChangeTrucker(String idFreteiro, String moveId) async {

    FirestoreServices().notifyTruckerThatHeWasChanged(idFreteiro, moveId); //alerta ao freteiro que ele foi cancelado na mudança. No freteiro vai recuperar isso para cancelar as notificações locais.

    await SharedPrefsUtils().updateSituation("sem motorista");
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => SelectItensPage()));

  }

  void _onFailureChangeTrucker(){
    setState(() {
      isLoading=false;
    });
    _displaySnackBar(context, "Ocorreu um erro. Tente novamente");
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


 */



