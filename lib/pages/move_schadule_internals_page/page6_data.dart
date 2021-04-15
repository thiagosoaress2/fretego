
import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/classes/truck_class.dart';
import 'package:fretego/models/home_page_model.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/services/date_services.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/date_utils.dart' as DateUtils;
import 'package:fretego/utils/globals_strings.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fretego/utils/notificationMeths.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

bool firstLoaded=false;

class Page6Data extends StatefulWidget {
  double heightPercent;
  double widthPercent;
  String uid;
  bool reschedule;
  Page6Data(this.heightPercent, this.widthPercent, this.uid, this.reschedule);

  @override
  _Page6DataState createState() => _Page6DataState();
}

class _Page6DataState extends State<Page6Data> {
  double _distance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationAppLaunchDetails notificationAppLaunchDetails;

  @override
  Widget build(BuildContext context) {

    double heightPercent = widget.heightPercent;
    double widthPercent = widget.widthPercent;
    bool reeschedule = widget.reschedule;
    String uid = widget.uid;

    return ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget child, MoveModel moveModel){

        return ScopedModelDescendant<UserModel>(
          builder: (BuildContext context, Widget child, UserModel userModel){

            if(firstLoaded==false){
              //primeira passagem

              //se estiver reagendando vai carregar a mudança e ai calcular a distancia em seguida.
              if(widget.reschedule==true){
                _loadMovieClass(moveModel, userModel, widget.uid).then((_) {
                  _getTheDistance(moveModel);
                });
              } else{
                //se nao é um reagendamento a moveModel está no sistema e pode ser carregada direto
                _getTheDistance(moveModel);
              }

              //_waitBuiltFinishToShowCalendar(moveModel);  funciona mas tava confuso
              firstLoaded=true;

            }

            return ScopedModelDescendant<HomePageModel>(
              builder: (BuildContext context, Widget widget, HomePageModel homePageModel){
                return Scaffold(
                  body: Container(
                    width: widthPercent,
                    height: heightPercent,
                    child: Stack(
                      children: [

                        _titulo(moveModel),

                        //botão de data e hora dentro de uma column
                        _btnDataEtexto(moveModel),
                        _btnHoraEtexto(moveModel),


                        if(moveModel.dataIsOk == true ) _okIcon(heightPercent*0.44),

                        if(moveModel.horaIsOk == true) _okIcon(heightPercent*0.64),

                        /*
                        //mensagem
                        moveModel.TheDataIsOk==true && moveModel.dataIsOk==true && moveModel.horaIsOk ? Positioned(
                          bottom: 5.0,
                          right: widthPercent*0.20,
                          left: widthPercent*0.20,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Container(
                              height: heightPercent*0.08,
                              color: CustomColors.yellow,
                              child: ResponsiveTextCustom('  Continuar >', context, Colors.white, 2.5, 0.0, 0.0, 'center'),
                            ),
                          ),
                        ) : SizedBox(),
                         */

                        //floating button
                        //moveModel.dataIsOk==true && moveModel.horaIsOk ? Positioned(
                        moveModel.TheDataIsOk==true && moveModel.dataIsOk==true && moveModel.horaIsOk ? Positioned(
                            bottom: 15.0,
                            right: 10.0,
                            child: FloatingActionButton(
                              onPressed: (){

                                moveModel.updateShowResume(false);  //esta variavel foi reciclada. Ela foi usada no endereço e agora vai ser usada na pagina final. Entou agora volto ela pro estado inicial

                                moveModel.moveClass.dateSelected = DateServices().convertToStringFromDate(moveModel.SelectedDate); //salvando dentro de moveclass
                                moveModel.moveClass.timeSelected = moveModel.SelectedTime.format(context);

                                //MyBottomSheet().settingModalBottomSheet(context, 'Contactando o profissional...', '', 'Pronto. Agora é só aguardar pela confirmação. Uma vez que o profissional aceite, você pode realizar o pagamento até duas horas antes do horário da mudança.', Icons.info, heightPercent, widthPercent, 0, true);

                                moveModel.moveClass.situacao = GlobalsStrings.sitAguardando;

                                moveModel.moveClass.userId = uid;
                                SharedPrefsUtils().saveMoveClassToShared(moveModel.moveClass);

                                //aqui e´agendada a mudança
                                scheduleAmove(userModel, moveModel, context);

                                waitAmoment(3, moveModel);


                                if(reeschedule==true){
                                  //ajusta a tela principal para a volta
                                  homePageModel.moveClass.dateSelected = moveModel.moveClass.dateSelected;
                                  homePageModel.moveClass.timeSelected = moveModel.moveClass.timeSelected;
                                  homePageModel.moveClass.situacao = GlobalsStrings.sitReschedule;

                                  Navigator.of(context).pop();
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => HomePage()));
                                } else {
                                  homePageModel.moveClass.dateSelected = moveModel.moveClass.dateSelected;
                                  homePageModel.moveClass.timeSelected = moveModel.moveClass.timeSelected;
                                  homePageModel.moveClass.situacao = moveModel.moveClass.situacao;
                                  moveModel.changePageForward('final', 'data', 'Mudança agendada');
                                }

                              },
                              backgroundColor: CustomColors.yellow,
                              splashColor: Colors.yellow,
                              child: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 50.0,),
                            )
                        ) : SizedBox(),

                        if(moveModel.isLoading==true) Center(child: CircularProgressIndicator(),),

                      ],
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

  Widget _titulo(MoveModel moveModel){
    return Positioned(
      top: widget.heightPercent*0.35,
      left: 10.0,
      right: 10.0,
      child: ResponsiveTextCustom(widget.reschedule == true? 'Redefinir data e hora' : moveModel.dataIsOk==true && moveModel.horaIsOk ? 'Pronto!' : 'Definir data e hora', context, CustomColors.blue, 3.5, 0.0, 40.0, 'center'),
    );
  }

  Widget _btnDataEtexto(MoveModel moveModel){
    return Positioned(
        left: widget.widthPercent*0.05,
        top: widget.heightPercent*0.45,
        right: widget.widthPercent*0.05,
        child: Container(
          //width: widthPercent*0.38,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              //botao data
              GestureDetector(
                onTap:(){
                  _selectDate(context, moveModel);
                },
                child: Container(
                  width: widget.widthPercent*0.20,
                  child: Image.asset('images/itensselect/date/calender.png'),
                ),
              ),
              ResponsiveTextCustom(moveModel.dataIsOk == false ? 'Definir data' : 'Data escolhida', context, Colors.black, 3.0, 5.0, 0.0, 'center'),
              if(moveModel.dataIsOk == true) ResponsiveTextCustom(DateServices().convertToStringFromDate(moveModel.SelectedDate) , context, Colors.black, 2.0, 5.0, 0.0, 'center'),

            ],
          ),
        )
    );
  }

  Widget _btnHoraEtexto(MoveModel moveModel){

    return Positioned(
        left: widget.widthPercent*0.05,
        top: widget.heightPercent*0.65,
        right: widget.widthPercent*0.05,
        child: Container(
          //width: widthPercent*0.38,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //botao hora
              GestureDetector(
                  onTap: (){
                    _selectTime(context, moveModel);
                  },
                  child: Container(
                    width: widget.widthPercent*0.20,
                    child: Image.asset('images/itensselect/date/clock.png'),
                  )
              ),
              ResponsiveTextCustom(moveModel.horaIsOk==false ? 'Definir hora' : 'Hora definida', context, Colors.black, 3.0, 7.0, 0.0, 'center'),
              if(moveModel.horaIsOk == true) ResponsiveTextCustom(moveModel.SelectedTime.format(context), context, Colors.black, 2.0, 5.0, 0.0, 'center'),
            ],
          ),
        )
    );
  }

  Widget _okIcon(double top){

    return Positioned(
        top: top,
        right: widget.widthPercent*0.40,
        child: Container(
      height: widget.heightPercent*0.05,
      width: widget.widthPercent*0.08,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CustomColors.blue
      ),
      child: Icon(Icons.done, color: Colors.white, size: widget.widthPercent*0.08,),
    )
    );
  }

  Future<void> _getTheDistance(MoveModel moveModel) async {

    _distance = await MoveClass().getTheDistanceFromTwoAddress(addressOrigem: moveModel.moveClass.enderecoOrigem, adressDestino: moveModel.moveClass.enderecoDestino);
    moveModel.updateDistance(_distance);

  }

  Future<void> _loadMovieClass(MoveModel moveModel, UserModel userModel, String uid) async {

    moveModel.setIsLoading(true);

    MoveClass _moveClass = MoveClass();

    void _loadFinish(){
      print(_moveClass);
      moveModel.moveClass = _moveClass;
      print(moveModel.moveClass.moveId);
      moveModel.setIsLoading(false);
    }

    _moveClass = await FirestoreServices().copyOfloadScheduledMoveInFbWithCallBack(_moveClass, uid, () {_loadFinish();});

  }

  _selectDate(BuildContext context, MoveModel moveModel) async {

    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: moveModel.SelectedDate, // Refer step 1
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year+1),
      helpText: "Escolha data da mudança", //opcional
      //confirmText: "ok" //opcional
      //cancelText: "ok"  //opcional
    );
    if (picked != null && picked != moveModel.SelectedDate){
      moveModel.updateselectedDate(picked);
      moveModel.updateDataIsOk(true);
    }

  }

  _selectTime(BuildContext context, MoveModel moveModel) async {

    final TimeOfDay timeToStart = TimeOfDay.now().replacing(
        hour: TimeOfDay.now().hour,
        minute: TimeOfDay.now().minute
    );

    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: timeToStart,
      //initialTime: TimeOfDay.now(),
      helpText: "Escolha o horário", //opcional
    );
    if (picked != null && picked != moveModel.SelectedTime){
      moveModel.updateSelectedTime(picked);
      moveModel.updateHoraIsOk(true);
    }

  }

  void scheduleAmove(UserModel userModel, MoveModel moveModel, BuildContext context) async {

    if(widget.reschedule==true){
      //este precisa ser editado, so fiz o de baixo
      _reeschedule(moveModel, userModel, context);
    } else {
      _finishSchedule(moveModel, userModel, context);
      //FirestoreServices().scheduleAmoveInBd(moveModel.moveClass,() {_onSucess(userModel); }, () {_onFailure();});


    }

  }

  void _finishSchedule(MoveModel moveModel, UserModel userModel, BuildContext context){

    void _onSucess(UserModel userModel){
      //set it on userModel
      userModel.updateThisUserHasAmove(true);

      //place a alert
      //FirestoreServices().alertSetTruckerAlert(moveModel.moveClass.moveId);

      //lets schedule a notification for 24 earlyer
      DateTime moveDate = MoveClass().formatMyDateToNotify(moveModel.moveClass.dateSelected, moveModel.moveClass.timeSelected);
      DateTime notifyDateTime = DateUtils.DateServices().subHoursFromDate(moveDate, 24); //ajusta 24 horas antes
      NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, moveModel.moveClass.userId, "Lembrete: Sua mudança é amanhã às "+moveModel.moveClass.timeSelected, notifyDateTime);


      //notificação com 2 horas de antecedencia (obs: o id da notificação é moveID (id do cliente+2)
      notifyDateTime = DateUtils.DateServices().subHoursFromDate(moveDate, 2); //ajusta 2 horas antes
      NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, moveModel.moveClass.userId+'2', "Lembrete: Mudança em duas horas. Realize pagamento para confirmar." , notifyDateTime);

      moveModel.setIsLoading(false);

    }

    void _onFailure(){

      print('ocorreu um erro');
      moveModel.setIsLoading(false);
    }


    final double latlong = moveModel.moveClass.latEnderecoOrigem+moveModel.moveClass.longEnderecoOrigem;

    moveModel.setIsLoading(true);

    if(moveModel.Distance!=0.0){
      FirestoreServices().scheduleAmoveInBdWithoutTrucker(moveModel, moveModel.moveClass,() {_onSucess(userModel); }, () {_onFailure();}, latlong, _distance);
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) {
        _finishSchedule(moveModel, userModel, context);
      });
    }
  }

  void _reeschedule(MoveModel moveModel, UserModel userModel, BuildContext context){

    void _onSucess(){

      NotificationMeths().turnOffNotification(flutterLocalNotificationsPlugin);

      //lets schedule a notification for 24 earlyer
      DateTime moveDate = MoveClass().formatMyDateToNotify(moveModel.moveClass.dateSelected, moveModel.moveClass.timeSelected);
      DateTime notifyDateTime = DateUtils.DateServices().subHoursFromDate(moveDate, 24); //ajusta 24 horas antes
      NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, moveModel.moveClass.userId, "Lembrete: Sua mudança é amanhã às "+moveModel.moveClass.timeSelected, notifyDateTime);


      //notificação com 2 horas de antecedencia (obs: o id da notificação é moveID (id do cliente+2)
      notifyDateTime = DateUtils.DateServices().subHoursFromDate(moveDate, 2); //ajusta 2 horas antes
      NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, moveModel.moveClass.userId+'2', "Lembrete: Mudança em duas horas. Realize pagamento para confirmar." , notifyDateTime);

      moveModel.setIsLoading(false);

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => HomePage()));


    }

    void _onFailure(){
      moveModel.setIsLoading(false);
      print('erro');
    }

    FirestoreServices().changeSchedule(widget.uid, moveModel.moveClass.dateSelected, moveModel.moveClass.timeSelected, moveModel.moveClass.situacao, () {_onSucess();}, () {_onFailure();});

  }

  void waitAmoment(int seconds, MoveModel moveModel){

    moveModel.setIsLoading(true);
    Future.delayed(Duration(seconds: seconds)).then((_){

      moveModel.setIsLoading(false);


    });

  }

  void _waitBuiltFinishToShowCalendar(MoveModel moveModel){

    WidgetsBinding.instance
        .addPostFrameCallback((_) => setState(() {

          _selectDate(context, moveModel); }));

  }

}




//backup antes de mudar o esquema do motorista
/*
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/classes/truck_class.dart';
import 'package:fretego/models/home_page_model.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/services/date_services.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/date_utils.dart' as DateUtils;
import 'package:fretego/utils/globals_strings.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fretego/utils/notificationMeths.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

bool firstLoaded=false;

class Page6Data extends StatelessWidget {
  double heightPercent;
  double widthPercent;
  String uid;
  bool reschedule;
  Page6Data(this.heightPercent, this.widthPercent, this.uid, this.reschedule);


  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  @override
  Widget build(BuildContext context) {


    return ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget child, MoveModel moveModel){

        return ScopedModelDescendant<UserModel>(
          builder: (BuildContext context, Widget child, UserModel userModel){

            if(firstLoaded==false && reschedule==true){
              firstLoaded=true;
              _loadMovieClass(moveModel, userModel, uid);
            }

            return ScopedModelDescendant<HomePageModel>(
              builder: (BuildContext context, Widget widget, HomePageModel homePageModel){
                return Scaffold(
                  body: Container(
                    width: widthPercent,
                    height: heightPercent,
                    child: Stack(
                      children: [

                        //imagem de fundo com relogio de pulso
                        Positioned(
                            top: heightPercent*0.40,
                            left: -10.0,
                            child: Image.asset('images/itensselect/relogiopulso.png')),

                        //botoes de hora e data
                        Positioned(
                            left: widthPercent*0.40,
                            top: heightPercent*0.50,
                            right: 5.0,
                            child: Container(
                              //width: widthPercent*0.38,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //botao data
                                  Container(
                                    color: Colors.blue,
                                    width: widthPercent*0.35,
                                    height: heightPercent*0.10,
                                    child: FlatButton(
                                      color: CustomColors.blue,
                                      onPressed: (){
                                        _selectDate(context, moveModel);
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          ResponsiveTextCustom('Data', context, Colors.white, 2.5, 0.0, 0.0, 'no'),
                                          Icon(Icons.calendar_today_rounded, color: Colors.white,)
                                        ],
                                      ),
                                    ),
                                  ),
                                  ResponsiveTextCustom(moveModel.dataIsOk == false ? 'Sem data definida' : 'Data escolhida: \n${DateServices().convertToStringFromDate(moveModel.SelectedDate)}', context, Colors.black, 2.0, 5.0, 0.0, 'center'),
                                  SizedBox(height: heightPercent*0.08,),
                                  //botao hora
                                  Container(
                                    color: Colors.blue,
                                    width: widthPercent*0.35,
                                    height: heightPercent*0.10,
                                    child: FlatButton(
                                      color: CustomColors.blue,
                                      onPressed: (){
                                        _selectTime(context, moveModel);
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          ResponsiveTextCustom('Hora', context, Colors.white, 2.5, 0.0, 0.0, 'no'),
                                          Icon(Icons.schedule, color: Colors.white,)
                                        ],
                                      ),
                                    ),
                                  ),
                                  ResponsiveTextCustom(moveModel.horaIsOk==false ? 'Sem hora definida' : 'Horário: \n${moveModel.SelectedTime.format(context)}', context, Colors.black, 2.0, 5.0, 0.0, 'center'),
                                ],
                              ),
                            )
                        ),


                        //titulo
                        Positioned(
                          top: heightPercent*0.40,
                          left: 10.0,
                          right: 10.0,
                          child: ResponsiveTextCustom(reschedule == true? 'Redefinir data e hora' : moveModel.dataIsOk==true && moveModel.horaIsOk ? 'Pronto!' : 'Definir data e hora', context, CustomColors.blue, 3.5, 0.0, 40.0, 'center'),
                        ),


                        //mensagem
                        moveModel.TheDataIsOk==true && moveModel.dataIsOk==true && moveModel.horaIsOk ? Positioned(
                          bottom: 25.0,
                          right: 100.0,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Container(
                              color: CustomColors.yellow,
                              child: ResponsiveTextCustom('Pronto! Toque aqui >', context, Colors.white, 2.5, 0.0, 0.0, 'center'),
                            ),
                          ),
                        ) : SizedBox(),

                        //floating button
                        //moveModel.dataIsOk==true && moveModel.horaIsOk ? Positioned(
                        moveModel.TheDataIsOk==true && moveModel.dataIsOk==true && moveModel.horaIsOk ? Positioned(
                            bottom: 15.0,
                            right: 10.0,
                            child: FloatingActionButton(
                              onPressed: (){

                                moveModel.updateShowResume(false);  //esta variavel foi reciclada. Ela foi usada no endereço e agora vai ser usada na pagina final. Entou agora volto ela pro estado inicial

                                moveModel.moveClass.dateSelected = DateServices().convertToStringFromDate(moveModel.SelectedDate); //salvando dentro de moveclass
                                moveModel.moveClass.timeSelected = moveModel.SelectedTime.format(context);

                                MyBottomSheet().settingModalBottomSheet(context, 'Contactando o profissional...', '', 'Pronto. Agora é só aguardar pela confirmação. Uma vez que o profissional aceite, você pode realizar o pagamento até duas horas antes do horário da mudança.', Icons.info, heightPercent, widthPercent, 0, true);

                                moveModel.moveClass.situacao = "aguardando_freteiro";

                                moveModel.moveClass.userId = uid;
                                SharedPrefsUtils().saveMoveClassToShared(moveModel.moveClass);

                                //aqui e´agendada a mudança
                                scheduleAmove(userModel, moveModel);

                                waitAmoment(3, moveModel);


                                if(reschedule==true){
                                  //ajusta a tela principal para a volta
                                  homePageModel.moveClass.dateSelected = moveModel.moveClass.dateSelected;
                                  homePageModel.moveClass.timeSelected = moveModel.moveClass.timeSelected;
                                  homePageModel.moveClass.situacao = GlobalsStrings.sitReschedule;

                                  Navigator.of(context).pop();
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => HomePage()));
                                } else {
                                  homePageModel.moveClass.dateSelected = moveModel.moveClass.dateSelected;
                                  homePageModel.moveClass.timeSelected = moveModel.moveClass.timeSelected;
                                  homePageModel.moveClass.situacao = moveModel.moveClass.situacao;
                                  moveModel.changePageForward('final', 'data', 'Mudança agendada');
                                }

                              },
                              backgroundColor: CustomColors.yellow,
                              splashColor: Colors.yellow,
                              child: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 50.0,),
                            )
                        ) : SizedBox(),

                      ],
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

  //load movieClass só vai acontecer se estiver reagendando horário
  Future<void> _loadMovieClass(MoveModel moveModel, UserModel userModel, String uid) async {

    moveModel.setIsLoading(true);

    MoveClass _moveClass = MoveClass();

    void _loadFinish(){
      print(_moveClass);
      moveModel.moveClass = _moveClass;
      print(moveModel.moveClass.moveId);
      moveModel.setIsLoading(false);
    }

    _moveClass = await FirestoreServices().copyOfloadScheduledMoveInFbWithCallBack(_moveClass, uid, () {_loadFinish();});

  }

  _selectDate(BuildContext context, MoveModel moveModel) async {

    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: moveModel.SelectedDate, // Refer step 1
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year+1),
      helpText: "Escolha data da mudança", //opcional
      //confirmText: "ok" //opcional
      //cancelText: "ok"  //opcional
    );
    if (picked != null && picked != moveModel.SelectedDate){
      moveModel.updateselectedDate(picked);
      moveModel.updateDataIsOk(true);
    }

  }

  _selectTime(BuildContext context, MoveModel moveModel) async {

    final TimeOfDay timeToStart = TimeOfDay.now().replacing(
        hour: TimeOfDay.now().hour,
        minute: TimeOfDay.now().minute
    );

    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: timeToStart,
      //initialTime: TimeOfDay.now(),
      helpText: "Escolha o horário", //opcional
    );
    if (picked != null && picked != moveModel.SelectedTime){
      moveModel.updateSelectedTime(picked);
      moveModel.updateHoraIsOk(true);
    }

  }

  void scheduleAmove(UserModel userModel, MoveModel moveModel) async {

    void _onSucess(UserModel userModel){
      //set it on userModel
      userModel.updateThisUserHasAmove(true);

      //place a alert
      FirestoreServices().alertSetTruckerAlert(moveModel.moveClass.moveId);

      //lets schedule a notification for 24 earlyer
      DateTime moveDate = MoveClass().formatMyDateToNotify(moveModel.moveClass.dateSelected, moveModel.moveClass.timeSelected);
      DateTime notifyDateTime = DateUtils.DateServices().subHoursFromDate(moveDate, 24); //ajusta 24 horas antes
      NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, moveModel.moveClass.userId, "Lembrete: Sua mudança é amanhã às "+moveModel.moveClass.timeSelected, notifyDateTime);


      //notificação com 2 horas de antecedencia (obs: o id da notificação é moveID (id do cliente+2)
      notifyDateTime = DateUtils.DateServices().subHoursFromDate(moveDate, 2); //ajusta 2 horas antes
      NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, moveModel.moveClass.userId+'2', "Lembrete: Mudança em duas horas. Realize pagamento para confirmar." , notifyDateTime);

    }

    void _onFailure(){

    }


    if(reschedule==true){
      FirestoreServices().changeSchedule(uid, moveModel.moveClass.dateSelected, moveModel.moveClass.timeSelected, moveModel.moveClass.situacao, () {_onSucess(userModel);}, () {_onFailure();});
    } else {
      FirestoreServices().scheduleAmoveInBd(moveModel.moveClass,() {_onSucess(userModel); }, () {_onFailure();});
    }


  }

  void waitAmoment(int seconds, MoveModel moveModel){

    moveModel.setIsLoading(true);
    Future.delayed(Duration(seconds: seconds)).then((_){

      moveModel.setIsLoading(false);


    });

  }

}


 */