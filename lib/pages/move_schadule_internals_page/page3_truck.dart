import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/classes/truck_class.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/responsive_text_custom_withmargin.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:fretego/classes/truck_class.dart';

class Page3Truck extends StatelessWidget {
  double heightPercent;
  double widthPercent;
  String uid;
  Page3Truck(this.heightPercent, this.widthPercent, this.uid);

  String truckSuggested;
  ScrollController _scrollController; //scroll screen to bottom

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MoveModel>(
        builder: (BuildContext context, Widget child, MoveModel moveModel){

          truckSuggested = TruckClass.empty().discoverTheBestTruck(moveModel.getTotalVolumeOfChart());
          _scrollController = ScrollController();

          return Container(
            width: widthPercent,
            height: heightPercent,
            color: Colors.white,
            child: Stack(
              children: [

                //modal sugerido e as opções
                Positioned(
                  top: heightPercent*0.26,
                  left: 0.5,
                  right: 0.5,
                  bottom: heightPercent*0.10,
                  child: ListView(
                    controller: _scrollController,
                    children: [

                      //WidgetsConstructor().makeText(moveModel.getItemsChartSize()!=1 ? "Sua mudança possui "+moveModel.getItemsChartSize().toString()+" itens." : "Sua mudança possui apenas "+moveModel.getItemsChartSize().toString()+" item.", Colors.black, 11.0, 5.0, 5.0, "center"),
                      //WidgetsConstructor().makeText("O volume da sua mudança é "+moveModel.getTotalVolumeOfChart().toStringAsFixed(2)+"m³.", Colors.black, 11.0, 00.0, 10.0, "center"),
                      Padding(
                          child: ResponsiveTextCustom('Modal sugerido', context, CustomColors.blue, 3.5, 10.0, 2.0, 'no'),
                          padding: EdgeInsets.only(left: 20.0)),
                      //banner com a sugestão
                      Padding(
                          child: Container(

                            width: widthPercent*0.7,
                            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 2.0),
                            child: Column(
                              children: [
                                ResponsiveTextCustomWithMargin(truckSuggested , context, Colors.black, 2.0, 5.0, 2.0, 5.0, 5.0,'center'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //primeira parte( a imagem selecionada e o nome em cima)
                                    Column(
                                      children: [

                                          Container(
                                            child:
                                            truckSuggested=='pickup pequena' ? Image.asset('images/itensselect/trucks/truck_pickupp.png', fit: BoxFit.fill,)
                                            : truckSuggested=='carroça' ? Image.asset('images/itensselect/trucks/truck_carroca.png', fit: BoxFit.fill,)
                                            : truckSuggested=='pickup grande' ? Image.asset('images/itensselect/trucks/truck_pickupg.png', fit: BoxFit.fill,)
                                            : truckSuggested=='kombi aberta' ? Image.asset('images/itensselect/trucks/truck_kombia.png', fit: BoxFit.fill,)
                                                : truckSuggested=='kombi fechada' ? Image.asset('images/itensselect/trucks/truck_kombi.png', fit: BoxFit.fill,)
                                                : truckSuggested=='caminhao aberto' ? Image.asset('images/itensselect/trucks/truck_aberto.png', fit: BoxFit.fill,)
                                                : truckSuggested=='caminhao baú pequeno' ? Image.asset('images/itensselect/trucks/truck_baup.png', fit: BoxFit.fill,)
                                                :  Image.asset('images/itensselect/trucks/truck_baug.png', fit: BoxFit.fill,),
                                            width: widthPercent*0.30,
                                            height: heightPercent*0.10,
                                            alignment: Alignment.center,
                                          )


                                      ],
                                    ),
                                    //segunda parte, com o texto explicativo.
                                    ResponsiveTextCustomWithMargin('Sugestão baseada no itens informados.\nAtente-se para a altura de alguns \nobjetos e as características do veículo.', context, Colors.black, 1.1, 20.0, 5.0, 5.0, 5.0, 'center'),

                                  ],
                                ),
                                //botao
                                Padding(
                                    padding: EdgeInsets.fromLTRB(widthPercent*0.20, 10.0, widthPercent*0.20, 10.0),
                                  child: Container(
                                    width: widthPercent*50,
                                    height: heightPercent*0.07,
                                    child: RaisedButton(
                                      color: CustomColors.blue,
                                      child: ResponsiveTextCustom('Aceitar sugestão', context, Colors.white, 2, 0.0, 0.0, 'center'),
                                      onPressed: (){

                                        if(truckSuggested=='pickup pequena'){
                                          moveModel.updateCarInMoveClass("pickupP");
                                        } else if(truckSuggested=='carroça'){
                                          moveModel.updateCarInMoveClass('carroca');
                                        } else if(truckSuggested=='pickup grande') {
                                          moveModel.updateCarInMoveClass("pickupG");
                                        } else if(truckSuggested=='kombi aberta') {
                                          moveModel.updateCarInMoveClass("kombiA");
                                        } else if(truckSuggested=='kombi fechada') {
                                          moveModel.updateCarInMoveClass("kombiF");
                                        } else if(truckSuggested=='caminhao pequeno aberto') {
                                          moveModel.updateCarInMoveClass("caminhaoPA");
                                        } else if(truckSuggested=='caminhao baú pequeno'){
                                          moveModel.updateCarInMoveClass("caminhaoBP");
                                        } else {
                                          moveModel.updateCarInMoveClass("caminhaoBG");
                                        }

                                        print('o carro selecionado é');
                                        print(moveModel.moveClass.carro);
                                        scrollToBottom();
                                      },
                                    ),
                                  ),
                                ),

                              ],
                            )
                          ),
                          padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 00.0)),
                      //lista de botões de carros
                      ResponsiveTextCustom('ou escolha abaixo', context, Colors.grey[400], 2, 5.0, 5.0, 'center'),
                      SizedBox(height: heightPercent*0.05,),
                      //linha 1 carroca, pickups
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          InkWell(
                            onTap: (){
                              moveModel.updateCarInMoveClass('carroca');
                              scrollToBottom();
                            },
                            child: Container(
                              height: heightPercent*0.15,
                              width: widthPercent*0.20,
                              child: Column(
                                children: [
                                  Container(
                                    width: widthPercent*0.20,
                                    height: heightPercent*0.05,
                                    child: Image.asset('images/itensselect/trucks/truck_carroca.png', fit: BoxFit.fill,),
                                  ),
                                  ResponsiveTextCustom('Carroça', context, CustomColors.blue, 1.5, 3.0, 3.0, 'center'),
                                  Container(
                                    decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 1.0, 4.0),
                                    child: ResponsiveTextCustom(MoveClass.empty().returnThePriceDiferenceWithNumberOnly(truckSuggested, 'carroça'), context, CustomColors.blue, 1.5, 5.0, 5.0, 'center'),
                                  )
                                ],
                              ),
                            ),
                          ),

                          InkWell(
                            onTap: (){
                              moveModel.updateCarInMoveClass('pickupP');
                              scrollToBottom();
                            },
                            child:
                            Container(
                            height: heightPercent*0.15,
                            width: widthPercent*0.20,
                            child: Column(
                              children: [

                                Container(
                                  width: widthPercent*0.20,
                                  height: heightPercent*0.05,
                                  child: Image.asset('images/itensselect/trucks/truck_pickupp.png', fit: BoxFit.fill,),
                                ),
                                ResponsiveTextCustom('Pickup peq', context, CustomColors.blue, 1.5, 3.0, 3.0, 'center'),
                                Container(
                                  decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 1.0, 4.0),
                                  child: ResponsiveTextCustom(MoveClass.empty().returnThePriceDiferenceWithNumberOnly(truckSuggested, 'pickup pequena'), context, CustomColors.blue, 1.5, 5.0, 5.0, 'center'),
                                )
                              ],
                            ),
                          ),
                          ),


                          InkWell(
                            onTap: (){
                              moveModel.updateCarInMoveClass('pickupG');
                              scrollToBottom();
                            },
                            child:
                            Container(
                            height: heightPercent*0.15,
                            width: widthPercent*0.20,
                            child: Column(
                              children: [

                                Container(
                                  width: widthPercent*0.20,
                                  height: heightPercent*0.05,
                                  child: Image.asset('images/itensselect/trucks/truck_pickupg.png', fit: BoxFit.fill,),
                                ),
                                ResponsiveTextCustom('Pickup G', context, CustomColors.blue, 1.5, 3.0, 3.0, 'center'),
                                Container(
                                  decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 1.0, 4.0),
                                  child: ResponsiveTextCustom(MoveClass.empty().returnThePriceDiferenceWithNumberOnly(truckSuggested, 'pickup grande'), context, CustomColors.blue, 1.5, 5.0, 5.0, 'center'),
                                )
                              ],
                            ),
                          ),
                          ),

                        ],
                      ),
                      SizedBox(height: heightPercent*0.07,),
                      //linha 2 kombis
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          InkWell(
                            onTap: (){
                              moveModel.updateCarInMoveClass('kombiF');
                              scrollToBottom();
                            },
                            child:
                            Container(
                            height: heightPercent*0.15,
                            width: widthPercent*0.20,
                            child: Column(
                              children: [

                                Container(
                                  width: widthPercent*0.20,
                                  height: heightPercent*0.05,
                                  child: Image.asset('images/itensselect/trucks/truck_kombi.png', fit: BoxFit.fill,),
                                ),

                                ResponsiveTextCustom('Kombi', context, CustomColors.blue, 1.5, 3.0, 3.0, 'center'),
                                Container(
                                  decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 1.0, 4.0),
                                  child: ResponsiveTextCustom(MoveClass.empty().returnThePriceDiferenceWithNumberOnly(truckSuggested, 'Kombi'), context, CustomColors.blue, 1.5, 5.0, 5.0, 'center'),
                                )
                              ],
                            ),
                          ),
                          ),

                          InkWell(
                            onTap: (){
                              moveModel.updateCarInMoveClass('kombiA');
                              scrollToBottom();
                            },
                            child:
                            Container(
                            height: heightPercent*0.15,
                            width: widthPercent*0.20,
                            child: Column(
                              children: [

                                Container(
                                  width: widthPercent*0.20,
                                  height: heightPercent*0.05,
                                  child: Image.asset('images/itensselect/trucks/truck_kombia.png', fit: BoxFit.fill,),
                                ),

                                ResponsiveTextCustom('Kombi aberta', context, CustomColors.blue, 1.3, 3.0, 3.0, 'center'),
                                Container(
                                  decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 1.0, 4.0),
                                  child: ResponsiveTextCustom(MoveClass.empty().returnThePriceDiferenceWithNumberOnly(truckSuggested, 'Kombi aberta'), context, CustomColors.blue, 1.5, 5.0, 5.0, 'center'),
                                )
                              ],
                            ),
                          ),
                          ),


                          InkWell(
                            onTap: (){
                              moveModel.updateCarInMoveClass('caminhaoBP');
                              scrollToBottom();
                            },
                            child:
                            Container(
                            height: heightPercent*0.15,
                            width: widthPercent*0.20,
                            child: Column(
                              children: [

                                Container(
                                  width: widthPercent*0.20,
                                  height: heightPercent*0.05,
                                  child: Image.asset('images/itensselect/trucks/truck_baup.png', fit: BoxFit.fill,),
                                ),

                                ResponsiveTextCustom('Baú peq', context, CustomColors.blue, 1.5, 3.0, 3.0, 'center'),
                                Container(
                                  decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 1.0, 4.0),
                                  child: ResponsiveTextCustom(MoveClass.empty().returnThePriceDiferenceWithNumberOnly(truckSuggested, 'caminhao baú pequeno'), context, CustomColors.blue, 1.5, 5.0, 5.0, 'center'),
                                )
                              ],
                            ),
                          ),
                          ),

                        ],
                      ),
                      SizedBox(height: heightPercent*0.07,),
                      //linha 3 caminhoes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [


                          InkWell(
                            onTap: (){
                              moveModel.updateCarInMoveClass('caminhaoBG');
                              scrollToBottom();
                            },
                            child:
                          Container(
                            height: heightPercent*0.15,
                            width: widthPercent*0.20,
                            child: Column(
                              children: [

                                Container(
                                  width: widthPercent*0.20,
                                  height: heightPercent*0.05,
                                  child: Image.asset('images/itensselect/trucks/truck_baug.png', fit: BoxFit.fill,),
                                ),

                                ResponsiveTextCustom('Baú grande', context, CustomColors.blue, 1.5, 3.0, 3.0, 'center'),
                                Container(
                                  decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 1.0, 4.0),
                                  child: ResponsiveTextCustom(MoveClass.empty().returnThePriceDiferenceWithNumberOnly(truckSuggested, 'caminhao bau aberto'), context, CustomColors.blue, 1.5, 5.0, 5.0, 'center'),
                                )
                              ],
                            ),
                          ),
                          ),

                          InkWell(
                            onTap: (){
                              moveModel.updateCarInMoveClass('caminhaoPA');
                              scrollToBottom();
                            },
                            child:
                          Container(
                            height: heightPercent*0.15,
                            width: widthPercent*0.20,
                            child: Column(
                              children: [

                                Container(
                                  width: widthPercent*0.20,
                                  height: heightPercent*0.05,
                                  child: Image.asset('images/itensselect/trucks/truck_aberto.png', fit: BoxFit.fill,),
                                ),

                                ResponsiveTextCustom('Peq aberto', context, CustomColors.blue, 1.5, 3.0, 3.0, 'center'),
                                Container(
                                  decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 1.0, 4.0),
                                  child: ResponsiveTextCustom(MoveClass.empty().returnThePriceDiferenceWithNumberOnly(truckSuggested, 'caminhao aberto'), context, CustomColors.blue, 1.5, 5.0, 5.0, 'center'),
                                )
                              ],
                            ),
                          ),
                          ),

                        ],
                      ),
                      SizedBox(height: heightPercent*0.05,),

                      //banner com o carro selecionado
                      Padding(
                          child: Container(

                              width: widthPercent*0.7,
                              decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 2.0),
                              child: Column(
                                children: [
                                  ResponsiveTextCustomWithMargin('Veículo selecionado' , context, Colors.black, 2.0, 5.0, 2.0, 5.0, 5.0,'center'),
                                  ResponsiveTextCustomWithMargin(moveModel.moveClass.carro == null ? '' : TruckClass.empty().formatCodeToHumanName(moveModel.moveClass.carro) , context, CustomColors.blue, 2.0, 10.0, 2.0, 5.0, 5.0,'center'),
                                  Container(
                                    child:
                                    moveModel.carInMoveClass == null ? ResponsiveTextCustomWithMargin('Não selecionado' , context, Colors.black, 1.5, 10.0, 2.0, 5.0, 5.0,'center')
                                        : moveModel.carInMoveClass=='pickupP' ? Image.asset('images/itensselect/trucks/truck_pickupp.png', fit: BoxFit.fill,)
                                        : moveModel.carInMoveClass=='carroca' ? Image.asset('images/itensselect/trucks/truck_carroca.png', fit: BoxFit.fill,)
                                        : moveModel.carInMoveClass=='pickupG' ? Image.asset('images/itensselect/trucks/truck_pickupg.png', fit: BoxFit.fill,)
                                        : moveModel.carInMoveClass=='kombiA' ? Image.asset('images/itensselect/trucks/truck_kombia.png', fit: BoxFit.fill,)
                                        : moveModel.carInMoveClass=='kombiF' ? Image.asset('images/itensselect/trucks/truck_kombi.png', fit: BoxFit.fill,)
                                        : moveModel.carInMoveClass=='caminhaoPA' ? Image.asset('images/itensselect/trucks/truck_aberto.png', fit: BoxFit.fill,)
                                        : moveModel.carInMoveClass=='caminhaoBP' ? Image.asset('images/itensselect/trucks/truck_baup.png', fit: BoxFit.fill,)
                                        :  Image.asset('images/itensselect/trucks/truck_baug.png', fit: BoxFit.fill,),
                                    width: widthPercent*0.30,
                                    height: heightPercent*0.10,
                                    alignment: Alignment.center,
                                  ),

                                  /*
                                  //botao
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(widthPercent*0.20, 10.0, widthPercent*0.20, 10.0),
                                    child: Container(
                                      width: widthPercent*50,
                                      height: heightPercent*0.07,
                                      child: RaisedButton(
                                        color: CustomColors.blue,
                                        child: ResponsiveTextCustom('Aceitar sugestão', context, Colors.white, 2, 0.0, 0.0, 'center'),
                                        onPressed: (){

                                          if(truckSuggested=='pickup pequena'){
                                            moveModel.moveClass.carro="pickupP";
                                          } else if(truckSuggested=='carroça'){
                                            moveModel.moveClass.carro='carroca';
                                          } else if(truckSuggested=='pickup grande') {
                                            moveModel.moveClass.carro="pickupG";
                                          } else if(truckSuggested=='kombi aberta') {
                                            moveModel.moveClass.carro="kombiA";
                                          } else if(truckSuggested=='kombi fechada') {
                                            moveModel.moveClass.carro="kombiF";
                                          } else if(truckSuggested=='caminhao pequeno aberto') {
                                            moveModel.moveClass.carro="caminhaoPA";
                                          } else if(truckSuggested=='caminhao baú pequeno'){
                                            moveModel.moveClass.carro= "caminhaoBP";
                                          } else {
                                            moveModel.moveClass.carro= "caminhaoBG";
                                          }

                                          print('o carro selecionado é');
                                          print(moveModel.moveClass.carro);
                                        },
                                      ),
                                    ),
                                  ),
                                   */
                                ],
                              )
                          ),
                          padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 00.0)),
                      SizedBox(height: 40.0,),

                    ],
                  ),

                ),


              ],
            ),
          );
    },
    );
  }

  void scrollToBottom() {
    double bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      bottomOffset,
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }


}


