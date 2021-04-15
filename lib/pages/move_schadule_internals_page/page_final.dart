import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/classes/truck_class.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/pages/avalatiation_page.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:fretego/utils/notificationMeths.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/responsive_text_custom_withmargin.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

class PageFinal extends StatefulWidget {
  double heightPercent;
  double widthPercent;
  String uid;
  PageFinal(this.heightPercent, this.widthPercent, this.uid);

  @override
  _PageFinalState createState() => _PageFinalState();
}

ScrollController _scrollController; //scroll screen to bottom

class _PageFinalState extends State<PageFinal> {

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  bool _showAnimatedPositioned=false;


  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget child, MoveModel moveModel){

        //_passTimetoShowPopup();

        return Scaffold(
          body: Container(
            color: Colors.white,
            width: widget.widthPercent,
            height: widget.heightPercent,
            child: Stack(
              children: [

                Positioned(
              left: widget.widthPercent*0.05,
              right: widget.widthPercent*0.05,
              bottom: 0.0,
              top: widget.heightPercent*0.02,
              child: ListView(
                controller: _scrollController,
                children: [

                  _closeButton(context),

                  SizedBox(height: widget.heightPercent*0.05,),

                  _iconOk(),

                  SizedBox(height: widget.heightPercent*0.05,),

                  //texto pronto, agora aguarde a confirmação de freteiro
                  _textTudoPronto(),

                  SizedBox(height: widget.heightPercent*0.05,),

                  //botao ver esconder resumo
                  _showResumeLine(moveModel),
                  //_btnShowResume(context, moveModel),
                  //_iconShowResume(context, moveModel),

                  //titulo resumo
                  if (moveModel.ShowResume == true) WidgetsConstructor().makeText("Resumo", CustomColors.blue, 25.0, 0.0, 20.0, "no"),

                  //resumo
                  if (moveModel.ShowResume == true) _resumo(moveModel),

                  SizedBox(height: widget.heightPercent*0.20,),

                  //botao fechar
                  _btnFecharScreen(context),

                  //SizedBox(height: 15.0,),

                  //_situacaoAtual(moveModel),

                  //SizedBox(height: 25.0,),

                  //_deleteButton(context, moveModel),

                ],
              )
              ),

                if(_showAnimatedPositioned == true) AnimatedPositioned(
                  bottom: _showAnimatedPositioned == true ? widget.heightPercent*0.0 : widget.heightPercent*0.3,
                    left: widget.widthPercent*0.10,
                    right: widget.widthPercent*0.10,
                    child: Container(
                      color: Colors.blue,
                    ),
                    duration: Duration(milliseconds: 500),
                ),

              ],
            ),
          ),
        );

      },
    );

  }

  Widget _closeButton(BuildContext context){

    return Row(
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
    );

  }

  Widget _iconOk(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CustomColors.yellow
          ),
          width: widget.widthPercent*0.25,
          height: widget.heightPercent*0.20,
          child: Icon(Icons.done, color: Colors.white, size: widget.widthPercent*0.20,),
        )
      ],
    );
  }

  Widget _textTudoPronto(){
    return Container(
      alignment: Alignment.center,
      width: widget.widthPercent*0.90,
      child: Text('Pronto. Agora aguarde um motorista aceitar o serviço', textAlign: TextAlign.center ,style: TextStyle(
          color: Colors.black,
          fontSize: ResponsiveFlutter.of(context).fontSize(3.0)))
      //child: WidgetsConstructor().makeText("Pronto. Agora aguarde a confirmação de "+moveModel.moveClass.nomeFreteiro.toString(), Colors.black, 25.0, 20.0, 20.0, "center"),
    );
  }

  Widget _showResumeLine(MoveModel moveModel){
    return GestureDetector(
      onTap: (){
        _showHideResume(moveModel);
      },
        child: Container(
        width: widget.widthPercent*0.70,
        height: widget.heightPercent*0.10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            //texto
            ResponsiveTextCustom(moveModel.ShowResume==false ? 'Ver resumo' : 'Esconder', context, CustomColors.blue, 3.0, 0.0, 0.0, 'center'),

            //icone
            Icon(moveModel.ShowResume==false ? Icons.keyboard_arrow_down_outlined : Icons.keyboard_arrow_up, color: CustomColors.blue, size: 40.0,),

          ],
        ),
      )
    );
  }


  Widget _resumo(MoveModel moveModel){

    return Container(
        width: widget.widthPercent*0.80,
        decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 5.0),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [

              WidgetsConstructor().makeText("Endereço de origem: "+moveModel.moveClass.enderecoOrigem.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
              WidgetsConstructor().makeText("Endereço de destino: "+moveModel.moveClass.enderecoDestino.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
              WidgetsConstructor().makeText("Data: "+moveModel.moveClass.dateSelected.toString()+" às "+moveModel.moveClass.timeSelected.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
              if(moveModel.moveClass.freteiroId!= null) WidgetsConstructor().makeText("Freteiro: "+moveModel.moveClass.nomeFreteiro.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
              WidgetsConstructor().makeText("Veículo: "+TruckClass().formatCodeToHumanName(moveModel.moveClass.carro), Colors.black, 15.0, 0.0, 10.0, "no"),
              WidgetsConstructor().makeText("Nº ajudantes: "+moveModel.moveClass.ajudantes.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
              WidgetsConstructor().makeText("Preço: R\$"+moveModel.moveClass.preco.toStringAsFixed(2), Colors.black, 15.0, 0.0, 10.0, "no"),

            ],
          ),
        )
    );
  }

  Widget _btnFecharScreen(BuildContext context){

    return Container(
      width: widget.widthPercent*0.8,
      height: widget.heightPercent*0.08,
      child: RaisedButton(
        color: CustomColors.blue,
        onPressed: (){

          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => HomePage()));

        },
        child: ResponsiveTextCustom('Página inicial', context, Colors.white, 2.5, 0.0, 0.0, 'center'),
      ),
    );
  }

  Widget _situacaoAtual(MoveModel moveModel){
    return Container(
      width: widget.widthPercent*0.90,
      child: WidgetsConstructor().makeText("Situação: "+MoveClass().formatSituationToHuman(moveModel.moveClass.situacao), Colors.redAccent, 15.0, 0.0, 12.0, "no"),
    );
  }

  Widget _deleteButton(BuildContext context, MoveModel moveModel){

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: widget.widthPercent*0.20,
          height: widget.heightPercent*0.08,
          child: FlatButton(
            onPressed: (){

              void _onSucessDelete(){
                MyBottomSheet().settingModalBottomSheet(context,
                    'Aguarde um instante', 'Cancelamento', 'O agendamento está sendo cancelado.',
                    Icons.cancel_outlined, widget.heightPercent, widget.widthPercent, 0, true);


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
                    Icons.warning_amber_sharp, widget.heightPercent, widget.widthPercent, 0, true);
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
    );
  }

  void _showHideResume(MoveModel moveModel){

    if(moveModel.ShowResume==false){
      moveModel.updateShowResume(true);
      Future.delayed(Duration(milliseconds: 500)).then((_){
        scrollToBottom();
      });
    } else {
      moveModel.updateShowResume(false);
    }

  }

  void _passTimetoShowPopup(){
    Future.delayed(Duration(milliseconds: 500)).then((_) {
      setState(() {
        _showAnimatedPositioned=true;
      });
    });
  }

  void scrollToBottom() {
    double bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      bottomOffset,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
