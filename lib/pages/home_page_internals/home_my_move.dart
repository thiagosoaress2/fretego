import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/login/pages/email_verify_view.dart';
import 'package:fretego/models/home_page_model.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/move_schedule_page.dart';
import 'package:fretego/pages/payment_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/date_utils.dart';
import 'package:fretego/utils/globals_strings.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:fretego/utils/notificationMeths.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/responsive_text_custom_withmargin.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';


class HomeMyMoves extends StatefulWidget {
  double heightPercent;
  double widthPercent;
  HomeMyMoves(this.heightPercent, this.widthPercent);

  @override
  _HomeMyMovesState createState() => _HomeMyMovesState();
}

class _HomeMyMovesState extends State<HomeMyMoves> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationAppLaunchDetails notificationAppLaunchDetails;

  bool isMovesLoadedFromFb = false;

  ScrollController _scrollController;

  bool _isFirstLoad=true;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<HomePageModel>(
      builder: (BuildContext context, Widget child, HomePageModel homePageModel){

        if(_isFirstLoad==true){
          _isFirstLoad=false;

          Future.delayed(Duration(seconds: 4)).then((value) {
            homePageModel.updateShowOptions();
          });
        }

        return ScopedModelDescendant<UserModel>(
          builder: (BuildContext context, Widget child, UserModel userModel){

            if(homePageModel.moveClass.userId!=null){
              //do nothing
            } else {
              _scrollController = ScrollController();
              loadInfoFromFb(userModel, homePageModel);
            }


            return Container(
              height: widget.heightPercent,
              width: widget.widthPercent,
              color: Colors.white,
              child: Stack(
                children: [

                  Positioned(
                    top: widget.heightPercent*0.01,
                    left: widget.widthPercent*0.05,
                    right: widget.widthPercent*0.05,
                    bottom: widget.heightPercent*0.20,
                    child: ListView(
                      controller: _scrollController,
                      children: [

                        //titulo situacao
                         ResponsiveTextCustom('Acompanhe sua mudança', context, CustomColors.blue, 2.5, 0.0, 15.0, 'no'),

                        homePageModel.moveClass.situacao != null ?
                        _orderTrack(homePageModel, userModel, context)
                        : Container(),

                        GestureDetector(
                          onTap: (){
                            homePageModel.updateShowResume(true);
                          },
                          child: ResponsiveTextCustomWithMargin('Ver detalhes', context, CustomColors.brown,
                              3.0, 5.0, 0.0, widget.widthPercent*0.25, widget.widthPercent*0.25, 'center'),

                        ),

                      ],
                    ),
                  ),

                  Positioned(
                    bottom: 0.0,
                    left: 5.0,
                    right: 5.0,
                    top: homePageModel.ShowOptions == true ? widget.heightPercent*0.30 : widget.heightPercent*0.75,
                    child: _bottomLine(homePageModel, userModel, context),),


                  homePageModel.ShowResume == true
                  ? _detailsPage(homePageModel) : Container(),

                  homePageModel.IsLoading==true ? Center(child: CircularProgressIndicator(),) : Container(),



                ],
              ),
            );

          },
        );

      },
    );
  }

  Widget _orderTrack(HomePageModel homePageModel, UserModel userModel, BuildContext context){


    bool _thisSitIsHighlighted_line4=false;
    bool _thisSitIsHighlighted_line3=false;
    bool _thisSitIsHighlighted_line2=false;
    bool _thisSitIsHighlighted_line1=false;
    String timeFinal;

    if(homePageModel.moveClass.situacao == GlobalsStrings.sitTruckerIsGoingToMove){
      _thisSitIsHighlighted_line3=true;
    } else {
      _thisSitIsHighlighted_line3=false;
    }

    if(_thisSitIsHighlighted_line3==false){

      if(homePageModel.moveClass.situacao == GlobalsStrings.sitAguardando || homePageModel.moveClass.situacao == GlobalsStrings.sitDeny  || homePageModel.moveClass.situacao == GlobalsStrings.sitNoTrucker){
        _thisSitIsHighlighted_line2=false;
      } else {
        _thisSitIsHighlighted_line2=false;
        if(homePageModel.moveClass.situacao != GlobalsStrings.sitPago){ ///unica situação que esta linha ficará azul
          _thisSitIsHighlighted_line2=true;
          timeFinal = DateUtils().iHaveStringWithTimeAndHaveToMinusItFromADateMinusHours(homePageModel.moveClass.dateSelected, homePageModel.moveClass.timeSelected, 2);
        } else {
          _thisSitIsHighlighted_line2=false;
        }
      }
    }

    if(_thisSitIsHighlighted_line3==false && _thisSitIsHighlighted_line2==false){
      if(homePageModel.moveClass.situacao == GlobalsStrings.sitAguardando|| homePageModel.moveClass.situacao ==  GlobalsStrings.sitDeny || homePageModel.moveClass.situacao == GlobalsStrings.sitNoTrucker){
        _thisSitIsHighlighted_line1=true;
      } else {
        _thisSitIsHighlighted_line1=false;
      }

    }

    DateTime dateNow = DateTime.now();
    DateTime dateScheduled = DateUtils().convertDateFromString(homePageModel.moveClass.dateSelected);
    DateTime dateTimeOfMove = DateUtils().addMinutesAndHoursFromStringToAdate(dateScheduled, homePageModel.moveClass.timeSelected);
    int difference = DateUtils().compareTwoDatesInMinutes(dateNow, dateTimeOfMove);
    if(difference==0 && _thisSitIsHighlighted_line2==false && _thisSitIsHighlighted_line1==false){
      _thisSitIsHighlighted_line4=true;
      _thisSitIsHighlighted_line3=false;
    } else if(difference.isNegative && _thisSitIsHighlighted_line2==false && _thisSitIsHighlighted_line1==false){
      _thisSitIsHighlighted_line4=true;
      _thisSitIsHighlighted_line3=false;
    } else {
      _thisSitIsHighlighted_line4=false;
    }

    if(_thisSitIsHighlighted_line1==true){
      _thisSitIsHighlighted_line2=false;
      _thisSitIsHighlighted_line3=false;
      _thisSitIsHighlighted_line4=false;
    } else if(_thisSitIsHighlighted_line2==true){
      _thisSitIsHighlighted_line1=false;
      _thisSitIsHighlighted_line3=false;
      _thisSitIsHighlighted_line4=false;
    } else if(_thisSitIsHighlighted_line3==true){
      _thisSitIsHighlighted_line1=false;
      _thisSitIsHighlighted_line2=false;
      _thisSitIsHighlighted_line4=false;
    } else if(_thisSitIsHighlighted_line4){
      _thisSitIsHighlighted_line1=false;
      _thisSitIsHighlighted_line2=false;
      _thisSitIsHighlighted_line3=false;
    }


    return Container(
      width: widget.widthPercent*0.9,
      height: widget.heightPercent*0.80,
      child: Stack(
        children: [

          //linha vertical
          Positioned(
            top: 12.0,
            left: widget.widthPercent*0.05,
            bottom: widget.heightPercent*0.33,
            child: Container(
              width: 3.0,
              color: Colors.blue,
            ),
          ),

          //primeira linha com bolinha do aguardando profissional, icone e texto
          Positioned(
            top: 5.0,
            left: widget.widthPercent*0.01,
            child: Row(
              children: [
                Container(
                  width: widget.widthPercent*0.10,
                  height: widget.heightPercent*0.06,
                  child: _thisSitIsHighlighted_line1==true ? Container() : Icon(Icons.done, color: Colors.white,),
                  decoration: new BoxDecoration(
                    border: Border.all(
                      color: CustomColors.yellow,
                      width: 4.0, //                   <--- border width here
                    ),
                    //borderRadius: new BorderRadius.circular(3.0),
                    shape: BoxShape.circle,
                    color: _thisSitIsHighlighted_line1==true ?  Colors.white : CustomColors.yellow,
                  ),
                ),
                SizedBox(width: 15.0,),
                _thisSitIsHighlighted_line1==true ?
                Container(
                  width: widget.widthPercent*0.10,
                  height: widget.heightPercent*0.05,
                  decoration: WidgetsConstructor().myBoxDecoration(Colors.white, _thisSitIsHighlighted_line1==true ? CustomColors.blue : Colors.white, 4.0, 5.0),
                  child: ResponsiveTextCustomWithMargin('?', context, _thisSitIsHighlighted_line1==true ? CustomColors.blue : Colors.grey , 3.5, 0.0, 2.0, 2.0, 2.0, 'center'),
                ) : Icon(Icons.people_alt, color: Colors.grey, size: 40.0,),
                SizedBox(width: 15.0,),
                Container(
                  width: widget.widthPercent*0.60,
                  color: _thisSitIsHighlighted_line1==true ? CustomColors.blue : Colors.white,
                  child: ResponsiveTextCustomWithMargin(
                      homePageModel.moveClass.situacao == GlobalsStrings.sitAguardando ? homePageModel.moveClass.situacao+' '+homePageModel.moveClass.nomeFreteiro+' aceitar o serviço.'
                          : homePageModel.moveClass.situacao ==  GlobalsStrings.sitDeny || homePageModel.moveClass.situacao == GlobalsStrings.sitNoTrucker ? 'O profissional não aceitou o serviço. Escolha outro.'
                          : '${homePageModel.moveClass.nomeFreteiro.toString()} aceitou o serviço'
                      , context,
                      //cor do texto
                      _thisSitIsHighlighted_line1==true ? Colors.white : Colors.grey,

                      2, 2.0, 2.0, 2.0, 2.0, 'center'),
                ),
                  //child: ResponsiveTextCustomWithMargin('Aguardando confirmaçao de freteiro', context, Colors.white, 2, 2.0, 2.0, 2.0, 2.0, 'no'),


              ],
            )
          ),

          //segunda linha com bolinha Pagamento
          Positioned(
              top: widget.heightPercent*0.15,
              left: widget.widthPercent*0.01,
              child: GestureDetector(
                onTap: (){
                  if(_thisSitIsHighlighted_line2==true){
                    _openPaymentPage(userModel, homePageModel);
                  }
                },
                child: Row(
                  children: [
                    Container(
                      width: widget.widthPercent*0.10,
                      height: widget.heightPercent*0.06,
                      decoration: new BoxDecoration(
                        border: Border.all(
                          color: CustomColors.yellow,
                          width: 2.0, //                   <--- border width here
                        ),
                        // borderRadius: new BorderRadius.circular(3.0),
                        shape: BoxShape.circle,
                        color: _thisSitIsHighlighted_line1==true ? Colors.grey : _thisSitIsHighlighted_line2 == true ? Colors.white : CustomColors.yellow,
                      ),
                      child: _thisSitIsHighlighted_line2 == false && _thisSitIsHighlighted_line1==false ? Icon(Icons.done, color: Colors.white,) : Container(),
                    ),
                    SizedBox(width: 15.0,),
                    Icon(Icons.credit_card, color: _thisSitIsHighlighted_line2 == true ? CustomColors.blue : Colors.grey, size: 40.0,),

                    SizedBox(width: 15.0,),
                    Container(
                      width: widget.widthPercent*0.60,
                      color: _thisSitIsHighlighted_line2==true ? CustomColors.blue : Colors.white,
                      child: ResponsiveTextCustomWithMargin(_thisSitIsHighlighted_line2 == true ||  _thisSitIsHighlighted_line1==true ? 'Esperando seu pagamento até ${timeFinal} do dia ${homePageModel.moveClass.dateSelected}.' : 'Pagamento realizado.', context,
                          _thisSitIsHighlighted_line2==true ? Colors.white : Colors.grey, 2, 2.0, 2.0, 2.0, 2.0, 'no'),
                    ),


                  ],
                ),
              )
          ),

          //terceira linha com aviso de profissional se deslocando
          Positioned(
              top: widget.heightPercent*0.30,
              left: widget.widthPercent*0.01,
              child: Row(
                children: [
                  Container(
                    width: widget.widthPercent*0.10,
                    height: widget.heightPercent*0.06,
                    child:  _thisSitIsHighlighted_line3==true ? Container() : _thisSitIsHighlighted_line1==true || _thisSitIsHighlighted_line2==true ? Container() : Icon(Icons.done, color: Colors.white,),
                    decoration: new BoxDecoration(
                      border: Border.all(
                        color: CustomColors.yellow,
                        width: 2.0, //                   <--- border width here
                      ),
                      // borderRadius: new BorderRadius.circular(3.0),
                      shape: BoxShape.circle,
                      color: _thisSitIsHighlighted_line4==true ? CustomColors.yellow : _thisSitIsHighlighted_line3==true ?  Colors.white : Colors.grey,
                    ),
                  ),
                  SizedBox(width: 15.0,),
                  Icon(Icons.airport_shuttle, color: _thisSitIsHighlighted_line3 == true ? CustomColors.blue : Colors.grey, size: 40.0,),

                  SizedBox(width: 15.0,),
                  Container(
                    width: widget.widthPercent*0.60,
                    color: _thisSitIsHighlighted_line3==true ? CustomColors.blue : Colors.white,
                    child: ResponsiveTextCustomWithMargin('Profissional está a caminho', context,
                        _thisSitIsHighlighted_line3==true ? Colors.white : Colors.grey,
                        2, 2.0, 2.0, 2.0, 2.0, 'no'),
                  ),


                ],
              )
          ),

          //quarta linha hora da mudança
          Positioned(
              top: widget.heightPercent*0.45,
              left: widget.widthPercent*0.01,
              child: Row(
                children: [
                  Container(
                    width: widget.widthPercent*0.10,
                    height: widget.heightPercent*0.06,
                    decoration: new BoxDecoration(
                      border: Border.all(
                        color: CustomColors.yellow,
                        width: 2.0, //                   <--- border width here
                      ),
                      // borderRadius: new BorderRadius.circular(3.0),
                      shape: BoxShape.circle,
                      color: _thisSitIsHighlighted_line4 == true ? Colors.white : Colors.grey,
                    ),
                  ),
                  SizedBox(width: 15.0,),
                  Icon(Icons.schedule, color: _thisSitIsHighlighted_line4 == true ? CustomColors.blue : Colors.grey, size: 40.0,),

                  SizedBox(width: 15.0,),
                  Container(
                    width: widget.widthPercent*0.60,
                    color: _thisSitIsHighlighted_line4==true ? CustomColors.blue : Colors.white,
                    child: ResponsiveTextCustomWithMargin(_thisSitIsHighlighted_line4==true ? 'Mudança agora' : 'Mudança agendada às ${homePageModel.moveClass.timeSelected} do dia ${homePageModel.moveClass.dateSelected}.', context,
                        _thisSitIsHighlighted_line4==true ? Colors.white : Colors.grey,
                        2, 2.0, 2.0, 2.0, 2.0, 'no'),
                  ),


                ],
              )
          ),

        ],
      ),

    );
  }

  Widget _bottomLine(HomePageModel homePageModel, UserModel userModel, BuildContext context) {

    return Container(
      color: Colors.white,
      width: widget.widthPercent,
      child: ListView(
        children: [

          Divider(color: Colors.blue,),
          //barra titulo com botões
          GestureDetector(
            onTap: (){
              homePageModel.updateShowOptions();
              },
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  homePageModel.ShowOptions == true ? ResponsiveTextCustomWithMargin('Mostrar menos', context, CustomColors.blue, 2.5, 1.0, 5.0, 0.0, 0.0, 'no')
                      : ResponsiveTextCustomWithMargin('Mostrar opções', context, CustomColors.blue, 2.5, 1.0, 5.0, 0.0, 0.0, 'no'),
                  homePageModel.ShowOptions == true ? Icon(Icons.keyboard_arrow_down, color: Colors.blue,size: 35.0,) : Icon(Icons.keyboard_arrow_up, color: Colors.blue, size: 35.0,),
                ],
              ),
            ),
          ),
          SizedBox(height: widget.heightPercent*0.03,),

          homePageModel.moveClass.situacao == GlobalsStrings.sitPago ||
              homePageModel.moveClass.situacao == GlobalsStrings.sitTruckerIsGoingToMove ||
              homePageModel.moveClass.situacao == GlobalsStrings.sitTruckerFinished ||
              homePageModel.moveClass.situacao == GlobalsStrings.sitUserFinished ||
              homePageModel.moveClass.situacao == GlobalsStrings.sitUserInformTruckerDidntFinishedButItsGoingBack ||
              homePageModel.moveClass.situacao == GlobalsStrings.sitUserInformTruckerDidntFinishedMove
              ? _lineWithWhastappBtn(context, userModel, homePageModel) : Container(),

          homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitAguardando ||
              homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitTruckerQuitAfterPayment ||
              homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitAccepted ||
              homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitPago ||
              homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitDeny ||
              homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitNoTrucker ?
          _lineWithChangetruckerButton(context, userModel, homePageModel): Container(),

          homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitAccepted ?
          _lineWithPayButton(context, userModel, homePageModel) : Container(),

          homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitAguardando ||
              homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitAccepted ||
              homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitTruckerQuitAfterPayment ||
              homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitDeny ||
              homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitNoTrucker ?
          _lineWithDeleteButton(context, homePageModel, userModel) : Container(),


        ],
      ),
    );

  }

  Widget _detailsPage(HomePageModel homePageModel){

    return Container(
      width: widget.widthPercent,
      color: Colors.white,
      height: widget.heightPercent,
      child: ListView(

        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CloseButton(onPressed: (){
                homePageModel.updateShowResume(false);
              },)
            ],
          ),

          SizedBox(height: widget.heightPercent*0.05,),
          Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [

                  Row(
                    children: [
                      WidgetsConstructor().makeText(
                          "Origem: ", Colors.black, 15.0, 0.0, 5.0, null),
                      Container(
                        width: widget.widthPercent*0.60,
                        child: WidgetsConstructor().makeText(
                            homePageModel.moveClass.enderecoOrigem, Colors.black, 15.0, 0.0, 5.0,
                            null),
                      ),

                    ],
                  ),

                  Row(
                    children: [
                      WidgetsConstructor().makeText(
                          "Destino: ", Colors.black, 15.0, 0.0, 5.0, null),
                      Container(
                        width: widget.widthPercent*0.60,
                        child: WidgetsConstructor().makeText(
                            homePageModel.moveClass.enderecoDestino, Colors.black, 15.0, 0.0,
                            5.0, null),
                      ),

                    ],
                  ),
                  Row(
                    children: [
                      WidgetsConstructor().makeText(
                          "Data: ", Colors.black, 15.0, 0.0, 5.0, null),
                      WidgetsConstructor().makeText(
                          "Destino: ", Colors.black, 15.0, 0.0, 5.0, null),
                      Container(
                        width: widget.widthPercent*0.60,
                        child: WidgetsConstructor().makeText(
                            homePageModel.moveClass.dateSelected, Colors.black, 15.0, 0.0, 5.0,
                            null),
                      ),

                    ],
                  ),
                  Row(
                    children: [
                      WidgetsConstructor().makeText(
                          "Horário: ", Colors.black, 15.0, 0.0, 5.0, null),
                      Container(
                        width: widget.widthPercent*0.60,
                        child: WidgetsConstructor().makeText(
                            homePageModel.moveClass.timeSelected, Colors.black, 15.0, 0.0, 5.0,
                            null),
                      ),


                    ],
                  ),
                  Row(
                    children: [
                      WidgetsConstructor().makeText(
                          "Valor: ", Colors.black, 15.0, 0.0, 5.0, null),
                      Container(
                        width: widget.widthPercent*0.60,
                        child: WidgetsConstructor().makeText(
                            "R\$ " + homePageModel.moveClass.preco.toStringAsFixed(2),
                            Colors.black, 15.0, 0.0, 5.0, null),
                      ),

                    ],
                  ),
                ],
              ),
            ),

        ],
      ),
    );
  }

  Widget _lineWithDeleteButton(BuildContext context, HomePageModel homePageModel, UserModel userModel){

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: widget.widthPercent*0.15,
              height: widget.heightPercent*0.08,
              child: RaisedButton(
                onPressed: (){

                  void _onSucessDelete(UserModel userModel) {
                    userModel.updateThisUserHasAmove(false);

                    FirestoreServices().notifyTruckerThatHeWasChanged(homePageModel.moveClass.freteiroId, homePageModel.moveClass.moveId); //alerta ao freteiro que ele foi cancelado na mudança. No freteiro vai recuperar isso para cancelar as notificações locais.

                    //cancelar as notificações neste caso
                    NotificationMeths().turnOffNotification(flutterLocalNotificationsPlugin); //apaga todas as notificações deste user


                    void _onFinishSaveNewAvaliation(){
                      MyBottomSheet().settingModalBottomSheet(context, 'Cancelamento', '', 'o agendamento foi cancelado.', Icons.done, widget.heightPercent, widget.widthPercent, 0, true);
                      homePageModel.moveClass = MoveClass();

                      homePageModel.setIsLoading(false);
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

                    MyBottomSheet().settingModalBottomSheet(context, 'Ops...', 'Ocorreu um erro.',
                        "O agendamento não foi cancelado. Tente novamente em instantes.", Icons.done, widget.heightPercent, widget.widthPercent, 0, true);
                  }

                  void _clickCancelMove(UserModel userModel){

                    homePageModel.setIsLoading(true);

                    SharedPrefsUtils().clearScheduledMove();
                    FirestoreServices().deleteAscheduledMove(
                        homePageModel.moveClass, () {
                      _onSucessDelete(userModel);
                    }, () {
                      _onFailureDelete();
                    });


                  }

                  homePageModel.showDarkBackground(true);
                  MyBottomSheet().settingModalBottomSheet(context, 'Cancelamento', 'Você está cancelando', 'Você tem certeza que deseja cancelar esta mudança?',
                      Icons.cancel_outlined, widget.heightPercent, widget.widthPercent, 2, false,
                      Icons.cancel, 'Sim, cancelar', () {_clickCancelMove(userModel);Navigator.pop(context);_toogleDarkScreen(homePageModel);},
                      Icons.arrow_downward, 'Manter mudança', () {Navigator.pop(context); _toogleDarkScreen(homePageModel);});


                },
                color: Colors.redAccent,
                child: Icon(Icons.cancel, color: Colors.white,),
              ),
            ),
            SizedBox(width: widget.widthPercent*0.05,),
            ResponsiveTextCustom('Cancelar mudança', context, Colors.black, 2, 0.0, 0.0, 'no'),
          ],
        ),
        Divider(),
      ],
    );
  }

  Widget _lineWithChangetruckerButton(BuildContext context, UserModel userModel, HomePageModel homePageModel ){

    Future<void> _onSucessChangeTrucker(String idFreteiro, String moveId) async {
      FirestoreServices().notifyTruckerThatHeWasChanged(idFreteiro,
          moveId); //alerta ao freteiro que ele foi cancelado na mudança. No freteiro vai recuperar isso para cancelar as notificações locais.

      await SharedPrefsUtils().updateSituation("sem motorista");
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => MoveSchedulePage(userModel.Uid)));
    }

    void _onFailureChangeTrucker() {

      homePageModel.setIsLoading(false);
      MyBottomSheet().settingModalBottomSheet(context, 'Ops..', 'Ocorreu um erro', 'Tente novamente.', Icons.warning_amber_sharp, widget.heightPercent, widget.widthPercent, 0, true);
    }


    void _changeTrucker(String id, String idFreteiro) {

      homePageModel.setIsLoading(true);

      FirestoreServices().changeTrucker(id, () {
        _onSucessChangeTrucker(idFreteiro, id);
      }, () {
        _onFailureChangeTrucker();
      });
    }

    void _sucess(){
      _changeTrucker(userModel.Uid, homePageModel.moveClass.freteiroId);

    }

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: widget.widthPercent*0.15,
              height: widget.heightPercent*0.08,
              child: RaisedButton(
                onPressed: (){

                  homePageModel.setIsLoading(true);

                  MyBottomSheet().settingModalBottomSheet(context, 'Mudança', 'Você está mudando de profissional', 'Você tem certeza que deseja trocar o profissional?',
                      Icons.assignment_ind_outlined, widget.heightPercent, widget.widthPercent, 2, false,
                      Icons.assignment_ind_outlined, 'Sim, trocar', () {_sucess();Navigator.pop(context);_toogleDarkScreen(homePageModel);},
                      Icons.arrow_downward, 'Manter profissional', () {Navigator.pop(context); _toogleDarkScreen(homePageModel);}

                  );
                },
                color: Colors.blue,
                child: Icon(Icons.account_box_sharp, color: Colors.white,),
              ),
            ),
            SizedBox(width: widget.widthPercent*0.05,),
            ResponsiveTextCustom('Trocar o profissional', context, Colors.black, 2, 0.0, 0.0, 'no'),
          ],
        ),
        Divider(),
      ],
    );
  }

  void _openPaymentPage(UserModel userModel, HomePageModel homePageModel){

    void _callback(){
      homePageModel.setIsLoading(false);
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => PaymentPage(homePageModel.moveClass)));
    }


    FirestoreServices().loadScheduledMoveInFbWithCallBack(homePageModel.moveClass, userModel, () {_callback();} );

  }

  Widget _lineWithPayButton(BuildContext context, UserModel userModel, HomePageModel homePageModel){

    /*
    void _openPaymentPage(UserModel userModel){

      void _callback(){
        homePageModel.setIsLoading(false);
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => PaymentPage(homePageModel.moveClass)));
      }


      FirestoreServices().loadScheduledMoveInFbWithCallBack(homePageModel.moveClass, userModel, () {_callback();} );

    }

     */

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: widget.widthPercent*0.15,
              height: widget.heightPercent*0.08,
              child: RaisedButton(
                onPressed: (){

                  if(homePageModel.moveClass.situacao == GlobalsStrings.sitAguardando){

                    homePageModel.setIsLoading(true);
                    MyBottomSheet().settingModalBottomSheet(context, 'Pagamento', 'Você está pagando', 'Você deseja pagar este serviço?',
                        Icons.credit_card, widget.heightPercent, widget.widthPercent, 2, false,
                        Icons.credit_card, 'Pagar', () {_openPaymentPage(userModel, homePageModel);Navigator.pop(context);_toogleDarkScreen(homePageModel);},
                        Icons.arrow_downward, 'Pagar depois', () {Navigator.pop(context); _toogleDarkScreen(homePageModel);}

                    );
                  }

                },
                color: CustomColors.yellow,
                child: Icon(Icons.credit_card, color: Colors.white,),
              ),
            ),
            SizedBox(width: widget.widthPercent*0.05,),
            ResponsiveTextCustom('Pagar', context, Colors.black, 2, 0.0, 0.0, 'no'),
          ],
        ),
        Divider(),
      ],
    );
  }

  Widget _lineWithWhastappBtn(BuildContext context, UserModel userModel, HomePageModel homePageModel){

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: widget.widthPercent*0.15,
              height: widget.heightPercent*0.08,
              child: RaisedButton(
                onPressed: () async {

                  homePageModel.setIsLoading(true);
                  String phone;
                  phone = await FirestoreServices().getTruckerPhone(homePageModel.moveClass.freteiroId);
                  //FlutterOpenWhatsapp.sendSingleMessage("918179015345", "Olá");
                  homePageModel.setIsLoading(false);
                  FlutterOpenWhatsapp.sendSingleMessage(
                      "55" + phone, "Olá, escolhi você no ${GlobalsStrings.appName}. Tudo bem?");

                },
                color: Colors.green,
                child: Icon(Icons.phone, color: Colors.white,),
              ),
            ),
            SizedBox(width: widget.widthPercent*0.05,),
            ResponsiveTextCustom('Mandar mensagem', context, Colors.black, 2, 0.0, 0.0, 'no'),
          ],
        ),
        Divider(),
      ],
    );
  }

  void _toogleDarkScreen(HomePageModel homePageModel){
    if(homePageModel.DarkBackground==true){
      homePageModel.showDarkBackground(false);
      homePageModel.setIsLoading(false);
    } else {
      homePageModel.showDarkBackground(true);
    }
  }

  void loadInfoFromFb(UserModel userModel, HomePageModel homePageModel) {


    print('load from db');

    Future<void> _onSucessExistsMove(UserModel userModel) async {
      //existe uma mudança para você
      MoveClass moveClassHere = MoveClass();
      moveClassHere = await FirestoreServices().loadScheduledMoveInFbWithCallBack(
          moveClassHere, userModel, () {
        _onSucessLoadScheduledMoveInFb(userModel, homePageModel, moveClassHere);
      });
    }

    void _onFailExistsMove() {
      //_displaySnackBar(context, "Você não possui mudança agendada");
    }

    if (isMovesLoadedFromFb == false) {
      isMovesLoadedFromFb = true;
      FirestoreServices().checkIfExistsAmoveScheduled(userModel.Uid, () {
        _onSucessExistsMove(userModel);
      }, () {
        _onFailExistsMove();
      });
    }
  }

  void _onSucessLoadScheduledMoveInFb(UserModel userModel, HomePageModel homePageModel, MoveClass moveClass) {
    //update the screen
    homePageModel.updateMoveClass(moveClass);
    //_moveClass = _moveClass;

  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(Duration(seconds: 1)).then((_) {

        double bottomOffset = _scrollController.position.maxScrollExtent;
        _scrollController.animateTo(
          bottomOffset,
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );

      });
    }
  }
}


/*
class HomeMyMoves extends StatelessWidget {
  double heightPercent;
  double widthPercent;
  HomeMyMoves(this.heightPercent, this.widthPercent);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  bool isMovesLoadedFromFb = false;

  ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<HomePageModel>(
      builder: (BuildContext context, Widget child, HomePageModel homePageModel){


        return ScopedModelDescendant<UserModel>(
          builder: (BuildContext context, Widget child, UserModel userModel){

            if(homePageModel.moveClass.userId!=null){
              //do nothing
            } else {
              _scrollController = ScrollController();
              loadInfoFromFb(userModel, homePageModel);
            }


            return Container(
              height: heightPercent,
              width: widthPercent,
              color: Colors.white,
              child: Stack(
                children: [

                  Positioned(
                    top: heightPercent*0.01,
                    left: widthPercent*0.05,
                    right: widthPercent*0.05,
                    bottom: 50.0,
                    child: ListView(
                      controller: _scrollController,
                      children: [

                        //titulo situacao
                        ResponsiveTextCustom('Situação da mudança', context, CustomColors.blue, 3, 0.0, 15.0, 'no'),
                        //caixa com a descricao da situação
                        Container(
                          alignment: Alignment.center,
                          decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 2.0, 4.0),
                          child: ResponsiveTextCustomWithMargin(MoveClass().returnSituation(homePageModel.moveClass.situacao), context,
                              CustomColors.blue, 2.0, 10.0, 10.0, 10.0, 10.0, 'no'),
                        ),
                        SizedBox(height: heightPercent*0.02,),
                        //texto mostrar mais
                        Container(
                          width: widthPercent*0.50,
                          height: 60.0,
                          child: RaisedButton(
                            color: CustomColors.yellow,
                              child: ResponsiveTextCustom(homePageModel.ShowResume==false ? 'Ver detalhes' : 'Recolher', context, Colors.white, 2.5, 0.0, 0.0, 'center'),
                            onPressed: (){
                              if(homePageModel.ShowResume==false){
                                homePageModel.updateShowResume(true);
                                scrollToBottom();
                              } else {
                                homePageModel.updateShowResume(false);
                              }
                            },
                        ),
                            color: CustomColors.yellow,
                        ),
                        //bloco com resumo
                        //SizedBox(height: heightPercent*0.05,),
                        homePageModel.ShowResume==true ? Container(
                          decoration: WidgetsConstructor().myBoxDecoration(CustomColors.yellow, CustomColors.yellow, 4.0, 4.0),
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              children: [

                                Row(
                                  children: [
                                    WidgetsConstructor().makeText(
                                        "Origem: ", Colors.black, 15.0, 0.0, 5.0, null),
                                    Container(
                                      width: widthPercent*0.60,
                                      child: WidgetsConstructor().makeText(
                                          homePageModel.moveClass.enderecoOrigem, Colors.black, 15.0, 0.0, 5.0,
                                          null),
                                    ),

                                  ],
                                ),

                                Row(
                                  children: [
                                    WidgetsConstructor().makeText(
                                        "Destino: ", Colors.black, 15.0, 0.0, 5.0, null),
                                    Container(
                                      width: widthPercent*0.60,
                                      child: WidgetsConstructor().makeText(
                                          homePageModel.moveClass.enderecoDestino, Colors.black, 15.0, 0.0,
                                          5.0, null),
                                    ),

                                  ],
                                ),
                                Row(
                                  children: [
                                    WidgetsConstructor().makeText(
                                        "Data: ", Colors.black, 15.0, 0.0, 5.0, null),
                                    WidgetsConstructor().makeText(
                                        "Destino: ", Colors.black, 15.0, 0.0, 5.0, null),
                                    Container(
                                      width: widthPercent*0.60,
                                      child: WidgetsConstructor().makeText(
                                          homePageModel.moveClass.dateSelected, Colors.black, 15.0, 0.0, 5.0,
                                          null),
                                    ),

                                  ],
                                ),
                                Row(
                                  children: [
                                    WidgetsConstructor().makeText(
                                        "Horário: ", Colors.black, 15.0, 0.0, 5.0, null),
                                    Container(
                                      width: widthPercent*0.60,
                                      child: WidgetsConstructor().makeText(
                                          homePageModel.moveClass.timeSelected, Colors.black, 15.0, 0.0, 5.0,
                                          null),
                                    ),


                                  ],
                                ),
                                Row(
                                  children: [
                                    WidgetsConstructor().makeText(
                                        "Valor: ", Colors.black, 15.0, 0.0, 5.0, null),
                                    Container(
                                      width: widthPercent*0.60,
                                      child: WidgetsConstructor().makeText(
                                          "R\$ " + homePageModel.moveClass.preco.toStringAsFixed(2),
                                          Colors.black, 15.0, 0.0, 5.0, null),
                                    ),

                                  ],
                                ),
                              ],
                            ),
                          ),
                        ) : Container(),
                        //SizedBox(height: 5.0,),
                        //linha com o resumo da mudança
                        //animPrevi(context, homePageModel),
                        animPrevi2(context, homePageModel),
                        SizedBox(height: 15.0,),

                        homePageModel.moveClass.situacao == GlobalsStrings.sitAccepted ?
                        _lineWithWhastappBtn(context, userModel, homePageModel) : Container(),
                        homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitAguardando ||
                            homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitTruckerQuitAfterPayment ||
                            homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitAccepted ||
                            homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitPago ||
                            homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitDeny ||
                            homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitNoTrucker
                            ? _lineWithChangetruckerButton(context, userModel, homePageModel) : Container(),
                        SizedBox(height: 5.0,),
                        //linha pagar
                        homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitAccepted
                            ? _lineWithPayButton(context, userModel, homePageModel) : Container(),
                        //linha com botao para cancelar
                        homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitAguardando ||
                            homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitAccepted ||
                            homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitTruckerQuitAfterPayment ||
                            homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitDeny ||
                            homePageModel.moveClass.moveId != null && homePageModel.moveClass.situacao == GlobalsStrings.sitNoTrucker
                            ? _lineWithDeleteButton(context, homePageModel, userModel): Container(),
                        SizedBox(height: 5.0,),




                      ],
                    ),
                  ),

                  homePageModel.IsLoading==true ? Center(child: CircularProgressIndicator(),) : Container(),


                ],
              ),
            );

          },
        );

      },
    );
  }

  Widget animPrevi(BuildContext context, HomePageModel homePageModel){

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(-3, 3), // changes position of shadow
          ),
        ],

      ),
      width: widthPercent*0.9,
      height: heightPercent*0.25,
      child: Stack(
        children: [

          Positioned(
            top: 5.0,
            left: 5.0,
            right: 5.0,
            child: ResponsiveTextCustom('Próximos passos', context, Colors.black, 2.0, 0.0, 0.0, 'center'),
          ),
          
          Positioned(
              top: 75.0,
              left: 5.0,
              right: 5.0,
              child: Container(
                height: 5.0,
                width: widthPercent*0.9,
                color: CustomColors.yellow,
              )),

          //primeira bolinha
          Positioned(
            top: 63.0,
            left: 4.0,
            child: Container(
              width: widthPercent*0.08,
              height: 28.0,
              decoration: new BoxDecoration(
                shape: BoxShape.circle,// You can use like this way or like the below line
                //borderRadius: new BorderRadius.circular(30.0),
                color: CustomColors.yellow,
              ),
            ),
          ),

          //texto em baixo da primeira bolinha
          Positioned(
            top: 95.0,
            left: 1.0,
            child: ResponsiveTextCustom('Hoje', context, Colors.black, 2, 0.0, 0.0, 'no'),
          ),

          //texto em cima da segunda bolinha
          Positioned(
            top: 50,
            left: homePageModel.moveClass.situacao == GlobalsStrings.sitAguardando ? widthPercent*0.13
            : homePageModel.moveClass.situacao == GlobalsStrings.sitDeny ? widthPercent*0.18
            : widthPercent*0.20,
            child: Container(
              decoration: new BoxDecoration(
                border: Border.all(
                  width: 2.0, //                   <--- border width here
                ),
                borderRadius: new BorderRadius.circular(3.0),
                color: CustomColors.blue,
              ),
              child: ResponsiveTextCustom(
                  homePageModel.moveClass.situacao == GlobalsStrings.sitAguardando ? homePageModel.moveClass.situacao+' '+homePageModel.moveClass.nomeFreteiro
                      : homePageModel.moveClass.situacao ==  GlobalsStrings.sitDeny || homePageModel.moveClass.situacao == GlobalsStrings.sitNoTrucker ? 'Escolher outro'
                      : 'etapa ok'
                  , context, Colors.white, 1.2, 0.5, 0.5, 'center'),
            ),
          ),

          //segunda bolinha (situacao)
          Positioned(
            top: 67.0,
            left: widthPercent*0.25,
            child: Container(
              width: widthPercent*0.05,
              height: 20.0,
              decoration: new BoxDecoration(
                border: Border.all(
                  color: CustomColors.yellow,
                  width: 2.0, //                   <--- border width here
                ),
                shape: BoxShape.circle,// You can use like this way or like the below line
                //borderRadius: new BorderRadius.circular(30.0),
                color: homePageModel.moveClass.situacao == GlobalsStrings.sitAguardando ? Colors.white
                    : homePageModel.moveClass.situacao == GlobalsStrings.sitDeny ? Colors.white
                    : CustomColors.yellow,
              ),
            ),
          ),


          //texto em cima da terceira bolinha
          Positioned(
            top: 50,
            left: homePageModel.moveClass.situacao == GlobalsStrings.sitPago ? widthPercent*0.52 : widthPercent*0.44,
            child: Container(
              decoration: new BoxDecoration(
                border: Border.all(
                  width: 2.0, //                   <--- border width here
                ),
                borderRadius: new BorderRadius.circular(3.0),
                color: CustomColors.blue,
              ),
              child: ResponsiveTextCustom(homePageModel.moveClass.situacao == GlobalsStrings.sitPago ? 'Pago' : 'Realizar pagamento', context, Colors.white, 1.2, 0.5, 0.5, 'center'),
            ),
          ),


          //terceira bolinha pagamento
          Positioned(
            top: 67.0,
            left: widthPercent*0.55,
            child: Container(
              width: widthPercent*0.05,
              height: 20.0,
              decoration: new BoxDecoration(
                border: Border.all(
                  color: CustomColors.yellow,
                  width: 2.0, //                   <--- border width here
                ),
                shape: BoxShape.circle,// You can use like this way or like the below line
                //borderRadius: new BorderRadius.circular(30.0),
                color: homePageModel.moveClass.situacao == GlobalsStrings.sitPago ? CustomColors.yellow : Colors.white,
              ),
            ),
          ),

          Positioned(
            top: 95.0,
            right: 1.0,
            child: ResponsiveTextCustom('Mudança', context, Colors.black, 2, 0.0, 0.0, 'no'),
          ),

          Positioned(
            top: 63.0,
            right: 4.0,
            child: Container(
              width: widthPercent*0.08,
              height: 28.0,
              decoration: new BoxDecoration(
                border: Border.all(
                  color: CustomColors.yellow,
                  width: 2.0, //                   <--- border width here
                ),
                shape: BoxShape.circle,// You can use like this way or like the below line
                //borderRadius: new BorderRadius.circular(30.0),
                color: Colors.white,
              ),
            ),
          ),

          //texto mostrando que está tudo ok
          homePageModel.moveClass.situacao == GlobalsStrings.sitPago ? Positioned(
            top: 110,
            left: 10.0,
            right: 10.0,
            child: ResponsiveTextCustom('Tudo certo. Aguarde a mudança', context, Colors.black, 1.8, 0.0, 0.0, 'center'),
          ) : Container(),

        ],
      ),
    );
  }

  Widget animPrevi2(BuildContext context, HomePageModel homePageModel){

    return Container(
      decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 2.0, 3.0),
      width: widthPercent*0.9,
      height: heightPercent*0.5,
      child: Stack(
        children: [

          Positioned(
            top: 5.0,
            left: 5.0,
            right: 5.0,
            child: ResponsiveTextCustom('Ações', context, Colors.black, 2.0, 0.0, 0.0, 'center'),
          ),



        ],
      ),
    );
  }

  Widget _lineWithDeleteButton(BuildContext context, HomePageModel homePageModel, UserModel userModel){

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: widthPercent*0.15,
              height: heightPercent*0.08,
              child: RaisedButton(
                onPressed: (){

                  void _onSucessDelete(UserModel userModel) {
                    userModel.updateThisUserHasAmove(false);

                    FirestoreServices().notifyTruckerThatHeWasChanged(homePageModel.moveClass.freteiroId, homePageModel.moveClass.moveId); //alerta ao freteiro que ele foi cancelado na mudança. No freteiro vai recuperar isso para cancelar as notificações locais.

                    //cancelar as notificações neste caso
                    NotificationMeths().turnOffNotification(flutterLocalNotificationsPlugin); //apaga todas as notificações deste user


                    void _onFinishSaveNewAvaliation(){
                      MyBottomSheet().settingModalBottomSheet(context, 'Cancelamento', '', 'o agendamento foi cancelado.', Icons.done, heightPercent, widthPercent, 0, true);
                      homePageModel.moveClass = MoveClass();

                      homePageModel.setIsLoading(false);
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

                    MyBottomSheet().settingModalBottomSheet(context, 'Ops...', 'Ocorreu um erro.',
                        "O agendamento não foi cancelado. Tente novamente em instantes.", Icons.done, heightPercent, widthPercent, 0, true);
                  }

                  void _clickCancelMove(UserModel userModel){

                    homePageModel.setIsLoading(true);

                    SharedPrefsUtils().clearScheduledMove();
                    FirestoreServices().deleteAscheduledMove(
                        homePageModel.moveClass, () {
                      _onSucessDelete(userModel);
                    }, () {
                      _onFailureDelete();
                    });


                  }

                  homePageModel.showDarkBackground(true);
                  MyBottomSheet().settingModalBottomSheet(context, 'Cancelamento', 'Você está cancelando', 'Você tem certeza que deseja cancelar esta mudança?',
                  Icons.cancel_outlined, heightPercent, widthPercent, 2, false,
                  Icons.cancel, 'Sim, cancelar', () {_clickCancelMove(userModel);Navigator.pop(context);_toogleDarkScreen(homePageModel);},
                  Icons.arrow_downward, 'Manter mudança', () {Navigator.pop(context); _toogleDarkScreen(homePageModel);});


                },
                color: Colors.redAccent,
                child: Icon(Icons.cancel, color: Colors.white,),
              ),
            ),
            SizedBox(width: widthPercent*0.05,),
            ResponsiveTextCustom('Cancelar mudança', context, Colors.black, 2, 0.0, 0.0, 'no'),
          ],
        ),
        Divider(),
      ],
    );
  }

  Widget _lineWithChangetruckerButton(BuildContext context, UserModel userModel, HomePageModel homePageModel ){

    Future<void> _onSucessChangeTrucker(String idFreteiro, String moveId) async {
      FirestoreServices().notifyTruckerThatHeWasChanged(idFreteiro,
          moveId); //alerta ao freteiro que ele foi cancelado na mudança. No freteiro vai recuperar isso para cancelar as notificações locais.

      await SharedPrefsUtils().updateSituation("sem motorista");
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => MoveSchedulePage(userModel.Uid)));
    }

    void _onFailureChangeTrucker() {

      homePageModel.setIsLoading(false);
      MyBottomSheet().settingModalBottomSheet(context, 'Ops..', 'Ocorreu um erro', 'Tente novamente.', Icons.warning_amber_sharp, heightPercent, widthPercent, 0, true);
    }


    void _changeTrucker(String id, String idFreteiro) {

      homePageModel.setIsLoading(true);

      FirestoreServices().changeTrucker(id, () {
        _onSucessChangeTrucker(idFreteiro, id);
      }, () {
        _onFailureChangeTrucker();
      });
    }

    void _sucess(){
      _changeTrucker(userModel.Uid, homePageModel.moveClass.freteiroId);

    }

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: widthPercent*0.15,
              height: heightPercent*0.08,
              child: RaisedButton(
                onPressed: (){

                  homePageModel.setIsLoading(true);

                  MyBottomSheet().settingModalBottomSheet(context, 'Mudança', 'Você está mudando de profissional', 'Você tem certeza que deseja trocar o profissional?',
                      Icons.assignment_ind_outlined, heightPercent, widthPercent, 2, false,
                      Icons.assignment_ind_outlined, 'Sim, trocar', () {_sucess();Navigator.pop(context);_toogleDarkScreen(homePageModel);},
                      Icons.arrow_downward, 'Manter profissional', () {Navigator.pop(context); _toogleDarkScreen(homePageModel);}

                  );
                },
                color: Colors.blue,
                child: Icon(Icons.account_box_sharp, color: Colors.white,),
              ),
            ),
            SizedBox(width: widthPercent*0.05,),
            ResponsiveTextCustom('Trocar o profissional', context, Colors.black, 2, 0.0, 0.0, 'no'),
          ],
        ),
        Divider(),
      ],
    );
  }

  Widget _lineWithPayButton(BuildContext context, UserModel userModel, HomePageModel homePageModel){

    void _openPaymentPage(UserModel userModel){

      void _callback(){
        homePageModel.setIsLoading(false);
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => PaymentPage(homePageModel.moveClass)));
      }

      
      FirestoreServices().loadScheduledMoveInFbWithCallBack(homePageModel.moveClass, userModel, () {_callback();} );

    }

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: widthPercent*0.15,
              height: heightPercent*0.08,
              child: RaisedButton(
                onPressed: (){

                  if(homePageModel.moveClass.situacao == GlobalsStrings.sitAguardando){

                    homePageModel.setIsLoading(true);
                    MyBottomSheet().settingModalBottomSheet(context, 'Pagamento', 'Você está pagando', 'Você deseja pagar este serviço?',
                        Icons.credit_card, heightPercent, widthPercent, 2, false,
                        Icons.credit_card, 'Pagar', () {_openPaymentPage(userModel);Navigator.pop(context);_toogleDarkScreen(homePageModel);},
                        Icons.arrow_downward, 'Pagar depois', () {Navigator.pop(context); _toogleDarkScreen(homePageModel);}

                    );
                  }

                },
                color: CustomColors.yellow,
                child: Icon(Icons.credit_card, color: Colors.white,),
              ),
            ),
            SizedBox(width: widthPercent*0.05,),
            ResponsiveTextCustom('Pagar', context, Colors.black, 2, 0.0, 0.0, 'no'),
          ],
        ),
        Divider(),
      ],
    );
  }

  Widget _lineWithWhastappBtn(BuildContext context, UserModel userModel, HomePageModel homePageModel){

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: widthPercent*0.15,
              height: heightPercent*0.08,
              child: RaisedButton(
                onPressed: () async {

                  homePageModel.setIsLoading(true);
                  String phone;
                  phone = await FirestoreServices().getTruckerPhone(homePageModel.moveClass.freteiroId);
                  //FlutterOpenWhatsapp.sendSingleMessage("918179015345", "Olá");
                  homePageModel.setIsLoading(false);
                  FlutterOpenWhatsapp.sendSingleMessage(
                      "55" + phone, "Olá, escolhi você no ${GlobalsStrings.appName}. Tudo bem?");

                },
                color: Colors.green,
                child: Icon(Icons.phone, color: Colors.white,),
              ),
            ),
            SizedBox(width: widthPercent*0.05,),
            ResponsiveTextCustom('Mandar mensagem', context, Colors.black, 2, 0.0, 0.0, 'no'),
          ],
        ),
        Divider(),
      ],
    );
  }


  void _toogleDarkScreen(HomePageModel homePageModel){
    if(homePageModel.DarkBackground==true){
      homePageModel.showDarkBackground(false);
      homePageModel.setIsLoading(false);
    } else {
      homePageModel.showDarkBackground(true);
    }
  }

  void loadInfoFromFb(UserModel userModel, HomePageModel homePageModel) {


    print('load from db');

    Future<void> _onSucessExistsMove(UserModel userModel) async {
      //existe uma mudança para você
      MoveClass moveClassHere = MoveClass();
      moveClassHere = await FirestoreServices().loadScheduledMoveInFbWithCallBack(
          moveClassHere, userModel, () {
        _onSucessLoadScheduledMoveInFb(userModel, homePageModel, moveClassHere);
      });
    }

    void _onFailExistsMove() {
      //_displaySnackBar(context, "Você não possui mudança agendada");
    }

    if (isMovesLoadedFromFb == false) {
      isMovesLoadedFromFb = true;
      FirestoreServices().checkIfExistsAmoveScheduled(userModel.Uid, () {
        _onSucessExistsMove(userModel);
      }, () {
        _onFailExistsMove();
      });
    }
  }

  void _onSucessLoadScheduledMoveInFb(UserModel userModel, HomePageModel homePageModel, MoveClass moveClass) {
    //update the screen
    homePageModel.updateMoveClass(moveClass);
    //_moveClass = _moveClass;

  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(Duration(seconds: 1)).then((_) {

        double bottomOffset = _scrollController.position.maxScrollExtent;
        _scrollController.animateTo(
          bottomOffset,
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );

      });
    }
  }

}

 */