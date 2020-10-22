import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/item_class.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/classes/truck_class.dart';
import 'package:fretego/models/selected_items_chart_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/services/distance_latlong_calculation.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:convert';
import 'package:geocoder/geocoder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_page.dart';

class SelectItensPage extends StatefulWidget {
  @override
  _SelectItensPageState createState() => _SelectItensPageState();
}

class _SelectItensPageState extends State<SelectItensPage> {

  //variaveis da busca
  TextEditingController _searchController = TextEditingController();
  String _filter;

  //fim das variaveis da busca

  int selectedOfSameItens=0;
  var myData;
  int selectedIndex;

  bool showPopUpQuant=false;

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  ScrollController _scrollController; //scroll screen to bottom

  bool isLoading=false;

  bool showSelectItemPage=true;
  bool showCustomItemPage=false;
  bool showSelectTruckPage=false;
  bool showAddressesPage=false;
  bool showSchedulePage=false;

  bool showPopupFinal = false;

  int helpersContracted = 1;
  bool editingHelpers=false;

  MoveClass moveClass = MoveClass();

  TextEditingController _sourceAdress = TextEditingController();
  TextEditingController _destinyAdress = TextEditingController();
  TextEditingController _destinyAdressNumber = TextEditingController();
  TextEditingController _destinyAdressComplement = TextEditingController();
  TextEditingController _sourceAdressNumber = TextEditingController();
  TextEditingController _sourceAdressComplement = TextEditingController();
  String origemAddressVerified ="";
  String destinyAddressVerified="";
  bool _searchCEP=false;

  TextEditingController _dateController = TextEditingController();

  double custoAjudantes=0.0;
  double custoFrete=0.0;

  double precoCadaAjudante=0.0;
  double precoGasolina=0.0;
  double precoBaseFreteiro=0.0;

  double finalGasCosts=0.00;
  double distance=0.0;
  double totalExtraProducts = 0.00;

  bool showResume=false;

  String carSelected="nao";


  @override
  void initState() {
    super.initState();

    /*
    somente para testes
     */
    setState(() {
      showSelectItemPage=false;
      showSchedulePage=true;
      carSelected="kombiA";
      moveClass.carro="kombiA";
    });


    //listener da busca
    _searchController.addListener(() {
      setState(() {
        _filter = _searchController.text.toLowerCase(); //a cada clique atualiza
      });
    });

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return
      showSelectItemPage==true ? selectItemsPage()
      : showCustomItemPage==true ? customItemPage()
      : showSelectTruckPage==true ? selectTruckPage()
      : showAddressesPage==true ?  selectAdressPage()
      : showSchedulePage==true ? schedulePage()
          : Container();

    /*
    return  showCustomItemPage==false && showSelectTruckPage==false
        ? selectItemsPage() :
        showCustomItemPage==true ? customItemPage() : selectTruckPage();

     */
  }

  Widget selectItemsPage (){

    double heightPercent = MediaQuery
        .of(context)
        .size
        .height;
    double widthPercent = MediaQuery
        .of(context)
        .size
        .width;

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        return ScopedModelDescendant<SelectedItemsChartModel>(
          builder: (BuildContext context, Widget child, SelectedItemsChartModel selectedItemsChartModel){
            return Scaffold(
                key: _scaffoldKey,
                floatingActionButton: FloatingActionButton(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.navigate_next, size: 50.0,),
                    onPressed: () {

                      if(selectedItemsChartModel.getItemsChartSize()!=0){
                        setState(() {
                          //update the moveClass for the firstTime
                          moveClass.itemsSelectedCart = selectedItemsChartModel.itemsSelectedCart;
                          //exibe a proxima página
                          showSelectItemPage=false;
                          showCustomItemPage=true;
                        });
                      } else {
                        _displaySnackBar(context, "Você não selecionou nada para a mudança");
                      }

                    }),
                appBar: AppBar(title: WidgetsConstructor().makeSimpleText(
                    "Itens grandes da mudança", Colors.white, 12.0),
                  backgroundColor: Colors.blue,
                  centerTitle: true,
                  automaticallyImplyLeading: true,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white,),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },),

                ),
                body: Stack(
                  children: [
                    ListView(
                      children: [

                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Container(
                            height: 60.0,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(suffixIcon: Icon(
                                  Icons.search),),
                            ),
                          ),
                        ), //editText de busca

                        FutureBuilder(
                          future: DefaultAssetBundle.of(context).loadString(
                              'loadjson/itens.json'),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator(),);
                            }
                            myData = json.decode(snapshot.data);
                            print(myData);

                            return ListView.builder(
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return _filter == null || _filter == ""
                                    ? InkWell(
                                  onTap: (){
                                    setState(() {
                                      selectedIndex = index;
                                      showPopUpQuant=true;
                                    });

                                  },
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
                                    child: Container(
                                      height: 100.0,
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 5.0, 0.0, 5.0),
                                        child: Row(
                                          children: [
                                            SizedBox(width: widthPercent * 0.03,),
                                            //Image.network(myData[index]['image'],),
                                            Image.asset(myData[index]['image']),
                                            SizedBox(width: widthPercent * 0.03,),
                                            Text(myData[index]["name"]),
                                          ],
                                        ),
                                      ),
                                      decoration: WidgetsConstructor()
                                          .myBoxDecoration(
                                          Colors.white, Colors.blue, 1.0, 5.0),
                                    ),
                                  ),
                                ) //card com resultado se não tiver filtro
                                    : myData[index]['name'].toString().toLowerCase().contains(_filter)
                                    ? InkWell(
                                  onTap: (){
                                    setState(() {
                                      selectedIndex = index;
                                      showPopUpQuant=true;
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
                                    child: Container(
                                      height: 100.0,
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 5.0, 0.0, 5.0),
                                        child: Row(
                                          children: [
                                            SizedBox(width: widthPercent * 0.03,),
                                            //Image.network(myData[index]['image'],),
                                            Image.asset(myData[index]['image']),
                                            SizedBox(width: widthPercent * 0.03,),
                                            Text(myData[index]["name"]),
                                          ],
                                        ),
                                      ),
                                      decoration: WidgetsConstructor()
                                          .myBoxDecoration(
                                          Colors.white, Colors.blue, 1.0, 5.0),
                                    ),
                                  ),
                                ) //card com resultado com filtro
                                    : Container(); //card caso nao tenha nada para exibir por causa do filtro


                                return Container(
                                    height: 100.0,
                                    child: Text(myData[index]["name"])
                                );
                              },
                              //itemCount: myData == null ? 0 : myData.length,
                              itemCount: myData == null ? 0 : 2,

                            );
                          },
                        ),

                      ],
                    ),

                    Positioned(
                      bottom: 10.0,
                      left: 5.0,
                      right: 80.0,
                      child: bottomCard(widthPercent, heightPercent),
                    ),

                    showPopUpQuant == true ? popUpSelectItemQuantity(selectedIndex, heightPercent, widthPercent): Container(),

                    isLoading == true
                        ? Center(
                      child: CircularProgressIndicator(),
                    ): Container(),

                  ],
                )
            );
          },
        );
      },
    );
  }

  Widget customItemPage(){

    TextEditingController _psController = TextEditingController();
    TextEditingController _qntLancesEscadaController = TextEditingController();

    bool _escadaCheckBoxvar=false;

    //verifica para lembrar a opção que o user deixou
    if(moveClass.escada!=null){
      _escadaCheckBoxvar=true;
      if(moveClass.lancesEscada!=null){
        _qntLancesEscadaController.text = moveClass.lancesEscada.toString();
      }
    } else {
      _escadaCheckBoxvar=false;
    }

    double heightPercent = MediaQuery
        .of(context)
        .size
        .height;
    double widthPercent = MediaQuery
        .of(context)
        .size
        .width;

    _qntLancesEscadaController.addListener(() {
      moveClass.lancesEscada= int.parse(_qntLancesEscadaController.text);
    });

    _psController.addListener(() {
      moveClass.ps = _psController.text;
    });

    _psController.text = moveClass.ps;

    return ScopedModelDescendant<SelectedItemsChartModel>(
      builder: (BuildContext context, Widget widget, SelectedItemsChartModel selectedItemsChartModel){
        return Scaffold(
          key: _scaffoldKey,
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.blue,
                child: Icon(Icons.navigate_next, size: 50.0,),
                onPressed: () {

                  setState(() {

                    if(moveClass.escada==true && _qntLancesEscadaController.text.isEmpty){
                      _displaySnackBar(context, "Você informou ter escada mas não definiu a quantidade de lances.");
                    } else {
                      if(_psController.text.isEmpty){
                        moveClass.ps = "nao";
                      } else {
                        moveClass.ps = _psController.text;
                      }
                      showCustomItemPage=false;
                      showSelectTruckPage=true;

                    }

                  });

                }),
            body: ListView(
              children: [
                Stack(
                  children: [
                    //toda a página
                    Container(
                      color: Colors.white,
                      height: heightPercent,
                      width: widthPercent,
                      child: Column(
                        children: [
                          //barra superior
                          topCustomBar(heightPercent, widthPercent, "Detalhamento", 1),
                          SizedBox(height: 40.0,),

                          //Texto titulo
                          Container(
                            width: widthPercent*0.7,
                            child: WidgetsConstructor().makeText("Características do local", Colors.black, 20.0, 10.0, 30.0, "center"),
                          ),
                          //checkbox escada
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              WidgetsConstructor().makeText("Lances de escada", Colors.black, 16.0, 0.0, 0.0, "center"),

                              Checkbox(
                                  value: _escadaCheckBoxvar,
                                  onChanged: (bool value){
                                    setState(() {
                                      if(value==true){
                                        moveClass.escada=true;
                                      } else {
                                        moveClass.escada=null;
                                      }
                                      _escadaCheckBoxvar = value;

                                    });
                                  }
                              ),
                            ],
                          ),
                          //linha para dizer quantos lances
                          moveClass.escada!= null ? Container(
                            width: widthPercent*0.8,
                            child: WidgetsConstructor().makeEditTextNumberOnly(_qntLancesEscadaController, "Quantos lances de escada"),
                          ) : Container(),


                          SizedBox(height: 40.0,),
                          //texto
                          Container(
                            width: widthPercent*0.7,
                            child: WidgetsConstructor().makeText("Alguma observação?", Colors.black, 20.0, 10.0, 30.0, "center"),
                          ),
                          //textField para escrever uma obs
                          Container(
                            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 1.0, 4.0),
                            height: heightPercent*0.25,
                            width: widthPercent*0.85,
                            child: TextField(
                              controller: _psController,
                              decoration: new InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                                  hintText: 'Sua observação aqui'
                              ),
                            ),
                          ),
                          SizedBox(height: 80.0,),
                          //botão de continuar
                          /*
                          GestureDetector(
                            onTap: (){
                              setState(() {

                                if(moveClass.escada==true && _qntLancesEscadaController.text.isEmpty){
                                  _displaySnackBar(context, "Você informou ter escada mas não definiu a quantidade de lances.");
                                } else {

                                  showCustomItemPage=false;
                                  showSelectTruckPage=true;

                                  if(_psController.text.isEmpty){
                                    moveClass.ps = "nao";
                                  } else {
                                    moveClass.ps = _psController.text;
                                  }

                                }


                              });

                            },
                            child: WidgetsConstructor().makeButton(Colors.blue, Colors.transparent, widthPercent*0.85, heightPercent*0.08,
                                2.0, 4.0, "Continuar", Colors.white, 18.0),
                          )

                           */

                        ],
                      ),
                    ),


                    //barra inferior
                    Positioned(
                      bottom: 10.0,
                      left: 5.0,
                      right: 80.0,
                      child: bottomCard(widthPercent, heightPercent),
                    )
                  ],
                )
              ],
            )
        );
      },
    );
  }

  Widget selectTruckPage(){

    double heightPercent = MediaQuery
        .of(context)
        .size
        .height;
    double widthPercent = MediaQuery
        .of(context)
        .size
        .width;


    //ajusta para a ultima seleção do usuário

    return Scaffold(
      key: _scaffoldKey,
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue,
            child: Icon(Icons.navigate_next, size: 50.0,),
            onPressed: () {

              setState(() {

                if(carSelected!="nao"){
                  //ajusta a quantidade de ajudantes desta mudança
                  moveClass.ajudantes = helpersContracted;

                  moveClass.carro = carSelected;

                  showSelectTruckPage=false;
                  showAddressesPage=true;


                } else {
                  _displaySnackBar(context, "Selecione o tipo de veículo para o frete antes.");
                }
              });

            }),
        body: ListView(
          controller: _scrollController,
          children: [
              Container(
                color: Colors.white,
                child: ScopedModelDescendant<SelectedItemsChartModel>(
                  builder: (BuildContext context, Widget widget, SelectedItemsChartModel selectedItemsChartModel){
                    int helpersNeeded = selectedItemsChartModel.needHelper()==true ? 2 : 1; //quantidade minima de ajudantes
                    if(editingHelpers==false){
                      helpersContracted = helpersNeeded;
                    } else {
                      //nao mexer
                    }

                    return Column(
                      children: [
                        topCustomBar(heightPercent, widthPercent, "Selecionar caminhão", 2),
                        //text que exibe a quantidade de items na mudança
                        WidgetsConstructor().makeText(selectedItemsChartModel.getItemsChartSize()!=1 ? "Sua mudança possui "+selectedItemsChartModel.getItemsChartSize().toString()+" itens." : "Sua mudança possui apenas "+selectedItemsChartModel.getItemsChartSize().toString()+" item.", Colors.black, 15.0, 10.0, 10.0, "center"),

                        //text que exibe o volume da mudança
                        //WidgetsConstructor().makeText(selectedItemsChartModel.getTotalVolumeOfChart()<10.00 ? "O volume da mudança é "+selectedItemsChartModel.getTotalVolumeOfChart().toStringAsFixed(2)+"m³. Você não precisa de um caminhão baú para esta quantidade." : "O volume da mudança é "+selectedItemsChartModel.getTotalVolumeOfChart().toStringAsPrecision(7)+". Recomendamos um caminhão estilo baú." , Colors.black, 15.0, 10.0, 20.0, "center"),
                        WidgetsConstructor().makeText("O volume da sua mudança é "+selectedItemsChartModel.getTotalVolumeOfChart().toStringAsFixed(2)+"m³.", Colors.black, 15.0, 10.0, 20.0, "center"),

                        WidgetsConstructor().makeText("De acordo com as informações que você disponibilizou a melhor opção de frete para você é: "+TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart()), Colors.blue, 15.0, 10.0, 20.0, "center"),
                        TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart()) == "carroça" ? WidgetsConstructor().makeText("Obs: Considere a distância antes de optar pela carroça manual.", Colors.red, 14.0, 10.0, 10.0, "center") : Container(),
                        SizedBox(height: 20.0,),
                        //button to acept suggestion of best truck choice
                        GestureDetector(
                          child: WidgetsConstructor().makeButton(Colors.blueAccent, Colors.blueAccent, widthPercent*0.65, 50.0, 0.0, 4.0, "Aceitar sugestão", Colors.white, 16.0),
                          onTap: (){

                            setState(() {
                              if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="pickup pequena"){
                                carSelected="pickupP";
                              } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="carroça"){
                                carSelected="carroca";
                              } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="pickup grande"){
                                carSelected="pickupG";
                              } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="kombi aberta"){
                                carSelected="kombiA";
                              } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="kombi fechada"){
                                carSelected="kombiF";
                              } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="caminhao pequeno aberto"){
                                carSelected="caminhaoPA";
                              } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="caminhao baú pequeno") {
                                carSelected = "caminhaoBP";
                              } else {
                                carSelected = "caminhaoBG";
                              }
                              scrollToBottom();
                            });


                            },
                        ),
                        SizedBox(height: 30.0,),


                        //lista de botoes dos caminhoes
                        SizedBox(height: 40.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  carSelected = "carroca";
                                  scrollToBottom();
                                });
                              },
                              //color: carSelected=="carroca" ? Colors.red : Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(height: 50.0, width: widthPercent*0.25, child: Image.asset("images/carrinhobaby.jpg"),),
                                  WidgetsConstructor().makeSimpleText("Carroça (sem motor)", Colors.blue, 15.0)
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  carSelected = "pickupP";
                                  scrollToBottom();
                                });

                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(height: 50.0, width: widthPercent*0.25, child: Image.asset("images/carrinhobaby.jpg"),),
                                  WidgetsConstructor().makeSimpleText("Pickup pequena", Colors.blue, 15.0)
                                ],
                              ),
                            )


                          ],
                        ), //primeira linha dos caminhoes para escolher
                        SizedBox(height: 30.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  carSelected = "pickupG";
                                  scrollToBottom();
                                });

                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(height: 50.0, width: widthPercent*0.25, child: Image.asset("images/carrinhobaby.jpg"),),
                                  WidgetsConstructor().makeSimpleText("Pickup grande", Colors.blue, 15.0)
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  carSelected = "kombiA";
                                  scrollToBottom();
                                });

                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(height: 50.0, width: widthPercent*0.25, child: Image.asset("images/carrinhobaby.jpg"),),
                                  WidgetsConstructor().makeSimpleText("Kombi aberta", Colors.blue, 15.0)
                                ],
                              ),
                            )


                          ],
                        ), //primeira linha dos caminhoes para escolher
                        SizedBox(height: 30.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  carSelected = "caminhaoPA";
                                  scrollToBottom();
                                });

                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(height: 50.0, width: widthPercent*0.25, child: Image.asset("images/carrinhobaby.jpg"),),
                                  WidgetsConstructor().makeSimpleText("Caminhão pequeno aberto", Colors.blue, 15.0)
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  carSelected = "kombiF";
                                  scrollToBottom();
                                });

                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(height: 50.0, width: widthPercent*0.25, child: Image.asset("images/carrinhobaby.jpg"),),
                                  WidgetsConstructor().makeSimpleText("Kombi fechada", Colors.blue, 15.0)
                                ],
                              ),
                            )

                          ],
                        ), //segunda linha dos caminhoes para escolher
                        SizedBox(height: 30.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  carSelected = "caminhaoBP";
                                  scrollToBottom();
                                });

                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(height: 50.0, width: widthPercent*0.25, child: Image.asset("images/carrinhobaby.jpg"),),
                                  WidgetsConstructor().makeSimpleText("Caminhão baú pequeno", Colors.blue, 15.0)
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  carSelected = "caminhaoBG";
                                  scrollToBottom();
                                });

                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(height: 50.0, width: widthPercent*0.25, child: Image.asset("images/carrinhobaby.jpg"),),
                                  WidgetsConstructor().makeSimpleText("Caminhão baú grande", Colors.blue, 15.0)
                                ],
                              ),
                            )


                          ],
                        ), //terceira linha dos caminhoes para escolher
                        SizedBox(height: 100.0,),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: WidgetsConstructor().makeText("Veículo selecionado: "+TruckClass.empty().formatCodeToHumanName(carSelected), Colors.blue, 18.0, 10.0, 30.0, null),
                        ),


                        //box dos ajudantes
                        Container(
                          decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 5.0),
                          height: heightPercent*0.35,
                          width: widthPercent*0.9,
                          child: Column(
                            children: [
                              WidgetsConstructor().makeText("Ajudantes", Colors.blue, 18.0, 10.0, 30.0, "center"),
                              Padding(
                                padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                child: Row(
                                  children: [
                                    WidgetsConstructor().makeText("Nº ajudantes: ", Colors.blue, 15.0, 10.0, 10.0, null),
                                    SizedBox(width: 5.0,),
                                    WidgetsConstructor().makeText(helpersContracted.toString(), Colors.blue, 17.0, 10.0, 10.0, null),
                                    SizedBox(width: 15.0,),
                                    GestureDetector(
                                      onTap: (){
                                        if(helpersContracted!=helpersNeeded){
                                          setState(() {
                                            editingHelpers=true;
                                            helpersContracted--;
                                          });
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: helpersContracted==helpersNeeded || helpersContracted==1 ? Colors.grey : Colors.blue),
                                        child: Icon(Icons.exposure_neg_1, color: Colors.white, size: 35.0),
                                      ),
                                    ),
                                    SizedBox(width: 30.0,),
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          editingHelpers=true;
                                          helpersContracted++;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                                        child: Icon(Icons.plus_one, color: Colors.white, size: 35.0),
                                      ),
                                    ), //botao com click para adicionar +
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(15.0),
                                child: WidgetsConstructor().makeText(helpersNeeded!=1 ? "Pelo menos dois ajudantes devido ao volume de alguns itens que não podem ser carregados por uma única pessoa." : "1 ajudante é suficiente de acordo com os itens escolhidos.", Colors.redAccent, 12.0, 20.0, 0.0, "center"),
                              ),

                            ],
                          ),
                        ), //caixinha de seleção de ajudantes

                        SizedBox(height: 30.0,),

                        //button to advance
                        GestureDetector(
                          onTap: (){
                            setState(() {

                              if(carSelected!="nao"){
                                //ajusta a quantidade de ajudantes desta mudança
                                moveClass.ajudantes=helpersContracted;

                                moveClass.carro = carSelected;

                                showSelectTruckPage=false;
                                showAddressesPage=true;
                              } else {
                                _displaySnackBar(context, "Selecione o tipo de veículo para o frete");
                              }

                            });

                          },
                          child: WidgetsConstructor().makeButton(Colors.blue, Colors.transparent, widthPercent*0.85, heightPercent*0.08,
                              2.0, 4.0, "Continuar", Colors.white, 18.0),
                        )

                      ],
                    );
                  }

                ),
              )
          ],
        ),
    );

  }

  Widget selectAdressPage() {

    double heightPercent = MediaQuery
        .of(context)
        .size
        .height;
    double widthPercent = MediaQuery
        .of(context)
        .size
        .width;

    loadDataFromDb();

    return Scaffold(
      key: _scaffoldKey,

      body: ListView(
        controller: _scrollController,
        children: [
          Container(
            color: Colors.white,
            child: ScopedModelDescendant<SelectedItemsChartModel>(
                builder: (BuildContext context, Widget widget, SelectedItemsChartModel selectedItemsChartModel){

                  return Stack(
                    children: [
                      Column(
                        children: [
                          //fake superior bar
                          topCustomBar(heightPercent, widthPercent, "Detalhar agendamento", 3),
                          SizedBox(height: 40.0,),
                          //box with the address search engine
                          Container(
                              width: widthPercent*0.90,
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
                                    _searchCEP == true ? WidgetsConstructor().makeSimpleText("Digíte o CEP somente com números", Colors.blue, 12.0) : Container(),
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

                                            //remove the focus to close the keyboard
                                            FocusScopeNode currentFocus = FocusScope.of(context);
                                            if (!currentFocus.hasPrimaryFocus) {
                                              currentFocus.unfocus();
                                            }

                                            if(_sourceAdress.text.isNotEmpty){

                                              //if the user meant to search by CEP
                                              if(_searchCEP==true && _sourceAdress.text.length==8){
                                                if(isNumeric(_sourceAdress.text)){
                                                  findAddress(_sourceAdress, "origem");
                                                } else {
                                                  _displaySnackBar(context, "O CEP deve conter apenas números e possuí 8 dígitos");
                                                }
                                              } else {
                                                //if the user meant to search by adress name
                                                if(_sourceAdress.text.contains("0") || _sourceAdress.text.contains("1") || _sourceAdress.text.contains("2") || _sourceAdress.text.contains("3") || _sourceAdress.text.contains("4") || _sourceAdress.text.contains("5") || _sourceAdress.text.contains("6") || _sourceAdress.text.contains("7") || _sourceAdress.text.contains("8") || _sourceAdress.text.contains("9") ){
                                                  findAddress(_sourceAdress, "origem");
                                                } else {
                                                  _displaySnackBar(context, "Informe o número da residência");
                                                }
                                              }

                                            }
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
                                    _searchCEP == true ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:  BorderRadius.all(Radius.circular(4.0)),),
                                          width: widthPercent*0.20,
                                          child: TextField(
                                              controller: _sourceAdressNumber,
                                              decoration: InputDecoration(hintText: " Nº",
                                                border: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                disabledBorder: InputBorder.none,
                                                contentPadding:
                                                EdgeInsets.only(left: 5, bottom: 5, top: 5, right: 5),),
                                              keyboardType: TextInputType.number
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:  BorderRadius.all(Radius.circular(4.0)),),
                                          width: widthPercent*0.50,
                                          child: TextField(
                                            controller: _sourceAdressComplement,
                                            decoration: InputDecoration(hintText: " Complemento",
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              contentPadding:
                                              EdgeInsets.only(left: 5, bottom: 5, top: 5, right: 5),),

                                          ),
                                        ),
                                        /*
                                  WidgetsConstructor().makeEditTextNumberOnly(_sourceAdressNumber, "Nº"),
                                  WidgetsConstructor().makeEditTextNumberOnly(_sourceAdressComplement, "Complemento"),

                                   */
                                      ],
                                    ) : Container(),
                                    //text informing user that address was found
                                    origemAddressVerified != "" ? WidgetsConstructor().makeText("Endereço localizado", Colors.blue, 15.0, 10.0, 5.0, "center") : Container(),
                                    //address found
                                    origemAddressVerified != "" ? WidgetsConstructor().makeText(origemAddressVerified, Colors.black, 12.0, 5.0, 10.0, "center") : Container(),
                                    SizedBox(height: 20.0,),
                                    //second searchbox of destiny address
                                    origemAddressVerified != "" ? Row(
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

                                            //remove the focus to close the keyboard
                                            FocusScopeNode currentFocus = FocusScope.of(context);
                                            if (!currentFocus.hasPrimaryFocus) {
                                              currentFocus.unfocus();
                                            }

                                            if(_destinyAdress.text.isNotEmpty){

                                              if(_searchCEP==true && _sourceAdress.text.length==8){

                                                if(isNumeric(_destinyAdress.text)) {
                                                  findAddress(_destinyAdress, "destiny");
                                                  //scroll down to end of screen
                                                  final bottomOffset = _scrollController.position.maxScrollExtent;
                                                  scrollToBottom();
                                                } else {
                                                  _displaySnackBar(context, "O CEP deve ter apenas números");
                                                }

                                              } else {

                                                if(_destinyAdress.text.contains("0") || _destinyAdress.text.contains("1") || _destinyAdress.text.contains("2") || _destinyAdress.text.contains("3") || _destinyAdress.text.contains("4") || _destinyAdress.text.contains("5") || _destinyAdress.text.contains("6") || _destinyAdress.text.contains("7") || _destinyAdress.text.contains("8") || _destinyAdress.text.contains("9") ){
                                                  findAddress(_destinyAdress, "destiny");
                                                } else {
                                                  _displaySnackBar(context, "Informe o número da residência do destino");
                                                }

                                              }

                                            }
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
                                    //second Row with the number and complementing textfields for destiny address
                                    origemAddressVerified != "" && _searchCEP == true ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:  BorderRadius.all(Radius.circular(4.0)),),
                                          width: widthPercent*0.20,
                                          child: TextField(
                                              controller: _destinyAdressNumber,
                                              decoration: InputDecoration(hintText: " Nº",
                                                border: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                disabledBorder: InputBorder.none,
                                                contentPadding:
                                                EdgeInsets.only(left: 5, bottom: 5, top: 5, right: 5),),
                                              keyboardType: TextInputType.number
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:  BorderRadius.all(Radius.circular(4.0)),),
                                          width: widthPercent*0.50,
                                          child: TextField(
                                            controller: _destinyAdressComplement,
                                            decoration: InputDecoration(hintText: " Complemento",
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              contentPadding:
                                              EdgeInsets.only(left: 5, bottom: 5, top: 5, right: 5),),

                                          ),
                                        ),
                                        /*
                                  WidgetsConstructor().makeEditTextNumberOnly(_sourceAdressNumber, "Nº"),
                                  WidgetsConstructor().makeEditTextNumberOnly(_sourceAdressComplement, "Complemento"),

                                   */
                                      ],
                                    ) : Container(),
                                    //text informing user that the address of destiny was found
                                    destinyAddressVerified != "" ? WidgetsConstructor().makeText("Destino localizado", Colors.blue, 15.0, 10.0, 5.0, "center") : Container(),
                                    //address found
                                    destinyAddressVerified != "" ? WidgetsConstructor().makeText(destinyAddressVerified, Colors.black, 12.0, 5.0, 10.0, "center") : Container(),
                                    SizedBox(height: 20.0,),
                                  ],
                                ),
                              )
                          ) ,
                          SizedBox(height: 30.0,),
                          //button to include address
                          _searchCEP== false && origemAddressVerified != "" && destinyAddressVerified != "" || _searchCEP== true && origemAddressVerified !="" && destinyAddressVerified != "" && _sourceAdressNumber.text.isNotEmpty && _destinyAdressNumber.text.isNotEmpty
                              ? GestureDetector(
                            child: WidgetsConstructor().makeButton(Colors.blue, Colors.blue, widthPercent*0.8, 50.0, 0.0, 4.0, "Incluir endereços", Colors.white, 20.0),
                            onTap: () async {

                              waitAmoment(3);
                              //o endereço é colocado logo para n precisa esperar o assyncrono
                              moveClass = await MoveClass().getTheCoordinates(moveClass, origemAddressVerified, destinyAddressVerified);
                              setState(() {
                                moveClass.enderecoOrigem = origemAddressVerified;
                                moveClass.enderecoDestino = destinyAddressVerified;
                              });

                              calculateThePrice();

                              scrollToBottom();



                            },
                          ) : Container(),
                          SizedBox(height: 30.0,),

                          //Box com o resumo do preço
                          //moveClass.enderecoOrigem != null && _searchCEP== false && origemAddressVerified != "" && destinyAddressVerified != "" || _searchCEP== true && origemAddressVerified !="" && destinyAddressVerified != "" && _sourceAdressNumber.text.isNotEmpty && _destinyAdressNumber.text.isNotEmpty ?
                          moveClass.enderecoOrigem != null && _searchCEP== false && origemAddressVerified != "" && destinyAddressVerified != "" || moveClass.enderecoOrigem != null && _searchCEP== true && origemAddressVerified !="" && destinyAddressVerified != "" && _sourceAdressNumber.text.isNotEmpty && _destinyAdressNumber.text.isNotEmpty ?
                          Container(
                            width: widthPercent*0.9,
                            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 3.0, 4.0),
                            child: Column(
                              children: [
                                WidgetsConstructor().makeText("Resumo e orçamento", Colors.blue, 18.0, 10.0, 10.0, "center"),

                                //endereços e distancia
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      WidgetsConstructor().makeText("Endereço de origem: "+origemAddressVerified, Colors.black, 15.0, 0.0, 5.0, null),
                                      SizedBox(height: 20.0,),
                                      WidgetsConstructor().makeText("Endereço de destino: "+destinyAddressVerified, Colors.black, 15.0, 0.0, 5.0, null),
                                      SizedBox(height: 20.0,),
                                      WidgetsConstructor().makeText("Distância: "+distance.toStringAsFixed(2)+"km", Colors.black, 15.0, 0.0, 5.0, null),
                                      SizedBox(height: 20.0,),
                                      WidgetsConstructor().makeText("Custos ", Colors.blue, 15.0, 0.0, 5.0, "center"),
                                    ],
                                  ),
                                ),
                                //linha da gasolina
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      WidgetsConstructor().makeText("Combustível", Colors.black, 14.0, 15.0, 5.0, null),
                                      WidgetsConstructor().makeText(finalGasCosts.toStringAsFixed(2), Colors.black, 14.0, 15.0, 5.0, null),
                                    ],
                                ),
                                SizedBox(height: 5.0,),
                                //linha ajudantes
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    WidgetsConstructor().makeText("Ajudantes", Colors.black, 14.0, 15.0, 5.0, null),
                                    WidgetsConstructor().makeText(custoAjudantes.toStringAsFixed(2), Colors.black, 14.0, 15.0, 5.0, null),
                                  ],
                                ),
                                SizedBox(height: 5.0,),
                                //linha custo veiculo
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    WidgetsConstructor().makeText("Veículo", Colors.black, 14.0, 15.0, 5.0, null),
                                    WidgetsConstructor().makeText((precoBaseFreteiro+moveClass.giveMeThePriceOfEachvehicle(moveClass.carro)).toStringAsFixed(2), Colors.black, 14.0, 15.0, 5.0, null),
                                  ],
                                ),
                                SizedBox(height: 5.0,),
                                //linha custo móveis
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    WidgetsConstructor().makeText("Móveis", Colors.black, 14.0, 15.0, 5.0, null),
                                    WidgetsConstructor().makeText(totalExtraProducts.toStringAsFixed(2), Colors.black, 14.0, 15.0, 5.0, null),
                                  ],
                                ),
                                SizedBox(height: 5.0,),
                                //linha custo por andar
                                moveClass.escada == true ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    WidgetsConstructor().makeText("Adicional escadas", Colors.black, 14.0, 15.0, 5.0, null),
                                    WidgetsConstructor().makeText(calculateTheCostsOfLadder().toStringAsFixed(2), Colors.black, 14.0, 15.0, 5.0, null),
                                  ],
                                ) : Container(),
                                moveClass.escada == true ? SizedBox(height: 5.0,) : Container(),
                                //linha total
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    WidgetsConstructor().makeText("Total", Colors.blue, 17.0, 15.0, 5.0, null),
                                    WidgetsConstructor().makeText(moveClass.preco==null ? "Calculando" : moveClass.preco.toStringAsFixed(2), Colors.blue, 17.0, 15.0, 5.0, null),
                                  ],
                                ),
                              ],
                            ),
                          ) : Container(),


                          SizedBox(height: 30.0,),
                          //the next button
                          //obs: Ainda falta verificar se a classe tá com td ok até aqui
                          moveClass.enderecoOrigem != null && _searchCEP== false && origemAddressVerified != "" && destinyAddressVerified != "" || _searchCEP== true && origemAddressVerified !="" && destinyAddressVerified != "" && _sourceAdressNumber.text.isNotEmpty && _destinyAdressNumber.text.isNotEmpty ?
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                isLoading=true;
                                showSchedulePage=true;
                                showAddressesPage=false;
                              });

                            },
                            child: WidgetsConstructor().makeButton(Colors.blue, Colors.transparent, widthPercent*0.85, heightPercent*0.08,
                                2.0, 4.0, "Aceitar o preço e agendar", Colors.white, 18.0),
                          ) : Container(),

                        ],
                      ),
                      //loading screen
                      isLoading==true ? Center(
                        child: CircularProgressIndicator(),
                      ) : Container(),
                    ],
                  );
                }

            ),
          )
        ],
      ),
    );

  }

  int scheduleSelection=0;
  Widget schedulePage(){

    double heightPercent = MediaQuery
        .of(context)
        .size
        .height;
    double widthPercent = MediaQuery
        .of(context)
        .size
        .width;


    return Scaffold(
      key: _scaffoldKey,
      body: ListView(
        controller: _scrollController,
        children: [
          Container(
            color: Colors.white,
            child: ScopedModelDescendant<SelectedItemsChartModel>(
                builder: (BuildContext context, Widget widget, SelectedItemsChartModel selectedItemsChartModel){

                  return Stack(
                    children: [

                      Column(
                        children: [
                          WidgetsConstructor().makeText("Agendar mudança", Colors.blue, 20.0, 40.0, 40.0, "center"),

                          //botoes agendar ou agora
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [

                              //botao agora
                              GestureDetector(
                                child:Container(
                                  height: 50.0,
                                  width: widthPercent*0.4,
                                  decoration: WidgetsConstructor().myBoxDecoration(scheduleSelection==1 ? Colors.blue : Colors.white, scheduleSelection==1 ? Colors.blue : Colors.grey, 3.0, 5.0),
                                  child: WidgetsConstructor().makeText("Agora", scheduleSelection==1 ? Colors.white : Colors.grey, 18.0, 10.0, 10.0, "center"),
                                ),
                                onTap: (){
                                  setState(() {
                                    scheduleSelection=1;
                                    //isLoading=true;
                                  });
                                },
                              ),

                              //botao agendar
                              GestureDetector(
                                child:Container(
                                  height: 50.0,
                                  width: widthPercent*0.4,
                                  decoration: WidgetsConstructor().myBoxDecoration(scheduleSelection==2 ? Colors.blue : Colors.white, scheduleSelection==2 ? Colors.blue : Colors.grey, 3.0, 5.0),
                                  child: WidgetsConstructor().makeText("Agendar", scheduleSelection==2 ? Colors.white : Colors.grey, 18.0, 10.0, 10.0, "center"),
                                ),
                                onTap: (){
                                  setState(() {
                                    scheduleSelection=2;
                                  });
                                },
                              ),

                            ],
                          ),
                          SizedBox(height: 40.0,),

                          scheduleSelection == 1 ?
                          //container de achar agora
                          //aqui dentro está a listview
                          Container(
                            width: widthPercent*0.9,
                            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 4.0),
                            child: Column(
                              children: [
                                WidgetsConstructor().makeText("Freteiros próximos de você", Colors.blue, 15.0, 15.0, 15.0, "center"),
                                SizedBox(height: 20.0,),

                                StreamBuilder<QuerySnapshot>(
                                  //stream: Firestore.instance.collection("truckers").where('latlong', isGreaterThanOrEqualTo: -69.011483).where('latlong', isLessThan: -63.011483).limit(25).snapshots(),
                                  stream: Firestore.instance.collection(moveClass.carro).where('latlong', isGreaterThanOrEqualTo: -69.011483).where('latlong', isLessThan: -63.011483).limit(25).snapshots(),
                                  builder: (context, snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting:
                                      case ConnectionState.none:
                                        return Center( //caso esteja vazio ou esperando exibir um circular progressbar no meio da tela
                                          child: CircularProgressIndicator(),
                                        );
                                      default:
                                        List<DocumentSnapshot> documents = snapshot
                                            .data.documents.toList();
                                        //return Text(snapshot.data.documents[0]['name']);
                                        return ScopedModelDescendant<UserModel>(
                                            builder: (BuildContext context, Widget child, UserModel userModel) {

                                              return ListView.builder(
                                                shrinkWrap: true,
                                                itemBuilder: (BuildContext context, int index) {

                                                  print(documents[index].data['vehicle']);
                                                  print(carSelected);

                                                  return InkWell(
                                                    onTap: (){
                                                      setState(() {

                                                        //agendar
                                                        print(documents[index].documentID);
                                                        moveClass.freteiroId = documents[index].documentID;
                                                        moveClass.userId = UserModel().Uid;
                                                        showPopupFinal=true;
                                                        //scheduleAmove();


                                                      });

                                                    },
                                                    child: Padding(
                                                      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
                                                      child: Container(
                                                        child: Padding(
                                                            padding: EdgeInsets.fromLTRB(
                                                                0.0, 5.0, 0.0, 5.0),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    SizedBox(width: widthPercent * 0.03,),
                                                                    Container(
                                                                      width: widthPercent*0.20,
                                                                      child:Image.network(documents[index]['image'], height: 100.0, width: 100.0,),
                                                                    ),
                                                                    //Image.asset(myData[index]['image']),
                                                                    SizedBox(width: widthPercent * 0.03,),
                                                                    Container(
                                                                      width: widthPercent*0.30,
                                                                      child: Text(documents[index]["name"]),
                                                                    ),
                                                                    SizedBox(width: widthPercent * 0.03,),
                                                                    Container(
                                                                      width: widthPercent*0.20,
                                                                      child: Text("nota: "+documents[index]['aval'].toString()),
                                                                    )

                                                                  ],
                                                                ),

                                                                documents[index].data['vehicle'] == carSelected ?
                                                                WidgetsConstructor().makeText("Este é o modelo que você escolheu", Colors.blue, 15.0, 5.0, 5.0, null) : Container(),

                                                                documents[index].data['vehicle'] == carSelected ?
                                                                WidgetsConstructor().makeText("Veículo: "+TruckClass.empty().formatCodeToHumanName(documents[index].data['vehicle']), Colors.blue, 15.0, 5.0, 5.0, null)
                                                                    : WidgetsConstructor().makeText("Veículo: "+TruckClass.empty().formatCodeToHumanName(documents[index].data['vehicle']), Colors.black, 15.0, 5.0, 5.0, null),

                                                                documents[index].data['vehicle'] != carSelected ?
                                                                WidgetsConstructor().makeText("Diferença: "+MoveClass().returnThePriceDiference(carSelected, documents[index].data['vehicle']), Colors.blue, 15.0, 5.0, 5.0, null) : Container(),

                                                              ],
                                                            )
                                                        ),
                                                        decoration: WidgetsConstructor()
                                                            .myBoxDecoration(
                                                            Colors.white, Colors.blue, 1.0, 5.0),
                                                      ),
                                                    ),
                                                  ); //card com resultado se não tiver filtr

                                                },
                                                itemCount: documents == null ? 0 : documents.length,

                                              );

                                            }

                                        );

                                    };
                                  },
                                )

                              ],
                            ),
                          )

                          //container de agendar
                              : Container(),


                        ],
                      ),

                      showPopupFinal == true ? Positioned(
                        bottom: 40.0,
                        top: 40.0,
                        left: 40.0,
                        right: 40.0,
                        child: Container(color: Colors.yellow, height: 100.0, width: 100.0,),
                      ) : Container(),

                    ],
                  );

                }

            ),
          )
        ],
      ),
    );
  }








  Widget popUpSelectItemQuantity(index, heightP, widhtP){
    return ScopedModelDescendant<SelectedItemsChartModel>(
      builder: (BuildContext context, Widget widget, SelectedItemsChartModel selectedItemsChartModel){
        return Center(
          //top: heightP*0.15,
          //left: widhtP*0.1,
          //right: widhtP*0.1,
          child: Container(
              height: heightP*0.45,
              width: widhtP*0.8,
              decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 1.0, 7.0),
              child: Column(
                children: [
                  WidgetsConstructor().makeText("Ajuste a quantidade", Colors.blue, 18.0, 10.0, 10.0, "center"), //titulo
                  WidgetsConstructor().makeText(myData[selectedIndex]['name'], Colors.blue, 15.0, 10.0, 5.0, "center"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      InkWell(
                        onTap: (){
                          setState(() {
                            if(selectedOfSameItens!=0){
                              selectedOfSameItens--;
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                          child: Icon(Icons.exposure_neg_1, color: Colors.black, size: 35.0),
                        ),
                      ),
                      Positioned(
                        child: Image.asset(myData[selectedIndex]['image'], height: heightP*0.1),
                      ),
                      InkWell(
                        onTap: (){
                          setState(() {
                            if(selectedOfSameItens>=10){
                              //exibir mensagem avisando se tem certeza da quantidade
                              _displaySnackBar(context, "Hum, parece que temos muitos itens iguais. Tem certeza da quantidade?");
                            }
                            selectedOfSameItens++;

                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                          child: Icon(Icons.exposure_plus_1, color: Colors.black, size: 35.0),
                        ),
                      ),

                    ],
                  ), //linha com imagens e botões - e +
                  Row(
                    children: [
                      SizedBox(width: widhtP*0.1,),
                      WidgetsConstructor().makeText("Quantidade:  ", Colors.black, 15.0, 10.0, 10.0, null),
                      WidgetsConstructor().makeText(selectedOfSameItens.toString() , Colors.black, 15.0, 10.0, 10.0, null),
                    ],
                  ),
                  SizedBox(height: heightP*0.04),//linha com a quantidade escolhida deste item
                  InkWell(
                    onTap: (){
                      setState(() {

                        if(selectedOfSameItens!=0){

                          isLoading=true;
                          //então adicionar este item ao carrinho
                          int cont=0;
                          while(cont<selectedOfSameItens){

                            //cria um objeto
                            ItemClass item = ItemClass(myData[selectedIndex]['name'].toString(), myData[selectedIndex]['weigth'], myData[selectedIndex]['singlePerson'], myData[selectedIndex]['volume'], myData[selectedIndex]['image']);
                            //adiciona a lista disponivel no model
                            selectedItemsChartModel.addItemToChart(item);
                            cont++;
                          }
                        }
                        selectedOfSameItens=0;
                        showPopUpQuant=false;

                        isLoading = false;
                      });
                    },
                    child: WidgetsConstructor().makeButton(Colors.blue, Colors.blue, widhtP*0.30, 50.0, 1.0, 5.0, "Fechar", Colors.white, 15.0),
                  )


                  /*

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  child: WidgetsConstructor().makeButton(Colors.blue, Colors.blue, widhtP*0.30, 50.0, 1.0, 5.0, "Fechar", Colors.white, 15.0),
                )
              ],
            )

             */
                ],
              )
          ),
        );
      },
    );
  }

  Widget bottomCard(double widthPercent, double heightPercent){
    return ScopedModelDescendant<SelectedItemsChartModel>(
      builder: (BuildContext context, Widget widget, SelectedItemsChartModel selectedItemsChartModel){
        return Container(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [

                selectedItemsChartModel.getItemsChartSize() == 0
                    ? WidgetsConstructor().makeSimpleText(
                    "Nenhum item selecionado", Colors.redAccent, 15.0)
                    : WidgetsConstructor().makeSimpleText(
                    "Itens: ", Colors.blue, 15.0),
                selectedItemsChartModel.getItemsChartSize() == 0
                    ? Container()
                    : WidgetsConstructor().makeSimpleText(
                    selectedItemsChartModel.getItemsChartSize().toString(), Colors.blue, 15.0),
                selectedItemsChartModel.getItemsChartSize() == 0 ? Container() : SizedBox(
                  width: widthPercent * 0.42,),
                //espaço vazio para colocar o X no cando direito
                selectedItemsChartModel.getItemsChartSize() == 0 ? Container() : Positioned(
                  right: 5.0, child: Container(width: 40.0,
                  height: 40.0,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.redAccent,),
                    onPressed: () {
                      setState(() {
                        selectedItemsChartModel.clearChart();
                        showCustomItemPage=false;
                        showSelectItemPage=true;
                      });
                    },),),)

              ],
            ),
          ),
          decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 1.0, 4.0), width: widthPercent * 0.75, height: heightPercent * 0.10,);
      },
    );
  }

  Widget topCustomBar(double heightPercent, double widthPercent, String text, int option){
    //obs option1 = volta de customPage para a pagina inicial
    //option2 = volta de selectTruck para customPage

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 15.0),
      //color: Colors.blue,
      height: heightPercent*0.12,
      child: Row(
        children: [
          Container(
            width: widthPercent*0.20,
            child: GestureDetector(
              onTap: (){
                setState(() {
                  if(option==1){
                    //volta pro inicio
                    showCustomItemPage=false;
                    showSelectItemPage=true;
                  } else if(option==2) {
                    //volta pra pagina 2 (customItemPage)
                    showCustomItemPage=true;
                    showSelectTruckPage=false;
                  } else if(option==3){
                    //volta pra página 3 (select car)
                    showSelectTruckPage=true;
                    showAddressesPage=false;
                    origemAddressVerified="";
                  } else if(option==4){
                    //volta para pagina 4 (selectAdress)
                    showAddressesPage=true;
                    showSchedulePage=false;
                  }

                });
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 15.0, 00.0),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 28.0),
              ),
            ),
          ),

          Container(
            width: widthPercent*0.65,
            child: WidgetsConstructor().makeText(text, Colors.white, 15.0, 15.0, 0.0, "center"),
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

  void findAddress(TextEditingController controller, String opcao) async {

    setState(() {
      isLoading=true;
    });

    String addressInformed = controller.text;

    try{

      var addresses = await Geocoder.local.findAddressesFromQuery(addressInformed);
      var first = addresses.first;

      if(addresses.length==1){
        setState(() {
          if(opcao=="origem") {
            origemAddressVerified = first.addressLine + " - " + first.adminArea;
          } else {
            destinyAddressVerified = first.addressLine + " - " + first.adminArea;
          }

        });
      } else {
        setState(() {
          if(opcao=="origem") {
            origemAddressVerified = "";
          } else {
            destinyAddressVerified = "";
          }
        });

        _displaySnackBar(context, "Especifique melhor o endereço. Estamos encontrando multiplos resultados");
      }

    } catch (e){

      origemAddressVerified = "";
      _displaySnackBar(context, "Formato de endereço inválido");

    }

    setState(() {
      isLoading=false;
    });


  }

  /// check if the string contains only numbers
  bool isNumeric(String str) {

    RegExp _numeric = RegExp(r'^-?[0-9]+$');

    return _numeric.hasMatch(str);
  }

  void waitAmoment(int seconds){

    setState(() {
      isLoading = true;
    });
    Future.delayed(Duration(seconds: seconds)).then((_){

      setState(() {
        isLoading = false;
      });

      scrollToBottom();

    });

  }

  void scrollToBottom() {
    final bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      bottomOffset,
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  //carrega dados de gasolina e ajudantes
  void loadDataFromDb() async {

    final String _collection = 'infos';
    final Firestore _fireStore = Firestore.instance;
    _fireStore.collection(_collection).getDocuments().then((value) {

      if(value.documents.length > 0){
        precoCadaAjudante =  value.documents[0].data['preco'].toDouble();
        print(precoCadaAjudante);
        precoBaseFreteiro = value.documents[1].data['preco'].toDouble();
        print(precoBaseFreteiro);
        precoGasolina = value.documents[2].data['preco'].toDouble();
        print(precoGasolina);



      } else {
        print("dados não encontrados");
      }

    });

  }

  void calculateThePrice() async {
    setState(() {
      isLoading=true;
    });
    //carrega o preco das coisas do bd
    loadDataFromDb();

    if(moveClass.longEnderecoDestino == null || moveClass.longEnderecoOrigem == null || moveClass.latEnderecoDestino == null || moveClass.latEnderecoOrigem == null){
      _displaySnackBar(context, "Ops um erro nos endereços. Por favor refaça o processo de infomar os endereços");
      origemAddressVerified="";
      destinyAddressVerified="";
      moveClass.enderecoOrigem=null;
      moveClass.enderecoDestino=null;
      _sourceAdress.text="";
      _destinyAdress.text="";
      _sourceAdressNumber.text="";
      _destinyAdressNumber.text="";
      _sourceAdressComplement.text="";
      _destinyAdressComplement.text="";

    } else if(moveClass.enderecoDestino=="" || moveClass.enderecoOrigem==""){
      _displaySnackBar(context, "Verifique os endereços informados");
    } else {
      
      //tudo ok. Vamos calcular as coisas
      double custoTotal=0.0;

      //distancia entre dois pontos
      distance = DistanceLatLongCalculation().calculateDistance(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem, moveClass.latEnderecoDestino, moveClass.longEnderecoDestino);
      
      //calculo dos custos com gasolina considerando 8km/L
      finalGasCosts = (distance/7)*precoGasolina;
      if(finalGasCosts<5.00){
        finalGasCosts=5.00;
      }
      custoTotal=custoTotal+finalGasCosts;
      print("custo total: "+custoTotal.toStringAsFixed(2));
      
      //custo com ajudantes
      custoAjudantes = moveClass.ajudantes*precoCadaAjudante;
      custoTotal=custoTotal+custoAjudantes;
      print("custo total: "+custoTotal.toStringAsFixed(2));

      //custo de cada caminhão adicionado
      custoTotal=custoTotal+precoBaseFreteiro+moveClass.giveMeThePriceOfEachvehicle(moveClass.carro);
      print("custo total: "+custoTotal.toStringAsFixed(2));

      //custo de cada móvel
      totalExtraProducts = 0.0;
      moveClass.itemsSelectedCart.forEach((element) {

        totalExtraProducts = totalExtraProducts+3.00;
      });
      custoTotal = custoTotal+totalExtraProducts;
      print("custo totoal final: "+custoTotal.toStringAsFixed(2));

     custoTotal = calculateTheCostsOfLadder()+custoTotal;

      moveClass.preco = custoTotal;

      setState(() {
        isLoading=false;
        moveClass.preco;
        showResume=true;
      });

    }


  }

  double calculateTheCostsOfLadder(){
    double value=0.00;
    if(moveClass.escada==true){
      final int multiplicador = moveClass.lancesEscada;
      value = multiplicador*20.0;
    }
    return value;
  }

  String isThisNumberNegative(double n){

    String isNegative='nao';
    if(n<0){
      isNegative="sim";
    } else if(n==0){
      isNegative="zero";
    } else {
      isNegative="nao";
    }
    return isNegative;

  }


  void scheduleAmove() async {

    Map<String , dynamic> data = {}; //map<String, dynamic> é como o cloud storage armazena as infos

    data['enderecoOrigem'] = moveClass.enderecoOrigem;
    data['enderecoDestino'] = moveClass.enderecoDestino;
    data['ps'] = moveClass.ps;
    data['carro'] = moveClass.carro;
    data['ajudantes'] = moveClass.ajudantes;
    data['ps'] = moveClass.ps;
    data['escada'] = moveClass.escada;
    if(moveClass.escada==true){
      data['lancesEscada'] = moveClass.lancesEscada;
    }
    data['idFreteiro'] = moveClass.freteiroId;
    data['valor'] = moveClass.preco;
    data['idContratante'] = moveClass.userId;


    Firestore.instance.collection('agendamentos_aguardando') .add(data);

  }



/*
  void testing(){

    /* estes dados sao para a busca
        var latlong = lat + long  //esta latlong é um double para calculos
        var startAtval = latlong-(0.01f*0.6*multiple)
        var endAtval = latlong+(0.01f*0.6*multiple)
   */

    int multiple =1; //2 para dobrar o raio
    //var latlong = lat + long  //esta latlong é um double para calculos
    double latlong = (-22.889936) + (-43.121547);  //esta latlong é um double para calculos
    var startAtval = latlong-(0.01*0.6*multiple); //1 é o multiplador da distancia
    var endAtval = latlong+(0.01*0.6*multiple);


    var raioBusca = 5.0; //var raioBusca  = 0.3 //marca o raio da busca dos pets  0.1 = 1km no mapa              obs: Mudamos para 10 km
    var raioUser = 7000; //obs: A busca está pegando endereços de um raio um pouco maior do que o desenhado. Vou aumentar o raio desenhado para nao apareceer o erro pro usuario               //var raioUser = 3000 //marca o circulo da distancia que foi buscada pelo user. 1000 = 1km no mapa    obs: Mudamos de 3000 para 10000 (10km)
    var dif = -0.07576889999999992; //diferença a ser adicona em startAtVal

    startAtval = (dif+startAtval);

    final String _collection = 'truckers';
    final Firestore _fireStore = Firestore.instance;
    _fireStore.collection(_collection).orderBy('aval').startAt(startAtval).getDocuments().then((value) {

      if(value.documents.length > 0){
        precoCadaAjudante =  value.documents[0].data['preco'].toDouble();
        print(precoCadaAjudante);
        precoBaseFreteiro = value.documents[1].data['preco'].toDouble();
        print(precoBaseFreteiro);
        precoGasolina = value.documents[2].data['preco'].toDouble();
        print(precoGasolina);



      } else {
        print("dados não encontrados");
      }

    });

    https://www.youtube.com/watch?v=2KknXzalXfg


  }


   */




}


