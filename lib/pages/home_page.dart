

import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/classes/test_class.dart';
import 'package:fretego/drawer/menu_drawer.dart';
import 'package:fretego/login/pages/email_verify_view.dart';
import 'package:fretego/login/pages/login_choose_view.dart';
import 'package:fretego/login/pages/login_page.dart';
import 'package:fretego/login/services/new_auth_service.dart';
import 'package:fretego/models/home_page_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/animationPlay.dart';
import 'package:fretego/pages/avalatiation_page.dart';
import 'package:fretego/pages/code_search_page.dart';
import 'package:fretego/pages/home_page_internals/components/dark_background.dart';
import 'package:fretego/pages/home_page_internals/home_classic.dart';
import 'package:fretego/pages/home_page_internals/home_my_move.dart';
import 'package:fretego/pages/home_page_internals/widget_loading_screen.dart';
import 'package:fretego/pages/move_schedule_page.dart';
import 'package:fretego/pages/payment_page.dart';
import 'package:fretego/pages/move_day_page.dart';
import 'package:fretego/pages/my_moves.dart';
import 'package:fretego/pages/select_itens_page.dart';
import 'package:fretego/pages/user_informs_bank_data_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/anim_fader.dart';
import 'package:fretego/utils/anim_fader_left.dart';
import 'package:fretego/utils/clean_popup.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/date_utils.dart';
import 'package:fretego/utils/globals_strings.dart';
import 'package:fretego/utils/mp_globals.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:fretego/utils/popup.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {

  bool _userHasAlert=false;

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  MoveClass moveClassGlobal = MoveClass();

  double heightPercent;
  double widthPercent;

  bool _showDarkerBackground=false;

  String _popupCode='no';

  bool _menuIsVisible=false;

  bool _isLoading=false;

  bool _lockButton=false; //migrar

  //TUDO DA ANIMIACAO DO DRAWER
  AnimationController _animationController; //usado para fazer a tela diminuir e dar sensação do menu

  bool _showCleanPopup=true;

  bool _showPopupWaitingLoadingToAvaliation=false;

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
    _animationController?.dispose();
    super.dispose();

  }

  //metodos do menu
  void _toggle(){
    if(_animationController.isDismissed){
      _menuIsVisible=true;
      _animationController.forward();
    } else {
      _menuIsVisible=false;
      _animationController.reverse();
    }
  }

  //variaveis para o menu
  bool _canBeDragged=false;
  double minDragStartEdge=60.0;
  double maxDragStartEdge;
  final double maxSlide=225.0;
  //variaveis para o menu

  void _onDragStart(DragStartDetails details){
    bool isDragOpenFromLeft = _animationController.isDismissed && details.globalPosition.dx < minDragStartEdge;
    bool isDragcloseFromRight = _animationController.isCompleted && details.globalPosition.dx > maxDragStartEdge;

    _canBeDragged = isDragOpenFromLeft || isDragcloseFromRight;
    if(isDragOpenFromLeft){
      _menuIsVisible=true;
      _canBeDragged=false;
    } else {
      _menuIsVisible=false;
    }
  }

  void _onDragUpdate(DragUpdateDetails details){
    if(_canBeDragged){
      double delta = details.primaryDelta / maxSlide;
      _animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details){
    if(_animationController.isDismissed || _animationController.isCompleted){
      return;
    }
    if(details.velocity.pixelsPerSecond.dx.abs() >= 365.0){
      double visualVelocity = details.velocity.pixelsPerSecond.dx / MediaQuery.of(context).size.width;

      _animationController.fling(velocity: visualVelocity);
    } else if(_animationController.value < 0.5){
      //close();
      _toggle();
    } else {
      //open();
      _toggle();
    }

  }
  //fim dos metodos do menu


  //FIM DE TUDO DA ANIMIACAO DO DRAWER

  //INICIO ANIMACAO DA APRESENTACAO DO APP

  ScrollController _scrollController;  //migrar
  double offset = 1.0; //migrar para model

  //FIM DA ANIMACAO DA APRESENTAO DO APP

  //ANIMACAO DO BOTAO
  double _buttonPosition=0.0;
  //FIM DA ANIMACAO COM BOTAO

  @override
  Widget build(BuildContext context) {
    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;

    maxDragStartEdge=maxSlide-16; //DRAWER

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {

        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {


            return ScopedModelDescendant<HomePageModel>(
              builder: (BuildContext context, Widget child, HomePageModel homePageModel){

                if(homePageModel.FirstLoad==true){
                  homePageModel.updateFirstLoad(false);
                  _handleLogin(homePageModel, userModel, newAuthService);
                }

                if(homePageModel.ShouldForceVeriry==true){
                  checkEmailVerified(userModel, newAuthService, homePageModel);
                }



                //uncoment para criar uma nova mudança
                //TesteClass().criarNovaMudanca(userModel.Uid);


                return Scaffold(
                    key: _scaffoldKey,
                    body: GestureDetector(
                      onHorizontalDragStart: _onDragStart,
                      onHorizontalDragUpdate: _onDragUpdate,
                      onHorizontalDragEnd: _onDragEnd,

                      //onTap: _toggle,

                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, _) {

                          double menuSlide = (maxSlide+20.0) * _animationController.value;
                          double menuScale = 1 + (_animationController.value*0.7);
                          double slide = maxSlide * _animationController.value;
                          double scale = 1 -(_animationController.value*0.3);
                          return Stack(
                            children: [


                              if(_menuIsVisible==true) CustomMenu(homePageModel),

                              //exibe a homepage classica pois o user n tem mudança agendada
                              if(userModel.ThisUserHasAmove==false) Positioned(
                                  top: 0.0,
                                  child: Transform(transform: Matrix4.identity() //aqui é onde estão todos os elementos da tela
                                    ..translate(slide)
                                    ..scale(scale),
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: heightPercent*0.0),
                                      child: HomeClassic(heightPercent, widthPercent),
                                    ),
                                  )),

                              //barra appbar
                              Positioned(
                                top: 0.0,
                                left: 0.0,
                                right: 0.0,
                                child: Transform(transform: Matrix4.identity() //aqui é o appbar fake q eu criei para simular a appbar original
                                  ..translate(menuSlide)
                                  ..scale(menuScale),
                                    child: FakeAppBar(userModel: userModel),
                                ),
                              ),
                              //FakeAppBar(menuScale: menuScale, menuSlide: menuSlide, userModel: userModel),

                              //botao amarelo / yellow button
                              if(homePageModel.Offset<350.0 && _menuIsVisible==false || homePageModel.Offset>=3779.022848510742 && _menuIsVisible==false) _yellowButton(userModel, homePageModel),

                              //tela quando user tem mudanca
                              if(userModel.ThisUserHasAmove==true) Positioned(
                                  top: heightPercent*0.0,
                                  child: Transform(transform: Matrix4.identity() //aqui é onde estão todos os elementos da tela
                                    ..translate(slide)
                                    ..scale(scale),
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: heightPercent*0.10),
                                      child: HomeMyMoves(heightPercent, widthPercent),
                                    ),
                                  )),

                              if(_showDarkerBackground==true) DarkBackground(heightPercent: heightPercent, widthPercent: widthPercent,),

                              if(homePageModel.ShowLoadingInitials==true) WidgetLoadingScreeen('Espere só um instantinho', 'Carregando informações'),

                              if(_isLoading == true) Center(child: CircularProgressIndicator(),),

                              //popups que interagem com o usuário de acordo com a situação da mudança

                              //o profissional rejeitou o serviço e estamso informando ao user
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeTruckerDeny) CleanPopUp(heightPercent, widthPercent, false, true, 'Que pena', 'O profissional que você escolheu não aceitou o serviço. Mas você pode escolher outro.', 'Escolher', 'Aguardar', (){popupCloseCallBack(); }, () {Navigator.pop(context); Navigator.of(context).push(_createRoute(MoveSchedulePage(userModel.Uid, true, false)));}, () {popupCloseCallBack(); }),
                              //motorista informou que a mudança encerrou
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeTruckerFinished) CleanPopUp(heightPercent, widthPercent, false, true, 'Mudança terminando', '${homePageModel.moveClass.nomeFreteiro} informou que a mudança terminou. Se o serviço realmente já terminou, confirme para avaliar.', 'Avaliar', 'Aguardar', (){popupCloseCallBack(); }, () {_truckerInformedFinishedMove(userModel);}, () {popupCloseCallBack(); }),
                              //motorista desistiu depois do pagamento mas não finalizou a mudança. O user reclamou e vai pegar o extorno agora.
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeTruckerquitedAfterPayment) CleanPopUp(heightPercent, widthPercent, false, true, 'Pedimos Desculpas', 'Infelizmente o profissional que você escolheu desistiu do serviço. Oferecemos as seguintes opções:', 'Escolher outro', 'Reaver dinheiro', (){popupCloseCallBack(); }, () {Navigator.pop(context); Navigator.of(context).push(_createRoute(MoveSchedulePage(userModel.Uid, true, false)));}, () {_trucker_quitedAfterPayment_cancel(userModel); }),
                              //user relatou problrema como: Mudança nao feita ou finalizada pelo trucker sem ter concluido. A popup é informativa mas existe um método rolando por trás
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeSolvingProblems) CleanPopUp(heightPercent, widthPercent, true, true, 'Aguarde só um pouco', 'Ainda estamos buscando a solução do seu problema', 'Ok', '-', (){popupCloseCallBack(); }, () {popupCloseCallBack();}, () {popupCloseCallBack(); }),
                              //Usuário não pagou e já passou da hora da mudança
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeAccepptedLittleNegative) CleanPopUp(heightPercent, widthPercent, false, true, 'Atenção', 'Pagamento ainda não realizado. Como ${moveClassGlobal.nomeFreteiro} ainda não cancelou, você pode pagar e realizar a mudança.', 'Pagar', 'Aguardar', (){popupCloseCallBack(); }, () {_aceppted_little_lateCallback_Pagar(userModel);}, () {popupCloseCallBack(); }),
                              //Usuário não pagou e já passou muito da hora da mudança.
                              // Aqui apaga a mudança. O método corre juntamente com a popup que é apenas informativa
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeAccepptedMuchNegative) CleanPopUp(heightPercent, widthPercent, true, true, 'Atenção', 'Esta mudança foi cancelada pela falta de pagamento', 'Entendi', '-', (){popupCloseCallBack(); }, () {popupCloseCallBack();}, () {popupCloseCallBack(); }),
                              //Usuário não pagou e já está quase nahora. Ele tem opção de pagar
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeAcceptedAlmostTime) CleanPopUp(heightPercent, widthPercent, false, true, 'Chegando a hora', 'Você têm uma mudança agendada para às ${moveClassGlobal.timeSelected}. Efetue o pagamento para o profissional começar a se deslocar até o ponto combinado.', 'Pagar', 'Aguardar', (){popupCloseCallBack(); }, () {_callbackPopupBtnPay(userModel);}, () {popupCloseCallBack(); }),
                              //Usuário não pagou e já está quase nahora. Ele tem opção de pagar pois motorista ainda não desistiu
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeAcceptedTimeToMove) CleanPopUp(heightPercent, widthPercent, false, true, 'Atenção', 'Você tem uma mudança agendada para daqui a pouco que não foi paga. O profissional não começa a se deslocar enquanto não houver pagamento.', 'Pagar', 'Aguardar', (){popupCloseCallBack(); }, () {_acepted_almostTime(userModel);}, () {popupCloseCallBack(); }),
                              //Usuário já pagou e a mudança ja deve ter começado
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodepagoLittleNegative) CleanPopUp(heightPercent, widthPercent, false, true, 'Hora da mudança', "Você tem uma mudança que iniciou às "+moveClassGlobal.timeSelected+'.', 'Mudança', 'Aguardar', (){popupCloseCallBack(); }, () {_pago_little_lateCallback_IrParaMudanca(userModel);}, () {popupCloseCallBack(); }),
                              //Usuário já pagou e a mudança ja deve ter começado
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodepagoMuchNegative) CleanPopUp(heightPercent, widthPercent, false, true, 'Mudança em curso', "Você tem uma mudança que iniciou às "+moveClassGlobal.timeSelected+'.', 'Mudança', 'Aguardar', (){popupCloseCallBack(); }, () {_pago_little_lateCallback_IrParaMudanca(userModel);}, () {popupCloseCallBack(); }),
                              //Usuário já pagou e a mudança ja vai começar
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodepagoAlmostTime) CleanPopUp(heightPercent, widthPercent, false, true, 'Quase na hora', 'Você tem uma mudança que inicia às ${moveClassGlobal.timeSelected}.', 'Mudança', 'Aguardar', (){popupCloseCallBack(); }, () {_pago_almost_time(userModel);}, () {popupCloseCallBack(); }),
                              //Usuário já pagou e a mudança tá na hora
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodepagoTimeToMove) CleanPopUp(heightPercent, widthPercent, false, true, 'Quase na hora', 'Você tem uma mudança que inicia às ${moveClassGlobal.timeSelected}.', 'Mudança', 'Aguardar', (){popupCloseCallBack(); }, () {_pago_almost_time(userModel);}, () {popupCloseCallBack(); }),
                              //Mudança foi cancelada e está ifnormando o user. O motorista n aceitou e user tb n pagou. O sistema cancelou
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeSystemCanceled) CleanPopUp(heightPercent, widthPercent, false, true, 'Mudança cancelada', 'O pagamento não foi efetuado para a mudança que estava agendada. Nós cancelamos este serviço.', 'Ok', '-', (){popupCloseCallBack(); }, () {popupCloseCallBack(); }, () {popupCloseCallBack(); }),
                              //Mudança foi cancelada e está ifnormando o user. O motorista n aceitou e user tb n pagou
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeSystemCanceledExpired) CleanPopUp(heightPercent, widthPercent, false, true, 'Atenção', 'Você possuia uma mudança, no entanto o motorista não deu resposta. Por isto estamos cancelando.', 'Ok', '-', (){popupCloseCallBack(); }, () {popupCloseCallBack(); }, () {popupCloseCallBack(); }),
                              //Está chegando perto mas o trucker ainda n confirmou
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeSystemTruckerNotAnsweredButIsClose) CleanPopUp(heightPercent, widthPercent, false, true, 'Sem resposta', 'O profissional ainda não respondeu. Você pode continuar aguardando ou escolher outro.', 'Escolher', 'Aguardar', (){popupCloseCallBack(); }, () {Navigator.of(context).pop(); Navigator.push(context, MaterialPageRoute(builder: (context) => MoveSchedulePage(userModel.Uid, true, false))); }, () {popupCloseCallBack(); }),
                              //avisa o user que ele reagendou mas o motorista ainda n aceitou a troca
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.sitReschedule) CleanPopUp(heightPercent, widthPercent, true, true, 'Aguardando motorista', 'O profissional ainda não aceitou a mudança dos horários.', 'Entendi', '-', (){popupCloseCallBack(); }, () {popupCloseCallBack();}, () {popupCloseCallBack(); }),



                              //popup usada unicamente quando está carregando a avaliação
                              if(_showPopupWaitingLoadingToAvaliation==true) WidgetLoadingScreeen('Aguarde', 'Carregando sistema\nde avaliação'),

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
      },
    );
  }




  // ignore: non_constant_identifier_names
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
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

    _scrollController = ScrollController();

  }


  //NOVOS METODOS LOGIN
  Future<void> checkEmailVerified(UserModel userModel, NewAuthService newAuthService, HomePageModel homePageModel) async {

    homePageModel.updateShouldForceVerify(false);

    //load data in model
    await newAuthService.loadUser();

    await newAuthService.loadUserBasicDataInSharedPrefs(userModel);

    //carregar mais infos - at this time the name
    _loadMoreInfos(userModel);
    userModel.updateThisUserHasAmove(false); //seta como falso para iniciar processo

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

      _ifUserIsVerified(homePageModel, userModel, newAuthService);

      //_everyProcedureAfterUserHasInfosLoaded(userModel, homePageModel);


    } else{

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => EmailVerify()));

    }
  }

  void _everyProcedureAfterUserHasInfosLoaded(UserModel userModel, HomePageModel homePageModel){

    //verifica se tem alerta
    FirestoreServices().checkIfThereIsAlert(userModel.Uid, () { _AlertExists(userModel);});

    //verifica se tem uma mudança acontecendo agora
    checkIfExistMovegoingNow(userModel, homePageModel);


    //runTest(1); //teste adiciona novos motoristas
    //runTest(homePageModel: homePageModel, test: 2); //teste de popup: Motorista rejeitou
    //runTest(homePageModel: homePageModel, test: 3); //teste de popup: Mudança terminou
    //runTest(homePageModel: homePageModel, test: 4); //teste de popup: Motorista desistiu e devolve dinheiro ao user
    //runTest(homePageModel: homePageModel, test: 5); //teste de popup: Resolvendo um problema
    //runTest(homePageModel: homePageModel, test: 6);
    //runTest(homePageModel: homePageModel, test: 7);
    //_runTestAvalationPage(userModel: userModel);



  }

  Future<void> _loadMoreInfos(UserModel userModel) async {
    if(await SharedPrefsUtils().checkIfExistsMoreInfos()==true){
      String name = await SharedPrefsUtils().loadMoreInfoInSharedPrefs(); //update userModel with extra info (ps: At this time only the name)
      if(name!=null){
        userModel.updateFullName(name);
      }

    } else {

      void _onSucess(){
        SharedPrefsUtils().saveMoreInfos(userModel);
      }

      void _onFail(){
        //apenas para cumprir requisitos
      }

      FirestoreServices().getUserInfoFromCloudFirestore(userModel, () {_onSucess();}, () {_onFail();});
    }
  }

  void setupYellowButtonText(UserModel userModel, HomePageModel homePageModel){


    if(homePageModel.UserIsLoggedIn==true){
      homePageModel.updateBtnTxt(GlobalsStrings.buttonTxtComecarMudanca);
    } else {
      homePageModel.updateBtnTxt(GlobalsStrings.buttonTxtLogin);
    }

    /*
    if(homePageModel.UserIsLoggedIn==true){
      if(userModel.ThisUserHasAmove==false){
        homePageModel.updateBtnTxt('Começar mudança');
      } else if(_showPayBtn == true){
        homePageModel.updateBtnTxt('Pagar');
      } else if(userModel.ThisUserHasAmove==true){
        if(homePageModel.moveClass.situacao == GlobalsStrings.sitUserFinished){
          //se o user deu como finalizada mas o ticket ainda não encerrou significa que ta esperando o trucker. Neste caso, para o user ja acabou.
          homePageModel.updateBtnTxt('Login');
        } else {
          homePageModel.updateBtnTxt('Ver minha mudança');
        }

      } else {
        homePageModel.updateBtnTxt('');
      }

    } else {
      homePageModel.updateBtnTxt('Login');

    }


     */
  }

  void _AlertExists(UserModel userModel) {
    setState(() {
      userModel.updateAlert(true);
    });
  }

  Future<void> checkIfExistMovegoingNow(UserModel userModel, HomePageModel homePageModel) async {

    void _onFailure(){

      homePageModel.updateShowLoadingInitial(false);
    }

    await FirestoreServices().loadScheduledMoveSituationAndDateTime(moveClassGlobal, userModel, () { _ExistAmovegoinOnNow(userModel, moveClassGlobal, homePageModel);}, (){_onFailure();});

    /*
    bool shouldCheckMove = await SharedPrefsUtils().checkIfThereIsScheduledMove();
    if(shouldCheckMove==true){

      await FirestoreServices().loadScheduledMoveSituationAndDateTime(moveClass, userModel, () { _ExistAmovegoinOnNow(userModel, moveClass);});

    }

     */

  }

  Future<void> _placeListenerInSituation(final String currentSituation, UserModel userModel, MoveClass moveClass, HomePageModel homePageModel){

    var situationRef = FirebaseFirestore.instance.collection(FirestoreServices .agendamentosPath).doc(moveClass.moveId);
    situationRef.snapshots().listen((DocumentSnapshot event) async {

      //se a situação mudar, chamar o método que lida com as situações
      if(event.data()['situacao'] !=  currentSituation){
        moveClass.situacao = event.data()['situacao'];
        moveClassGlobal.situacao = moveClass.situacao;
        homePageModel.updateSituationInMoveClass(moveClassGlobal.situacao);
        _handleSituation(userModel, moveClass, homePageModel);
      }
    });
  }

  Future<void> _ExistAmovegoinOnNow(UserModel userModel, MoveClass moveClass, HomePageModel homePageModel) async {


    userModel.updateThisUserHasAmove(true);
    setupYellowButtonText(userModel, homePageModel); //atualiza o texto do botão

    _handleSituation(userModel, moveClass, homePageModel); //lida com o valor existente agora
    _placeListenerInSituation(moveClass.situacao, userModel, moveClass, homePageModel); //coloca um listener para ficar observando se mudou

    homePageModel.updateShowLoadingInitial(false);



  }

  void _handleSituation(UserModel userModel, MoveClass moveClass, HomePageModel homePageModel){

    //update ui para informar que tem mudança
    userModel.updateThisUserHasAmove(true);

    moveClassGlobal.situacao = moveClass.situacao;
    DateTime scheduledDate = DateServices().convertDateFromString(moveClass.dateSelected);
    DateTime scheduledDateAndTime = DateServices().addMinutesAndHoursFromStringToAdate(scheduledDate, moveClass.timeSelected);
    final dif = DateServices().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

    homePageModel.moveClass = moveClass; //atualiza para poder utilizar em home_my_move

    //abaixo: Se a situação for sitUserFinished (user finished the move) significz que o user ja finalizou o ticker mas o motorista ainda não. Então não vamos exibir pra ele.
    if(moveClass.situacao == GlobalsStrings.sitUserFinished){
      //significa que o user ja finalizou esta mudança e está apenas aguardando o motorista para fechar o ticket
      userModel.updateThisUserHasAmove(false);
    } else {

      //se chegar aqui o ticket está ativo

      if(moveClass.situacao == GlobalsStrings.sitAccepted && moveClass.pago==true){
        //significa que o usuário trocou de motorista por algum motivo mas a mudança ja estava paga. Vamos atualizar o campo então
        moveClass.situacao = GlobalsStrings.sitPago;
        FirestoreServices().updateMoveSituation(moveClass.situacao, moveClass.freteiroId, moveClass);
      }

      if(moveClass.situacao == GlobalsStrings.sitDeny){

        /*
        setState(() {
          _showDarkerBackground=true;
          MyBottomSheet().settingModalBottomSheet(context, 'Que pena', 'Vamos escolher outro profissional', 'O profissional que você escolheu não aceitou o serviço. Você pode escolher outro.',
              Icons.assignment_ind_outlined, heightPercent, widthPercent, 2, true,
              Icons.assignment_ind_outlined, 'Gerenciar minha mudança', () {Navigator.of(context).push(_createRoute(MyMoves())); Navigator.pop(context);_toogleDarkScreen();},
              Icons.schedule, 'Decidir depois', () {_aceppted_little_lateCallback_Depois();Navigator.pop(context);_toogleDarkScreen();}
          );
        });
         */
        setState(() {
          _showCleanPopup=true;
          _popupCode=GlobalsStrings.popupCodeTruckerDeny;
        });

      }

      if(moveClass.situacao == GlobalsStrings.sitTruckerFinished) {

        /*
        setState(() {
          //popupCode='trucker_finished';
          _showDarkerBackground=true;
          MyBottomSheet().settingModalBottomSheet(context, 'Terminando', 'Mudança terminando', 'O profissional informou que a mudança terminou. Se o serviço realmente já terminou, confirme para avaliar.',
              Icons.warning_amber_sharp, heightPercent, widthPercent, 2, false,
              Icons.star, 'Finalizar e avaliar', () {_truckerInformedFinishedMove(userModel); Navigator.pop(context);_toogleDarkScreen();},
              Icons.schedule, 'Ainda não terminou', () {_setPopuoCodeToDefault();Navigator.pop(context);_toogleDarkScreen();}
          );
        });
         */
        setState(() {
          _popupCode = GlobalsStrings.popupCodeTruckerFinished;
          _showCleanPopup=true;
        });


      }


      if(moveClass.situacao == GlobalsStrings.sitTruckerQuitAfterPayment){

        setState(() {
          _showCleanPopup=true;
          _popupCode = GlobalsStrings.popupCodeTruckerquitedAfterPayment;
        });
        /*
        setState(() {
          //popupCode='trucker_quited_after_payment';
          _showDarkerBackground=true;
          MyBottomSheet().settingModalBottomSheet(context, 'Desculpas', 'Pedimos Desculpas', 'Infelizmente o profissional que você escolheu desistiu do serviço. Sabemos o quanto isso é chato e oferecemos as seguintes opções',
              Icons.warning_amber_sharp, heightPercent, widthPercent, 2, false,
              Icons.account_box_rounded, 'Escolher outro profissional', () {_trucker_quitedAfterPayment_getNewTrucker(userModel.Uid); Navigator.pop(context);_toogleDarkScreen();},
              Icons.monetization_on_outlined, 'Reaver dinheiro', () {_trucker_quitedAfterPayment_cancel(userModel);;Navigator.pop(context);_toogleDarkScreen();}
          );
        });

         */

      } else if(moveClass.situacao == GlobalsStrings.sitUserInformTruckerDidntMakeMove || moveClass.situacao == GlobalsStrings.sitUserInformTruckerDidntFinishedMove){
        //user relatou problrema como: Mudança nao feita ou finalizada pelo trucker sem ter concluido
        //o método vai ser chamado e a popup será exibida só para informar o user
        _solvingProblems(userModel);
        setState(() {
          _showCleanPopup=true;
          _popupCode = GlobalsStrings.popupCodeSolvingProblems;
        });

      } else if(moveClass.situacao == GlobalsStrings.sitAccepted){

        if(dif.isNegative) {
          //a data já expirou

          if (dif > -300) {  //5 horas
            setState(() {
              _showCleanPopup=true;
              _popupCode=GlobalsStrings.popupCodeAccepptedLittleNegative;
            });
            /*
            setState(() {
              //popupCode = 'accepted_little_negative';
              _showDarkerBackground=true;
              MyBottomSheet().settingModalBottomSheet(context, 'Atenção', 'Pagamento ainda não realizado', 'Você ainda não pagou pela mudança. No entanto o profissional ainda não cancelou o serviço. Caso decida pagar, o trabalho ainda pode ocorrer.',
                  Icons.warning_amber_sharp, heightPercent, widthPercent, 2, true,
                  Icons.credit_card, 'Pagar', () {_aceppted_little_lateCallback_Pagar(userModel); Navigator.pop(context);_toogleDarkScreen();},
                  Icons.schedule, 'Decidir depois', () {_aceppted_little_lateCallback_Depois();Navigator.pop(context);_toogleDarkScreen();}
              );
            });

             */

            //neste caso o user fechou o app e abriu novamente

          } else {
            //a mudança já se encerrou há tempos
            setState(() {
              //popupCode = 'accepted_much_negative';
              _popupCode = GlobalsStrings.popupCodeAccepptedMuchNegative;
              _showCleanPopup=true;
              /*
              _showDarkerBackground=true;
              MyBottomSheet().settingModalBottomSheet(context, 'Atenção', 'Pagamento ainda não realizado', 'Você possuia uma mudança agendada às'+moveClassGlobal.timeSelected+' na data '+moveClassGlobal.dateSelected+', no entanto não efetuou pagamento. Esta mudança foi cancelada pela falta de pagamento.',
                  Icons.warning_amber_sharp, heightPercent, widthPercent, 2, false,
                  Icons.info, '   Ok', () {_aceppted_toMuch_lateCallback_Delete(); Navigator.pop(context);_toogleDarkScreen();},
                  null, '', () {Navigator.pop(context);_toogleDarkScreen();}
              );

               */
            });
            _aceppted_toMuch_lateCallback_Delete(userModel);
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
            _showCleanPopup=true;
            _popupCode=GlobalsStrings.popupCodeAcceptedAlmostTime;
          });

          /*
          setState(() {
            //_showPayPopUp=true;
            _showDarkerBackground=true;
            MyBottomSheet().settingModalBottomSheet(context, 'Mudança', 'Chegou a hora', 'Você têm uma mudança agendada para às '+moveClassGlobal.timeSelected+". Efetue o pagamento para o profissional começar a se deslocar até o ponto combinado.",
                Icons.schedule_outlined, heightPercent, widthPercent, 2, false,
                Icons.credit_card, 'Pagar', () {_callbackPopupBtnPay(userModel); Navigator.pop(context);_toogleDarkScreen();},
                Icons.schedule, 'Decidir depois', () {_callbackPopupBtnCancel();Navigator.pop(context);_toogleDarkScreen();}
            );
          });

           */

        } else if(dif<=15){

          setState(() {
            _showCleanPopup=true;
            _popupCode=GlobalsStrings.popupCodeAcceptedTimeToMove;
          });

          /*
          setState(() {
            //popupCode='accepted_timeToMove';
            _showDarkerBackground=true;
            MyBottomSheet().settingModalBottomSheet(context, 'Atenção', 'Pagamento não identificado', 'Você tem uma mudança agendada para daqui a pouco que não foi paga. O profissional não começa a se deslocar enquanto não houver pagamento.',
                Icons.warning_amber_sharp, heightPercent, widthPercent, 2, false,
                Icons.credit_card, 'Pagar', () {_acepted_almostTime(userModel); Navigator.pop(context);_toogleDarkScreen();},
                Icons.schedule, 'Decidir depois', () {_setPopuoCodeToDefault();Navigator.pop(context);_toogleDarkScreen();}
            );
          });

           */

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

      } else if(moveClass.situacao == GlobalsStrings.sitPago){

        if(dif.isNegative) {
          //a data já expirou

          if (dif > -300) {  //5 horas

            setState(() {
              _showCleanPopup=true;
              _popupCode = GlobalsStrings.popupCodepagoLittleNegative;
            });

            /*
            setState(() {
              //popupCode = 'pago_little_negative';
              //_showDarkerBackground=true;
              //libera o botão na proxima página
              homePageModel.updateShouldShowGoToMoveBtn(true);
              MyBottomSheet().settingModalBottomSheet(context, 'Mudança', 'Mudança acontecendo agora', "Você tem uma mudança que iniciou às "+moveClassGlobal.timeSelected+'.',
                  Icons.schedule_outlined, heightPercent, widthPercent, 2, true,
                  Icons.airport_shuttle, 'Ir para mudança', () {_pago_little_lateCallback_IrParaMudanca(userModel); Navigator.pop(context);},
                  Icons.schedule, 'Decidir depois', () {_setPopuoCodeToDefault();Navigator.pop(context);}
              );
            });
             */

            //neste caso o user fechou o app e abriu novamente

          } else {
            //a mudança já se encerrou há tempos
            setState(() {
              _showCleanPopup=true;
              _popupCode = GlobalsStrings.popupCodepagoMuchNegative;
            });

            /*
            setState(() {
              //popupCode = 'pago_much_negative';
              //_showDarkerBackground=true;
              homePageModel.updateShouldShowGoToMoveBtn(true);
              MyBottomSheet().settingModalBottomSheet(context, 'Mudança', 'Mudança em curso', "Você tem uma mudança que iniciou às "+moveClassGlobal.timeSelected+'.',
                  Icons.schedule_outlined, heightPercent, widthPercent, 2, true,
                  Icons.airport_shuttle, 'Ir para mudança', () {_pago_toMuch_lateCallback_Finalizar(userModel); Navigator.pop(context);},
                  Icons.schedule, 'Decidir depois', () {_setPopuoCodeToDefault();Navigator.pop(context);}
              );
            });
             */
          }

        } else if(dif<=150 && dif>15){

          setState(() {
            _showCleanPopup=true;
            _popupCode = GlobalsStrings.popupCodepagoAlmostTime;
          });

          homePageModel.updateShouldShowGoToMoveBtn(true);
          /*
          setState(() {
            //popupCode = 'pago_almost_time';
            MyBottomSheet().settingModalBottomSheet(context, 'Mudança', 'Quase na hora', "Você tem uma mudança que iniciou às "+moveClassGlobal.timeSelected+'.',
                Icons.schedule_outlined, heightPercent, widthPercent, 2, true,
                Icons.airport_shuttle, 'Ir para mudança', () {_pago_almost_time(userModel); Navigator.pop(context);},
                Icons.schedule, 'Decidir depois', () {_setPopuoCodeToDefault();Navigator.pop(context);}
            );
          });
           */


        } else if(dif<=15){

          setState(() {
            _showCleanPopup=true;
            _popupCode = GlobalsStrings.popupCodepagoTimeToMove;
          });

          /*
          setState(() {
            //popupCode='pago_timeToMove';
            homePageModel.updateShouldShowGoToMoveBtn(true);
            MyBottomSheet().settingModalBottomSheet(context, 'Mudança', 'Tá na hora', 'Você tem uma mudança agendada para agora.',
                Icons.schedule_outlined, heightPercent, widthPercent, 2, true,
                Icons.airport_shuttle, 'Ir para mudança', () {_pago_almost_time(userModel);; Navigator.pop(context);},
                Icons.schedule, 'Decidir depois', () {_setPopuoCodeToDefault();Navigator.pop(context);}
            );
          });
           */

        } else {

          //do nothing, falta mt ainda

        }


      } else if(moveClass.situacao == GlobalsStrings.sitQuit){

        setState(() {
          _showCleanPopup=true;
          _popupCode = GlobalsStrings.popupCodeSystemCanceled;
        });
        //significa que o sistema cancelou - agora vamso cancelar essa mudança
        _quit_systemQuitMove(userModel);

        /*
        setState(() {
          //popupCode='sistem_canceled';
          MyBottomSheet().settingModalBottomSheet(context, 'Mudança cancelada', 'Motivo: Falta de pagamento', 'Você não efetuou o pagamento para uma mudança que estava agendada. Nós cancelamos este serviço.',
            Icons.warning_amber_sharp, heightPercent, widthPercent, 0, true,
          );
        });
         */
      }

      //verifica se o prazo expirou
      if(moveClass.situacao == GlobalsStrings.sitAguardando){
        //verifique o prazo.
        //se ja expirou, cancelar o ticket.
        if(dif.isNegative){

          setState(() {
            _showCleanPopup=true;
            _popupCode = GlobalsStrings.popupCodeSystemCanceledExpired;
          });
          _quit_systemQuitMove(userModel);

          /*
          setState(() {
            _showDarkerBackground=true;
          });
          MyBottomSheet().settingModalBottomSheet(context, 'Atenção', 'O prazo desta mudança já expirou', 'Você possuia uma mudança agendada às'+moveClassGlobal.timeSelected+' na data '+moveClassGlobal.dateSelected+', no entanto o motorista não deu resposta. Por isto estamos cancelando. Você pode agendar novamente',
              Icons.warning_amber_sharp, heightPercent, widthPercent, 2, false,
              Icons.info, '   Ok', () {_quit_systemQuitMove(userModel); Navigator.pop(context);_toogleDarkScreen();},
              null, '', () {Navigator.pop(context);_toogleDarkScreen();}
          );

           */

        } else {
          //vamso ver se faltam dois dias para a mudança
          if(dif<2880){

            setState(() {
              _showCleanPopup=true;
              _popupCode = GlobalsStrings.popupCodeSystemTruckerNotAnsweredButIsClose;
            });

            /*
            setState(() {
              _showDarkerBackground=true;
              //erro aqui. Precisa mudar o link
              MyBottomSheet().settingModalBottomSheet(context, 'Sem resposta', 'O profissional ainda não respondeu.', 'Você pode continuar aguardando mas se preferir, pode escolher outro.',
                  Icons.assignment_ind_outlined, heightPercent, widthPercent, 2, true,
                  Icons.assignment_ind_outlined, 'Escolher outro', () {Navigator.of(context).pop(); Navigator.push(context, MaterialPageRoute(builder: (context) => MoveSchedulePage(userModel.Uid, true)));Navigator.pop(context);_toogleDarkScreen();},
                  Icons.schedule, 'Decidir depois', () {_aceppted_little_lateCallback_Depois();Navigator.pop(context);_toogleDarkScreen();}
              );
            });
             */

          }
        }


      }

      moveClassGlobal = moveClass; //used in showShortCutToMove


      //exibe o botao para pagar

    }


  }

  Future<void> _callbackPopupBtnPay(UserModel userModel) async {

    setState(() {
      _isLoading=true;
    });

    _displaySnackBar(context, 'Carregando informações, aguarde');
    await UserModel().getEmailFromFb();
    print(userModel.Email);
    moveClassGlobal = await FirestoreServices().loadScheduledMoveInFbReturnMoveClass(moveClassGlobal, userModel);

    setState(() {
      _isLoading=false;
    });

    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => PaymentPage(moveClassGlobal)));
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

          WidgetsConstructor().makeText(MoveClass().returnResumeSituationToUser(_popupCode), Colors.blue, 18.0, 20.0, 10.0, 'center'),


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

  Widget FakeAppBar({UserModel userModel}){


    return Container(
      width: widthPercent,
      height: heightPercent*0.14,
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          IconButton(
            splashColor: Colors.lightBlueAccent,
            icon: AnimatedIcon(
                size: 45.0,
                color: userModel.ThisUserHasAmove==true ? CustomColors.blue:
                _menuIsVisible==true ? CustomColors.blue : Colors.white,
                icon: AnimatedIcons.menu_close,
                progress: _animationController),
            onPressed: () => _toggle(),),
          //WidgetsConstructor().makeSimpleText("Página principal", Colors.white, 15.0),

          /*
          IconButton(color: userModel.Alert == false ? Colors.grey[50] : Colors.red, icon: Icon(Icons.add_alert_outlined, color: userModel.Alert == false ? Colors.grey[50] : Colors.red,), onPressed: (){

            if(userModel.Alert==true){
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => MyMoves()));
            }

          },),


           */
        ],
      ),
    );

  }

  Widget CustomMenu(HomePageModel homePageModel){

    return ScopedModelDescendant<NewAuthService>(
      builder: (BuildContext context, Widget child, NewAuthService newAuthService){

        return ScopedModelDescendant<UserModel>(
          builder: (BuildContext context, Widget child, UserModel userModel){

            return Container(
              alignment: Alignment.topLeft,
              color: Colors.white,
              width: widthPercent,
              height: heightPercent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Padding(padding: EdgeInsets.only(left: 25.0), child: Column(
                    children: [
                      WidgetsConstructor().makeText(MpGlobals.appNamePart1, CustomColors.blue, 35.0, 35.0, 0.0, 'no'),
                      WidgetsConstructor().makeText(MpGlobals.appNamePart2, CustomColors.blue, 50.0, 5.0, 5.0, 'no'),

                    ],
                  ),),

                  Container(
                    //width: widthPercent*0.55,
                    alignment: Alignment.centerLeft,
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 20.0,),
                        userModel.FullName != null ? WidgetsConstructor().makeText('Olá '+userModel.FullName, Colors.black, 16.0, 10.0, 0.0, 'no') : WidgetsConstructor().makeText('Você não está logado', Colors.black, 16.0, 10.0, 0.0, 'no'),
                      ],
                    ),
                  ),

                  SizedBox(height: heightPercent*0.05,),

                  //botão de login
                  homePageModel.UserIsLoggedIn == false ?
                  FlatButton(
                      onPressed: () {
                        //Navigator.of(context).push(_createRoute(LoginChooseView()));
                        Navigator.of(context).push(_createRoute(LoginPage()));
                      },
                      child: Container(

                        child: _drawMenuLine(Icons.person, "Login", CustomColors.blue, context),
                      )) : Container(),

                  //minhas mudanças obs: N existe mais
                  /*
                  FlatButton(
                      onPressed: (){
                        Navigator.of(context).push(_createRoute(MyMoves()));
                      },
                      child: Container(
                        child: _drawMenuLine(Icons.list, "Minhas\nmudanças", CustomColors.blue, context),
                      )
                  ),
                   */

                  //botão de logout
                  homePageModel.UserIsLoggedIn == true ?
                  FlatButton(
                    onPressed: (){
                      //Navigator.of(context).pop();
                      newAuthService.SignOut();
                      newAuthService.updateAuthStatus(false);
                      homePageModel.updateFirstLoad(true);
                      userModel.updateThisUserHasAmove(false);
                      userModel.updateFullName(null);
                      homePageModel.updateUserIsLoggedIn(false);
                      setupYellowButtonText(userModel, homePageModel);
                      _toggle();
                    },
                    child: userModel.Uid != "" ? _drawMenuLine(Icons.exit_to_app, "Sair", CustomColors.blue, context) : Container(),
                  ) : Container(),

                  if(homePageModel.UserIsLoggedIn == true) FlatButton(
                      onPressed: (){

                        Navigator.of(context).push(_createRoute(CodeSearchPage(uid: userModel.Uid, heightPercent: heightPercent, widthPercent: widthPercent,)));

                      },
                      child: userModel.Uid != "" ? _drawMenuLine(Icons.search, "Motoristas", CustomColors.blue, context) : Container(),
                    )



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

  Widget _yellowButton(UserModel userModel, HomePageModel homePageModel){

    return Positioned(
      right: userModel.ThisUserHasAmove==true ? 2000.0 : widthPercent*0.05, ///manda o botao para longe
      top: heightPercent*0.12,
      child: Column(
        children: [

          Container(
            alignment: Alignment.center,
            //width: userIsLoggedIn == true && _showMoveShortCutBtn==true ? widthPercent*0.40 : widthPercent*0.35,
            width: homePageModel.UserIsLoggedIn == true && userModel.ThisUserHasAmove==true ? widthPercent*0.40 : widthPercent*0.35,
            child: RaisedButton(
              splashColor: Colors.grey[200],
              elevation: 10.0,
              color: CustomColors.yellow,
              onPressed: (){

                if(_lockButton==false){
                  _lockButton=true;

                  homePageModel.setIsLoading(true);

                  if(homePageModel.BtnTxt == GlobalsStrings.buttonTxtComecarMudanca){
                    //Navigator.of(context).pushReplacement(_createRoute(SelectItensPage()));  //nao envia mais para cá. Envia para a página minhas mudanças que tem o mesmo resumo
                    Navigator.of(context).pushReplacement(_createRoute(MoveSchedulePage(userModel.Uid, false, false)));  //nao envia mais para cá. Envia para a página minhas mudanças que tem o mesmo resumo
                    _lockButton=false;
                  } else {
                    //login
                    //homePageModel.BtnTxt== GlobalsStrings.buttonTxtLogin
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => LoginPage()));
                    _lockButton=false;
                  }

                  /*
                                            if(homePageModel.BtnTxt== GlobalsStrings.buttonTxtLogin){
                                              //Navigator.of(context).push(_createRoute(LoginChooseView()));
                                              //Navigator.of(context).push(_createRoute(LoginPage()));
                                              Navigator.of(context).pop();
                                              Navigator.push(context, MaterialPageRoute(
                                                  builder: (context) => LoginPage()));
                                              lockButton=false;
                                            } else if(homePageModel.BtnTxt == GlobalsStrings.buttonTxtComecarMudanca){
                                              //Navigator.of(context).pushReplacement(_createRoute(SelectItensPage()));  //nao envia mais para cá. Envia para a página minhas mudanças que tem o mesmo resumo
                                              Navigator.of(context).pushReplacement(_createRoute(MoveSchedulePage(userModel.Uid, false)));  //nao envia mais para cá. Envia para a página minhas mudanças que tem o mesmo resumo
                                              lockButton=false;
                                            } else if(homePageModel.BtnTxt==GlobalsStrings.buttonTxtVerMudanca){
                                              _loadMoveClassAndOpenPage(MyMoves(), userModel);
                                              lockButton=false;
                                            } else if(homePageModel.BtnTxt==GlobalsStrings.buttonTxtPagar){
                                              _openPaymentPageFromCallBacks(userModel);
                                              lockButton=false;
                                            } else {
                                              _displaySnackBar(context, 'Ocorreu um erro');
                                              lockButton=false;
                                            }

                                             */



                } else {
                  //faça nada
                }


              },
              //child: WidgetsConstructor().makeText(userIsLoggedIn == true && _showMoveShortCutBtn==false ? 'Começar mudança' : _showPayBtn == true ? 'Pagar' : userIsLoggedIn == true && _showMoveShortCutBtn==true ? 'Ver minha mudança'  : 'Login', Colors.white, 18.0, 5.0, 5.0, 'center'),
              //child: WidgetsConstructor().makeText(userIsLoggedIn == true && userModel.ThisUserHasAmove==false ? 'Começar mudança' : _showPayBtn == true ? 'Pagar' : userIsLoggedIn == true && userModel.ThisUserHasAmove==true ? 'Ver minha mudança'  : 'Login', Colors.white, 18.0, 5.0, 5.0, 'center'),
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: WidgetsConstructor().makeText(homePageModel.BtnTxt, Colors.white, 18.0, 5.0, 5.0, 'center'),
              ),
            ),
          ),

        ],
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




  //vou consolidar aqui tds procedimentos de loggin, ler dados iniciais e check email verify

  //primeiro passo: Descobrir se o user está logged in ou logged out

  Future<void> _handleLogin(HomePageModel homePageModel, UserModel userModel, NewAuthService newAuthService) async {

    await checkFirebaseAuthConnection(homePageModel);  //verifica se o usuário está logado.

    if(homePageModel.UserIsLoggedIn==true){  //se estiver logado dará procedimento ao carregamento de dados do usuário. Se não, encerra e deixa a tela pronta pro loggin

      //se for usuario do facebook nao exibir tela de verificação de e-mail
      if(newAuthService.isFacebookUser()==true){
        //não precisa checar email
        _ifUserIsVerified(homePageModel, userModel, newAuthService);
      } else {
        checkEmailVerified(userModel, newAuthService, homePageModel); //aqui vai carregar dados do shared primeiro. Em seguida vai verificar o e-mail
      }

    } else {
      homePageModel.updateBtnTxt('Login');
    }

  }

  //procedimentos caso o user esteja autenticado pelo firebase, tanto com face ou email
  Future<void> _ifUserIsVerified(HomePageModel homePageModel, UserModel userModel, NewAuthService newAuthService) async {

    //load data in model
    await newAuthService.loadUser();

    await newAuthService.loadUserBasicDataInSharedPrefs(userModel);

    //carregar mais infos - at this time the name
    _loadMoreInfos(userModel);

    //homePageModel.updateShowLoadingInitial(true); //exibe a janela de carregando ambiente
    //checkEmailVerified(userModel, newAuthService, homePageModel); //aqui vai carregar dados do shared primeiro. Em seguida vai verificar o e-mail
    setupYellowButtonText(userModel, homePageModel);

    _everyProcedureAfterUserHasInfosLoaded(userModel, homePageModel);

  }

  void checkFirebaseAuthConnection(HomePageModel homePageModel) async {

    //SharedPrefsUtils().deletePageOneInfo();

    FirebaseAuth.instance
        .authStateChanges()
        .listen((User user) {
      if (user == null) {
        //userIsLoggedIn=false;
        homePageModel.updateUserIsLoggedIn(false);
      } else {
        homePageModel.updateUserIsLoggedIn(true);
        //mudei aqui
        /*
        setState(() {
          userIsLoggedIn=true;
          needCheck=true;

        });

         */

      }
    });
  }

  Future<bool> checkFirebaseAuthConnectionWithReturn() async {

    //SharedPrefsUtils().deletePageOneInfo();

    FirebaseAuth.instance
        .authStateChanges()
        .listen((User user) {
      if (user == null) {
        return false;
      } else {
        return true;
      }
    });
  }




  Future<void> _loadMoveClassAndOpenPage(Widget page, UserModel userModel) async {

    setState(() {
      _isLoading=true;
    });

    void _sucessfullLoad(){
      Navigator.of(context).push(_createRoute(page));
      setState(() {
        _isLoading=false;
      });

    }

    await UserModel().getEmailFromFb();
    print(userModel.Email);
    FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClassGlobal, userModel, () {_sucessfullLoad();});
    //moveClassGlobal = await FirestoreServices().loadScheduledMoveInFbReturnMoveClass(moveClassGlobal, userModel);


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

  void _aceppted_toMuch_lateCallback_Delete(UserModel userModel){
    //deletar do bd

    void _onSucess(){
      _displaySnackBar(context, 'A mudança foi cancelada');
      FirestoreServices().createTruckerAlertToInformMoveDeleted(moveClassGlobal, 'pagamento');
      _setPopuoCodeToDefault();
      userModel.updateThisUserHasAmove(false);
      moveClassGlobal = MoveClass();
      setState(() {
        //update
      });

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
      _isLoading=true;
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

  void _trucker_quitedAfterPayment_getNewTrucker(String uid){
    //escolher novo trucker
    //a gerencia de saber em qual página abrir vai ser feita na página. Neste ponto já está atualizado no bd
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => MoveSchedulePage(uid, true, false)));
  }

  //aqui foi o trucker que informou que n fez a mudança, n precisa verificar e pode cancelar direto.
  Future<void> _trucker_quitedAfterPayment_cancel(UserModel userModel) async {
    //aqui vai abrir uma pagina para informar dados bancários para ressarcir

    //codigo para abrir a mudança
    setState(() {
      _isLoading=true;
    });

    Future<void> _onSucessLoadScheduledMoveInFb(UserModel userModel) async {

      moveClassGlobal = await MoveClass().getTheCoordinates(moveClassGlobal, moveClassGlobal.enderecoOrigem, moveClassGlobal.enderecoDestino).whenComplete(() {

        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => UserInformsBankDataPage(moveClassGlobal, GlobalsStrings.motivoTruckerAbandon)));


        setState(() {
          _isLoading=false;
        });

      });
    }

    //ta na hora da mudança. Abrir a pagina de mudança
    await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClassGlobal, userModel, (){ _onSucessLoadScheduledMoveInFb(userModel);});


  }



  Future<void> _goToMovePage(UserModel userModel) async {
    //codigo para abrir a mudança
    setState(() {
      _isLoading=true;
    });

    Future<void> _onSucessLoadScheduledMoveInFb(UserModel userModel) async {

      moveClassGlobal = await MoveClass().getTheCoordinates(moveClassGlobal, moveClassGlobal.enderecoOrigem, moveClassGlobal.enderecoDestino).whenComplete(() {

        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => MoveDayPage(moveClassGlobal)));

        _isLoading=false;

      });
    }

    //ta na hora da mudança. Abrir a pagina de mudança
    await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClassGlobal, userModel, (){ _onSucessLoadScheduledMoveInFb(userModel);});

  }

  void _setPopuoCodeToDefault(){
    setState(() {
      _isLoading=false;
      _popupCode='no';
    });
  }

  Future<void> _solvingProblems(UserModel userModel) async {
    //esta função é para o caso do user relatar que o trucker encerrou ou nao apareceu na mudança e fechou o app. Então vai abrir
    //direto a pagina de mudança aguardando o trucker resonder
    /*
    MyBottomSheet().settingModalBottomSheet(context, 'Aguarde', 'Só mais um pouquinho', 'Ainda estamos buscando a solução do seu problema', Icons.warning_amber_sharp, heightPercent, widthPercent,
        0, true);
     */
    //_displaySnackBar(context, "Ainda estamos buscando a solução do seu problema, aguarde.");

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
      _isLoading=true;
      _showPopupWaitingLoadingToAvaliation=true;
    });


    //_displaySnackBar(context, 'Aguarde, carregando sistema de avaliação');



    //primeiro callback
    Future<void> _onSucessLoadScheduledMoveInFb(UserModel userModel) async {

      Future<void> _onSucessLoadAdditonalInfoInMoveClass(UserModel userModel) async{


        moveClassGlobal = await MoveClass().getTheCoordinates(moveClassGlobal, moveClassGlobal.enderecoOrigem, moveClassGlobal.enderecoDestino).whenComplete(() {

          print('imagem em moveclass testando');
          print(moveClassGlobal.freteiroImage);

          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => AvaliationPage(moveClassGlobal)));


          setState(() {
            _showPopupWaitingLoadingToAvaliation=false;
            _isLoading=false;
          });

        });

      }

      await FirestoreServices().loadAdditionalTruckerInfosToScheduledMoveInFbWithCallBack(moveClassGlobal, userModel, () { _onSucessLoadAdditonalInfoInMoveClass(userModel); });

    }



    //ta na hora da mudança. Abrir a pagina de mudança
    await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClassGlobal, userModel, (){ _onSucessLoadScheduledMoveInFb(userModel);});


  }

  void popupCloseCallBack(){
    setState(() {
      _showCleanPopup=false;
    });
  }

/*
  FIM DOS CALLBACKS DOS POPUPS
   */


  Future<void> runTest({int test, HomePageModel homePageModel}) async {

    //legenda
    /*
  1 = criar novos truckers para testar na lista (n tem latlong)
  2 = Teste de popup: Motorista rejeitou serviço e está ifnormando o user aqui o retorno
  3 = Teste de popup: Mudança terminou
  4 = Teste de popup: Motorista desistiu e vamos devolver dinheiro
  5 = Teste de popup: Resolvendo um problema
  6 = Teste de popup: Cliente não pagou e já passou um pouco da hora. MAs motorista ainda n desistiu
   */

    if(test==1){
      int _cont=0;
      while(_cont<5){
        TesteClass().criarNovoTrucker();
        _cont++;
      }
    } else if(test == 2){
      _showCleanPopup=true;
      setState(() {
        _popupCode = TesteClass().popupCodeTruckerRejeitouServico();
      });
    } else if(test == 3){
      _showCleanPopup=true;
      setState(() {
        _popupCode = TesteClass().popupCodeMudancaAcabou(homePageModel: homePageModel);
      });
    } else if(test == 4){
      _showCleanPopup=true;
      setState(() {
        _popupCode = TesteClass().popupCodeDevolverDinheiroPorDesistenciaMotorista(homePageModel: homePageModel);
      });
    } else if(test == 5){
      _showCleanPopup=true;
      setState(() {
        _popupCode = TesteClass().popupCodeSolvingProblems();
      });
    }else if(test == 6){
      _showCleanPopup=true;
      setState(() {
        _popupCode = TesteClass().popupCodeAcceptedLittleNegative(homePageModel: homePageModel);
      });
    }



  }

  Future<void> _runTestAvalationPage({UserModel userModel}) async {

    _truckerInformedFinishedMove(userModel);

  }

}





//backup antes de mudar o fundo
/*


import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/classes/test_class.dart';
import 'package:fretego/drawer/menu_drawer.dart';
import 'package:fretego/login/pages/email_verify_view.dart';
import 'package:fretego/login/pages/login_choose_view.dart';
import 'package:fretego/login/pages/login_page.dart';
import 'package:fretego/login/services/new_auth_service.dart';
import 'package:fretego/models/home_page_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/animationPlay.dart';
import 'package:fretego/pages/avalatiation_page.dart';
import 'package:fretego/pages/code_search_page.dart';
import 'package:fretego/pages/home_page_internals/components/dark_background.dart';
import 'package:fretego/pages/home_page_internals/home_classic.dart';
import 'package:fretego/pages/home_page_internals/home_my_move.dart';
import 'package:fretego/pages/home_page_internals/widget_loading_screen.dart';
import 'package:fretego/pages/move_schedule_page.dart';
import 'package:fretego/pages/payment_page.dart';
import 'package:fretego/pages/move_day_page.dart';
import 'package:fretego/pages/my_moves.dart';
import 'package:fretego/pages/select_itens_page.dart';
import 'package:fretego/pages/user_informs_bank_data_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/anim_fader.dart';
import 'package:fretego/utils/anim_fader_left.dart';
import 'package:fretego/utils/clean_popup.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/date_utils.dart';
import 'package:fretego/utils/globals_strings.dart';
import 'package:fretego/utils/mp_globals.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:fretego/utils/popup.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {

  bool _userHasAlert=false;

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  MoveClass moveClassGlobal = MoveClass();

  double heightPercent;
  double widthPercent;

  bool _showDarkerBackground=false;

  String _popupCode='no';

  bool _menuIsVisible=false;

  bool _isLoading=false;

  bool _lockButton=false; //migrar

  //TUDO DA ANIMIACAO DO DRAWER
  AnimationController _animationController; //usado para fazer a tela diminuir e dar sensação do menu

  bool _showCleanPopup=true;

  bool _showPopupWaitingLoadingToAvaliation=false;

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
    _animationController?.dispose();
    super.dispose();

  }

  //metodos do menu
  void _toggle(){
    if(_animationController.isDismissed){
      _menuIsVisible=true;
      _animationController.forward();
    } else {
      _menuIsVisible=false;
      _animationController.reverse();
    }
  }

  //variaveis para o menu
  bool _canBeDragged=false;
  double minDragStartEdge=60.0;
  double maxDragStartEdge;
  final double maxSlide=225.0;
  //variaveis para o menu

  void _onDragStart(DragStartDetails details){
    bool isDragOpenFromLeft = _animationController.isDismissed && details.globalPosition.dx < minDragStartEdge;
    bool isDragcloseFromRight = _animationController.isCompleted && details.globalPosition.dx > maxDragStartEdge;

    _canBeDragged = isDragOpenFromLeft || isDragcloseFromRight;
    if(isDragOpenFromLeft){
      _menuIsVisible=true;
      _canBeDragged=false;
    } else {
      _menuIsVisible=false;
    }
  }

  void _onDragUpdate(DragUpdateDetails details){
    if(_canBeDragged){
      double delta = details.primaryDelta / maxSlide;
      _animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details){
    if(_animationController.isDismissed || _animationController.isCompleted){
      return;
    }
    if(details.velocity.pixelsPerSecond.dx.abs() >= 365.0){
      double visualVelocity = details.velocity.pixelsPerSecond.dx / MediaQuery.of(context).size.width;

      _animationController.fling(velocity: visualVelocity);
    } else if(_animationController.value < 0.5){
      //close();
      _toggle();
    } else {
      //open();
      _toggle();
    }

  }
  //fim dos metodos do menu


  //FIM DE TUDO DA ANIMIACAO DO DRAWER

  //INICIO ANIMACAO DA APRESENTACAO DO APP

  ScrollController _scrollController;  //migrar
  double offset = 1.0; //migrar para model

  //FIM DA ANIMACAO DA APRESENTAO DO APP

  //ANIMACAO DO BOTAO
  double _buttonPosition=0.0;
  //FIM DA ANIMACAO COM BOTAO

  @override
  Widget build(BuildContext context) {
    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;

    maxDragStartEdge=maxSlide-16; //DRAWER

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {

        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {


            return ScopedModelDescendant<HomePageModel>(
              builder: (BuildContext context, Widget child, HomePageModel homePageModel){

                if(homePageModel.FirstLoad==true){
                  homePageModel.updateFirstLoad(false);
                  _handleLogin(homePageModel, userModel, newAuthService);
                }

                if(homePageModel.ShouldForceVeriry==true){
                  checkEmailVerified(userModel, newAuthService, homePageModel);
                }



                //uncoment para criar uma nova mudança
                //TesteClass().criarNovaMudanca(userModel.Uid);


                return Scaffold(
                    key: _scaffoldKey,
                    body: GestureDetector(
                      onHorizontalDragStart: _onDragStart,
                      onHorizontalDragUpdate: _onDragUpdate,
                      onHorizontalDragEnd: _onDragEnd,

                      //onTap: _toggle,

                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, _) {

                          double menuSlide = (maxSlide+20.0) * _animationController.value;
                          double menuScale = 1 + (_animationController.value*0.7);
                          double slide = maxSlide * _animationController.value;
                          double scale = 1 -(_animationController.value*0.3);
                          return Stack(
                            children: [


                              if(_menuIsVisible==true) CustomMenu(homePageModel),

                              //exibe a homepage classica pois o user n tem mudança agendada
                              if(userModel.ThisUserHasAmove==false) Positioned(
                                  top: heightPercent*0.0,
                                  child: Transform(transform: Matrix4.identity() //aqui é onde estão todos os elementos da tela
                                    ..translate(slide)
                                    ..scale(scale),
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: heightPercent*0.10),
                                      child: HomeClassic(heightPercent, widthPercent),
                                    ),
                                  )),

                              //barra appbar
                              Positioned(
                                top: 0.0,
                                left: 0.0,
                                right: 0.0,
                                child: Transform(transform: Matrix4.identity() //aqui é o appbar fake q eu criei para simular a appbar original
                                  ..translate(menuSlide)
                                  ..scale(menuScale),
                                    child: FakeAppBar(userModel: userModel),
                                ),
                              ),
                              //FakeAppBar(menuScale: menuScale, menuSlide: menuSlide, userModel: userModel),

                              //botao amarelo / yellow button
                              if(homePageModel.Offset<350.0 && _menuIsVisible==false || homePageModel.Offset>=3779.022848510742 && _menuIsVisible==false) _yellowButton(userModel, homePageModel),

                              //tela quando user tem mudanca
                              if(userModel.ThisUserHasAmove==true) Positioned(
                                  top: heightPercent*0.0,
                                  child: Transform(transform: Matrix4.identity() //aqui é onde estão todos os elementos da tela
                                    ..translate(slide)
                                    ..scale(scale),
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: heightPercent*0.10),
                                      child: HomeMyMoves(heightPercent, widthPercent),
                                    ),
                                  )),

                              if(_showDarkerBackground==true) DarkBackground(heightPercent: heightPercent, widthPercent: widthPercent,),

                              if(homePageModel.ShowLoadingInitials==true) WidgetLoadingScreeen('Espere só um instantinho', 'Carregando informações'),

                              if(_isLoading == true) Center(child: CircularProgressIndicator(),),

                              //popups que interagem com o usuário de acordo com a situação da mudança

                              //o profissional rejeitou o serviço e estamso informando ao user
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeTruckerDeny) CleanPopUp(heightPercent, widthPercent, false, true, 'Que pena', 'O profissional que você escolheu não aceitou o serviço. Mas você pode escolher outro.', 'Escolher', 'Aguardar', (){popupCloseCallBack(); }, () {Navigator.pop(context); Navigator.of(context).push(_createRoute(MoveSchedulePage(userModel.Uid, true, false)));}, () {popupCloseCallBack(); }),
                              //motorista informou que a mudança encerrou
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeTruckerFinished) CleanPopUp(heightPercent, widthPercent, false, true, 'Mudança terminando', '${homePageModel.moveClass.nomeFreteiro} informou que a mudança terminou. Se o serviço realmente já terminou, confirme para avaliar.', 'Avaliar', 'Aguardar', (){popupCloseCallBack(); }, () {_truckerInformedFinishedMove(userModel);}, () {popupCloseCallBack(); }),
                              //motorista desistiu depois do pagamento mas não finalizou a mudança. O user reclamou e vai pegar o extorno agora.
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeTruckerquitedAfterPayment) CleanPopUp(heightPercent, widthPercent, false, true, 'Pedimos Desculpas', 'Infelizmente o profissional que você escolheu desistiu do serviço. Oferecemos as seguintes opções:', 'Escolher outro', 'Reaver dinheiro', (){popupCloseCallBack(); }, () {Navigator.pop(context); Navigator.of(context).push(_createRoute(MoveSchedulePage(userModel.Uid, true, false)));}, () {_trucker_quitedAfterPayment_cancel(userModel); }),
                              //user relatou problrema como: Mudança nao feita ou finalizada pelo trucker sem ter concluido. A popup é informativa mas existe um método rolando por trás
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeSolvingProblems) CleanPopUp(heightPercent, widthPercent, true, true, 'Aguarde só um pouco', 'Ainda estamos buscando a solução do seu problema', 'Ok', '-', (){popupCloseCallBack(); }, () {popupCloseCallBack();}, () {popupCloseCallBack(); }),
                              //Usuário não pagou e já passou da hora da mudança
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeAccepptedLittleNegative) CleanPopUp(heightPercent, widthPercent, false, true, 'Atenção', 'Pagamento ainda não realizado. Como ${moveClassGlobal.nomeFreteiro} ainda não cancelou, você pode pagar e realizar a mudança.', 'Pagar', 'Aguardar', (){popupCloseCallBack(); }, () {_aceppted_little_lateCallback_Pagar(userModel);}, () {popupCloseCallBack(); }),
                              //Usuário não pagou e já passou muito da hora da mudança.
                              // Aqui apaga a mudança. O método corre juntamente com a popup que é apenas informativa
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeAccepptedMuchNegative) CleanPopUp(heightPercent, widthPercent, true, true, 'Atenção', 'Esta mudança foi cancelada pela falta de pagamento', 'Entendi', '-', (){popupCloseCallBack(); }, () {popupCloseCallBack();}, () {popupCloseCallBack(); }),
                              //Usuário não pagou e já está quase nahora. Ele tem opção de pagar
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeAcceptedAlmostTime) CleanPopUp(heightPercent, widthPercent, false, true, 'Chegando a hora', 'Você têm uma mudança agendada para às ${moveClassGlobal.timeSelected}. Efetue o pagamento para o profissional começar a se deslocar até o ponto combinado.', 'Pagar', 'Aguardar', (){popupCloseCallBack(); }, () {_callbackPopupBtnPay(userModel);}, () {popupCloseCallBack(); }),
                              //Usuário não pagou e já está quase nahora. Ele tem opção de pagar pois motorista ainda não desistiu
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeAcceptedTimeToMove) CleanPopUp(heightPercent, widthPercent, false, true, 'Atenção', 'Você tem uma mudança agendada para daqui a pouco que não foi paga. O profissional não começa a se deslocar enquanto não houver pagamento.', 'Pagar', 'Aguardar', (){popupCloseCallBack(); }, () {_acepted_almostTime(userModel);}, () {popupCloseCallBack(); }),
                              //Usuário já pagou e a mudança ja deve ter começado
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodepagoLittleNegative) CleanPopUp(heightPercent, widthPercent, false, true, 'Hora da mudança', "Você tem uma mudança que iniciou às "+moveClassGlobal.timeSelected+'.', 'Mudança', 'Aguardar', (){popupCloseCallBack(); }, () {_pago_little_lateCallback_IrParaMudanca(userModel);}, () {popupCloseCallBack(); }),
                              //Usuário já pagou e a mudança ja deve ter começado
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodepagoMuchNegative) CleanPopUp(heightPercent, widthPercent, false, true, 'Mudança em curso', "Você tem uma mudança que iniciou às "+moveClassGlobal.timeSelected+'.', 'Mudança', 'Aguardar', (){popupCloseCallBack(); }, () {_pago_little_lateCallback_IrParaMudanca(userModel);}, () {popupCloseCallBack(); }),
                              //Usuário já pagou e a mudança ja vai começar
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodepagoAlmostTime) CleanPopUp(heightPercent, widthPercent, false, true, 'Quase na hora', 'Você tem uma mudança que inicia às ${moveClassGlobal.timeSelected}.', 'Mudança', 'Aguardar', (){popupCloseCallBack(); }, () {_pago_almost_time(userModel);}, () {popupCloseCallBack(); }),
                              //Usuário já pagou e a mudança tá na hora
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodepagoTimeToMove) CleanPopUp(heightPercent, widthPercent, false, true, 'Quase na hora', 'Você tem uma mudança que inicia às ${moveClassGlobal.timeSelected}.', 'Mudança', 'Aguardar', (){popupCloseCallBack(); }, () {_pago_almost_time(userModel);}, () {popupCloseCallBack(); }),
                              //Mudança foi cancelada e está ifnormando o user. O motorista n aceitou e user tb n pagou. O sistema cancelou
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeSystemCanceled) CleanPopUp(heightPercent, widthPercent, false, true, 'Mudança cancelada', 'O pagamento não foi efetuado para a mudança que estava agendada. Nós cancelamos este serviço.', 'Ok', '-', (){popupCloseCallBack(); }, () {popupCloseCallBack(); }, () {popupCloseCallBack(); }),
                              //Mudança foi cancelada e está ifnormando o user. O motorista n aceitou e user tb n pagou
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeSystemCanceledExpired) CleanPopUp(heightPercent, widthPercent, false, true, 'Atenção', 'Você possuia uma mudança, no entanto o motorista não deu resposta. Por isto estamos cancelando.', 'Ok', '-', (){popupCloseCallBack(); }, () {popupCloseCallBack(); }, () {popupCloseCallBack(); }),
                              //Está chegando perto mas o trucker ainda n confirmou
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.popupCodeSystemTruckerNotAnsweredButIsClose) CleanPopUp(heightPercent, widthPercent, false, true, 'Sem resposta', 'O profissional ainda não respondeu. Você pode continuar aguardando ou escolher outro.', 'Escolher', 'Aguardar', (){popupCloseCallBack(); }, () {Navigator.of(context).pop(); Navigator.push(context, MaterialPageRoute(builder: (context) => MoveSchedulePage(userModel.Uid, true, false))); }, () {popupCloseCallBack(); }),
                              //avisa o user que ele reagendou mas o motorista ainda n aceitou a troca
                              if(_showCleanPopup==true && _popupCode == GlobalsStrings.sitReschedule) CleanPopUp(heightPercent, widthPercent, true, true, 'Aguardando motorista', 'O profissional ainda não aceitou a mudança dos horários.', 'Entendi', '-', (){popupCloseCallBack(); }, () {popupCloseCallBack();}, () {popupCloseCallBack(); }),



                              //popup usada unicamente quando está carregando a avaliação
                              if(_showPopupWaitingLoadingToAvaliation==true) WidgetLoadingScreeen('Aguarde', 'Carregando sistema\nde avaliação'),

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
      },
    );
  }




  // ignore: non_constant_identifier_names
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
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

    _scrollController = ScrollController();

  }


  //NOVOS METODOS LOGIN
  Future<void> checkEmailVerified(UserModel userModel, NewAuthService newAuthService, HomePageModel homePageModel) async {

    homePageModel.updateShouldForceVerify(false);

    //load data in model
    await newAuthService.loadUser();

    await newAuthService.loadUserBasicDataInSharedPrefs(userModel);

    //carregar mais infos - at this time the name
    _loadMoreInfos(userModel);
    userModel.updateThisUserHasAmove(false); //seta como falso para iniciar processo

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

      _ifUserIsVerified(homePageModel, userModel, newAuthService);

      //_everyProcedureAfterUserHasInfosLoaded(userModel, homePageModel);


    } else{

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => EmailVerify()));

    }
  }

  void _everyProcedureAfterUserHasInfosLoaded(UserModel userModel, HomePageModel homePageModel){

    //verifica se tem alerta
    FirestoreServices().checkIfThereIsAlert(userModel.Uid, () { _AlertExists(userModel);});

    //verifica se tem uma mudança acontecendo agora
    checkIfExistMovegoingNow(userModel, homePageModel);


    //runTest(1); //teste adiciona novos motoristas
    //runTest(homePageModel: homePageModel, test: 2); //teste de popup: Motorista rejeitou
    //runTest(homePageModel: homePageModel, test: 3); //teste de popup: Mudança terminou
    //runTest(homePageModel: homePageModel, test: 4); //teste de popup: Motorista desistiu e devolve dinheiro ao user
    //runTest(homePageModel: homePageModel, test: 5); //teste de popup: Resolvendo um problema
    //runTest(homePageModel: homePageModel, test: 6);
    //runTest(homePageModel: homePageModel, test: 7);
    //_runTestAvalationPage(userModel: userModel);



  }

  Future<void> _loadMoreInfos(UserModel userModel) async {
    if(await SharedPrefsUtils().checkIfExistsMoreInfos()==true){
      String name = await SharedPrefsUtils().loadMoreInfoInSharedPrefs(); //update userModel with extra info (ps: At this time only the name)
      if(name!=null){
        userModel.updateFullName(name);
      }

    } else {

      void _onSucess(){
        SharedPrefsUtils().saveMoreInfos(userModel);
      }

      void _onFail(){
        //apenas para cumprir requisitos
      }

      FirestoreServices().getUserInfoFromCloudFirestore(userModel, () {_onSucess();}, () {_onFail();});
    }
  }

  void setupYellowButtonText(UserModel userModel, HomePageModel homePageModel){


    if(homePageModel.UserIsLoggedIn==true){
      homePageModel.updateBtnTxt(GlobalsStrings.buttonTxtComecarMudanca);
    } else {
      homePageModel.updateBtnTxt(GlobalsStrings.buttonTxtLogin);
    }

    /*
    if(homePageModel.UserIsLoggedIn==true){
      if(userModel.ThisUserHasAmove==false){
        homePageModel.updateBtnTxt('Começar mudança');
      } else if(_showPayBtn == true){
        homePageModel.updateBtnTxt('Pagar');
      } else if(userModel.ThisUserHasAmove==true){
        if(homePageModel.moveClass.situacao == GlobalsStrings.sitUserFinished){
          //se o user deu como finalizada mas o ticket ainda não encerrou significa que ta esperando o trucker. Neste caso, para o user ja acabou.
          homePageModel.updateBtnTxt('Login');
        } else {
          homePageModel.updateBtnTxt('Ver minha mudança');
        }

      } else {
        homePageModel.updateBtnTxt('');
      }

    } else {
      homePageModel.updateBtnTxt('Login');

    }


     */
  }

  void _AlertExists(UserModel userModel) {
    setState(() {
      userModel.updateAlert(true);
    });
  }

  Future<void> checkIfExistMovegoingNow(UserModel userModel, HomePageModel homePageModel) async {

    void _onFailure(){

      homePageModel.updateShowLoadingInitial(false);
    }

    await FirestoreServices().loadScheduledMoveSituationAndDateTime(moveClassGlobal, userModel, () { _ExistAmovegoinOnNow(userModel, moveClassGlobal, homePageModel);}, (){_onFailure();});

    /*
    bool shouldCheckMove = await SharedPrefsUtils().checkIfThereIsScheduledMove();
    if(shouldCheckMove==true){

      await FirestoreServices().loadScheduledMoveSituationAndDateTime(moveClass, userModel, () { _ExistAmovegoinOnNow(userModel, moveClass);});

    }

     */

  }

  Future<void> _placeListenerInSituation(final String currentSituation, UserModel userModel, MoveClass moveClass, HomePageModel homePageModel){

    var situationRef = FirebaseFirestore.instance.collection(FirestoreServices .agendamentosPath).doc(moveClass.moveId);
    situationRef.snapshots().listen((DocumentSnapshot event) async {

      //se a situação mudar, chamar o método que lida com as situações
      if(event.data()['situacao'] !=  currentSituation){
        moveClass.situacao = event.data()['situacao'];
        moveClassGlobal.situacao = moveClass.situacao;
        homePageModel.updateSituationInMoveClass(moveClassGlobal.situacao);
        _handleSituation(userModel, moveClass, homePageModel);
      }
    });
  }

  Future<void> _ExistAmovegoinOnNow(UserModel userModel, MoveClass moveClass, HomePageModel homePageModel) async {


    userModel.updateThisUserHasAmove(true);
    setupYellowButtonText(userModel, homePageModel); //atualiza o texto do botão

    _handleSituation(userModel, moveClass, homePageModel); //lida com o valor existente agora
    _placeListenerInSituation(moveClass.situacao, userModel, moveClass, homePageModel); //coloca um listener para ficar observando se mudou

    homePageModel.updateShowLoadingInitial(false);



  }

  void _handleSituation(UserModel userModel, MoveClass moveClass, HomePageModel homePageModel){

    //update ui para informar que tem mudança
    userModel.updateThisUserHasAmove(true);

    moveClassGlobal.situacao = moveClass.situacao;
    DateTime scheduledDate = DateServices().convertDateFromString(moveClass.dateSelected);
    DateTime scheduledDateAndTime = DateServices().addMinutesAndHoursFromStringToAdate(scheduledDate, moveClass.timeSelected);
    final dif = DateServices().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

    homePageModel.moveClass = moveClass; //atualiza para poder utilizar em home_my_move

    //abaixo: Se a situação for sitUserFinished (user finished the move) significz que o user ja finalizou o ticker mas o motorista ainda não. Então não vamos exibir pra ele.
    if(moveClass.situacao == GlobalsStrings.sitUserFinished){
      //significa que o user ja finalizou esta mudança e está apenas aguardando o motorista para fechar o ticket
      userModel.updateThisUserHasAmove(false);
    } else {

      //se chegar aqui o ticket está ativo

      if(moveClass.situacao == GlobalsStrings.sitAccepted && moveClass.pago==true){
        //significa que o usuário trocou de motorista por algum motivo mas a mudança ja estava paga. Vamos atualizar o campo então
        moveClass.situacao = GlobalsStrings.sitPago;
        FirestoreServices().updateMoveSituation(moveClass.situacao, moveClass.freteiroId, moveClass);
      }

      if(moveClass.situacao == GlobalsStrings.sitDeny){

        /*
        setState(() {
          _showDarkerBackground=true;
          MyBottomSheet().settingModalBottomSheet(context, 'Que pena', 'Vamos escolher outro profissional', 'O profissional que você escolheu não aceitou o serviço. Você pode escolher outro.',
              Icons.assignment_ind_outlined, heightPercent, widthPercent, 2, true,
              Icons.assignment_ind_outlined, 'Gerenciar minha mudança', () {Navigator.of(context).push(_createRoute(MyMoves())); Navigator.pop(context);_toogleDarkScreen();},
              Icons.schedule, 'Decidir depois', () {_aceppted_little_lateCallback_Depois();Navigator.pop(context);_toogleDarkScreen();}
          );
        });
         */
        setState(() {
          _showCleanPopup=true;
          _popupCode=GlobalsStrings.popupCodeTruckerDeny;
        });

      }

      if(moveClass.situacao == GlobalsStrings.sitTruckerFinished) {

        /*
        setState(() {
          //popupCode='trucker_finished';
          _showDarkerBackground=true;
          MyBottomSheet().settingModalBottomSheet(context, 'Terminando', 'Mudança terminando', 'O profissional informou que a mudança terminou. Se o serviço realmente já terminou, confirme para avaliar.',
              Icons.warning_amber_sharp, heightPercent, widthPercent, 2, false,
              Icons.star, 'Finalizar e avaliar', () {_truckerInformedFinishedMove(userModel); Navigator.pop(context);_toogleDarkScreen();},
              Icons.schedule, 'Ainda não terminou', () {_setPopuoCodeToDefault();Navigator.pop(context);_toogleDarkScreen();}
          );
        });
         */
        setState(() {
          _popupCode = GlobalsStrings.popupCodeTruckerFinished;
          _showCleanPopup=true;
        });


      }


      if(moveClass.situacao == GlobalsStrings.sitTruckerQuitAfterPayment){

        setState(() {
          _showCleanPopup=true;
          _popupCode = GlobalsStrings.popupCodeTruckerquitedAfterPayment;
        });
        /*
        setState(() {
          //popupCode='trucker_quited_after_payment';
          _showDarkerBackground=true;
          MyBottomSheet().settingModalBottomSheet(context, 'Desculpas', 'Pedimos Desculpas', 'Infelizmente o profissional que você escolheu desistiu do serviço. Sabemos o quanto isso é chato e oferecemos as seguintes opções',
              Icons.warning_amber_sharp, heightPercent, widthPercent, 2, false,
              Icons.account_box_rounded, 'Escolher outro profissional', () {_trucker_quitedAfterPayment_getNewTrucker(userModel.Uid); Navigator.pop(context);_toogleDarkScreen();},
              Icons.monetization_on_outlined, 'Reaver dinheiro', () {_trucker_quitedAfterPayment_cancel(userModel);;Navigator.pop(context);_toogleDarkScreen();}
          );
        });

         */

      } else if(moveClass.situacao == GlobalsStrings.sitUserInformTruckerDidntMakeMove || moveClass.situacao == GlobalsStrings.sitUserInformTruckerDidntFinishedMove){
        //user relatou problrema como: Mudança nao feita ou finalizada pelo trucker sem ter concluido
        //o método vai ser chamado e a popup será exibida só para informar o user
        _solvingProblems(userModel);
        setState(() {
          _showCleanPopup=true;
          _popupCode = GlobalsStrings.popupCodeSolvingProblems;
        });

      } else if(moveClass.situacao == GlobalsStrings.sitAccepted){

        if(dif.isNegative) {
          //a data já expirou

          if (dif > -300) {  //5 horas
            setState(() {
              _showCleanPopup=true;
              _popupCode=GlobalsStrings.popupCodeAccepptedLittleNegative;
            });
            /*
            setState(() {
              //popupCode = 'accepted_little_negative';
              _showDarkerBackground=true;
              MyBottomSheet().settingModalBottomSheet(context, 'Atenção', 'Pagamento ainda não realizado', 'Você ainda não pagou pela mudança. No entanto o profissional ainda não cancelou o serviço. Caso decida pagar, o trabalho ainda pode ocorrer.',
                  Icons.warning_amber_sharp, heightPercent, widthPercent, 2, true,
                  Icons.credit_card, 'Pagar', () {_aceppted_little_lateCallback_Pagar(userModel); Navigator.pop(context);_toogleDarkScreen();},
                  Icons.schedule, 'Decidir depois', () {_aceppted_little_lateCallback_Depois();Navigator.pop(context);_toogleDarkScreen();}
              );
            });

             */

            //neste caso o user fechou o app e abriu novamente

          } else {
            //a mudança já se encerrou há tempos
            setState(() {
              //popupCode = 'accepted_much_negative';
              _popupCode = GlobalsStrings.popupCodeAccepptedMuchNegative;
              _showCleanPopup=true;
              /*
              _showDarkerBackground=true;
              MyBottomSheet().settingModalBottomSheet(context, 'Atenção', 'Pagamento ainda não realizado', 'Você possuia uma mudança agendada às'+moveClassGlobal.timeSelected+' na data '+moveClassGlobal.dateSelected+', no entanto não efetuou pagamento. Esta mudança foi cancelada pela falta de pagamento.',
                  Icons.warning_amber_sharp, heightPercent, widthPercent, 2, false,
                  Icons.info, '   Ok', () {_aceppted_toMuch_lateCallback_Delete(); Navigator.pop(context);_toogleDarkScreen();},
                  null, '', () {Navigator.pop(context);_toogleDarkScreen();}
              );

               */
            });
            _aceppted_toMuch_lateCallback_Delete(userModel);
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
            _showCleanPopup=true;
            _popupCode=GlobalsStrings.popupCodeAcceptedAlmostTime;
          });

          /*
          setState(() {
            //_showPayPopUp=true;
            _showDarkerBackground=true;
            MyBottomSheet().settingModalBottomSheet(context, 'Mudança', 'Chegou a hora', 'Você têm uma mudança agendada para às '+moveClassGlobal.timeSelected+". Efetue o pagamento para o profissional começar a se deslocar até o ponto combinado.",
                Icons.schedule_outlined, heightPercent, widthPercent, 2, false,
                Icons.credit_card, 'Pagar', () {_callbackPopupBtnPay(userModel); Navigator.pop(context);_toogleDarkScreen();},
                Icons.schedule, 'Decidir depois', () {_callbackPopupBtnCancel();Navigator.pop(context);_toogleDarkScreen();}
            );
          });

           */

        } else if(dif<=15){

          setState(() {
            _showCleanPopup=true;
            _popupCode=GlobalsStrings.popupCodeAcceptedTimeToMove;
          });

          /*
          setState(() {
            //popupCode='accepted_timeToMove';
            _showDarkerBackground=true;
            MyBottomSheet().settingModalBottomSheet(context, 'Atenção', 'Pagamento não identificado', 'Você tem uma mudança agendada para daqui a pouco que não foi paga. O profissional não começa a se deslocar enquanto não houver pagamento.',
                Icons.warning_amber_sharp, heightPercent, widthPercent, 2, false,
                Icons.credit_card, 'Pagar', () {_acepted_almostTime(userModel); Navigator.pop(context);_toogleDarkScreen();},
                Icons.schedule, 'Decidir depois', () {_setPopuoCodeToDefault();Navigator.pop(context);_toogleDarkScreen();}
            );
          });

           */

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

      } else if(moveClass.situacao == GlobalsStrings.sitPago){

        if(dif.isNegative) {
          //a data já expirou

          if (dif > -300) {  //5 horas

            setState(() {
              _showCleanPopup=true;
              _popupCode = GlobalsStrings.popupCodepagoLittleNegative;
            });

            /*
            setState(() {
              //popupCode = 'pago_little_negative';
              //_showDarkerBackground=true;
              //libera o botão na proxima página
              homePageModel.updateShouldShowGoToMoveBtn(true);
              MyBottomSheet().settingModalBottomSheet(context, 'Mudança', 'Mudança acontecendo agora', "Você tem uma mudança que iniciou às "+moveClassGlobal.timeSelected+'.',
                  Icons.schedule_outlined, heightPercent, widthPercent, 2, true,
                  Icons.airport_shuttle, 'Ir para mudança', () {_pago_little_lateCallback_IrParaMudanca(userModel); Navigator.pop(context);},
                  Icons.schedule, 'Decidir depois', () {_setPopuoCodeToDefault();Navigator.pop(context);}
              );
            });
             */

            //neste caso o user fechou o app e abriu novamente

          } else {
            //a mudança já se encerrou há tempos
            setState(() {
              _showCleanPopup=true;
              _popupCode = GlobalsStrings.popupCodepagoMuchNegative;
            });

            /*
            setState(() {
              //popupCode = 'pago_much_negative';
              //_showDarkerBackground=true;
              homePageModel.updateShouldShowGoToMoveBtn(true);
              MyBottomSheet().settingModalBottomSheet(context, 'Mudança', 'Mudança em curso', "Você tem uma mudança que iniciou às "+moveClassGlobal.timeSelected+'.',
                  Icons.schedule_outlined, heightPercent, widthPercent, 2, true,
                  Icons.airport_shuttle, 'Ir para mudança', () {_pago_toMuch_lateCallback_Finalizar(userModel); Navigator.pop(context);},
                  Icons.schedule, 'Decidir depois', () {_setPopuoCodeToDefault();Navigator.pop(context);}
              );
            });
             */
          }

        } else if(dif<=150 && dif>15){

          setState(() {
            _showCleanPopup=true;
            _popupCode = GlobalsStrings.popupCodepagoAlmostTime;
          });

          homePageModel.updateShouldShowGoToMoveBtn(true);
          /*
          setState(() {
            //popupCode = 'pago_almost_time';
            MyBottomSheet().settingModalBottomSheet(context, 'Mudança', 'Quase na hora', "Você tem uma mudança que iniciou às "+moveClassGlobal.timeSelected+'.',
                Icons.schedule_outlined, heightPercent, widthPercent, 2, true,
                Icons.airport_shuttle, 'Ir para mudança', () {_pago_almost_time(userModel); Navigator.pop(context);},
                Icons.schedule, 'Decidir depois', () {_setPopuoCodeToDefault();Navigator.pop(context);}
            );
          });
           */


        } else if(dif<=15){

          setState(() {
            _showCleanPopup=true;
            _popupCode = GlobalsStrings.popupCodepagoTimeToMove;
          });

          /*
          setState(() {
            //popupCode='pago_timeToMove';
            homePageModel.updateShouldShowGoToMoveBtn(true);
            MyBottomSheet().settingModalBottomSheet(context, 'Mudança', 'Tá na hora', 'Você tem uma mudança agendada para agora.',
                Icons.schedule_outlined, heightPercent, widthPercent, 2, true,
                Icons.airport_shuttle, 'Ir para mudança', () {_pago_almost_time(userModel);; Navigator.pop(context);},
                Icons.schedule, 'Decidir depois', () {_setPopuoCodeToDefault();Navigator.pop(context);}
            );
          });
           */

        } else {

          //do nothing, falta mt ainda

        }


      } else if(moveClass.situacao == GlobalsStrings.sitQuit){

        setState(() {
          _showCleanPopup=true;
          _popupCode = GlobalsStrings.popupCodeSystemCanceled;
        });
        //significa que o sistema cancelou - agora vamso cancelar essa mudança
        _quit_systemQuitMove(userModel);

        /*
        setState(() {
          //popupCode='sistem_canceled';
          MyBottomSheet().settingModalBottomSheet(context, 'Mudança cancelada', 'Motivo: Falta de pagamento', 'Você não efetuou o pagamento para uma mudança que estava agendada. Nós cancelamos este serviço.',
            Icons.warning_amber_sharp, heightPercent, widthPercent, 0, true,
          );
        });
         */
      }

      //verifica se o prazo expirou
      if(moveClass.situacao == GlobalsStrings.sitAguardando){
        //verifique o prazo.
        //se ja expirou, cancelar o ticket.
        if(dif.isNegative){

          setState(() {
            _showCleanPopup=true;
            _popupCode = GlobalsStrings.popupCodeSystemCanceledExpired;
          });
          _quit_systemQuitMove(userModel);

          /*
          setState(() {
            _showDarkerBackground=true;
          });
          MyBottomSheet().settingModalBottomSheet(context, 'Atenção', 'O prazo desta mudança já expirou', 'Você possuia uma mudança agendada às'+moveClassGlobal.timeSelected+' na data '+moveClassGlobal.dateSelected+', no entanto o motorista não deu resposta. Por isto estamos cancelando. Você pode agendar novamente',
              Icons.warning_amber_sharp, heightPercent, widthPercent, 2, false,
              Icons.info, '   Ok', () {_quit_systemQuitMove(userModel); Navigator.pop(context);_toogleDarkScreen();},
              null, '', () {Navigator.pop(context);_toogleDarkScreen();}
          );

           */

        } else {
          //vamso ver se faltam dois dias para a mudança
          if(dif<2880){

            setState(() {
              _showCleanPopup=true;
              _popupCode = GlobalsStrings.popupCodeSystemTruckerNotAnsweredButIsClose;
            });

            /*
            setState(() {
              _showDarkerBackground=true;
              //erro aqui. Precisa mudar o link
              MyBottomSheet().settingModalBottomSheet(context, 'Sem resposta', 'O profissional ainda não respondeu.', 'Você pode continuar aguardando mas se preferir, pode escolher outro.',
                  Icons.assignment_ind_outlined, heightPercent, widthPercent, 2, true,
                  Icons.assignment_ind_outlined, 'Escolher outro', () {Navigator.of(context).pop(); Navigator.push(context, MaterialPageRoute(builder: (context) => MoveSchedulePage(userModel.Uid, true)));Navigator.pop(context);_toogleDarkScreen();},
                  Icons.schedule, 'Decidir depois', () {_aceppted_little_lateCallback_Depois();Navigator.pop(context);_toogleDarkScreen();}
              );
            });
             */

          }
        }


      }

      moveClassGlobal = moveClass; //used in showShortCutToMove


      //exibe o botao para pagar

    }


  }

  Future<void> _callbackPopupBtnPay(UserModel userModel) async {

    setState(() {
      _isLoading=true;
    });

    _displaySnackBar(context, 'Carregando informações, aguarde');
    await UserModel().getEmailFromFb();
    print(userModel.Email);
    moveClassGlobal = await FirestoreServices().loadScheduledMoveInFbReturnMoveClass(moveClassGlobal, userModel);

    setState(() {
      _isLoading=false;
    });

    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => PaymentPage(moveClassGlobal)));
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

          WidgetsConstructor().makeText(MoveClass().returnResumeSituationToUser(_popupCode), Colors.blue, 18.0, 20.0, 10.0, 'center'),


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

  Widget FakeAppBar({UserModel userModel}){


    return Container(
      width: widthPercent,
      height: heightPercent*0.14,
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          IconButton(
            splashColor: Colors.lightBlueAccent,
            icon: AnimatedIcon(
                size: 45.0,
                color: Colors.blue,
                icon: AnimatedIcons.menu_arrow,
                progress: _animationController),
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

  Widget CustomMenu(HomePageModel homePageModel){

    return ScopedModelDescendant<NewAuthService>(
      builder: (BuildContext context, Widget child, NewAuthService newAuthService){

        return ScopedModelDescendant<UserModel>(
          builder: (BuildContext context, Widget child, UserModel userModel){

            return Container(
              alignment: Alignment.topLeft,
              color: Colors.white,
              width: widthPercent,
              height: heightPercent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Padding(padding: EdgeInsets.only(left: 25.0), child: Column(
                    children: [
                      WidgetsConstructor().makeText(MpGlobals.appNamePart1, CustomColors.blue, 35.0, 35.0, 0.0, 'no'),
                      WidgetsConstructor().makeText(MpGlobals.appNamePart2, CustomColors.blue, 50.0, 5.0, 5.0, 'no'),

                    ],
                  ),),

                  Container(
                    //width: widthPercent*0.55,
                    alignment: Alignment.centerLeft,
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 20.0,),
                        userModel.FullName != null ? WidgetsConstructor().makeText('Olá '+userModel.FullName, Colors.black, 16.0, 10.0, 0.0, 'no') : WidgetsConstructor().makeText('Você não está logado', Colors.black, 16.0, 10.0, 0.0, 'no'),
                      ],
                    ),
                  ),

                  SizedBox(height: heightPercent*0.05,),

                  //botão de login
                  homePageModel.UserIsLoggedIn == false ?
                  FlatButton(
                      onPressed: () {
                        //Navigator.of(context).push(_createRoute(LoginChooseView()));
                        Navigator.of(context).push(_createRoute(LoginPage()));
                      },
                      child: Container(

                        child: _drawMenuLine(Icons.person, "Login", CustomColors.blue, context),
                      )) : Container(),

                  //minhas mudanças obs: N existe mais
                  /*
                  FlatButton(
                      onPressed: (){
                        Navigator.of(context).push(_createRoute(MyMoves()));
                      },
                      child: Container(
                        child: _drawMenuLine(Icons.list, "Minhas\nmudanças", CustomColors.blue, context),
                      )
                  ),
                   */

                  //botão de logout
                  homePageModel.UserIsLoggedIn == true ?
                  FlatButton(
                    onPressed: (){
                      //Navigator.of(context).pop();
                      newAuthService.SignOut();
                      newAuthService.updateAuthStatus(false);
                      homePageModel.updateFirstLoad(true);
                      userModel.updateThisUserHasAmove(false);
                      userModel.updateFullName(null);
                      homePageModel.updateUserIsLoggedIn(false);
                      setupYellowButtonText(userModel, homePageModel);
                      _toggle();
                    },
                    child: userModel.Uid != "" ? _drawMenuLine(Icons.exit_to_app, "Sair", CustomColors.blue, context) : Container(),
                  ) : Container(),

                  if(homePageModel.UserIsLoggedIn == true) FlatButton(
                      onPressed: (){

                        Navigator.of(context).push(_createRoute(CodeSearchPage(uid: userModel.Uid, heightPercent: heightPercent, widthPercent: widthPercent,)));

                      },
                      child: userModel.Uid != "" ? _drawMenuLine(Icons.search, "Motoristas", CustomColors.blue, context) : Container(),
                    )



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

  Widget _yellowButton(UserModel userModel, HomePageModel homePageModel){

    return Positioned(
      right: userModel.ThisUserHasAmove==true ? 2000.0 : widthPercent*0.05, ///manda o botao para longe
      top: heightPercent*0.12,
      child: Column(
        children: [

          Container(
            alignment: Alignment.center,
            //width: userIsLoggedIn == true && _showMoveShortCutBtn==true ? widthPercent*0.40 : widthPercent*0.35,
            width: homePageModel.UserIsLoggedIn == true && userModel.ThisUserHasAmove==true ? widthPercent*0.40 : widthPercent*0.35,
            child: RaisedButton(
              splashColor: Colors.grey[200],
              elevation: 10.0,
              color: CustomColors.yellow,
              onPressed: (){

                if(_lockButton==false){
                  _lockButton=true;

                  homePageModel.setIsLoading(true);

                  if(homePageModel.BtnTxt == GlobalsStrings.buttonTxtComecarMudanca){
                    //Navigator.of(context).pushReplacement(_createRoute(SelectItensPage()));  //nao envia mais para cá. Envia para a página minhas mudanças que tem o mesmo resumo
                    Navigator.of(context).pushReplacement(_createRoute(MoveSchedulePage(userModel.Uid, false, false)));  //nao envia mais para cá. Envia para a página minhas mudanças que tem o mesmo resumo
                    _lockButton=false;
                  } else {
                    //login
                    //homePageModel.BtnTxt== GlobalsStrings.buttonTxtLogin
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => LoginPage()));
                    _lockButton=false;
                  }

                  /*
                                            if(homePageModel.BtnTxt== GlobalsStrings.buttonTxtLogin){
                                              //Navigator.of(context).push(_createRoute(LoginChooseView()));
                                              //Navigator.of(context).push(_createRoute(LoginPage()));
                                              Navigator.of(context).pop();
                                              Navigator.push(context, MaterialPageRoute(
                                                  builder: (context) => LoginPage()));
                                              lockButton=false;
                                            } else if(homePageModel.BtnTxt == GlobalsStrings.buttonTxtComecarMudanca){
                                              //Navigator.of(context).pushReplacement(_createRoute(SelectItensPage()));  //nao envia mais para cá. Envia para a página minhas mudanças que tem o mesmo resumo
                                              Navigator.of(context).pushReplacement(_createRoute(MoveSchedulePage(userModel.Uid, false)));  //nao envia mais para cá. Envia para a página minhas mudanças que tem o mesmo resumo
                                              lockButton=false;
                                            } else if(homePageModel.BtnTxt==GlobalsStrings.buttonTxtVerMudanca){
                                              _loadMoveClassAndOpenPage(MyMoves(), userModel);
                                              lockButton=false;
                                            } else if(homePageModel.BtnTxt==GlobalsStrings.buttonTxtPagar){
                                              _openPaymentPageFromCallBacks(userModel);
                                              lockButton=false;
                                            } else {
                                              _displaySnackBar(context, 'Ocorreu um erro');
                                              lockButton=false;
                                            }

                                             */



                } else {
                  //faça nada
                }


              },
              //child: WidgetsConstructor().makeText(userIsLoggedIn == true && _showMoveShortCutBtn==false ? 'Começar mudança' : _showPayBtn == true ? 'Pagar' : userIsLoggedIn == true && _showMoveShortCutBtn==true ? 'Ver minha mudança'  : 'Login', Colors.white, 18.0, 5.0, 5.0, 'center'),
              //child: WidgetsConstructor().makeText(userIsLoggedIn == true && userModel.ThisUserHasAmove==false ? 'Começar mudança' : _showPayBtn == true ? 'Pagar' : userIsLoggedIn == true && userModel.ThisUserHasAmove==true ? 'Ver minha mudança'  : 'Login', Colors.white, 18.0, 5.0, 5.0, 'center'),
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: WidgetsConstructor().makeText(homePageModel.BtnTxt, Colors.white, 18.0, 5.0, 5.0, 'center'),
              ),
            ),
          ),

        ],
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




  //vou consolidar aqui tds procedimentos de loggin, ler dados iniciais e check email verify

  //primeiro passo: Descobrir se o user está logged in ou logged out

  Future<void> _handleLogin(HomePageModel homePageModel, UserModel userModel, NewAuthService newAuthService) async {

    await checkFirebaseAuthConnection(homePageModel);  //verifica se o usuário está logado.

    if(homePageModel.UserIsLoggedIn==true){  //se estiver logado dará procedimento ao carregamento de dados do usuário. Se não, encerra e deixa a tela pronta pro loggin

      //se for usuario do facebook nao exibir tela de verificação de e-mail
      if(newAuthService.isFacebookUser()==true){
        //não precisa checar email
        _ifUserIsVerified(homePageModel, userModel, newAuthService);
      } else {
        checkEmailVerified(userModel, newAuthService, homePageModel); //aqui vai carregar dados do shared primeiro. Em seguida vai verificar o e-mail
      }

    } else {
      homePageModel.updateBtnTxt('Login');
    }

  }

  //procedimentos caso o user esteja autenticado pelo firebase, tanto com face ou email
  Future<void> _ifUserIsVerified(HomePageModel homePageModel, UserModel userModel, NewAuthService newAuthService) async {

    //load data in model
    await newAuthService.loadUser();

    await newAuthService.loadUserBasicDataInSharedPrefs(userModel);

    //carregar mais infos - at this time the name
    _loadMoreInfos(userModel);

    //homePageModel.updateShowLoadingInitial(true); //exibe a janela de carregando ambiente
    //checkEmailVerified(userModel, newAuthService, homePageModel); //aqui vai carregar dados do shared primeiro. Em seguida vai verificar o e-mail
    setupYellowButtonText(userModel, homePageModel);

    _everyProcedureAfterUserHasInfosLoaded(userModel, homePageModel);

  }

  void checkFirebaseAuthConnection(HomePageModel homePageModel) async {

    //SharedPrefsUtils().deletePageOneInfo();

    FirebaseAuth.instance
        .authStateChanges()
        .listen((User user) {
      if (user == null) {
        //userIsLoggedIn=false;
        homePageModel.updateUserIsLoggedIn(false);
      } else {
        homePageModel.updateUserIsLoggedIn(true);
        //mudei aqui
        /*
        setState(() {
          userIsLoggedIn=true;
          needCheck=true;

        });

         */

      }
    });
  }

  Future<bool> checkFirebaseAuthConnectionWithReturn() async {

    //SharedPrefsUtils().deletePageOneInfo();

    FirebaseAuth.instance
        .authStateChanges()
        .listen((User user) {
      if (user == null) {
        return false;
      } else {
        return true;
      }
    });
  }




  Future<void> _loadMoveClassAndOpenPage(Widget page, UserModel userModel) async {

    setState(() {
      _isLoading=true;
    });

    void _sucessfullLoad(){
      Navigator.of(context).push(_createRoute(page));
      setState(() {
        _isLoading=false;
      });

    }

    await UserModel().getEmailFromFb();
    print(userModel.Email);
    FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClassGlobal, userModel, () {_sucessfullLoad();});
    //moveClassGlobal = await FirestoreServices().loadScheduledMoveInFbReturnMoveClass(moveClassGlobal, userModel);


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

  void _aceppted_toMuch_lateCallback_Delete(UserModel userModel){
    //deletar do bd

    void _onSucess(){
      _displaySnackBar(context, 'A mudança foi cancelada');
      FirestoreServices().createTruckerAlertToInformMoveDeleted(moveClassGlobal, 'pagamento');
      _setPopuoCodeToDefault();
      userModel.updateThisUserHasAmove(false);
      moveClassGlobal = MoveClass();
      setState(() {
        //update
      });

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
      _isLoading=true;
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

  void _trucker_quitedAfterPayment_getNewTrucker(String uid){
    //escolher novo trucker
    //a gerencia de saber em qual página abrir vai ser feita na página. Neste ponto já está atualizado no bd
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => MoveSchedulePage(uid, true, false)));
  }

  //aqui foi o trucker que informou que n fez a mudança, n precisa verificar e pode cancelar direto.
  Future<void> _trucker_quitedAfterPayment_cancel(UserModel userModel) async {
    //aqui vai abrir uma pagina para informar dados bancários para ressarcir

    //codigo para abrir a mudança
    setState(() {
      _isLoading=true;
    });

    Future<void> _onSucessLoadScheduledMoveInFb(UserModel userModel) async {

      moveClassGlobal = await MoveClass().getTheCoordinates(moveClassGlobal, moveClassGlobal.enderecoOrigem, moveClassGlobal.enderecoDestino).whenComplete(() {

        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => UserInformsBankDataPage(moveClassGlobal, GlobalsStrings.motivoTruckerAbandon)));


        setState(() {
          _isLoading=false;
        });

      });
    }

    //ta na hora da mudança. Abrir a pagina de mudança
    await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClassGlobal, userModel, (){ _onSucessLoadScheduledMoveInFb(userModel);});


  }



  Future<void> _goToMovePage(UserModel userModel) async {
    //codigo para abrir a mudança
    setState(() {
      _isLoading=true;
    });

    Future<void> _onSucessLoadScheduledMoveInFb(UserModel userModel) async {

      moveClassGlobal = await MoveClass().getTheCoordinates(moveClassGlobal, moveClassGlobal.enderecoOrigem, moveClassGlobal.enderecoDestino).whenComplete(() {

        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => MoveDayPage(moveClassGlobal)));

        _isLoading=false;

      });
    }

    //ta na hora da mudança. Abrir a pagina de mudança
    await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClassGlobal, userModel, (){ _onSucessLoadScheduledMoveInFb(userModel);});

  }

  void _setPopuoCodeToDefault(){
    setState(() {
      _isLoading=false;
      _popupCode='no';
    });
  }

  Future<void> _solvingProblems(UserModel userModel) async {
    //esta função é para o caso do user relatar que o trucker encerrou ou nao apareceu na mudança e fechou o app. Então vai abrir
    //direto a pagina de mudança aguardando o trucker resonder
    /*
    MyBottomSheet().settingModalBottomSheet(context, 'Aguarde', 'Só mais um pouquinho', 'Ainda estamos buscando a solução do seu problema', Icons.warning_amber_sharp, heightPercent, widthPercent,
        0, true);
     */
    //_displaySnackBar(context, "Ainda estamos buscando a solução do seu problema, aguarde.");

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
      _isLoading=true;
      _showPopupWaitingLoadingToAvaliation=true;
    });


    //_displaySnackBar(context, 'Aguarde, carregando sistema de avaliação');



    //primeiro callback
    Future<void> _onSucessLoadScheduledMoveInFb(UserModel userModel) async {

      Future<void> _onSucessLoadAdditonalInfoInMoveClass(UserModel userModel) async{


        moveClassGlobal = await MoveClass().getTheCoordinates(moveClassGlobal, moveClassGlobal.enderecoOrigem, moveClassGlobal.enderecoDestino).whenComplete(() {

          print('imagem em moveclass testando');
          print(moveClassGlobal.freteiroImage);

          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => AvaliationPage(moveClassGlobal)));


          setState(() {
            _showPopupWaitingLoadingToAvaliation=false;
            _isLoading=false;
          });

        });

      }

      await FirestoreServices().loadAdditionalTruckerInfosToScheduledMoveInFbWithCallBack(moveClassGlobal, userModel, () { _onSucessLoadAdditonalInfoInMoveClass(userModel); });

    }



    //ta na hora da mudança. Abrir a pagina de mudança
    await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClassGlobal, userModel, (){ _onSucessLoadScheduledMoveInFb(userModel);});


  }

  void popupCloseCallBack(){
    setState(() {
      _showCleanPopup=false;
    });
  }

/*
  FIM DOS CALLBACKS DOS POPUPS
   */


  Future<void> runTest({int test, HomePageModel homePageModel}) async {

    //legenda
    /*
  1 = criar novos truckers para testar na lista (n tem latlong)
  2 = Teste de popup: Motorista rejeitou serviço e está ifnormando o user aqui o retorno
  3 = Teste de popup: Mudança terminou
  4 = Teste de popup: Motorista desistiu e vamos devolver dinheiro
  5 = Teste de popup: Resolvendo um problema
  6 = Teste de popup: Cliente não pagou e já passou um pouco da hora. MAs motorista ainda n desistiu
   */

    if(test==1){
      int _cont=0;
      while(_cont<5){
        TesteClass().criarNovoTrucker();
        _cont++;
      }
    } else if(test == 2){
      _showCleanPopup=true;
      setState(() {
        _popupCode = TesteClass().popupCodeTruckerRejeitouServico();
      });
    } else if(test == 3){
      _showCleanPopup=true;
      setState(() {
        _popupCode = TesteClass().popupCodeMudancaAcabou(homePageModel: homePageModel);
      });
    } else if(test == 4){
      _showCleanPopup=true;
      setState(() {
        _popupCode = TesteClass().popupCodeDevolverDinheiroPorDesistenciaMotorista(homePageModel: homePageModel);
      });
    } else if(test == 5){
      _showCleanPopup=true;
      setState(() {
        _popupCode = TesteClass().popupCodeSolvingProblems();
      });
    }else if(test == 6){
      _showCleanPopup=true;
      setState(() {
        _popupCode = TesteClass().popupCodeAcceptedLittleNegative(homePageModel: homePageModel);
      });
    }



  }

  Future<void> _runTestAvalationPage({UserModel userModel}) async {

    _truckerInformedFinishedMove(userModel);

  }

}
 */
