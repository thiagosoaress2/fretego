import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:fretego/models/home_page_model.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/pages/move_schadule_internals_page/my_list_of_itens_page.dart';
import 'package:fretego/pages/move_schadule_internals_page/page1_select_itens.dart';
import 'package:fretego/pages/move_schadule_internals_page/page2_obs.dart';
import 'package:fretego/pages/move_schadule_internals_page/page3_truck.dart';
import 'package:fretego/pages/move_schadule_internals_page/page4_enderecos.dart';
import 'package:fretego/pages/move_schadule_internals_page/page5_trucker.dart';
import 'package:fretego/pages/move_schadule_internals_page/page6_data.dart';
import 'package:fretego/pages/move_schadule_internals_page/page_final.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/globals_strings.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

class MoveSchedulePage extends StatefulWidget{
  String userId;
  MoveSchedulePage(this.userId);


  @override
  _MoveSchedulePageState createState() => _MoveSchedulePageState();
}

class _MoveSchedulePageState extends State<MoveSchedulePage>{

  ScrollController _TopAnimcrollController;

  double heightPercent;
  double widthPercent;

  bool _showTip = true;


  @override
  void initState() {
    Future.delayed(Duration(seconds: 2)).then((value) {
      setState(() {
        _showTip = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return ScopedModel<MoveModel>(
      model: MoveModel(),
      child: ScopedModelDescendant<MoveModel>(
        builder: (BuildContext context, Widget child, MoveModel moveModel) {
          if (heightPercent == null) {
            heightPercent = MediaQuery
                .of(context)
                .size
                .height;
            widthPercent = MediaQuery
                .of(context)
                .size
                .width;
            moveModel.updateAppBarText('Início', 'Itens grandes');
          }

          if (moveModel.NeedFirstLoad == true) {
            moveModel.updateNeedFirstLoad(false);

            _checkIfTheUserIsChangingTheTrucker(moveModel);
          }


          return ScopedModelDescendant<HomePageModel>(
            builder: (BuildContext context, Widget child,
                HomePageModel homePageModel) {
              return Scaffold(
                body: Container(
                  color: Colors.white,
                  width: widthPercent,
                  height: heightPercent,
                  child: Stack(
                    children: [

                      moveModel.ActualPage == 'itens' ? Page1SelectItens(
                          heightPercent, widthPercent, widget.userId)
                          : moveModel.ActualPage == 'obs' ? Page2Obs(
                          heightPercent, widthPercent, widget.userId)
                          : moveModel.ActualPage == 'truck' ? Page3Truck(
                          heightPercent, widthPercent, widget.userId)
                          : moveModel.ActualPage == 'end' ? Page4Enderecos()
                          : moveModel.ActualPage == 'trucker' ? Page5Trucker(
                          heightPercent, widthPercent, widget.userId)
                          : moveModel.ActualPage == 'data' ? Page6Data(
                          heightPercent, widthPercent, widget.userId)
                          : moveModel.ActualPage == 'final' ? PageFinal(
                          heightPercent, widthPercent, widget.userId)
                          : Container(),


                      //animação
                      Positioned(
                          top: heightPercent * 0.12,
                          width: widthPercent,
                          child: _itensPageAnim(moveModel)),

                      //appbar
                      Positioned(
                        top: heightPercent * 0.05,
                        left: 0.0,
                        right: 0.0,
                        child: customFakeAppBar(moveModel, context),),


                      //float action button
                      //situacoes onde o botão nao deve aparecer pois tem um floting btn igual dentro da página
                      moveModel.ActualPage != 'itens' && moveModel.ActualPage !=
                          'end' && moveModel.ActualPage != 'trucker' &&
                          moveModel.ActualPage != 'data' &&
                          moveModel.ActualPage != 'final' ?
                      Positioned(
                          bottom: 15.0,
                          right: 10.0,
                          child: FloatingActionButton(
                            onPressed: () {
                              if (moveModel.ActualPage == 'itens') {
                                print(moveModel.itemsSelectedCart.length);
                                print('tamanho do chart');
                                if (moveModel.itemsSelectedCart.length == 0 ||
                                    moveModel.itemsSelectedCart.length ==
                                        null) {
                                  MyBottomSheet().settingModalBottomSheet(
                                      context,
                                      'Ops...',
                                      'Lista vazia',
                                      'Nenhum item escolhido para a mudança.',
                                      Icons.info,
                                      heightPercent,
                                      widthPercent,
                                      0,
                                      true);
                                } else {
                                  moveModel.changePageForward(
                                      'obs', 'Itens', 'Observações');
                                }
                              } else if (moveModel.ActualPage == 'obs') {
                                //_topAnimScroll(moveModel, widthPercent);
                                SharedPrefsUtils().savePsInShared(
                                    moveModel.moveClass.ps);
                                moveModel.changePageForward(
                                    'truck', 'Obs', 'Veículo');
                              } else if (moveModel.ActualPage == 'truck') {
                                if (moveModel.carInMoveClass != null) {
                                  moveModel.changePageForward(
                                      'end', 'Veículo', "Endereço");
                                } else {
                                  MyBottomSheet().settingModalBottomSheet(
                                      context,
                                      'Ops...',
                                      'Sem veículo selecioando',
                                      'Nenhum veículo escolhido ainda.',
                                      Icons.info,
                                      heightPercent,
                                      widthPercent,
                                      0,
                                      true);
                                }
                              } else if (moveModel.ActualPage == 'end') {
                                moveModel.changePageForward(
                                    'hora', 'Endereço', 'Horários');
                              } else if (moveModel.ActualPage == 'data') {
                                print('implementar');
                              }
                            },
                            backgroundColor: CustomColors.yellow,
                            splashColor: Colors.yellow,
                            child: Icon(
                              Icons.keyboard_arrow_right, color: Colors.white,
                              size: 50.0,),
                          )
                      ) : SizedBox(),


                      moveModel.ShowListAnywhere == true ? MyListOfItensPage(
                          heightPercent, widthPercent) : SizedBox(),


                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _itensPageAnim(MoveModel moveModel) {
    _TopAnimcrollController = ScrollController();

    //para animação da tela
    _TopAnimcrollController.addListener(() {
      moveModel.updateOffset(_TopAnimcrollController.hasClients
          ? _TopAnimcrollController.offset
          : 0.1);
    });

    return Container(
      width: widthPercent,
      height: heightPercent,
      child: Stack(
        children: [

          //fundo
          Positioned(
              top: heightPercent * 0.10,
              left: 0.1,
              right: 0.1,
              child: Container(
                width: widthPercent,
                height: heightPercent * 0.08,
                decoration: new BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 3,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
              )
          ),

          //lista
          Positioned(
            top: heightPercent * 0.08,
            left: widthPercent * 0.05,
            right: 10.0,
            child: Container(
              height: heightPercent * 0.10,
              width: widthPercent,
              child: ListView(
                controller: _TopAnimcrollController,
                physics: moveModel.CanScroll == false
                    ? NeverScrollableScrollPhysics()
                    : AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,

                children: [


                  moveModel.ActualPage != 'final' ? SizedBox(
                    width: widthPercent * 0.02,) : SizedBox(),
                  moveModel.ActualPage != 'final' ? Column(
                    children: [
                      Container(
                        child: Icon(Icons.assignment, color: Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          // You can use like this way or like the below line
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent * 0.10,
                        height: heightPercent * 0.07,
                      ),
                      WidgetsConstructor().makeText(
                          'Itens', Colors.grey, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ) : SizedBox(),

                  moveModel.ActualPage != 'final' ? SizedBox(
                    width: widthPercent * 0.09,) : SizedBox(),
                  moveModel.ActualPage != 'final' ? Column(
                    children: [
                      Container(
                        child: Icon(Icons.airport_shuttle, color: moveModel
                            .ActualPage == 'itens' || moveModel.ActualPage ==
                            'obs' ? Colors.blue : Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          // You can use like this way or like the below line
                          color: moveModel.ActualPage == 'itens' || moveModel
                              .ActualPage == 'obs' ? Colors.white : Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent * 0.10,
                        height: heightPercent * 0.07,
                      ),
                      WidgetsConstructor().makeText(
                          'Veículo', Colors.grey, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ) : SizedBox(),

                  moveModel.ActualPage != 'final' ? SizedBox(
                    width: widthPercent * 0.09,) : SizedBox(),
                  moveModel.ActualPage != 'final' ? Column(
                    children: [
                      Container(
                        child: Icon(Icons.home, color: moveModel.ActualPage ==
                            'itens' || moveModel.ActualPage == 'obs' ||
                            moveModel.ActualPage == 'truck'
                            ? Colors.blue
                            : Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          // You can use like this way or like the below line
                          color: moveModel.ActualPage == 'itens' || moveModel
                              .ActualPage == 'obs' || moveModel.ActualPage ==
                              'truck' ? Colors.white : Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent * 0.10,
                        height: heightPercent * 0.07,
                      ),
                      WidgetsConstructor().makeText(
                          'Endereços', Colors.grey, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ) : SizedBox(),


                  moveModel.ActualPage != 'final' ? SizedBox(
                    width: widthPercent * 0.09,) : SizedBox(),
                  moveModel.ActualPage != 'final' ? Column(
                    children: [
                      Container(
                        child: Icon(Icons.people_alt_sharp, color: moveModel
                            .ActualPage == 'itens' ||
                            moveModel.ActualPage == 'obs' || moveModel
                            .ActualPage == 'truck' || moveModel.ActualPage ==
                            'end' ? Colors.blue : Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          // You can use like this way or like the below line
                          color: moveModel.ActualPage == 'itens' ||
                              moveModel.ActualPage == 'obs' || moveModel
                              .ActualPage == 'truck' || moveModel.ActualPage ==
                              'end' ? Colors.white : Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent * 0.10,
                        height: heightPercent * 0.07,
                      ),
                      WidgetsConstructor().makeText(
                          'Pessoal', Colors.grey, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ) : SizedBox(),

                  moveModel.ActualPage != 'final' ? SizedBox(
                    width: widthPercent * 0.09,) : SizedBox(),
                  moveModel.ActualPage != 'final' ? Column(
                    children: [
                      Container(
                        child: Icon(Icons.schedule_outlined, color: moveModel
                            .ActualPage == 'itens' ||
                            moveModel.ActualPage == 'obs' ||
                            moveModel.ActualPage == 'truck' || moveModel
                            .ActualPage == 'end' || moveModel.ActualPage ==
                            'trucker' ? Colors.blue : Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          // You can use like this way or like the below line
                          color: moveModel.ActualPage == 'itens' ||
                              moveModel.ActualPage == 'obs' ||
                              moveModel.ActualPage == 'truck' || moveModel
                              .ActualPage == 'end' || moveModel.ActualPage ==
                              'trucker' ? Colors.white : Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent * 0.10,
                        height: heightPercent * 0.07,
                      ),
                      WidgetsConstructor().makeText(
                          'Agendar', Colors.grey, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ) : SizedBox(),

                  SizedBox(width: widthPercent * 0.40,),
                  Column(
                    children: [
                      Container(
                        child: Icon(Icons.check, color: Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          // You can use like this way or like the below line
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.blue,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent * 0.10,
                        height: heightPercent * 0.07,
                      ),
                      WidgetsConstructor().makeText(
                          'Pronto!', CustomColors.yellow, 8.0, 1.0, 0.0,
                          'center'),
                    ],
                  ),


                ],
              ),
            ),

          ),


        ],
      ),
    );
  }

  Widget customFakeAppBar(MoveModel moveModel, BuildContext context) {
    void _customBackButton() {
      if (moveModel.ActualPage == 'itens') {
        moveModel.prepareAnim(false, widthPercent);
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomePage()));
      } else if (moveModel.ActualPage == 'obs') {
        //moveModel.updateActualPage('itens');
        moveModel.prepareAnim(false, widthPercent);
        moveModel.changePageBackward('itens', 'Início', 'Itens Grandes');
      } else if (moveModel.ActualPage == 'truck') {
        moveModel.prepareAnim(false, widthPercent);
        moveModel.changePageBackward('obs', 'Itens', 'Observações');
      } else if (moveModel.ActualPage == 'end') {
        moveModel.changePageBackward('truck', 'Obs', 'Veículo');
      } else if (moveModel.ActualPage == 'trucker') {
        moveModel.changePageBackward('end', 'Veículo', 'Endereço');
      } else if (moveModel.ActualPage == 'data') {
        moveModel.changePageBackward('trucker', 'Veículo', 'Profissional');
      }
    }

    void _showListClick() {
      moveModel.updateShowListAnywhere(true);
    }


    return Container(
      decoration: _showTip == true ? BoxDecoration(
        color: Colors.white, boxShadow: [BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 3,
        blurRadius: 3,
        offset: Offset(0, 3), // changes position of shadow
      ),
      ],) : BoxDecoration(color: Colors.transparent,),
      alignment: _showTip == true ? Alignment.topCenter : Alignment.topCenter,
      width: widthPercent,
      height: _showTip == true ? heightPercent * 0.40 : heightPercent * 0.12,
      //color:  _showTip==true ? Colors.white : Colors.transparent,
      child: Column(
        children: [
          _showTip == false
              ? SizedBox(height: heightPercent * 0.01,)
              : Container(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Column(
                  children: [
                    moveModel.ActualPage != 'final' ? IconButton(
                      icon: Icon(
                        Icons.arrow_back, color: CustomColors.blue, size: 35,),
                      onPressed: () {
                        _customBackButton();
                      },) : SizedBox(width: 35.0,),
                    //WidgetsConstructor().makeText(appBarText, Colors.grey[400], 9.0, 0.0, 0.0, 'center'),
                    moveModel.ActualPage != 'final'
                        ? Text(moveModel.AppBarTextBack, style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: ResponsiveFlutter.of(context).fontSize(1.5)))
                        : SizedBox(),
                  ],
                ),
              ),
              WidgetsConstructor().makeResponsiveText(
                  context,
                  moveModel.AppBarTextTitle,
                  _showTip == true ? Colors.white : CustomColors.blue,
                  3,
                  10.0,
                  0.0,
                  'no'),
              moveModel.ActualPage == 'itens' && _showTip == false ? IconButton(
                  icon: Icon(
                    Icons.help_outline, color: CustomColors.blue, size: 35,),
                  onPressed: () {
                    setState(() {
                      _showTip = true;
                    });
                  })
                  : moveModel.ActualPage == 'itens' && _showTip == true
                  ? IconButton(icon: Icon(
                Icons.arrow_circle_up, color: CustomColors.blue, size: 35,),
                onPressed: () {
                  setState(() {
                    _showTip = false;
                  });
                },)
                  : IconButton(icon: Icon(Icons.assignment), onPressed: () {
                moveModel.updateShowListAnywhere(true);
                //showDetalhesLocalPage=false;  >>>ainda n sei o que fazer com esse.

              }),
              //WidgetsConstructor().makeSimpleText("Itens grandes", CustomColors.blue, 18.0),

            ],
          ),
          _showTip == true ? WidgetsConstructor().makeResponsiveText(
              context,
              'Dicas',
              Colors.black,
              2.5,
              20.0,
              0.0,
              'center') : Container(),
          _showTip == true ? WidgetsConstructor().makeResponsiveText(
              context,
              '   - Você não precisa selecionar todos itens da sua mudança, apenas os grandes.',
              Colors.black,
              2,
              20.0,
              0.0,
              'no') : Container(),
          _showTip == true ? WidgetsConstructor().makeResponsiveText(
              context,
              '   - Caso o item não exista na lista, você pode adiciona-lo depois nas observações.',
              Colors.black,
              2,
              10.0,
              0.0,
              'no') : Container(),
        ],
      ),
    );
  }

  void _topAnimScroll(MoveModel moveModel, double widthPercent) {
    moveModel.prepareAnim(true, widthPercent); //libera para o click
    _TopAnimcrollController.animateTo(
        moveModel.Offset, duration: Duration(milliseconds: 450),
        curve: Curves.easeInOut);
    moveModel.finishAnim(true);
  }

  void _topAnimScrollBack(MoveModel moveModel) {
    moveModel.prepareAnim(false, widthPercent);
    _TopAnimcrollController.animateTo(
        moveModel.Offset, duration: Duration(milliseconds: 450),
        curve: Curves.easeInOut);
    moveModel.finishAnim(false);
  }

  Future<void> _checkIfTheUserIsChangingTheTrucker(MoveModel moveModel) async {
    bool isChangingTrucker = await SharedPrefsUtils()
        .checkIfThereIsNeedNewTrucker();
    if (isChangingTrucker == true) {
      void _onFinishLoad() {
        moveModel.updateSpecialCondition(true);
        moveModel.updateActualPage('trucker');
      }
      //se o user está aqui é pq tá sem motorista pq o freteiro negou ou está trocando o motorista
      FirestoreServices().loadScheduledMoveInMoveMovelToChangeTrucker(
          moveModel, widget.userId, () {
        _onFinishLoad();
      });
    }
  }


}





/*
class MoveSchedulePage extends StatefulWidget {


  ScrollController _TopAnimcrollController;
  double heightPercent;
  double widthPercent;

  //appbar
  int step=0;
  bool _showTip=true;

  @override
  _MoveSchedulePageState createState() => _MoveSchedulePageState();
}

class _MoveSchedulePageState extends State<MoveSchedulePage> {

  ScrollController _TopAnimcrollController;
  double heightPercent;
  double widthPercent;

  //appbar
  int step=0;
  bool _showTip=true;

  @override
  Widget build(BuildContext context) {

    return ScopedModel<MoveModel>(
      model: MoveModel(),
      child: ScopedModelDescendant<MoveModel>(
        builder: (BuildContext context, Widget child, MoveModel moveModel){

          if(heightPercent == null){
            heightPercent = MediaQuery.of(context).size.height;
            widthPercent = MediaQuery.of(context).size.width;
          }

          moveModel.updateAppBarText('Início', 'Itens grandes');


          return Scaffold(
            body: Container(
              color: Colors.white,
              width: widthPercent,
              height: heightPercent,
              child: Stack(
                children: [

                  //animação
                  Positioned(
                      top: heightPercent*0.12,
                      width: widthPercent,
                      child: _itensPageAnim(moveModel)),

                  //appbar
                  Positioned(
                    top: heightPercent*0.05,
                    left: 0.0,
                    right: 0.0,
                    child: customFakeAppBar(moveModel),),

                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _itensPageAnim(MoveModel moveModel){

    _TopAnimcrollController = ScrollController();

    //para animação da tela
    _TopAnimcrollController.addListener(() {
      moveModel.updateOffset(_TopAnimcrollController.hasClients ? _TopAnimcrollController.offset : 0.1);
    });

    return Container(
      width: widthPercent,
      height: heightPercent,
      child: Stack(
        children: [

          Positioned(
              top: heightPercent*0.12,
              left: 0.1,
              right: 0.1,
              child: Container(
                width: widthPercent,
                height: heightPercent*0.08,
                decoration: new BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 3,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
              )
          ),

          //lista
          Positioned(
            top: heightPercent*0.10,
            left: widthPercent*0.05,
            right: 10.0,
            child: Container(
              height: heightPercent*0.10,
              width: widthPercent,
              child: ListView(
                controller: _TopAnimcrollController,
                physics: moveModel.CanScroll == false ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,

                children: [


                  SizedBox(width: widthPercent*0.02,),
                  Column(
                    children: [
                      Container(
                        child: Icon(Icons.assignment, color: Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,// You can use like this way or like the below line
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent*0.10,
                        height: heightPercent*0.07,
                      ),
                      WidgetsConstructor().makeText('Itens', Colors.grey, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ),

                  SizedBox(width: widthPercent*0.09,),
                  Column(
                    children: [
                      Container(
                        child: Icon(Icons.home, color: Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,// You can use like this way or like the below line
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent*0.10,
                        height: heightPercent*0.07,
                      ),
                      WidgetsConstructor().makeText('Endereços', Colors.grey, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ),

                  SizedBox(width: widthPercent*0.09,),
                  Column(
                    children: [
                      Container(
                        child: Icon(Icons.airport_shuttle, color: Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,// You can use like this way or like the below line
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent*0.10,
                        height: heightPercent*0.07,
                      ),
                      WidgetsConstructor().makeText('Veículo', Colors.grey, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ),


                  SizedBox(width: widthPercent*0.09,),
                  Column(
                    children: [
                      Container(
                        child: Icon(Icons.people_alt_sharp, color: Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,// You can use like this way or like the below line
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent*0.10,
                        height: heightPercent*0.07,
                      ),
                      WidgetsConstructor().makeText('Pessoal', Colors.grey, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ),

                  SizedBox(width: widthPercent*0.09,),
                  Column(
                    children: [
                      Container(
                        child: Icon(Icons.schedule_outlined, color: Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,// You can use like this way or like the below line
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent*0.10,
                        height: heightPercent*0.07,
                      ),
                      WidgetsConstructor().makeText('Agendar', Colors.grey, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ),

                  SizedBox(width: widthPercent*0.09,),
                  Column(
                    children: [
                      Container(
                        child: Icon(Icons.check, color: Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,// You can use like this way or like the below line
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.blue,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent*0.10,
                        height: heightPercent*0.07,
                      ),
                      WidgetsConstructor().makeText('Pronto!', CustomColors.yellow, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ),

                  SizedBox(width: 10000.0,),


                ],
              ),
            ),

          ),

          //caixa 1
          step>=1 ? Positioned(
              top: heightPercent*0.04,
              left: widthPercent*0.047,
              child: Container(
                width: widthPercent*0.025,
                height: heightPercent*0.015,
                color: CustomColors.brown,)
          ) : Container(),

          //caixa 2
          step>=2 ? Positioned(
              top: heightPercent*0.04,
              left: widthPercent*0.072,
              child: Container(
                width: widthPercent*0.025,
                height: heightPercent*0.015,
                color: CustomColors.brown,)
          ) : Container(),

          //caixa 3
          step>=3 ? Positioned(
              top: heightPercent*0.04,
              left: widthPercent*0.097,
              child: Container(
                width: widthPercent*0.025,
                height: heightPercent*0.015,
                color: CustomColors.brown,)
          ) : Container(),

          //caixa 4
          step>=4 ? Positioned(
              top: heightPercent*0.025,
              left: widthPercent*0.052,
              child: Container(
                width: widthPercent*0.025,
                height: heightPercent*0.015,
                color: CustomColors.brown,)
          ) : Container(),

          //caixa 5
          step>=5 ? Positioned(
              top: heightPercent*0.025,
              left: widthPercent*0.082,
              child: Container(
                width: widthPercent*0.025,
                height: heightPercent*0.015,
                color: CustomColors.brown,)
          ) : Container(),

          //caminhonete
          Positioned(
              top: heightPercent*0.03,
              left: widthPercent*0.04,
              child: Container(
                width: widthPercent*0.15,
                height: heightPercent*0.055,
                child: Image.asset('images/itensselect/anim/anim_caminhonete.png', fit: BoxFit.fill,),
              )),

          //roda traseira
          Positioned(
              top: heightPercent*0.07,
              left: widthPercent*0.047,
              child: Container(
                width: widthPercent*0.045,
                height: heightPercent*0.025,
                child: Image.asset('images/itensselect/anim/anim_roda.png', fit: BoxFit.fill,),
              )
          ),

          //roda dianteira
          Positioned(
              top: heightPercent*0.07,
              left: widthPercent*0.14,
              child: Container(
                width: widthPercent*0.045,
                height: heightPercent*0.025,
                child: Image.asset('images/itensselect/anim/anim_roda.png', fit: BoxFit.fill,),
              )
          ),



        ],
      ),
    );


  }

  //elementos do layout
  Widget customFakeAppBar(MoveModel moveModel){

    void _customBackButton(){

      if(moveModel.ActualPage=='itens'){
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomePage()));
      } else if(moveModel.ActualPage=='obs'){
        moveModel.updateActualPage('itens');
      }


      /*
      bool showSelectItemPage=true;
  bool showCustomItemPage=false;
  bool showSelectTruckPage=false;
  bool showAddressesPage=false;
  bool showChooseTruckerPage=false;
  bool showDatePage=false;
  bool showFinalPage=false;
  bool showListOfItemsEdit=false;
       */

    }

    void _showListClick(){
      moveModel.updateShowListAnywhere(true);
    }


    return Container(
      decoration: _showTip==true ? BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 3,
        blurRadius: 3,
        offset: Offset(0, 3), // changes position of shadow
      ),],) : BoxDecoration(color: Colors.transparent,),
      alignment:  _showTip==true ? Alignment.topCenter : Alignment.topCenter,
      width: widthPercent,
      height: _showTip==true ? heightPercent*0.50 : heightPercent*0.10,
      //color:  _showTip==true ? Colors.white : Colors.transparent,
      child: Column(
        children: [
          _showTip==false ? SizedBox(height: heightPercent*0.01,) : Container(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: CustomColors.blue, size: 35,),
                      onPressed: () {
                        _customBackButton();
                      },),
                    //WidgetsConstructor().makeText(appBarText, Colors.grey[400], 9.0, 0.0, 0.0, 'center'),
                    Text(moveModel.AppBarTextBack, style: TextStyle(color: Colors.grey[400], fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
                  ],
                ),
              ),
              WidgetsConstructor().makeResponsiveText(context, moveModel.AppBarTextTitle, _showTip==true ? Colors.white : CustomColors.blue, 3, 10.0, 0.0, 'no'),
              moveModel.ActualPage == 'itens'  && _showTip==false ? IconButton(icon: Icon(Icons.help_outline, color: CustomColors.blue, size: 35,), onPressed: (){
                setState(() {
                  _showTip=true;
                });
              })
                  : moveModel.ActualPage == 'itens' && _showTip==true ? IconButton(icon: Icon(Icons.arrow_circle_up, color: CustomColors.blue, size: 35,), onPressed: (){
                setState(() {
                  _showTip=false;
                });
              },)
                  : IconButton(icon: Icon(Icons.assignment), onPressed: (){
                setState(() {
                  moveModel.updateShowListAnywhere(true);
                  //_showListAnywhere=true;
                  //showDetalhesLocalPage=false;  >>>ainda n sei o que fazer com esse.
                });
              }) ,
              //WidgetsConstructor().makeSimpleText("Itens grandes", CustomColors.blue, 18.0),

            ],
          ),
          _showTip==true ? WidgetsConstructor().makeResponsiveText(context, 'Dicas', Colors.black, 2.5, 20.0, 0.0, 'center') : Container(),
          _showTip==true ? WidgetsConstructor().makeResponsiveText(context, '   - Você não precisa selecionar todos itens da sua mudança, apenas os grandes.', Colors.black, 2, 20.0, 0.0, 'no') : Container(),
          _showTip==true ? WidgetsConstructor().makeResponsiveText(context, '   - Caso o item não exista na lista, você pode adiciona-lo depois nas observações.', Colors.black, 2, 10.0, 0.0, 'no') : Container(),
        ],
      ),
    );
  }

}


 */