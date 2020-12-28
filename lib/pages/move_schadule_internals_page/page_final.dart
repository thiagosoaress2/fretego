import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/classes/truck_class.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:fretego/utils/notificationMeths.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/responsive_text_custom_withmargin.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class PageFinal extends StatelessWidget {
  double heightPercent;
  double widthPercent;
  String uid;
  PageFinal(this.heightPercent, this.widthPercent, this.uid);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget child, MoveModel moveModel){

        return Scaffold(
          body: Container(
            color: Colors.white,
            width: widthPercent,
            height: heightPercent,
            child: Stack(
              children: [

              Positioned(
              left: 10.0,
              right: 10.0,
              bottom: heightPercent*0.10,
              top: heightPercent*0.32,
              child: ListView(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CloseButton(
                        onPressed: (){
                          Navigator.of(context).pop();
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => HomePage()));
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 5.0,),
                  //texto pronto, agora aguarde a confirmação de freteiro
                  Container(
                    width: widthPercent*0.90,
                    child: WidgetsConstructor().makeText("Pronto. Agora aguarde a confirmação de "+moveModel.moveClass.nomeFreteiro.toString(), Colors.black, 25.0, 20.0, 20.0, "center"),
                  ),


                  //botao ver esconder resumo
                  Container(
                    width: widthPercent*0.9,
                    height: heightPercent*0.08,
                    child: FlatButton(
                      onPressed: (){
                        if(moveModel.ShowResume==false){
                          moveModel.updateShowResume(true);
                        } else {
                          moveModel.updateShowResume(false);
                        }

                      },
                      color: Colors.white,
                      child: ResponsiveTextCustom(moveModel.ShowResume==false ? 'Ver resumo' : 'Esconder', context, Colors.black, 2, 0.0, 0.0, 'center'),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      if(moveModel.ShowResume==false){
                        moveModel.updateShowResume(true);
                      } else {
                        moveModel.updateShowResume(false);
                      }
                    },
                    child: Icon(moveModel.ShowResume==false ? Icons.keyboard_arrow_down_outlined : Icons.keyboard_arrow_up, color: Colors.blue, size: 40.0,),

                  ),

                  //titulo resumo
                  moveModel.ShowResume == true ? WidgetsConstructor().makeText("Resumo", CustomColors.blue, 25.0, 0.0, 20.0, "no") : SizedBox(),
                  //resumo
                  moveModel.ShowResume == true ? Container(
                    width: widthPercent*0.80,
                    decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 5.0),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          children: [

                            WidgetsConstructor().makeText("Endereço de origem: "+moveModel.moveClass.enderecoOrigem.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
                            WidgetsConstructor().makeText("Endereço de destino: "+moveModel.moveClass.enderecoDestino.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
                            WidgetsConstructor().makeText("Data: "+moveModel.moveClass.dateSelected.toString()+" às "+moveModel.moveClass.timeSelected.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
                            WidgetsConstructor().makeText("Freteiro: "+moveModel.moveClass.nomeFreteiro.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
                            WidgetsConstructor().makeText("Veículo: "+TruckClass().formatCodeToHumanName(moveModel.moveClass.carro), Colors.black, 15.0, 0.0, 10.0, "no"),
                            WidgetsConstructor().makeText("Nº ajudantes: "+moveModel.moveClass.ajudantes.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
                            WidgetsConstructor().makeText("Preço: R\$"+moveModel.moveClass.preco.toStringAsFixed(2), Colors.black, 15.0, 0.0, 10.0, "no"),

                          ],
                        ),
                      )
                  ) : SizedBox(),

                  SizedBox(height: 40.0,),

                  //botao fechar
                  Container(
                    width: widthPercent*0.75,
                    height: heightPercent*0.08,
                    child: RaisedButton(
                      color: CustomColors.blue,
                      onPressed: (){

                        Navigator.of(context).pop();
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => HomePage()));

                      },
                      child: ResponsiveTextCustom('Fechar e voltar ao ínicio', context, Colors.white, 2.5, 0.0, 0.0, 'center'),
                    ),
                  ),

                  SizedBox(height: 15.0,),

                  Container(
                    width: widthPercent*0.90,
                    child: WidgetsConstructor().makeText("Situação: "+MoveClass().formatSituationToHuman(moveModel.moveClass.situacao), Colors.redAccent, 15.0, 0.0, 12.0, "no"),
                  ),

                  SizedBox(height: 25.0,),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: widthPercent*0.20,
                        height: heightPercent*0.08,
                        child: FlatButton(
                          onPressed: (){

                            void _onSucessDelete(){
                              MyBottomSheet().settingModalBottomSheet(context,
                                  'Aguarde um instante', 'Cancelamento', 'O agendamento está sendo cancelado.',
                                  Icons.cancel_outlined, heightPercent, widthPercent, 0, true);


                              FirestoreServices().notifyTruckerThatHeWasChanged(moveModel.moveClass.freteiroId, moveModel.moveClass.userId); //alerta ao freteiro que ele foi cancelado na mudança. No freteiro vai recuperar isso para cancelar as notificações locais.
                              //cancelar as notificações neste caso
                              NotificationMeths().turnOffNotification(flutterLocalNotificationsPlugin); //apaga todas as notificações deste user
                              moveModel.setIsLoading(false);

                              //retorna pra página principal
                              Navigator.of(context).pop();
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => HomePage()));

                            }

                            void _onFailureDelete(){
                              MyBottomSheet().settingModalBottomSheet(context,
                                  'Ops..', 'Ocorreu um erro', 'O agendamento não foi cancelado. Tente novamente em instantes.',
                                  Icons.warning_amber_sharp, heightPercent, widthPercent, 0, true);
                            }

                            SharedPrefsUtils().clearScheduledMove();
                            FirestoreServices().deleteAscheduledMove(moveModel.moveClass, () {_onSucessDelete(); }, () { _onFailureDelete(); });
                            moveModel.setIsLoading(true);

                          },
                          color: Colors.redAccent,
                          child: Icon(Icons.cancel_outlined, color: Colors.white,),
                        ),
                      ),
                      ResponsiveTextCustomWithMargin('Ou cancele aqui', context, Colors.redAccent, 2.0, 0.0, 0.0, 15.0, 0.0, 'center'),

                    ],
                  ),

                ],
              )
              ),

              ],
            ),
          ),
        );

      },
    );
  }
}
