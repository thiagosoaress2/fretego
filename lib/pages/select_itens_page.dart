import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/item_class.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/models/selected_items_chart_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:convert';
import 'package:geocoder/geocoder.dart';

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

  bool isLoading=false;

  bool showSelectItemPage=true;
  bool showCustomItemPage=false;
  bool showSelectTruckPage=false;
  bool showAddressesPage=false;
  bool showResumePage=false;

  int helpersContracted = 1;
  bool editingHelpers=false;

  MoveClass moveClass = MoveClass();

  //String origemAddressVerified ="";
  //String destinyAddressVerified="";

  bool _searchCEP=false;

  @override
  void initState() {
    super.initState();
    //listener da busca
    _searchController.addListener(() {
      setState(() {
        _filter = _searchController.text.toLowerCase(); //a cada clique atualiza
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return
      showSelectItemPage==true ? selectItemsPage()
      : showCustomItemPage==true ? customItemPage()
      : showSelectTruckPage==true ? selectTruckPage()
      : showAddressesPage==true ?  selectAdressPage()
      : showResumePage==true ? resumePage()
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

    double heightPercent = MediaQuery
        .of(context)
        .size
        .height;
    double widthPercent = MediaQuery
        .of(context)
        .size
        .width;

    return ScopedModelDescendant<SelectedItemsChartModel>(
      builder: (BuildContext context, Widget widget, SelectedItemsChartModel selectedItemsChartModel){
        return Scaffold(
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.blue,
                child: Icon(Icons.navigate_next, size: 50.0,),
                onPressed: () {

                  setState(() {

                    if(_psController.text.isEmpty){
                      moveClass.ps = "nao";
                    } else {
                      moveClass.ps = _psController.text;
                    }
                    showCustomItemPage=false;
                    showSelectTruckPage=true;


                  });

                }),
            body: ListView(
              children: [
                Stack(
                  children: [
                    Container(
                      color: Colors.white,
                      height: heightPercent,
                      width: widthPercent,
                      child: Column(
                        children: [

                          topCustomBar(heightPercent, widthPercent, "Detalhamento", 1),
                          SizedBox(height: 40.0,),
                          Container(
                            width: widthPercent*0.7,
                            child: WidgetsConstructor().makeText("Alguma observação?", Colors.black, 20.0, 10.0, 30.0, "center"),
                          ),
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
                          SizedBox(height: 25.0,),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                showCustomItemPage=false;
                                showSelectTruckPage=true;

                                if(_psController.text.isEmpty){
                                  moveClass.ps = "nao";
                                } else {
                                  moveClass.ps = _psController.text;
                                }
                              });

                            },
                            child: WidgetsConstructor().makeButton(Colors.blue, Colors.transparent, widthPercent*0.85, heightPercent*0.08,
                                2.0, 4.0, "Continuar", Colors.white, 18.0),
                          )

                        ],
                      ),
                    ),

                    Positioned(
                      bottom: 40.0,
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

    String carSelected="nao";

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
                        WidgetsConstructor().makeText(selectedItemsChartModel.getItemsChartSize()!=1 ? "Sua mudança possui "+selectedItemsChartModel.getItemsChartSize().toString()+" itens." : "Sua mudança possui apenas "+selectedItemsChartModel.getItemsChartSize().toString()+" item.", Colors.black, 15.0, 10.0, 10.0, "center"),
                        WidgetsConstructor().makeText(selectedItemsChartModel.getTotalVolumeOfChart()<10.000 ? "O volume da mudança é "+selectedItemsChartModel.getTotalVolumeOfChart().toStringAsPrecision(7)+". Você não precisa de um caminhão baú para esta quantidade." : "O volume da mudança é "+selectedItemsChartModel.getTotalVolumeOfChart().toStringAsPrecision(7)+". Recomendamos um caminhão estilo baú." , Colors.black, 15.0, 10.0, 20.0, "center"),
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
                                child: WidgetsConstructor().makeText(helpersNeeded!=1 ? "Pelo menos dois ajudantes devido ao volume de alguns itens." : "1 ajudante é suficiente de acordo com os itens escolhidos.", Colors.redAccent, 12.0, 20.0, 0.0, "center"),
                              ),

                              




                            ],
                          ),
                        ), //caixinha de seleção de ajudantes
                        SizedBox(height: 40.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: (){
                                carSelected = "carroca";
                              },
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
                                carSelected = "pickupP";
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
                                carSelected = "pickupG";
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
                                carSelected = "kombiA";
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
                                carSelected = "caminhaoPA";
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
                                carSelected = "kombiF";
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
                                carSelected = "caminhaoBP";
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
                                carSelected = "caminhaoBG";
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

    TextEditingController _sourceAdress = TextEditingController();
    TextEditingController _destinyAdress = TextEditingController();

    return Scaffold(
      key: _scaffoldKey,

      body: ListView(
        children: [
          Container(
            color: Colors.white,
            child: ScopedModelDescendant<SelectedItemsChartModel>(
                builder: (BuildContext context, Widget widget, SelectedItemsChartModel selectedItemsChartModel){

                  return Column(
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
                                      if(_sourceAdress.text.isNotEmpty){

                                        //if the user meant to search by CEP
                                        if(_searchCEP==true){
                                          if(isNumeric(_sourceAdress.text)){
                                            findAddress(_sourceAdress, "origem");
                                          } else {
                                            _displaySnackBar(context, "O CEP deve ter apenas números");
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
                                      if(_destinyAdress.text.isNotEmpty){

                                        if(_searchCEP==true){

                                          if(isNumeric(_destinyAdress.text)) {
                                            findAddress(_destinyAdress, "destiny");
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
                              //text informing user that the address of destiny was found
                              destinyAddressVerified != "" ? WidgetsConstructor().makeText("Destino localizado", Colors.blue, 15.0, 10.0, 5.0, "center") : Container(),
                              //address found
                              destinyAddressVerified != "" ? WidgetsConstructor().makeText(destinyAddressVerified, Colors.black, 12.0, 5.0, 10.0, "center") : Container(),
                              SizedBox(height: 20.0,),
                            ],
                          ),
                        )
                      ) ,


                      SizedBox(height: 40.0,),
                      //the next button
                      GestureDetector(
                        onTap: (){
                          setState(() {


                          });

                        },
                        child: WidgetsConstructor().makeButton(Colors.blue, Colors.transparent, widthPercent*0.85, heightPercent*0.08,
                            2.0, 4.0, "Continuar", Colors.white, 18.0),
                      ) //botao final

                    ],
                  );
                }

            ),
          )
        ],
      ),
    );

  }

  Widget resumePage(){

    return Container(color: Colors.amber);
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
                    showResumePage=false;
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


  }

  /// check if the string contains only numbers
  bool isNumeric(String str) {

    RegExp _numeric = RegExp(r'^-?[0-9]+$');

    return _numeric.hasMatch(str);
  }
}


