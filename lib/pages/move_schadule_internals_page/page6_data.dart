import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/classes/truck_class.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/services/date_services.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/date_utils.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fretego/utils/notificationMeths.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class Page6Data extends StatelessWidget {
  double heightPercent;
  double widthPercent;
  String uid;
  Page6Data(this.heightPercent, this.widthPercent, this.uid);


  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  @override
  Widget build(BuildContext context) {



    return ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget child, MoveModel moveModel){

        return ScopedModelDescendant<UserModel>(
          builder: (BuildContext context, Widget child, UserModel userModel){

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
                      child: ResponsiveTextCustom(moveModel.dataIsOk==true && moveModel.horaIsOk ? 'Pronto!' : 'Definir data e hora', context, CustomColors.blue, 3.5, 0.0, 40.0, 'center'),
                    ),


                    //mensagem
                      moveModel.dataIsOk==true && moveModel.horaIsOk ? Positioned(
                        bottom: 25.0,
                        right: 100.0,
                        child: ResponsiveTextCustom('Pronto! Toque aqui >', context, CustomColors.yellow, 2.5, 0.0, 0.0, 'center'),
                      ) : SizedBox(),

                    //floating button
                    moveModel.dataIsOk==true && moveModel.horaIsOk ? Positioned(
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
                            scheduleAmove(userModel, moveModel);

                            waitAmoment(3, moveModel);
                            moveModel.changePageForward('final', 'data', 'Mudança agendada');

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

    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

      //lets schedule a notification for 24 earlyer
      DateTime moveDate = MoveClass().formatMyDateToNotify(moveModel.moveClass.dateSelected, moveModel.moveClass.timeSelected);
      DateTime notifyDateTime = DateUtils().subHoursFromDate(moveDate, 24); //ajusta 24 horas antes
      NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, moveModel.moveClass.userId, "Lembrete: Sua mudança é amanhã às "+moveModel.moveClass.timeSelected, notifyDateTime);


      //notificação com 2 horas de antecedencia (obs: o id da notificação é moveID (id do cliente+2)
      notifyDateTime = DateUtils().subHoursFromDate(moveDate, 2); //ajusta 2 horas antes
      NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, moveModel.moveClass.userId+'2', "Lembrete: Mudança em duas horas. Realize pagamento para confirmar." , notifyDateTime);

    }

    void _onFailure(){

    }

    FirestoreServices().scheduleAmoveInBd(moveModel.moveClass,() {_onSucess(userModel); }, () {_onFailure();});

  }

  void waitAmoment(int seconds, MoveModel moveModel){

    moveModel.setIsLoading(true);
    Future.delayed(Duration(seconds: seconds)).then((_){

      moveModel.setIsLoading(false);


    });

  }

}
