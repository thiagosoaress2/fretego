import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:fretego/login/pages/email_verify_view.dart';
import 'package:fretego/models/home_page_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/utils/anim_fader.dart';
import 'package:fretego/utils/anim_fader_left.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

import '../avalatiation_page.dart';

class HomeClassic extends StatefulWidget {
  double heightPercent;
  double widthPercent;
  HomeClassic(this.heightPercent, this.widthPercent);

  @override
  _HomeClassicState createState() => _HomeClassicState();
}


  bool _firstLoad=true;

class _HomeClassicState extends State<HomeClassic> {

  bool firstLoadVar=false;
  ScrollController _scrollController;
  ScrollController _scrollControllerLocal;

  void scrollToEnd(HomePageModel homePageModel) {

    print('scrollToEnd');
    //para animação da tela
    bool carroAndou=false;
    if(_scrollControllerLocal.hasClients){
      print('tem clientes');
      if(homePageModel.Offset>1990.0 && carroAndou==false){
        carroAndou=true;
        print('entrou no if');
        double end = _scrollControllerLocal.position.maxScrollExtent;
        setState(() {
          _scrollControllerLocal.animateTo(end, duration: Duration(seconds: 3), curve: Curves.easeInOut);
        });

      }
    }


  }

  @override
  Widget build(BuildContext context) {
    _scrollController = ScrollController();
    _scrollControllerLocal =  ScrollController();
    return ScopedModelDescendant<HomePageModel>(
      builder: (BuildContext context, Widget child, HomePageModel homePageModel){

        if(_firstLoad==true){
          _firstLoad=false;
          //print('entrou no clickticking');
          //ClockTicking(homePageModel);
        }

        //para animação da tela
        _scrollController.addListener(() {
          setState(() {
            print('offset quando entrou'+homePageModel.Offset.toString());
            homePageModel.updateOffset(_scrollController.hasClients ? _scrollController.offset : 0.1);
            print('offset quando dps de atualizar'+homePageModel.Offset.toString());
          });
          if(homePageModel.Offset>1990.0){
            scrollToEnd(homePageModel);
          }

        });


        return ScopedModelDescendant<UserModel>(
          builder: (BuildContext context, Widget child, UserModel userModel){

            return Container(
              width: widget.widthPercent,
              height: widget.heightPercent,
              color: Colors.white,
              child: Stack(
                children: [

                //fundo de parede
                _deepestBackground(),

              //casal
              _imagemCasal(homePageModel),

              //caixas
              _imagemCaixas(homePageModel),

              //primeira parte da animação
              _inicioAnimacao(homePageModel),

              //este é o card com o freteiro. Aparece sobreponto a Listview
              if(homePageModel.Offset > 2250 && homePageModel.Offset<2650) _freteiroPreview(homePageModel),

              if(homePageModel.Offset > 2550 && homePageModel.Offset < 3357) _animCarrinhos(homePageModel),

              if(homePageModel.Offset < 250.0) Positioned(
                  left: 10.0,
                  right: 10.0,
                  top: widget.heightPercent*0.3,
                  //bottom: heightPercent*0.45,
                  child: Container(
                    width: widget.widthPercent*0.7,
                    child: GestureDetector(

                      onTap: (){
                        setState(() {

                          double end = _scrollController.position.maxScrollExtent;
                          setState(() {
                            //_scrollController.animateTo(end, duration: Duration(seconds: 20), curve: Curves.easeInOut);
                            _scrollController.animateTo(end, duration: Duration(seconds: 35), curve: Curves.easeOut);
                          });

                        });
                      },

                      child: Column(
                        children: [
                          WidgetsConstructor().makeText('Conheça nosso', Colors.white, 25.0, 0.0, 0.0, 'center'),
                          WidgetsConstructor().makeText('serviço', Colors.white, 25.0, 0.0, 0.0, 'center'),
                          Transform.rotate(angle: 1.5, child: Icon(Icons.double_arrow, size: 25, color: Colors.white.withOpacity(0.5),),),
                        ],
                      ),
                    ),
                  )),


                ],
              ),
            );

          },
        );

      },
    );
  }

  Widget AnimationPage1(HomePageModel homePageModel, double heightPercent, double widthPercent){
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
                  SizedBox(width: homePageModel.Offset<400 ? 1000 : 600-homePageModel.Offset > 0.0 ? 600-homePageModel.Offset: 0.0,),
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
                    homePageModel.Offset>550 ? EntranceFaderLeft(
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
                    homePageModel.Offset>650 ? EntranceFader(
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

  Widget AnimationPage2(HomePageModel homePageModel, double heightPercent, double widthPercent){


    TextEditingController _sourceAdress = TextEditingController();
    TextEditingController _destinyAdress = TextEditingController();
    bool _searchCEP = false;


    if(homePageModel.Offset>1330){
      _sourceAdress.text='Aven';
    }
    if (homePageModel.Offset>1500){
      _sourceAdress.text='Avenida';
    }
    if(homePageModel.Offset>1600){
      _sourceAdress.text='Avenida Um';
    }
    if(homePageModel.Offset>1700){
      _destinyAdress.text='Rua';
    }
    if(homePageModel.Offset>1800){
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
              SizedBox(height: (1400-homePageModel.Offset) < 2.0 ? 2.0 : 1400-homePageModel.Offset,),
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
                        homePageModel.Offset> 1620 && _sourceAdress.text != "" ? WidgetsConstructor().makeText("Endereço localizado", Colors.blue, 15.0, 10.0, 5.0, "center") : Container(),
                        //address found
                        homePageModel.Offset> 1650 && _sourceAdress.text != "" ? WidgetsConstructor().makeText(_sourceAdress.text+' CEP - 24070120', Colors.black, 12.0, 5.0, 10.0, "center") : Container(),
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

  Widget AnimationPage3(HomePageModel homePageModel, double heightPercent, double widthPercent){



    return Container(
      child: Column(
        children: [

          SizedBox(width: homePageModel.Offset<1850 ? 1000 : 2200-homePageModel.Offset > 0.0 ? 2200-homePageModel.Offset: 0.0,),
          WidgetsConstructor().makeText('Encontre o melhor veículo', homePageModel.Offset<2200? Colors.white: CustomColors.blue, 20.0, 0.0, 0.0, 'no'),
          WidgetsConstructor().makeText('para você!', CustomColors.blue, homePageModel.Offset<2260? 35.0 : 50.0, 0.0, 0.0, 'center'),
          SizedBox(height: 35.0,),

          SingleChildScrollView(
            controller: _scrollControllerLocal,
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                Row(
                  children: [

                    Image.asset('images/itensselect/trucks/truck_pickupp.png'),
                    SizedBox(width: 25.0,),
                    Image.asset('images/itensselect/trucks/truck_pickupg.png'),
                    SizedBox(width: 25.0,),
                    Image.asset('images/itensselect/trucks/truck_kombi.png'),
                    SizedBox(width: 25.0,),
                    Image.asset('images/itensselect/trucks/truck_kombia.png'),
                    SizedBox(width: 25.0,),
                    Image.asset('images/itensselect/trucks/truck_baup.png'),
                    SizedBox(width: 25.0,),
                    Image.asset('images/itensselect/trucks/truck_aberto.png'),
                    SizedBox(width: 25.0,),
                  ],
                )
              ],
            )

          ),

          SizedBox(height: 200.0,),
          homePageModel.Offset> 2100 ? EntranceFader(
            offset: Offset(widthPercent /4,0),
            duration: Duration(seconds: 3),
            child: WidgetsConstructor().makeText('Ache a ', Colors.white, 25.0, 10.0, 0.0, 'center'),
          ): Container(),
          homePageModel.Offset> 2130 ? EntranceFader(
            offset: Offset(widthPercent /4,0),
            duration: Duration(seconds: 3),
            child: WidgetsConstructor().makeText('    pessoa certa!', Colors.white, homePageModel.Offset<2492 ? 25.0 : 40.0, 10.0, 0.0, 'center'),
          ) : Container(),
        ],
      ),

    );
  }

  Widget AnimationPage4(HomePageModel homePageModel, double heightPercent, double widthPercent){

    return Container(
      height: 700.0,
      color: Colors.white,
      child: Column(
        children: [

          homePageModel.Offset>3150
              ? WidgetsConstructor().makeText('Pague com cartão de crédito', CustomColors.blue, 20.0, 30.0, 25.0, 'center'): Container(),
          homePageModel.Offset>3200
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
          homePageModel.Offset>3200
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
          homePageModel.Offset>3400
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

          homePageModel.Offset>3450 ? Container(
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

          homePageModel.Offset>3050 ? WidgetsConstructor().makeText('Voltar ao início', CustomColors.blue, 16.0, 5.0, 10.0, 'center') : Container(),

        ],
      ),
    );

  }

  void ClockTicking(HomePageModel model){

    Future.delayed(Duration(seconds: 15)).then((_) {
      print('15 segundos');
      print(model.Offset);
      if(model.Offset < 100.0 ){
        print('scrolled to end');

        _scrollController.animateTo(
          3955.8999999999996, //este valor é offset máximo
          duration: Duration(milliseconds: 25000),
          curve: Curves.linear,
        );

      }
    });

  }


  Widget _deepestBackground(){

    return Positioned(
      //top: heightPercent*0.05,
      left: -5.0,
      right: -10.0,
      top: 0.0,
      child: Container(
        width: widget.widthPercent,
        height: widget.heightPercent,
        child: Image.asset('images/home_backwall_noeffect.png', fit: BoxFit.fill,),
      ),
    );
  }

  Widget _imagemCasal(HomePageModel homePageModel){
    return Positioned(
      //right: widget.widthPercent*0.10,
        right: 0.0,
        left: 0.0,
        top: widget.heightPercent*0.45+homePageModel.Offset,
        //bottom: heightPercent*0.1,
        child: Container(
          width: widget.widthPercent,
          height: widget.heightPercent*0.40,
          child: Image.asset('images/home_couple.png'),
        ));
  }

  Widget _imagemCaixas(HomePageModel homePageModel){

    return Positioned(
        top: widget.heightPercent*0.70 -homePageModel.Offset,
        //bottom: 0.0,
        child: Container(
          width: widget.widthPercent,
          height: widget.heightPercent*0.25,
          child: Image.asset('images/home_boxes.png', fit: BoxFit.fill,),
        ));
  }

  Widget _inicioAnimacao(HomePageModel homePageModel){
    return Scrollbar(
        child: ListView(
          controller: _scrollController,
          children: [

            SizedBox(height: widget.heightPercent*0.85,),
            Container(alignment: Alignment.topCenter,color: CustomColors.brown,height: 100.0, width: widthPercent, child: Image.asset('images/home_boxline.png'),),
            Container(color: CustomColors.brown, width: widthPercent, height: 150.0,
              child: Column(
                children: [
                  if(homePageModel.Offset>280) WidgetsConstructor().makeText('O que nós fazemos?', Colors.white, 25.0, 25.0, 0.0, 'center'),
                  if(homePageModel.Offset>350) WidgetsConstructor().makeText('- Ajudamos na sua mudança', Colors.white, 16.0, 20.0, 0.0, 'center'),

                ],
              ),
            ),
            Container(
              color: Colors.white,
              width: widthPercent,
              height: 700.0,
              child: homePageModel.Offset>400 ? AnimationPage1(homePageModel, widget.heightPercent, widget.widthPercent): Container(),
            ),
            SizedBox(height: 20.0,),
            if(homePageModel.Offset>1000) EntranceFader(
              offset: Offset(widget.widthPercent /4,0),
              duration: Duration(seconds: 3),
              child: WidgetsConstructor().makeText('Informe os endereços', homePageModel.Offset<1455.0 ? Colors.white : CustomColors.blue, 25.0, 10.0, 0.0, 'center'),
            ),
            if(homePageModel.Offset>1100) AnimationPage2(homePageModel, widget.heightPercent, widget.widthPercent),
            SizedBox(height: 250.0,),
            if(homePageModel.Offset>1850) AnimationPage3(homePageModel, widget.heightPercent, widget.widthPercent),
            SizedBox(height: 1000.0,),
            if(homePageModel.Offset>3050) AnimationPage4(homePageModel, widget.heightPercent, widget.widthPercent),
            //Container(color: Colors.white, height: 500.0,),

          ],
        )
    );
  }

  Widget _freteiroPreview(HomePageModel homePageModel){

    return Positioned(
      left: 10.0,
      top: homePageModel.Offset-2250,
      child: Container(
        height: 200.0,
        decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.white, 2.0, 8.0),
        width: widget.widthPercent*0.6,
        child: Column(
          children: [
            WidgetsConstructor().makeText('João do frete', CustomColors.blue, 18.0, 20.0, 20.0, 'center'),
            SizedBox(height: 15.0,),
            Row(
              children: [
                SizedBox(width: widget.widthPercent*0.02,),
                ClipRRect(
                    borderRadius: BorderRadius.circular(360.0),
                    child: Image.asset('images/home_trucker.jpg', width: 75.0, height: 75.9, fit: BoxFit.fill,)
                ),
                SizedBox(width: widget.widthPercent*0.02,),
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
    );
  }

  Widget _animCarrinhos(HomePageModel homePageModel){

    return Positioned(
      left: widget.widthPercent*0.2,
      bottom: homePageModel.Offset<2890 ? homePageModel.Offset-2900 : homePageModel.Offset<3100 ? 0.0 : 3100-homePageModel.Offset, //primeiro vamos aumentando, pra subir, dps retirando pra baixar
      child: Container(
        width: 150.0,
        height: 250.0,
        child: Image.asset('images/home_trucker_anim.png', fit: BoxFit.fill,),
      ),
    );
  }

}
