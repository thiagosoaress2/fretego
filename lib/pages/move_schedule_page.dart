import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:fretego/models/home_page_model.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/pages/move_schadule_internals_page/my_list_of_itens_page.dart';
import 'package:fretego/pages/move_schadule_internals_page/page1_select_itens.dart';
import 'package:fretego/pages/move_schadule_internals_page/page2_obs.dart';
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
import 'package:fretego/utils/popup.dart';
import 'package:fretego/utils/popup2.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

class MoveSchedulePage extends StatefulWidget{
  String userId;
  bool changingTrucker; //caso o user esteja trocando de motorista
  bool specificTrucker; //caso o user esteja chegando aqui tendo escolhido um  motorista específico
  MoveSchedulePage(this.userId, this.changingTrucker, this.specificTrucker);


  @override
  _MoveSchedulePageState createState() => _MoveSchedulePageState();
}

class _MoveSchedulePageState extends State<MoveSchedulePage>{

  ScrollController _TopAnimcrollController;

  double heightPercent;
  double widthPercent;

  bool _showTip = true;


  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MoveModel>(
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

          //_checkIfTheUserIsChangingTheTrucker(moveModel);
          _goChangeTheTrucker(moveModel);

        }

        void _closePopup(){
          setState(() {
            _showTip=false;
          });
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

                    //exibe a pagina apropriada
                    if(moveModel.ActualPage == 'itens') Page1SelectItens(heightPercent, widthPercent, widget.userId),
                    if(moveModel.ActualPage == 'obs') Page2Obs(heightPercent, widthPercent, widget.userId),
                    if(moveModel.ActualPage == 'truck') Page3Truck(heightPercent, widthPercent, widget.userId),
                    if(moveModel.ActualPage == 'end') Page4Enderecos(),
                    if(moveModel.ActualPage == 'trucker') Page5Trucker(heightPercent, widthPercent, widget.userId),
                    if(moveModel.ActualPage == 'data') Page6Data(heightPercent, widthPercent, widget.userId, false),
                    if(moveModel.ActualPage == 'final') PageFinal(heightPercent, widthPercent, widget.userId),


                    //animação
                    //barra superior mostrando a progressão. Quando exibe uma ajuda ela some para n ficar em evidencia
                    if(moveModel.HelpIsOnScreen==false && moveModel.ActualPage != 'final') Positioned(top: heightPercent * 0.12, width: widthPercent,
                        child: _itensPageAnim(moveModel)
                    ),

                    //appbar
                    if(moveModel.ActualPage != 'final') _customFakeAppBar(moveModel, context),

                    //float action button
                    //situacoes onde o botão nao deve aparecer pois tem um floting btn igual dentro da página
                    if(moveModel.ActualPage != 'itens' && moveModel.ActualPage != 'end' && moveModel.ActualPage != 'trucker' &&
                        moveModel.ActualPage != 'data' && moveModel.ActualPage != 'final'
                        && moveModel.ActualPage != 'truck') _nextFloatButton(moveModel,),

                    //mostra a lista de itens em qualquer página
                    if(moveModel.ShowListAnywhere == true) MyListOfItensPage(heightPercent, widthPercent),

                    //dica inicial em formato popuo
                    /*
                    if(_showTip == true) Popup2().popupWithOneButton(context, heightPercent, widthPercent, 'Dicas',
                        '-Você não precisa selecionar todos os itens da mudança, apenas os grandes. \n\n'
                            '-Caso o item não exista na lista, você pode adiciona-lo na página seguinte nas observações', 'Ok',
                            () { _closePopup(); }),

                     */

                    //popup de ajuda
                    if(_showTip == true) GestureDetector(
                      onTap: (){
                        setState(() {
                          _showTip=false;
                        });
                      },
                      child: Container(
                        height: heightPercent,
                        width: widthPercent,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),

                    AnimatedPositioned(
                      duration: Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                      top: _showTip==false ? heightPercent*0.01 : heightPercent*0.15,
                      right: _showTip==false ? 5.0 : widthPercent*0.02,
                      left: _showTip==false ? widthPercent*0.95 : widthPercent*0.02,
                      bottom: _showTip==false ? heightPercent*0.96 : heightPercent*0.20,
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: Container(
                            height: 100.0,
                            margin: const EdgeInsets.fromLTRB(0.0, 0.0, 6.0, 6.0), //Same as `blurRadius` i guess
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(0.0, 1.0), //(x,y)
                                  blurRadius: 6.0,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: heightPercent*0.02,),
                                Container(
                                  decoration: BoxDecoration(
                                    color: CustomColors.yellow,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.help, color: Colors.white, size: widthPercent*0.15,),
                                ),
                                SizedBox(height: heightPercent*0.02,),
                                if(_showTip==true)
                                Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Text('-Você não precisa selecionar todos os itens da mudança, apenas os grandes. \n\n'
                                        '-Caso o item não exista na lista, você pode adiciona-lo na página seguinte nas observações'
                                      , style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2.5), color: Colors.black),),
                                ),
                                SizedBox(height: heightPercent*0.005,),
                                Container(
                                  width: widthPercent*0.50,
                                  height: heightPercent*0.10,
                                  child: RaisedButton(
                                    onPressed: (){
                                      setState(() {
                                        _showTip=false;
                                      });
                                    },
                                    color: CustomColors.yellow,
                                    child: Text('Ok'
                                      , style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(3.5), color: Colors.white),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    )

                  ],
                ),
              ),
            );
          },
        );
      },
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


    Widget _topBarListAnimElement({double espacoInicial, IconData icon, String text, String thisElement}){

      //thisElement é o elemento sendo exibido (itens, obs etc)
      int passo;
      if(moveModel.ActualPage=='itens'){
        passo=1;
      } else if(moveModel.ActualPage=='obs'){
        passo=2;
      } else if(moveModel.ActualPage== 'truck'){
        passo=3;
      } else if(moveModel.ActualPage=='end'){
        passo=4;
      } else if(moveModel.ActualPage=='data'){
        passo=5;
      } else {
        //entao é a pagina final
        passo=6;
      }

      int elementN;
      if(thisElement=='Itens'){
        elementN=1;
      } else if(thisElement=='obs'){
        elementN=2;
      } else if(thisElement=='truck'){
        elementN=3;
      } else if(thisElement=='end'){
        elementN=4;
      } else if(thisElement=='data'){
        elementN=5;
      } else {
        elementN=6;
      }

      return Row(
        children: [

          SizedBox(width: espacoInicial,),

          Column(
            children: [
              Container(
                child: Icon(icon,
                  color: passo>= elementN ? Colors.white : Colors.blue,),
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  // You can use like this way or like the below line
                  color: passo>=elementN ? Colors.blue :  Colors.white,
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
                  text, Colors.grey, 8.0, 1.0, 0.0, 'center'),
            ],
          ),

        ],
      );

    }

    return Container(
      width: widthPercent,
      height: heightPercent,
      child: Stack(
        children: [

          //bara de acompanhamento
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


                  //lista original
                  if(moveModel.ActualPage != 'final') _topBarListAnimElement(espacoInicial: widthPercent*0.008, icon: Icons.assignment, text: 'Itens', thisElement: 'Itens'),

                  /*
                  moveModel.ActualPage != 'final' ? SizedBox(width: widthPercent * 0.02,) : SizedBox(),
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

                   */

                  if(moveModel.ActualPage != 'final') _topBarListAnimElement(espacoInicial: widthPercent*0.09, icon: Icons.info, text: 'Observações', thisElement: 'obs'),

                  /*
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

                   */

                  if(moveModel.ActualPage != 'final') _topBarListAnimElement(espacoInicial: widthPercent*0.09, icon: Icons.airport_shuttle, text: 'Veículo', thisElement: 'truck'),

                  /*
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
                   */

                  if(moveModel.ActualPage != 'final') _topBarListAnimElement(espacoInicial: widthPercent*0.09, icon: Icons.add_business_sharp, text: 'Endereços', thisElement: 'end'),

                  /*
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
                   */

                  if(moveModel.ActualPage != 'final') _topBarListAnimElement(espacoInicial: widthPercent*0.09, icon: Icons.schedule_outlined, text: 'Agendar', thisElement: 'data'),

                  /*
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


                   */


                  if(moveModel.ActualPage=='final') _topBarListAnimElement(
                    espacoInicial: widthPercent*0.4, icon: Icons.check, text: 'Resumo', thisElement: 'final'
                  )
                  /*
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
                   */

                ],
              ),
            ),

          )


        ],
      ),
    );
  }

  Widget _customFakeAppBar(MoveModel moveModel, BuildContext context) {
    void _customBackButton() {
      if (moveModel.ActualPage == 'itens') {
        //moveModel.prepareAnim(false, widthPercent);
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
        //se estiver adicionando um motorista especifico vai saltar essa página
        if(widget.specificTrucker==true){
          moveModel.changePageBackward('obs', 'Itens', 'Observações');
        } else {
          moveModel.changePageBackward('truck', 'Obs', 'Veículo');
        }

      } else if (moveModel.ActualPage == 'trucker') {
        moveModel.changePageBackward('end', 'Veículo', 'Endereço');
      } else if (moveModel.ActualPage == 'data') {
        //moveModel.changePageBackward('trucker', 'Veículo', 'Profissional');
        moveModel.changePageBackward('end', 'Veículo', 'Endereço');
      }
    }

    void _showListClick() {
      moveModel.updateShowListAnywhere(true);
    }

    return Positioned(
        top: heightPercent * 0.05,
        left: 0.0,
        right: 0.0,
        child: Container(
          decoration: BoxDecoration(color: Colors.transparent,),
          alignment: Alignment.topCenter,
          width: widthPercent,
          height: heightPercent * 0.15,
          //color:  _showTip==true ? Colors.white : Colors.transparent,
          child: Column(
            children: [
              Container(),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  //seta de voltar
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

                  //texto
                  if(moveModel.ActualPage != 'final') WidgetsConstructor().makeResponsiveText(context, moveModel.AppBarTextTitle, CustomColors.blue, 3, 10.0, 0.0, 'no'),

                  //icone da lista
                  moveModel.ActualPage == 'final' ? Container() :
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

            ],
          ),
        ));

  }

  Widget _nextFloatButton(MoveModel moveModel){

    return Positioned(
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


                //se o user estiver vindo da pagina com trucker especifico, vai saltar a página de carro. Os dados
                //referentes a um carro já estão armazenados na classe movemodel;
                if(widget.specificTrucker==true){
                  moveModel.changePageForward('end', 'Veículo', "Endereço");
                } else {
                  moveModel.changePageForward(
                      'truck', 'Obs', 'Veículo');
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
    );
  }

  Future<void> _goChangeTheTrucker(MoveModel moveModel) async {


    //carrega a situação para o final
    moveModel.moveClass.pago = await FirestoreServices().loadPagoSituation(widget.userId);
    if(moveModel.moveClass.pago==true){
      //saltar direto para escolher o motorista e apenas atualizar isso. N vai poder mexer no resto pois
      //pois poderia  mudar o endereço e escolher algo mais caro
      moveModel.changePageForward('trucker', 'Endereço', 'Profissional');
    } else
      //outra opção. Caso esteja mudando o motorista vai encontrar situação trocando motorista. Atenção: Esta mudança não ocorre no BD, apenas agora em tempo de execução
    if(widget.changingTrucker==true){
      moveModel.changePageForward('trucker', 'Endereço', 'Profissional');
    }

  }

}









//antes da mudança do esquema do motorista
/*
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:fretego/models/home_page_model.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/pages/move_schadule_internals_page/my_list_of_itens_page.dart';
import 'package:fretego/pages/move_schadule_internals_page/page1_select_itens.dart';
import 'package:fretego/pages/move_schadule_internals_page/page2_obs.dart';
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
import 'package:fretego/utils/popup.dart';
import 'package:fretego/utils/popup2.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

class MoveSchedulePage extends StatefulWidget{
  String userId;
  bool changingTrucker;
  MoveSchedulePage(this.userId, this.changingTrucker);


  @override
  _MoveSchedulePageState createState() => _MoveSchedulePageState();
}

class _MoveSchedulePageState extends State<MoveSchedulePage>{

  ScrollController _TopAnimcrollController;

  double heightPercent;
  double widthPercent;

  bool _showTip = true;


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

            //_checkIfTheUserIsChangingTheTrucker(moveModel);
            _goChangeTheTrucker(moveModel);

          }

          void _closePopup(){
            setState(() {
              _showTip=false;
            });
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

                      //exibe a pagona apropriada
                      if(moveModel.ActualPage == 'itens') Page1SelectItens(heightPercent, widthPercent, widget.userId),
                      if(moveModel.ActualPage == 'obs') Page2Obs(heightPercent, widthPercent, widget.userId),
                      if(moveModel.ActualPage == 'truck') Page3Truck(heightPercent, widthPercent, widget.userId),
                      if(moveModel.ActualPage == 'end') Page4Enderecos(),
                      if(moveModel.ActualPage == 'trucker') Page5Trucker(heightPercent, widthPercent, widget.userId),
                      if(moveModel.ActualPage == 'data') Page6Data(heightPercent, widthPercent, widget.userId, false),
                      if(moveModel.ActualPage == 'final') PageFinal(heightPercent, widthPercent, widget.userId),


                      //animação
                      //barra superior mostrando a progressão. Quando exibe uma ajuda ela some para n ficar em evidencia
                      if(moveModel.HelpIsOnScreen==false) Positioned(top: heightPercent * 0.12, width: widthPercent,
                          child: _itensPageAnim(moveModel)
                      ),

                      //appbar
                      _customFakeAppBar(moveModel, context),

                      //float action button
                      //situacoes onde o botão nao deve aparecer pois tem um floting btn igual dentro da página
                      if(moveModel.ActualPage != 'itens' && moveModel.ActualPage != 'end' && moveModel.ActualPage != 'trucker' &&
                          moveModel.ActualPage != 'data' && moveModel.ActualPage != 'final'
                          && moveModel.ActualPage != 'truck') _nextFloatButton(moveModel,),

                      //mostra a lista de itens em qualquer página
                      if(moveModel.ShowListAnywhere == true) MyListOfItensPage(heightPercent, widthPercent),

                      //dica inicial em formato popuo
                      if(_showTip == true) Popup2().popupWithOneButton(context, heightPercent, widthPercent, 'Dicas',
                          '-Você não precisa selecionar todos os itens da mudança, apenas os grandes. \n\n'
                              '-Caso o item não exista na lista, você pode adiciona-lo na página seguinte nas observações', 'Ok',
                              () { _closePopup(); }),

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

          //bara de acompanhamento
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

          )


        ],
      ),
    );
  }

  Widget _customFakeAppBar(MoveModel moveModel, BuildContext context) {
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

    return Positioned(
      top: heightPercent * 0.05,
      left: 0.0,
      right: 0.0,
      child: Container(
        decoration: BoxDecoration(color: Colors.transparent,),
        alignment: Alignment.topCenter,
        width: widthPercent,
        height: heightPercent * 0.15,
        //color:  _showTip==true ? Colors.white : Colors.transparent,
        child: Column(
          children: [
            Container(),
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
                    CustomColors.blue,
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

          ],
        ),
      ));

  }

  Widget _nextFloatButton(MoveModel moveModel){

    return Positioned(
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
    );
  }

  Future<void> _goChangeTheTrucker(MoveModel moveModel) async {


    //carrega a situação para o final
    moveModel.moveClass.pago = await FirestoreServices().loadPagoSituation(widget.userId);
    if(moveModel.moveClass.pago==true){
      //saltar direto para escolher o motorista e apenas atualizar isso. N vai poder mexer no resto pois
      //pois poderia  mudar o endereço e escolher algo mais caro
      moveModel.changePageForward('trucker', 'Endereço', 'Profissional');
    } else
      //outra opção. Caso esteja mudando o motorista vai encontrar situação trocando motorista. Atenção: Esta mudança não ocorre no BD, apenas agora em tempo de execução
    if(widget.changingTrucker==true){
      moveModel.changePageForward('trucker', 'Endereço', 'Profissional');
    }

  }

}



 */
