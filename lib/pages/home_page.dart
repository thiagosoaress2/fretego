import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/drawer/menu_drawer.dart';
import 'package:fretego/login/pages/email_verify_view.dart';
import 'package:fretego/login/pages/login_choose_view.dart';
import 'package:fretego/login/services/auth.dart';
import 'package:fretego/login/services/new_auth_service.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/animationPlay.dart';
import 'package:fretego/pages/avalatiation_page.dart';
import 'package:fretego/pages/mercadopago.dart';
import 'package:fretego/pages/payment_page.dart';
import 'package:fretego/pages/move_day_page.dart';
import 'package:fretego/pages/my_moves.dart';
import 'package:fretego/pages/select_itens_page.dart';
import 'package:fretego/pages/user_informs_bank_data_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/anim_fader.dart';
import 'package:fretego/utils/anim_fader_left.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/date_utils.dart';
import 'package:fretego/utils/mp_globals.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

//https://www.geeksforgeeks.org/splash-screen-in-flutter/   splashscreen

class HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage>, TickerProviderStateMixin {

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

  bool menuIsVisible=false;

  bool isLoading=false;

  //TUDO DA ANIMIACAO DO DRAWER
  AnimationController animationController; //usado para fazer a tela diminuir e dar sensação do menu

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    //para animação da tela
    _scrollController.addListener(() {
      setState(() {
        offset = _scrollController.hasClients ? _scrollController.offset : 0.1;

      });
      print(offset);
    });
    //offset = _scrollController.hasClients ? _scrollController.offset : 0.1;

  }


  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();

  }

  void _toggle(){
    if(animationController.isDismissed){
      menuIsVisible=true;
      animationController.forward();
    } else {
      menuIsVisible=false;
      animationController.reverse();
    }
  }

  bool _canBeDragged=false;
  double minDragStartEdge=60.0;
  double maxDragStartEdge;

  final double maxSlide=225.0;


  void _onDragStart(DragStartDetails details){
    bool isDragOpenFromLeft = animationController.isDismissed && details.globalPosition.dx < minDragStartEdge;
    bool isDragcloseFromRight = animationController.isCompleted && details.globalPosition.dx > maxDragStartEdge;

    _canBeDragged = isDragOpenFromLeft || isDragcloseFromRight;
    if(isDragOpenFromLeft){
      menuIsVisible=true;
      _canBeDragged=false;
    } else {
      menuIsVisible=false;
    }
  }

  void _onDragUpdate(DragUpdateDetails details){
    if(_canBeDragged){
      double delta = details.primaryDelta / maxSlide;
      animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details){
    if(animationController.isDismissed || animationController.isCompleted){
      return;
    }
    if(details.velocity.pixelsPerSecond.dx.abs() >= 365.0){
      double visualVelocity = details.velocity.pixelsPerSecond.dx / MediaQuery.of(context).size.width;

      animationController.fling(velocity: visualVelocity);
    } else if(animationController.value < 0.5){
      //close();
      _toggle();
    } else {
      //open();
      _toggle();
    }

  }


  //FIM DE TUDO DA ANIMIACAO DO DRAWER

  //INICIO ANIMACAO DA APRESENTACAO DO APP

    ScrollController _scrollController;
    double offset = 1.0;
  //FIM DA ANIMACAO DA APRESENTAO DO APP

  //ANIMACAO DO BOTAO
  double _buttonPosition=0.0;
  //FIM DA ANIMACAO COM BOTAO

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

    maxDragStartEdge=maxSlide-16; //DRAWER

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        //isLoggedIn(userModel);

        userModelGLobal = userModel;


        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {

            _newAuthService = newAuthService;


            return SafeArea(
              child: Scaffold(
                  key: _scaffoldKey,
                  body: GestureDetector(
                    onHorizontalDragStart: _onDragStart,
                    onHorizontalDragUpdate: _onDragUpdate,
                    onHorizontalDragEnd: _onDragEnd,

                    //onTap: _toggle,

                    child: AnimatedBuilder(
                      animation: animationController,
                      builder: (context, _) {

                        double menuSlide = (maxSlide+20.0) * animationController.value;
                        double menuScale = 1 + (animationController.value*0.7);
                        double slide = maxSlide * animationController.value;
                        double scale = 1 -(animationController.value*0.3);
                        return Stack(
                          children: [


                            menuIsVisible==true ? CustomMenu() : Container(), //isto é o fundo. O menu é um container azul que em uma parte tem o menu

                            //corpo

                            Transform(transform: Matrix4.identity() //aqui é onde estão todos os elementos da tela
                              ..translate(slide)
                              ..scale(scale),
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(top: heightPercent*0.10),
                                child: Stack(
                                  children: [

                                    /*
                                    Center(
                                      child: Container(
                                        color: Colors.white,
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

                                     */

                                    //fundo de parede
                                    Positioned(
                                        //top: heightPercent*0.05,
                                        top: 5.0,
                                        child: Container(
                                          width: widthPercent,
                                          height: heightPercent*0.9,
                                          child: Image.asset('images/home_backwall.png', fit: BoxFit.fill,),
                                        ),
                                    ),

                                    //casal
                                    Positioned(
                                        right: widthPercent*0.10,
                                        top: heightPercent*0.42+offset,
                                        //bottom: heightPercent*0.1,
                                        child: Container(
                                          width: widthPercent,
                                          height: heightPercent*0.40,
                                          child: Image.asset('images/home_couple.png'),
                                        )),

                                    Positioned(
                                        top: heightPercent*0.63 -offset,
                                      //bottom: 0.0,
                                        child: Container(
                                          width: widthPercent,
                                          height: heightPercent*0.25,
                                          child: Image.asset('images/home_boxes.png', fit: BoxFit.fill,),
                                        )),

                                    offset < 250.0
                                    ? Positioned(
                                        left: 10.0,
                                        right: 10.0,
                                        top: heightPercent*0.3,
                                        //bottom: heightPercent*0.45,
                                        child: Container(
                                          width: widthPercent*0.7,
                                          child: Column(
                                            children: [
                                              WidgetsConstructor().makeText('Conheça nosso', Colors.white, 25.0, 0.0, 0.0, 'center'),
                                              WidgetsConstructor().makeText('serviço', Colors.white, 25.0, 0.0, 0.0, 'center'),
                                              Transform.rotate(angle: 1.5, child: Icon(Icons.double_arrow, size: 25, color: Colors.white.withOpacity(0.5),),),
                                            ],
                                          ),
                                        ))
                                    :Container(),


                                    Scrollbar(child: ListView(
                                      controller: _scrollController,
                                      children: [
                                        SizedBox(height: heightPercent*0.85,),
                                        Container(alignment: Alignment.topCenter,color: CustomColors.brown,height: 100.0, width: widthPercent, child: Image.asset('images/home_boxline.png'),),
                                        Container(color: CustomColors.brown, width: widthPercent, height: 150.0,
                                          child: Column(
                                            children: [
                                              offset>280
                                              ? WidgetsConstructor().makeText('O que nós fazemos?', Colors.white, 25.0, 25.0, 0.0, 'center')
                                                  : Container(),
                                              offset>350
                                                  ? WidgetsConstructor().makeText('- Ajudamos na sua mudança', Colors.white, 16.0, 20.0, 0.0, 'center')
                                                  : Container(),

                                            ],
                                          ),
                                        ),
                                        Container(
                                          color: Colors.white,
                                          width: widthPercent,
                                          height: 700.0,
                                          child: offset>400 ? AnimationPage1(): Container(),
                                        ),
                                        SizedBox(height: 20.0,),
                                        offset>1000 ? EntranceFader(
                                          offset: Offset(widthPercent /4,0),
                                          duration: Duration(seconds: 3),
                                          child: WidgetsConstructor().makeText('Informe os endereços', Colors.white, 25.0, 10.0, 0.0, 'center'),
                                        ): Container(),
                                        offset>1100 ? AnimationPage2() : Container(),
                                        SizedBox(height: 250.0,),
                                        offset>1850 ? AnimationPage3() : Container(),
                                        SizedBox(height: 1000.0,),
                                        offset>3050 ? AnimationPage4() : Container(),
                                        //Container(color: Colors.white, height: 500.0,),
                                        


                                      ],
                                    ),
                                    ),

                                    //este é o card com o freteiro. Aparece sobreponto a Listview
                                    offset > 2250 && offset<2650 ? Positioned(
                                        left: 10.0,
                                        top: offset-2250,
                                        child: Container(
                                          height: 200.0,
                                          decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.white, 2.0, 8.0),
                                          width: widthPercent*0.6,
                                          child: Column(
                                            children: [
                                              WidgetsConstructor().makeText('João do frete', CustomColors.blue, 18.0, 20.0, 20.0, 'center'),
                                              SizedBox(height: 15.0,),
                                              Row(
                                                children: [
                                                  SizedBox(width: widthPercent*0.02,),
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(360.0),
                                                    child: Image.asset('images/home_trucker.jpg', width: 75.0, height: 75.9, fit: BoxFit.fill,)
                                                    ),
                                                  SizedBox(width: widthPercent*0.02,),
                                                  Icon(Icons.star, size: 20.0, color: Colors.yellow,),
                                                  Icon(Icons.star, size: 20.0, color: Colors.yellow,),
                                                  Icon(Icons.star, size: 20.0, color: Colors.yellow,),
                                                  Icon(Icons.star, size: 20.0, color: Colors.yellow,),
                                                  Icon(Icons.star, size: 20.0, color: Colors.yellow,),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                    ) : Container(),

                                    offset > 2550 && offset < 3357 ?
                                        Positioned(
                                          left: widthPercent*0.2,
                                          bottom: offset<2890 ? offset-2900 : offset<3100 ? 0.0 : 3100-offset, //primeiro vamos aumentando, pra subir, dps retirando pra baixar
                                          child: Container(
                                            width: 150.0,
                                            height: 250.0,
                                            child: Image.asset('images/home_trucker_anim.png', fit: BoxFit.fill,),
                                          ),
                                        ) : Container(),

                                    /*
                                    offset > 2550 && offset<2790 ? Positioned(
                                      bottom: 0.0,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            //SizedBox(width: widthPercent,),
                                            SizedBox(width: offset<2550 ? 1000 : 2800-offset > 0.0 ? 2800-offset: 0.0,),
                                            Container(
                                              width: 150.0,
                                              height: 250.0,
                                              child: Image.asset('images/home_trucker_anim.png', fit: BoxFit.fill,),
                                            )
                                          ],
                                        ),
                                      ),
                                    ) : Container(),
                                     */

                                    //botão Para ir pra mudança
                                    offset<350 ? Positioned(
                                      right: widthPercent*0.05,
                                      top: heightPercent*0.02,
                                      child: Column(
                                        children: [

                                          Container(
                                            width: userIsLoggedIn == true && _showMoveShortCutBtn==true ? widthPercent*0.45 : widthPercent*0.35,
                                            child: RaisedButton(
                                              splashColor: Colors.grey[200],
                                              elevation: 10.0,
                                              color: _showPayBtn == true ? Colors.red : CustomColors.yellow,
                                              onPressed: (){

                                                if(userIsLoggedIn==true){

                                                  //se o botão de pagar está sendo exibido enviar direto para página de pagamento
                                                  if(_showPayBtn==true){
                                                    setState(() {
                                                      isLoading=true;
                                                    });
                                                    _openPaymentPageFromCallBacks(userModel);
                                                  } else {
                                                    Navigator.of(context).push(_createRoute(SelectItensPage()));
                                                  }


                                                } else {

                                                  Navigator.of(context).push(_createRoute(LoginChooseView()));

                                                }

                                              },
                                              child: WidgetsConstructor().makeText(userIsLoggedIn == true && _showMoveShortCutBtn==false ? 'Começar mudança' : _showPayBtn == true ? 'Pagar' : userIsLoggedIn == true && _showMoveShortCutBtn==true ? 'Ver minha mudança'  : 'Login', Colors.white, 18.0, 5.0, 5.0, 'center'),
                                            ),
                                          ),

                                          _showPayBtn == true
                                              ? WidgetsConstructor().makeText('Realize pagamento', CustomColors.blue, 16.0, 5.0, 0.0, 'center') : Container(),


                                        ],
                                      ),

                                      /*
                                            setState(() {
                                              _buttonPosition=widthPercent*0.06;
                                            });


                                            if(userIsLoggedIn==true){

                                            Future.delayed(Duration(milliseconds: 200)).then((value) {
                                              Future.delayed(Duration(milliseconds: 200)).then((value){
                                                setState(() {
                                                  _buttonPosition=-300.0;
                                                });
                                              });

                                              Navigator.of(context).push(_createRoute(SelectItensPage()));

                                            });

                                              } else {

                                              Future.delayed(Duration(milliseconds: 200)).then((value) {
                                                Future.delayed(Duration(milliseconds: 200)).then((value){
                                                  setState(() {
                                                    _buttonPosition=-300.0;
                                                  });
                                                });

                                                Navigator.of(context).push(_createRoute(LoginChooseView()));

                                              });

                                            }

                                          },
                                          child: WidgetsConstructor().makeText(userIsLoggedIn == true ? 'Começar mudança' : 'Login', Colors.white, 18.0, 5.0, 5.0, 'center'),
                                        ),

                                      ),
                                          offset: Offset(_buttonPosition, 0.0)

                                      ),

                                             */
                                    ) : Container(),



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
                                        ? WidgetsConstructor().customPopUp('Pedimos Desculpas', 'Infelizmente o profissional que você escolheu desistiu do serviço. Sabemos o quanto isso é chato e oferecemos as seguintes opções:', 'Escolher outro', 'Reaver dinheiro', widthPercent, heightPercent, () { _trucker_quitedAfterPayment_getNewTrucker();}, () { _trucker_quitedAfterPayment_cancel(userModel);})
                                        : popupCode=='trucker_finished'
                                        ? WidgetsConstructor().customPopUp('Mudança terminando', 'O profissional informou que a mudança terminou. Se o serviço realmente já terminou, confirme para avaliar.', 'Finalizar e avaliar', 'Ainda não terminou', widthPercent, heightPercent, () { _truckerInformedFinishedMove(userModel);}, () {_setPopuoCodeToDefault();})
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),

                            //barra appbar
                            Transform(transform: Matrix4.identity() //aqui é o appbar fake q eu criei para simular a appbar original
                              ..translate(menuSlide)
                              ..scale(menuScale),
                              child: FakeAppBar(userModel),
                            ),

                            GestureDetector(
                              onTap: (){

                                void _click1(){
                                  print('click1');
                                }
                                void _click2(){
                                  print('click2');
                                }

                                MyBottomSheet().settingModalBottomSheet(context, 'Titulo', 'subtitle', 'texts saijisi asuhdu asinasini saijiasji exemplos text txtx dlksalk txe', Icons.credit_card, heightPercent, widthPercent, 2, true, Icons.credit_card, 'Pagar', () {_click1();}, Icons.arrow_downward, 'Pagar depois', () {_click1();});
                              },
                              child: Container(width: 150.0, height: 100.0, color: Colors.pink,),
                            ),



                          ],
                        );
                      },
                    ),
                  )
              ),
            );
          },
        );
      },
    );
  }

  Route _createRoute(Widget Page) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) => Page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        //var tween = Tween(begin: begin, end: end); //comente este para usar o final suave

        var curve = Curves.easeInOut; // - use este para final suave

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve)); //- use estepara final suave
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  void _setupAnimations(){

    //este controler é do menu
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

    _scrollController = ScrollController();

  }

  Widget AnimationPage1(){
      return Container(
        width: widthPercent,
        height: 350.0,
        color: Colors.white,
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(width: offset<400 ? 1000 : 600-offset > 0.0 ? 600-offset: 0.0,),
                  WidgetsConstructor().makeText('VEJA COMO', CustomColors.yellow, 50.0, 5.0, 15.0, 'no')
                ],
              ),
            ),

            EntranceFader(
              offset: Offset(widthPercent /4,0),
              duration: Duration(seconds: 5),
              child: WidgetsConstructor().makeText('Selecione os', CustomColors.blue, 20.0, 10.0, 10.0, 'center'),
            ),
            EntranceFader(
              offset: Offset(widthPercent /4,0),
              duration: Duration(seconds: 5),
              child: WidgetsConstructor().makeText('                  itens importantes', CustomColors.blue, 20.0, 10.0, 10.0, 'center'),
            ),
            SizedBox(height: 40.0,),
            Row(
              children: [
                SizedBox(width: 15.0,),
                Stack(
                  children: [
                    offset>550 ? EntranceFaderLeft(
                      offset: Offset(widthPercent/4,0),
                      duration: Duration(seconds: 2),
                      child: Container(width: widthPercent*0.5, height: 200.0, child: Image.asset(
                        'images/home_sofaazul.png',
                        fit: BoxFit.fill,
                      ),),
                    ) : Container(),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Stack(
                  children: [
                    offset>650 ? EntranceFader(
                      offset: Offset(widthPercent /4,0),
                      duration: Duration(seconds: 2),
                      child: Container(width: widthPercent*0.5, height: 200.0, child: Image.asset(
                        'images/home_tv.png',
                        fit: BoxFit.fill,
                      ),),
                    ) : Container(),
                  ],
                ),
                SizedBox(width: 15.0,),
              ],
            ),
          ],
        )
      );
  }

  Widget AnimationPage2(){


    TextEditingController _sourceAdress = TextEditingController();
    TextEditingController _destinyAdress = TextEditingController();
    bool _searchCEP = false;


    if(offset>1200){
      _sourceAdress.text='Aven';
    }
    if (offset>1300){
      _sourceAdress.text='Avenida';
    }
    if(offset>1400){
      _sourceAdress.text='Avenida Um';
    }
    if(offset>1500){
      _destinyAdress.text='Rua';
    }
    if(offset>1600){
      _destinyAdress.text='Rua sete';
    }


    return Container(
      width: widthPercent,
      alignment: Alignment.center,
      height: 500.0,
      child: Stack(
        children: [

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [

                    //SizedBox(height: (offset-1000) > 80.0 ? 80 : (offset-1000)< 10.0 ? 10.0 : (offset-1000),),
                    //SizedBox(height: (offset-1000) > 10.0 ? 10.0 : (offset-1000),),
                    SizedBox(height: (1400-offset) < 2.0 ? 2.0 : 1400-offset,),
                    //box with the address search engine
                    Container(
                        width: widthPercent*0.9,
                        decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 3.0, 2.0),
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              SizedBox(height: 10.0,),
                              //text of centralized title
                              WidgetsConstructor().makeText("Endereços", Colors.blue, 18.0, 5.0, 0.0, "center"),
                              SizedBox(height: 20.0,),
                              //Row with button search criteria select (address or CEP)
                              Row(
                                children: [
                                  //search by address button
                                  GestureDetector(
                                    child: _searchCEP == false ? WidgetsConstructor().makeButton(Colors.lightBlueAccent, Colors.white, widthPercent*0.40, 50.0, 1.0, 3.0, "Endereço", Colors.white, 15.0)
                                        :WidgetsConstructor().makeButton(Colors.grey[10], Colors.white, widthPercent*0.40, 50.0, 1.0, 3.0, "Endereço", Colors.white, 15.0),
                                    onTap: (){
                                      setState(() {
                                        _searchCEP = false;
                                      });
                                    },
                                  ),
                                  //search by CEP button
                                  GestureDetector(
                                    child:_searchCEP == true ? WidgetsConstructor().makeButton(Colors.lightBlueAccent, Colors.white, widthPercent*0.40, 50.0, 1.0, 3.0, "CEP", Colors.white, 15.0)
                                        :WidgetsConstructor().makeButton(Colors.grey[10], Colors.white, widthPercent*0.40, 50.0, 1.0, 3.0, "CEP", Colors.white, 15.0),
                                    onTap: (){
                                      setState(() {
                                        _searchCEP = true;
                                      });
                                    },
                                  )

                                ],
                              ),
                              SizedBox(height: 10.0,),
                              SizedBox(height: 10.0,),
                              //first searchbox of origem address
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    height: heightPercent*0.08,
                                    width: widthPercent*0.6,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius:  BorderRadius.all(Radius.circular(4.0)),),
                                    child: TextField(controller: _sourceAdress,
                                      //enabled: _permissionGranted==true ? true : false,
                                      decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.home),
                                          labelText: "Origem",
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          contentPadding:
                                          EdgeInsets.only(left: 5, bottom: 5, top: 5, right: 5),
                                          hintText: "De onde?"),

                                    ) ,
                                  ),//search adress origem
                                  GestureDetector(
                                    onTap: (){

                                    },
                                    child: Container(
                                      child: Icon(Icons.search, color: Colors.white,),
                                      decoration: WidgetsConstructor().myBoxDecoration(Colors.blue, Colors.blue, 1.0, 5.0),
                                      width: widthPercent*0.15,
                                      height: heightPercent*0.08,
                                    ),
                                  ),
                                ],
                              ),
                              //Row with the number and complement of the origemAdress if provided by CEP
                              SizedBox(height: 10.0,),

                              //text informing user that address was found
                              _sourceAdress.text != "" ? WidgetsConstructor().makeText("Endereço localizado", Colors.blue, 15.0, 10.0, 5.0, "center") : Container(),
                              //address found
                              _sourceAdress.text != "" ? WidgetsConstructor().makeText(_sourceAdress.text+' CEP - 24070120', Colors.black, 12.0, 5.0, 10.0, "center") : Container(),
                              SizedBox(height: 20.0,),
                              //second searchbox of destiny address
                              _sourceAdress.text != "" ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    height: heightPercent*0.08,
                                    width: widthPercent*0.6,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius:  BorderRadius.all(Radius.circular(4.0)),),
                                    child: TextField(controller: _destinyAdress,
                                      //enabled: _permissionGranted==true ? true : false,
                                      decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.home),
                                          labelText: "Destino",
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          contentPadding:
                                          EdgeInsets.only(left: 5, bottom: 5, top: 5, right: 5),
                                          hintText: "Para onde?"),

                                    ) ,
                                  ),//search adress origem
                                  GestureDetector(
                                    onTap: (){

                                    },
                                    child: Container(
                                      child: Icon(Icons.search, color: Colors.white,),
                                      decoration: WidgetsConstructor().myBoxDecoration(Colors.blue, Colors.blue, 1.0, 5.0),
                                      width: widthPercent*0.15,
                                      height: heightPercent*0.08,
                                    ),
                                  ),
                                ],
                              ): Container(),
                              SizedBox(height: 10.0,),

                            ],
                          ),
                        )
                    ) ,

                    SizedBox(height: 30.0,),
                    //button to include address
                          GestureDetector(
                            child: WidgetsConstructor().makeButton(Colors.blue, Colors.blue, widthPercent*0.8, 50.0, 0.0, 4.0, "Incluir endereços", Colors.white, 20.0),
                            onTap: () async {

                            },
                          ),

                    ],
                  ),
                      ],
                    ),
                  );
  }

  Widget AnimationPage3(){
    return Container(
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(width: offset<1850 ? 1000 : 2200-offset > 0.0 ? 2200-offset: 0.0,),
                2200-offset>0.0 ? Container(
                  width: widthPercent*0.25,
                  height: 90.0,
                  child: Image.asset('images/home_caminhao.png', fit: BoxFit.fill,),
                ) : Container(),
                SizedBox(width: 10.0,),
                Column(
                  children: [
                    WidgetsConstructor().makeText('Encontre o melhor veículo', offset<2200? Colors.white: CustomColors.blue, 20.0, 0.0, 0.0, 'no'),
                    WidgetsConstructor().makeText('para você!', CustomColors.blue, offset<2260? 35.0 : 50.0, 0.0, 0.0, 'center'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 200.0,),
          offset> 2100 ? EntranceFader(
            offset: Offset(widthPercent /4,0),
            duration: Duration(seconds: 3),
            child: WidgetsConstructor().makeText('Ache a ', Colors.white, 25.0, 10.0, 0.0, 'center'),
          ): Container(),
          offset> 2130 ? EntranceFader(
            offset: Offset(widthPercent /4,0),
            duration: Duration(seconds: 3),
            child: WidgetsConstructor().makeText('    pessoa certa!', Colors.white, offset<2492 ? 25.0 : 40.0, 10.0, 0.0, 'center'),
          ) : Container(),
        ],
      ),

    );
  }
  
  Widget AnimationPage4(){
    
    return Container(
      height: 700.0,
      color: Colors.white,
      child: Column(
        children: [

          offset>3150
          ? WidgetsConstructor().makeText('Pague com cartão de crédito', CustomColors.blue, 20.0, 30.0, 25.0, 'center'): Container(),
          offset>3200
              ? EntranceFader(
            offset: Offset(widthPercent /4,0),
            duration: Duration(seconds: 3),
            child: Transform.rotate(angle: 6,
              child: Container(
                width: widthPercent*0.5,
                height: 150.0,
                //color: CustomColors.brown.withOpacity(20.0),
                child: Icon(Icons.credit_card, size: 100.0, color: CustomColors.blue,),
              ),
            ),
          ) : Container(),
          offset>3200
          ? EntranceFader(
            offset: Offset(widthPercent /4,0),
            duration: Duration(seconds: 3),
            child: Container(
                width: widthPercent*0.5,
                height: 150.0,
                //color: CustomColors.brown.withOpacity(20.0),
                child: Column(
                  children: [
                    WidgetsConstructor().makeText('Acompanhe pelo', CustomColors.brown, 20.0, 30.0, 0.0, 'center'),
                    WidgetsConstructor().makeText('telefone', CustomColors.brown, 20.0, 0.0, 0.0, 'center')
                  ],
                )
            ),
          ) : Container(),
          offset>3400
              ? EntranceFader(
            offset: Offset(widthPercent /4,0),
            duration: Duration(seconds: 3),
            child: Transform.rotate(angle: 6,
              child: Container(
                  width: widthPercent*0.5,
                  height: 110.0,
                  //color: CustomColors.brown.withOpacity(20.0),
                  //child: Icon(Icons.map, size: 100.0, color: CustomColors.blue,),
                  child: Image.asset('images/home_mapa.png'),
              ),
            ),
          ) : Container(),

          SizedBox(height: 60.0,),

          offset>3450 ? Container(
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],

            ),
            child: IconButton(icon: Icon(Icons.arrow_upward, color: CustomColors.yellow, size: 35.0,), onPressed: (){
              //final topOffset = _scrollController.position.maxScrollExtent;
              _scrollController.animateTo(
                0.0,
                duration: Duration(milliseconds: 2000),
                curve: Curves.easeInOut,
              );
            }),
          ) : Container(),

          offset>3050 ? WidgetsConstructor().makeText('Voltar ao início', CustomColors.blue, 16.0, 5.0, 10.0, 'center') : Container(),

        ],
      ),
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

  Future<void> _truckerInformedFinishedMove(UserModel userModel) async {

    //codigo para abrir a mudança
    setState(() {
      isLoading=true;
    });

    _displaySnackBar(context, 'Aguarde, carregando sistema de avaliação');

    Future<void> _onSucessLoadScheduledMoveInFb(UserModel userModel) async {

      moveClassGlobal = await MoveClass().getTheCoordinates(moveClassGlobal, moveClassGlobal.enderecoOrigem, moveClassGlobal.enderecoDestino).whenComplete(() {

        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => AvaliationPage(moveClassGlobal)));


        setState(() {
          isLoading=false;
        });

      });
    }

    //ta na hora da mudança. Abrir a pagina de mudança
    await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClassGlobal, userModel, (){ _onSucessLoadScheduledMoveInFb(userModel);});


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

  Future<void> _placeListenerInSituation(final String currentSituation, UserModel userModel, MoveClass moveClass){

    var situationRef = FirebaseFirestore.instance.collection(FirestoreServices .agendamentosPath).doc(moveClass.moveId);
    situationRef.snapshots().listen((DocumentSnapshot event) async {

      print('teste: currentSituation inicial é '+currentSituation);
      //se a situação mudar, chamar o método que lida com as situações
      if(event.data()['situacao'] !=  currentSituation){
        print('entrou no listener');
        print('nova situação é ${event.data()['situacao']}');
        moveClass.situacao = event.data()['situacao'];
        moveClassGlobal.situacao = moveClass.situacao;
        _handleSituation(userModel, moveClass);
      }
    });
  }

  Future<void> _ExistAmovegoinOnNow(UserModel userModel, MoveClass moveClass) async {

    _handleSituation(userModel, moveClass); //lida com o valor existente agora
    _placeListenerInSituation(moveClass.situacao, userModel, moveClass); //coloca um listener para ficar observando se mudou


  }



  void _handleSituation(UserModel userModel, MoveClass moveClass){

    moveClassGlobal.situacao = moveClass.situacao;
    DateTime scheduledDate = DateUtils().convertDateFromString(moveClass.dateSelected);
    DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, moveClass.timeSelected);
    final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

    if(moveClass.situacao == 'trucker_finished') {

      setState(() {
        popupCode='trucker_finished';
      });

    }

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

          WidgetsConstructor().makeText(MoveClass().returnResumeSituationToUser(popupCode), Colors.blue, 18.0, 20.0, 10.0, 'center'),


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

  Widget FakeAppBar(UserModel userModel){

    return Container(
      width: widthPercent,
      height: heightPercent*0.10,
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          /*
          IconButton(
            icon: Icon(Icons.menu, size: 45.0, color: Colors.white,),
            onPressed: () => _toggle(),),

           */
          IconButton(
            splashColor: Colors.lightBlueAccent,
            icon: AnimatedIcon(
                size: 45.0,
                color: Colors.blue,
                icon: AnimatedIcons.menu_arrow,
                progress: animationController),
            onPressed: () => _toggle(),),
          //WidgetsConstructor().makeSimpleText("Página principal", Colors.white, 15.0),
          IconButton(color: userModel.Alert == false ? Colors.grey[50] : Colors.red, icon: Icon(Icons.add_alert_outlined, color: userModel.Alert == false ? Colors.grey[50] : Colors.red,), onPressed: (){

            if(userModel.Alert==true){
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => MyMoves()));
            }

          },),
        ],
      ),
    );
  }

  Widget CustomMenu(){

    return ScopedModelDescendant<NewAuthService>(
      builder: (BuildContext context, Widget child, NewAuthService newAuthService){

        return ScopedModelDescendant<UserModel>(
          builder: (BuildContext context, Widget child, UserModel userModel){

            return Container(
              color: Colors.white,
              width: widthPercent,
              height: heightPercent,
              child: Column(
                children: [

                  Padding(padding: EdgeInsets.only(left: 25.0), child: Column(
                    children: [
                      WidgetsConstructor().makeText(MpGlobals.appNamePart1, CustomColors.blue, 35.0, 35.0, 0.0, 'no'),
                      WidgetsConstructor().makeText(MpGlobals.appNamePart2, CustomColors.blue, 50.0, 5.0, 5.0, 'no'),

                    ],
                  ),),

                  Container(
                    width: widthPercent*0.55,
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 10.0,),
                        userModel.FullName != null ? WidgetsConstructor().makeText(userModel.FullName, CustomColors.blue, 16.0, 10.0, 0.0, 'no') : WidgetsConstructor().makeText('Você não está logado', CustomColors.blue, 16.0, 10.0, 0.0, 'no'),
                      ],
                    ),
                  ),

                  Container(
                    width: widthPercent*0.55,
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 10.0,),
                        userModel.Email != null ? WidgetsConstructor().makeText(userModel.Email, CustomColors.blue, 14.0, 0.0, 10.0, 'no') : Container(),
                      ],
                    ),
                  ),


                  InkWell( //só exibir o botão de loggin se não estiver logado
                    onTap: (){ //click

                      Navigator.of(context).push(_createRoute(LoginChooseView()));

                      /*
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => LoginChooseView()));
                       */

                    },
                    child: Container(

                      child: _drawMenuLine(Icons.person, "Login", CustomColors.blue, context),
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

                      child: _drawMenuLine(Icons.airport_shuttle, "Quero me mudar", CustomColors.blue, context),
                    ),
                  ),

                  InkWell( //toque com animação
                    onTap: (){ //click


                      Navigator.of(context).pop();
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => MyMoves()));


                    },
                    child: Container(
                      child: _drawMenuLine(Icons.shopping_bag, "Minhas mudanças", CustomColors.blue, context),
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
                    child: userModel.Uid != "" ? Container(margin: EdgeInsets.only(left: 20.0), child:_drawMenuLine(Icons.exit_to_app, "Sair da conta", CustomColors.blue, context),) : Container(),

                  ),


                ],
              ),
            );
          },
        );

      },
    );
  }

  Widget _drawMenuLine(IconData icon, String text, Color color, BuildContext context){

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(5.0, 0.0, widthPercent*0.40, 0.0),
        child: Column(
          children: <Widget>[
            Container(
              //decoration: WidgetsConstructor().myBoxDecoration(Colors.blue, Colors.white70, 2.0, 4.0),
              color: Colors.transparent,
              height: 60.0,

              child: Row(
                children: <Widget>[

                  Icon(
                      icon, size: 32.0,
                      color : color
                  ),
                  SizedBox(width: 5.0,),
                  Text(
                    text, style: TextStyle(fontSize: 16.0,
                    color : color,

                  ),
                  ),
                ],
              ),
            ),
            Divider(),
          ],
        ),
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



/*  CLASSE PRONTA ANTES DE COLOCAR OS MATERIAIS DE TESTE DO NOVO UI
class HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage>, TickerProviderStateMixin {

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


  //TUDO DA ANIMIACAO DO DRAWER
  AnimationController animationController; //usado para fazer a tela diminuir e dar sensação do menu
  AnimationController _menuController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

  }


  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();

  }

  void _toggle() => animationController.isDismissed
      ? animationController.forward()
      : animationController.reverse();


  bool _canBeDragged=false;
  double minDragStartEdge=60.0;
  double maxDragStartEdge;

  final double maxSlide=225.0;


  void _onDragStart(DragStartDetails details){
    bool isDragOpenFromLeft = animationController.isDismissed && details.globalPosition.dx < minDragStartEdge;
    bool isDragcloseFromRight = animationController.isCompleted && details.globalPosition.dx > maxDragStartEdge;

    _canBeDragged = isDragOpenFromLeft || isDragcloseFromRight;
  }

  void _onDragUpdate(DragUpdateDetails details){
    if(_canBeDragged){
      double delta = details.primaryDelta / maxSlide;
      animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details){
    if(animationController.isDismissed || animationController.isCompleted){
      return;
    }
    if(details.velocity.pixelsPerSecond.dx.abs() >= 365.0){
      double visualVelocity = details.velocity.pixelsPerSecond.dx / MediaQuery.of(context).size.width;

      animationController.fling(velocity: visualVelocity);
    } else if(animationController.value < 0.5){
      //close();
      _toggle();
    } else {
      //open();
      _toggle();
    }

  }


  //FIM DE TUDO DA ANIMIACAO DO DRAWER

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

    maxDragStartEdge=maxSlide-16; //DRAWER

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        //isLoggedIn(userModel);

        userModelGLobal = userModel;


        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {

            _newAuthService = newAuthService;


            return Scaffold(
                key: _scaffoldKey,
                floatingActionButton: FloatingActionButton(backgroundColor: Colors.blue, child: Icon(Icons.add_circle, size: 50.0,), onPressed: (){print('click');},),
                body: GestureDetector(
                  onHorizontalDragStart: _onDragStart,
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,

                  onTap: _toggle,

                  child: AnimatedBuilder(
                    animation: animationController,
                    builder: (context, _) {

                      double menuSlide = (maxSlide+20.0) * animationController.value;
                      double menuScale = 1 + (animationController.value*0.7);
                      double slide = maxSlide * animationController.value;
                      double scale = 1 -(animationController.value*0.3);
                      return Stack(
                        children: [
                          CustomMenu(userModel), //isto é o fundo. O menu é um container azul que em uma parte tem o menu
                          Transform(transform: Matrix4.identity() //aqui é onde estão todos os elementos da tela
                            ..translate(slide)
                            ..scale(scale),
                            alignment: Alignment.centerLeft,
                            child: SafeArea(
                              child: Padding(
                                padding: EdgeInsets.only(top: heightPercent*0.10),
                                child: Stack(
                                  children: [

                                    Center(
                                      child: Container(
                                        color: Colors.white,
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
                                        ? WidgetsConstructor().customPopUp('Pedimos Desculpas', 'Infelizmente o profissional que você escolheu desistiu do serviço. Sabemos o quanto isso é chato e oferecemos as seguintes opções:', 'Escolher outro', 'Reaver dinheiro', widthPercent, heightPercent, () { _trucker_quitedAfterPayment_getNewTrucker();}, () { _trucker_quitedAfterPayment_cancel(userModel);})
                                        : popupCode=='trucker_finished'
                                        ? WidgetsConstructor().customPopUp('Mudança terminando', 'O profissional informou que a mudança terminou. Se o serviço realmente já terminou, confirme para avaliar.', 'Finalizar e avaliar', 'Ainda não terminou', widthPercent, heightPercent, () { _truckerInformedFinishedMove(userModel);}, () {_setPopuoCodeToDefault();})
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Transform(transform: Matrix4.identity() //aqui é o appbar fake q eu criei para simular a appbar original
                            ..translate(menuSlide)
                            ..scale(menuScale),
                            child: FakeAppBar(userModel),
                          ),


                        ],
                      );
                    },
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

  Future<void> _truckerInformedFinishedMove(UserModel userModel) async {

    //codigo para abrir a mudança
    setState(() {
      isLoading=true;
    });
    
    _displaySnackBar(context, 'Aguarde, carregando sistema de avaliação');

    Future<void> _onSucessLoadScheduledMoveInFb(UserModel userModel) async {

      moveClassGlobal = await MoveClass().getTheCoordinates(moveClassGlobal, moveClassGlobal.enderecoOrigem, moveClassGlobal.enderecoDestino).whenComplete(() {

        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => AvaliationPage(moveClassGlobal)));


        setState(() {
          isLoading=false;
        });

      });
    }

    //ta na hora da mudança. Abrir a pagina de mudança
    await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClassGlobal, userModel, (){ _onSucessLoadScheduledMoveInFb(userModel);});


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

  Future<void> _placeListenerInSituation(final String currentSituation, UserModel userModel, MoveClass moveClass){

    var situationRef = FirebaseFirestore.instance.collection(FirestoreServices .agendamentosPath).doc(moveClass.moveId);
    situationRef.snapshots().listen((DocumentSnapshot event) async {

      print('teste: currentSituation inicial é '+currentSituation);
      //se a situação mudar, chamar o método que lida com as situações
      if(event.data()['situacao'] !=  currentSituation){
          print('entrou no listener');
          print('nova situação é ${event.data()['situacao']}');
          moveClass.situacao = event.data()['situacao'];
          moveClassGlobal.situacao = moveClass.situacao;
        _handleSituation(userModel, moveClass);
      }
    });
  }

  Future<void> _ExistAmovegoinOnNow(UserModel userModel, MoveClass moveClass) async {

    _handleSituation(userModel, moveClass); //lida com o valor existente agora
    _placeListenerInSituation(moveClass.situacao, userModel, moveClass); //coloca um listener para ficar observando se mudou


  }



  void _handleSituation(UserModel userModel, MoveClass moveClass){

    moveClassGlobal.situacao = moveClass.situacao;
    DateTime scheduledDate = DateUtils().convertDateFromString(moveClass.dateSelected);
    DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, moveClass.timeSelected);
    final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

    if(moveClass.situacao == 'trucker_finished') {

      setState(() {
        popupCode='trucker_finished';
      });

    }

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

          WidgetsConstructor().makeText(MoveClass().returnResumeSituationToUser(popupCode), Colors.blue, 18.0, 20.0, 10.0, 'center'),


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


  Widget FakeAppBar(UserModel userModel){

    bool isPlaying = false;

    void _handleOnPressed(){
      setState(() {
        isPlaying = !isPlaying;
        isPlaying
            ? animationController.forward()
            : animationController.reverse();
      });

      _toggle();
    }

    return SafeArea(child: Container(
      width: widthPercent,
      height: heightPercent*0.10,
      color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          /*
          IconButton(
            icon: Icon(Icons.menu, size: 45.0, color: Colors.white,),
            onPressed: () => _toggle(),),

           */
          IconButton(
            splashColor: Colors.lightBlueAccent,
            icon: AnimatedIcon(
                size: 45.0,
                color: Colors.white,
                icon: AnimatedIcons.menu_arrow,
                progress: animationController),
            onPressed: () => _handleOnPressed(),),
          WidgetsConstructor().makeSimpleText("Página principal", Colors.white, 15.0),
          IconButton(color: userModel.Alert == false ? Colors.grey[50] : Colors.red, icon: Icon(Icons.add_alert_outlined, color: userModel.Alert == false ? Colors.grey[50] : Colors.red,), onPressed: (){

            if(userModel.Alert==true){
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => MyMoves()));
            }

          },),
        ],
      ),
    ),);
  }

  Widget CustomMenu(UserModel userModel){

    return ScopedModelDescendant<NewAuthService>(
      builder: (BuildContext context, Widget child, NewAuthService newAuthService){

        return Container(
          color: Colors.blue,
          width: widthPercent,
          height: heightPercent,
          child: Column(
            children: [

              Padding(padding: EdgeInsets.only(left: 25.0), child: Column(
                children: [
                  WidgetsConstructor().makeText(MpGlobals.appNamePart1, Colors.white, 35.0, 35.0, 0.0, 'no'),
                  WidgetsConstructor().makeText(MpGlobals.appNamePart2, Colors.white, 50.0, 5.0, 5.0, 'no'),
                ],
              ),),


              InkWell( //só exibir o botão de loggin se não estiver logado
                onTap: (){ //click

                  /*
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => LoginChooseView()));
                   */


                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => AnimationPlayPage()));


                },
                child: Container(

                  child: _drawMenuLine(Icons.person, "Login", Colors.white, context),
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

                  child: _drawMenuLine(Icons.airport_shuttle, "Quero me mudar", Colors.white, context),
                ),
              ),

              InkWell( //toque com animação
                onTap: (){ //click


                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => MyMoves()));


                },
                child: Container(
                  child: _drawMenuLine(Icons.shopping_bag, "Minhas mudanças", Colors.white, context),
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
                child: userModel.Uid != "" ? Container(margin: EdgeInsets.only(left: 20.0), child:_drawMenuLine(Icons.exit_to_app, "Sair da conta", Colors.white, context),) : Container(),

              ),


            ],
          ),
        );

      },
    );
  }

  Widget _drawMenuLine(IconData icon, String text, Color color, BuildContext context){

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(5.0, 0.0, widthPercent*0.40, 0.0),
        child: Column(
          children: <Widget>[
            Container(
              decoration: WidgetsConstructor().myBoxDecoration(Colors.blue, Colors.white70, 2.0, 4.0),
              height: 60.0,

              child: Row(
                children: <Widget>[

                  Icon(
                      icon, size: 32.0,
                      color : color
                  ),
                  SizedBox(width: 5.0,),
                  Text(
                    text, style: TextStyle(fontSize: 16.0,
                    color : color,

                  ),
                  ),
                ],
              ),
            ),
            Divider(),
          ],
        ),
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

 */


/* ESTA USA A ANIMACAO PRIMEIRO
class HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage>, SingleTickerProviderStateMixin {

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


  //TUDO DA ANIMIACAO DO DRAWER
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

  }


  @override
  void dispose() {
    animationController.dispose();
    super.dispose();

  }

  void _toggle() => animationController.isDismissed
      ? animationController.forward()
      : animationController.reverse();


  bool _canBeDragged=false;
  double minDragStartEdge=60.0;
  double maxDragStartEdge;

  final double maxSlide=225.0;


  void _onDragStart(DragStartDetails details){
    bool isDragOpenFromLeft = animationController.isDismissed && details.globalPosition.dx < minDragStartEdge;
    bool isDragcloseFromRight = animationController.isCompleted && details.globalPosition.dx > maxDragStartEdge;

    _canBeDragged = isDragOpenFromLeft || isDragcloseFromRight;
  }

  void _onDragUpdate(DragUpdateDetails details){
    if(_canBeDragged){
      double delta = details.primaryDelta / maxSlide;
      animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details){
    if(animationController.isDismissed || animationController.isCompleted){
      return;
    }
    if(details.velocity.pixelsPerSecond.dx.abs() >= 365.0){
      double visualVelocity = details.velocity.pixelsPerSecond.dx / MediaQuery.of(context).size.width;

      animationController.fling(velocity: visualVelocity);
    } else if(animationController.value < 0.5){
      //close();
      _toggle();
    } else {
      //open();
      _toggle();
    }

  }


  //FIM DE TUDO DA ANIMIACAO DO DRAWER

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

    maxDragStartEdge=maxSlide-16; //DRAWER

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        //isLoggedIn(userModel);

        userModelGLobal = userModel;


        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {

            _newAuthService = newAuthService;


            return Scaffold(
                key: _scaffoldKey,
                floatingActionButton: FloatingActionButton(backgroundColor: Colors.blue, child: Icon(Icons.add_circle, size: 50.0,), onPressed: (){print('click');},),
                body: GestureDetector(
                  onHorizontalDragStart: _onDragStart,
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,

                  onTap: _toggle,

                  child: AnimatedBuilder(
                    animation: animationController,
                    builder: (context, _) {

                      double menuSlide = (maxSlide+20.0) * animationController.value;
                      double menuScale = 1 + (animationController.value*0.7);
                      double slide = maxSlide * animationController.value;
                      double scale = 1 -(animationController.value*0.3);
                      return Stack(
                        children: [
                          CustomMenu(userModel), //isto é o fundo. O menu é um container azul que em uma parte tem o menu
                          Transform(transform: Matrix4.identity() //aqui é onde estão todos os elementos da tela
                            ..translate(slide)
                            ..scale(scale),
                            alignment: Alignment.centerLeft,
                            child: SafeArea(
                              child: Padding(
                                padding: EdgeInsets.only(top: heightPercent*0.10),
                                child: Stack(
                                  children: [

                                    Center(
                                      child: Container(
                                        color: Colors.white,
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
                              ),
                            ),
                          ),
                          Transform(transform: Matrix4.identity() //aqui é o appbar fake q eu criei para simular a appbar original
                          ..translate(menuSlide)
                          ..scale(menuScale),
                            child: FakeAppBar(userModel),
                          ),


                        ],
                      );
                    },
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


  Widget FakeAppBar(UserModel userModel){

    return SafeArea(child: Container(
      width: widthPercent,
      height: heightPercent*0.10,
      color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          IconButton(
            icon: Icon(Icons.menu, size: 45.0, color: Colors.white,),
            onPressed: () => _toggle(),),
          WidgetsConstructor().makeSimpleText("Página principal", Colors.white, 15.0),
          IconButton(color: userModel.Alert == false ? Colors.grey[50] : Colors.red, icon: Icon(Icons.add_alert_outlined, color: userModel.Alert == false ? Colors.grey[50] : Colors.red,), onPressed: (){

            if(userModel.Alert==true){
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => MyMoves()));
            }

          },),
        ],
      ),
    ),);
  }

  Widget CustomMenu(UserModel userModel){

    return ScopedModelDescendant<NewAuthService>(
      builder: (BuildContext context, Widget child, NewAuthService newAuthService){

        return Container(
          color: Colors.blue,
          width: widthPercent,
          height: heightPercent,
          child: Column(
            children: [

              Padding(padding: EdgeInsets.only(left: 25.0), child: Column(
                children: [
                  WidgetsConstructor().makeText(MpGlobals.appNamePart1, Colors.white, 35.0, 35.0, 0.0, 'no'),
                  WidgetsConstructor().makeText(MpGlobals.appNamePart2, Colors.white, 50.0, 5.0, 5.0, 'no'),
                ],
              ),),


              InkWell( //só exibir o botão de loggin se não estiver logado
                onTap: (){ //click

                  /*
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => LoginChooseView()));
                   */


                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => AnimationPlayPage()));


                },
                child: Container(

                  child: _drawMenuLine(Icons.person, "Login", Colors.white, context),
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

                  child: _drawMenuLine(Icons.airport_shuttle, "Quero me mudar", Colors.white, context),
                ),
              ),

              InkWell( //toque com animação
                onTap: (){ //click


                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => MyMoves()));


                },
                child: Container(
                  child: _drawMenuLine(Icons.shopping_bag, "Minhas mudanças", Colors.white, context),
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
                child: userModel.Uid != "" ? Container(margin: EdgeInsets.only(left: 20.0), child:_drawMenuLine(Icons.exit_to_app, "Sair da conta", Colors.white, context),) : Container(),

              ),


            ],
          ),
        );

      },
    );
  }

  Widget _drawMenuLine(IconData icon, String text, Color color, BuildContext context){

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(5.0, 0.0, widthPercent*0.40, 0.0),
        child: Column(
          children: <Widget>[
            Container(
              decoration: WidgetsConstructor().myBoxDecoration(Colors.blue, Colors.white70, 2.0, 4.0),
              height: 60.0,

              child: Row(
                children: <Widget>[

                  Icon(
                      icon, size: 32.0,
                      color : color
                  ),
                  SizedBox(width: 5.0,),
                  Text(
                    text, style: TextStyle(fontSize: 16.0,
                    color : color,

                  ),
                  ),
                ],
              ),
            ),
            Divider(),
          ],
        ),
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

 */


/* ESTA USA O MENU DRAWER COMUM SEM ANIMACAO
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

 */