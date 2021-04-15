import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fretego/classes/item_class.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/classes/truck_class.dart';
import 'package:fretego/classes/trucker_class.dart';
import 'package:fretego/models/selected_items_chart_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/services/date_services.dart';
import 'package:fretego/services/distance_latlong_calculation.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/date_utils.dart' as dateUtils;
import 'package:fretego/utils/notificationMeths.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:convert';
import 'package:geocoder/geocoder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

/*

ATENÇÃO ESTA PÁGINA FOI DESATIVADA E AGORA TODO PROCEDIMENTO OCORRE EM MOVE_SCHEDULE_PAGE POIS FOI DESMEMBRADA EM VÁRIAS.
VAI SER MANTIIDA AQUI POR REFERENCIA MAS QUASE TODOS ELEMENTOS FORAM TRANSPORTADOS


 */
class SelectItensPage extends StatefulWidget {
  @override
  _SelectItensPageState createState() => _SelectItensPageState();
}

class _SelectItensPageState extends State<SelectItensPage>  with AfterLayoutMixin<SelectItensPage> {

  //variaveis da busca
  TextEditingController _searchController = TextEditingController();
  String _filter;

  //fim das variaveis da busca

  bool initialLoad=false;

  int selectedOfSameItens=0;
  var myData;
  int selectedIndex;

  bool showPopUpQuant=false;

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  ScrollController _scrollController; //scroll screen to bottom

  bool isLoading=false;

  bool showSelectItemPage=true;
  bool showDetalhesLocalPage=false;
  bool showSelectTruckPage=false;
  bool showAddressesPage=false;
  bool showChooseTruckerPage=false;
  bool showDatePage=false;
  bool showFinalPage=false;
  bool showListOfItemsEdit=false;

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

  double precoCadaAjudante=50.0;
  double precoGasolina=5.30;
  double precoBaseFreteiro=80.0;

  double finalGasCosts=0.00;
  double distance=0.0;
  double totalExtraProducts = 0.00;

  bool showResume=false;
  bool isUpdating=false;

  //String carSelected="nao";

  TruckerClass truckerClass = TruckerClass();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedtime = TimeOfDay.now();

  bool customItem=false;

  double heightPercent;
  double widthPercent;

  String appBarTextBack='Início';
  String appBarTitleText='Itens Grandes';

  //animação do topo
  bool canScroll=false; //vai liberar o scroll so na hora da animacao
  double offset=0.0;
  ScrollController _TopAnimcrollController;
  int step=0;


  String _selectedItensLine1='';
  Map<String, int> itensMap = Map(); //guarda o nome do item e a quantidade do item que existe
  Map<String, int> itensIndex = Map(); //guarda a posicao do item na itensMap

  bool _showTip=true;

  bool _showListAnywhere=false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  @override
  Future<void> afterFirstLayout(BuildContext context) async {


    Future.delayed(Duration(seconds: 2)).then((value) {
      setState(() {
        _showTip=false;
      });
    });



  }

  @override
  Future<void> initState(){
    super.initState();

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
    _TopAnimcrollController.dispose();
    super.dispose();
  }

  Future<void> deleteForTests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('situacao');
    FirestoreServices().deleteAscheduledMove(moveClass);
  }

  Future<void> _loadTheListFromAndPutInScreen(UserModel userModel, SelectedItemsChartModel selectedItemsChartModel) async {

    void _listIsUpToRead(){

      //moveClass.itemsSelectedCart = selectedItemsChartModel.itemsSelectedCart;

      //preenche os itens da primeira página
      if(moveClass.itemsSelectedCart.isNotEmpty){
        int cont=0;
        while(cont<moveClass.itemsSelectedCart.length){
          String item = moveClass.itemsSelectedCart[cont].name;
          if(itensMap.containsKey(item)){
            int total = itensMap[item];
            itensMap[item]=total+1;
          } else {
            itensMap[item]=1;
          }
          cont++;
          //moveClass.itemsSelectedCart['name'];
        }
      }
      if(itensMap.length!=0){
        setState(() {
          itensMap=itensMap;
        });
      }

    }

    if(initialLoad==false){
      initialLoad=true;
      checkIfExistsInShared(userModel); //it will also check if there is in firebase if there is no data in shared

      await loadItemsFromShared(selectedItemsChartModel, () {_listIsUpToRead();});
      //moveClass.itemsSelectedCart = selectedItemsChartModel.itemsSelectedCart;
    }

  }

  @override
  Widget build(BuildContext context) {

    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;

    return ScopedModelDescendant<SelectedItemsChartModel>(
      builder: (BuildContext context, Widget child, SelectedItemsChartModel selectedItemsChartModel) {
        return ScopedModelDescendant<UserModel>(
          builder: (BuildContext context, Widget child, UserModel userModel){

            _loadTheListFromAndPutInScreen(userModel, selectedItemsChartModel);

            return SafeArea(child:
            Scaffold(
              body: Stack(
                children: [

                  showSelectItemPage==true ? selectItemsPage()
                      : showDetalhesLocalPage==true ? detalhesLocalPage()
                      : showSelectTruckPage==true ? selectTruckPage()
                      : showAddressesPage==true ?  selectAdressPage()
                      : showChooseTruckerPage==true ? chooseTruckerPage()
                      : showDatePage==true ? datePage()
                      : showFinalPage==true ? finalPage()
                      :showListOfItemsEdit==true ? editListOfItemsPage()
                      //: _showListAnywhere==true ? listAnywhere()
                      : Container(),

                  //animação
                  Positioned(
                      top: heightPercent*0.07,
                      width: widthPercent,
                      child: _itensPageAnim()),

                  //appbar
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: customFakeAppBar(),),


                  _showListAnywhere==true ?
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                    child: listAnywhere(),
                  ) : Container(),


                ],
              ),
            )

            );

          },
        );



      },
    );
    /*
    return  showCustomItemPage==false && showSelectTruckPage==false
        ? selectItemsPage() :
        showCustomItemPage==true ? customItemPage() : selectTruckPage();

     */
  }

  Widget selectItemsPage (){

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        return Scaffold(
          key: _scaffoldKey,
          floatingActionButton: FloatingActionButton(
              backgroundColor: CustomColors.yellow,
              child: Icon(Icons.navigate_next, size: 50.0,),
              onPressed: () {


                if(itensMap.length!=0){

                  /*
                      setState(() {
                        isLoading=true;
                      });

                      if(moveClass.itemsSelectedCart!=null){
                        SharedPrefsUtils().clearListInShared(moveClass.itemsSelectedCart.length);
                        selectedItemsChartModel.clearChart();
                        moveClass.itemsSelectedCart.clear();
                      }

                      itensMap.forEach((key, value) {

                        int cont=0;
                        while(cont<value){
                          int indexHere = itensIndex[key];
                          ItemClass item = ItemClass(myData[indexHere]['name'].toString(), myData[indexHere]['weigth'], myData[indexHere]['singlePerson'], myData[indexHere]['volume']);
                          if(moveClass.itemsSelectedCart == null){
                            List<ItemClass>list=[];
                            list.add(item);
                            moveClass.itemsSelectedCart = list;
                            selectedItemsChartModel.addItemToChart(item);
                            //moveClass.itemsSelectedCart.add(item);
                          } else {
                            selectedItemsChartModel.addItemToChart(item);
                            moveClass.itemsSelectedCart.add(item);
                          }
                          cont++;
                        }


                      });

                      selectedItemsChartModel.updateItemsSelectedCartList(moveClass.itemsSelectedCart);
                      SharedPrefsUtils().saveListOfItemsInShared(moveClass.itemsSelectedCart);


                       */

                  //exibe a proxima página
                  showSelectItemPage=false;
                  showDetalhesLocalPage=true;
                  appBarTextBack='Itens';
                  setState(() {
                    appBarTitleText='Observações';
                  });

                } else {
                  _displaySnackBar(context, "Você não selecionou nenhum item para a mudança");
                }


                /*
                    if(selectedItemsChartModel.getItemsChartSize()!=0){

                      //update the moveClass for the firstTime
                      moveClass.itemsSelectedCart = selectedItemsChartModel.itemsSelectedCart;
                      //salva no shared para continuar de onde parou em outra sessão
                      SharedPrefsUtils().saveListOfItemsInShared(moveClass.itemsSelectedCart);
                      //exibe a proxima página
                      showSelectItemPage=false;
                      showDetalhesLocalPage=true;
                      appBarTextBack='Itens';
                      setState(() {
                        appBarTitleText='Observações';
                      });


                      /*
                      setState(() {
                        _topAnimScroll();
                      });

                       */

                    } else {
                      _displaySnackBar(context, "Você não selecionou nenhum item para a mudança");
                    }

                     */



              }),

          body: Container(
            width: widthPercent,
            height: heightPercent,
            color: Colors.white,
            child: Stack(
              children: [


                //barra de busca
                selectItemPageElement_searchBar(),

                //barra marrom com os itens selecionados
                //query com futurebuilder
                selectItemPageElement_productList(),


                isLoading == true
                    ? Center(
                  child: CircularProgressIndicator(),
                ): Container(),

              ],
            ),
          ),
        );
      },
    );
  }

  Widget selectItemPageElement_searchBar(){

    return Positioned(
      top: heightPercent*0.27,
      left: widthPercent*0.05,
      right: widthPercent*0.05,
      child: Container(
        height: 60.0,
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(suffixIcon: Icon(
              Icons.search),labelText: 'Busque aqui'),
        ),
      ),);

  }

  Widget selectItemPageElement_productList(){

    bool lastItem=false;

    return Positioned(

      top: heightPercent*0.37,
      left: widthPercent*0.05,
      right: widthPercent*0.05,
      bottom: heightPercent*0.10,
      child: Column(
        children: [

          _selectedItensLine1.isNotEmpty
              ? Container(
            color: CustomColors.brown,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetsConstructor().makeText('Itens Selecionados', Colors.black, 16.0, 2.0, 0.0, 'no'),
                WidgetsConstructor().makeText(_selectedItensLine1, Colors.black, 13.0, 5.0, 3.0, 'no'),
              ],
            ),
          ) : Container(),

          Expanded(child:FutureBuilder(
            future: DefaultAssetBundle.of(context).loadString(
                'loadjson/itens.json'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator(),);
              }
              myData = json.decode(snapshot.data);
              print(myData);

              return ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  print(index+1);
                  print(myData.length);
                  if(index+1==myData.length){
                    lastItem=true;
                    print('last item enocntrado em index '+index.toString());
                  }
                  return _filter == null || _filter == ""
                      ? InkWell(
                    onTap: (){
                      selectedIndex = index;

                      /*
                                      setState(() {
                                        if(myData[index]['name'].toString() == 'Outro'){
                                          print('outro');
                                          customItem = true;
                                        }
                                      });

                                       */

                    },
                    child: _itemCard(index, lastItem),
                  ) //card com resultado se não tiver filtro
                      : myData[index]['name'].toString().toLowerCase().contains(_filter)
                      ? InkWell(
                    onTap: (){
                      selectedIndex = index;

                      /*
                                      setState(() {
                                        if(myData[index]['name'].toString() == 'Outro'){
                                          print('outro');
                                          customItem = true;
                                        }
                                      });
                                       */
                    },
                    child: _itemCard(index, lastItem),
                  ) //card com resultado com filtro
                      : Container(); //card caso nao tenha nada para exibir por causa do filtro


                },
                itemCount: myData == null ? 0 : myData.length,
                //itemCount: myData == null ? 0 : 5,  //mudar aqui para alterar quantidade de itens

              );
            },
          ) ),



        ],
      ),
    );
  }

  double _currentSliderValue = 0.0;

  Widget detalhesLocalPage(){

    loadDataFromDb();

    TextEditingController _psController = TextEditingController();
    TextEditingController _qntLancesEscadaController = TextEditingController();


    //verifica para lembrar a opção que o user deixou
    if(moveClass.escada==true){
      if(moveClass.lancesEscada.toString()!="null"){
        _qntLancesEscadaController.text = moveClass.lancesEscada.toString();
      }
    }

    if(moveClass.ps!=null){
      _psController.text=moveClass.ps;
    }


    _qntLancesEscadaController.addListener(() {
      moveClass.lancesEscada= int.parse(_qntLancesEscadaController.text);
    });

    _psController.addListener(() {
      moveClass.ps = _psController.text;
    });

    if(moveClass.ps!=null){
      _psController.text = moveClass.ps;
    }

    if(moveClass.escada==null){
      moveClass.escada=false;
    }


    return ScopedModelDescendant<SelectedItemsChartModel>(
      builder: (BuildContext context, Widget widget, SelectedItemsChartModel selectedItemsChartModel){
        return Scaffold(
            key: _scaffoldKey,
            floatingActionButton: FloatingActionButton(
                backgroundColor: CustomColors.yellow,
                child: Icon(Icons.navigate_next, size: 50.0,),
                onPressed: () {

                  if(_currentSliderValue!=0){
                    moveClass.escada=true;
                    moveClass.lancesEscada = _currentSliderValue.round().toInt();
                  } else {
                    moveClass.escada=false;
                    moveClass.lancesEscada=0;
                  }
                  if(_psController.text.isEmpty){
                    moveClass.ps = "nao";
                  } else {
                    moveClass.ps = _psController.text;
                  }
                  SharedPrefsUtils().saveDataFromCustomItemPage(moveClass);

                  //exibe a proxima página
                  showDetalhesLocalPage=false;
                  showSelectTruckPage=true;
                  appBarTextBack='Obs';
                  appBarTitleText='Selecionar veículo';

                  setState(() {
                    _topAnimScroll();
                  });

                }),

            body: Container(
              width: widthPercent,
              height: heightPercent,
              color: Colors.white,
              child: Stack(
                children: [

                  Positioned(
                      top: heightPercent*0.29,
                      left: 0.5,
                      right: 0.5,
                      child:
                      Column(
                        children: [

                          Container(

                            //titulo
                            child: WidgetsConstructor().makeResponsiveText(context,
                                'Características do local', CustomColors.blue, 3, 0.0, 0.0, 'center'),),
                          SizedBox(height: heightPercent*0.04,),

                          Container(
                            width: widthPercent*0.9,
                            child: WidgetsConstructor().makeResponsiveText(context,
                                'Lances de escada', CustomColors.blue, 2.5, 0.0, 10.0, 'no'),
                          ),
                          Container(
                            width: widthPercent*0.90,
                            height: heightPercent*0.15,
                            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 2.0, 0.0),
                            child: Column(
                              children: [

                                SizedBox(height: heightPercent*0.02,),
                                Slider(
                                  value: _currentSliderValue,
                                  min: 0,
                                  max: 20,
                                  divisions: 20,
                                  label: _currentSliderValue.round().toString(),
                                  onChanged: (double value) {
                                    setState(() {
                                      _currentSliderValue = value;
                                    });
                                  },
                                ),
                                WidgetsConstructor().makeResponsiveText(context,
                                    _currentSliderValue==0.0 ? 'Sem escada' : 'lances: '+_currentSliderValue.round().toString(),
                                    Colors.grey[400], 2.0, 5.0, 0.0, 'center'),

                              ],
                            ),
                          ),

                          SizedBox(height: heightPercent*0.05,),
                          //observacoes
                          Container(
                            width: widthPercent*0.9,
                            child: WidgetsConstructor().makeResponsiveText(context,
                                'Observações', CustomColors.blue, 2.5, 0.0, 10.0, 'no'),
                          ),

                          Container(
                            width: widthPercent*0.90,
                            height: heightPercent*0.15,
                            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 2.0, 0.0),
                            child: TextField(
                              controller: _psController,
                              decoration: new InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                                  hintText: 'Suas observações aqui, se houver.'
                              ),
                            ),
                          ),

                          //slider



                        ],
                      )
                  ),


                ],
              ),
            )

          /*
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
                              value: moveClass.escada,
                              onChanged: (bool value){
                                setState(() {
                                  if(value==true){
                                    moveClass.escada=true;
                                  } else {
                                    moveClass.escada=false;
                                  }
                                  //_escadaCheckBoxvar = value;

                                });
                              }
                          ),
                        ],
                      ),
                      //linha para dizer quantos lances
                      moveClass.escada== true ? Container(
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
            ),

           */

        );
      },
    );
  }

  /*
  Widget detalhesLocalPage(){

    loadDataFromDb();

    TextEditingController _psController = TextEditingController();
    TextEditingController _qntLancesEscadaController = TextEditingController();


    //verifica para lembrar a opção que o user deixou
    if(moveClass.escada==true){
      if(moveClass.lancesEscada.toString()!="null"){
        _qntLancesEscadaController.text = moveClass.lancesEscada.toString();
      }
    }

    if(moveClass.ps!=null){
      _psController.text=moveClass.ps;
    }


    _qntLancesEscadaController.addListener(() {
      moveClass.lancesEscada= int.parse(_qntLancesEscadaController.text);
    });

    _psController.addListener(() {
      moveClass.ps = _psController.text;
    });

    if(moveClass.ps!=null){
      _psController.text = moveClass.ps;
    }

    if(moveClass.escada==null){
      moveClass.escada=false;
    }


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
                        showDetalhesLocalPage=false;
                      showSelectTruckPage=true;

                      //save em shared
                      SharedPrefsUtils().saveDataFromCustomItemPage(moveClass);

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
                                  value: moveClass.escada,
                                  onChanged: (bool value){
                                    setState(() {
                                      if(value==true){
                                        moveClass.escada=true;
                                      } else {
                                        moveClass.escada=false;
                                      }
                                      //_escadaCheckBoxvar = value;

                                    });
                                  }
                              ),
                            ],
                          ),
                          //linha para dizer quantos lances
                          moveClass.escada== true ? Container(
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

   */
  Widget selectTruckPage(){

    initialLoad=false; //ajusta para as proximas telas

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

              if(moveClass.carro!=null){
                //ajusta a quantidade de ajudantes desta mudança
                moveClass.ajudantes = helpersContracted;
                //moveClass.carro = carSelected;
                SharedPrefsUtils().saveDataFromSelectTruckPage(moveClass);
                initialLoad=false;
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
                              //carSelected="pickupP";
                              moveClass.carro="pickupP";
                            } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="carroça"){
                              //carSelected="carroca";
                              moveClass.carro="carroca";
                            } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="pickup grande"){
                              //carSelected="pickupG";
                              moveClass.carro="pickupG";
                            } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="kombi aberta"){
                              //carSelected="kombiA";
                              moveClass.carro="kombiA";
                            } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="kombi fechada"){
                              //carSelected="kombiF";
                              moveClass.carro="kombiF";
                            } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="caminhao pequeno aberto"){
                              //carSelected="caminhaoPA";
                              moveClass.carro="caminhaoPA";
                            } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="caminhao baú pequeno") {
                              //carSelected = "caminhaoBP";
                              moveClass.carro= "caminhaoBP";
                            } else {
                              //carSelected = "caminhaoBG";
                              moveClass.carro= "caminhaoBG";
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
                                //carSelected = "carroca";
                                moveClass.carro = "carroca";
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
                                //carSelected = "pickupP";
                                moveClass.carro = "pickupP";
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
                                //carSelected = "pickupG";
                                moveClass.carro = "pickupG";
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
                                //carSelected = "kombiA";
                                moveClass.carro = "kombiA";
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
                                //carSelected = "caminhaoPA";
                                moveClass.carro = "caminhaoPA";
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
                                //carSelected = "kombiF";
                                moveClass.carro = "kombiF";
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
                                //carSelected = "caminhaoBP";
                                moveClass.carro = "caminhaoBP";
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
                                //carSelected = "caminhaoBG";
                                moveClass.carro = "caminhaoBG";
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
                        child: WidgetsConstructor().makeText("Veículo selecionado: "+TruckClass.empty().formatCodeToHumanName(moveClass.carro.toString()), Colors.blue, 18.0, 10.0, 30.0, null),
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

                            if(moveClass.carro!=null){
                              //ajusta a quantidade de ajudantes desta mudança
                              moveClass.ajudantes = helpersContracted;
                              //moveClass.carro = carSelected;
                              SharedPrefsUtils().saveDataFromSelectTruckPage(moveClass);
                              initialLoad=false;
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


    String enderecoOrigem = moveClass.enderecoOrigem?? 'nao';

    if(enderecoOrigem!='nao' && initialLoad==false){
      _sourceAdress.text = moveClass.enderecoOrigem;
      findAddress(_sourceAdress, "origem");
      fakeClickIncludeEndereco();
    }

    String enderecoDest = moveClass.enderecoDestino?? 'nao';

    if(enderecoDest!='nao' && initialLoad==false){
      initialLoad=true;
      _destinyAdress.text = moveClass.enderecoDestino;
      findAddress(_destinyAdress, "destiny");
      fakeClickIncludeEndereco();
    }

    //loadDataFromDb();

    return Scaffold(
      key: _scaffoldKey,

      body: ListView(
        controller: _scrollController,
        children: [
          Container(
            color: Colors.white,
            child: ScopedModelDescendant<UserModel>(
                builder: (BuildContext context, Widget widget, UserModel userModel){

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
                                              scrollToBottom();
                                            } else {
                                              _displaySnackBar(context, "O CEP deve ter apenas números");
                                            }

                                          } else {

                                            if(_destinyAdress.text.contains("0") || _destinyAdress.text.contains("1") || _destinyAdress.text.contains("2") || _destinyAdress.text.contains("3") || _destinyAdress.text.contains("4") || _destinyAdress.text.contains("5") || _destinyAdress.text.contains("6") || _destinyAdress.text.contains("7") || _destinyAdress.text.contains("8") || _destinyAdress.text.contains("9") ){
                                              findAddress(_destinyAdress, "destiny");
                                              scrollToBottom();
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
                          await _makeAddressConfig();
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
                                //WidgetsConstructor().makeText(custoAjudantes.toStringAsFixed(2), Colors.black, 14.0, 15.0, 5.0, null),
                                WidgetsConstructor().makeText((precoCadaAjudante*moveClass.ajudantes).toStringAsFixed(2), Colors.black, 14.0, 15.0, 5.0, null),

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
                        onTap: () async {

                          await SharedPrefsUtils().saveDataFromSelectAddressPage(moveClass);

                          /*
                          setState(() {
                            isLoading=true;

                          });

                           */


                          setState(() {
                            isLoading=true;
                            showChooseTruckerPage=true;
                            //isUpdating=false;
                            showAddressesPage=false;
                          });



                        },
                        child: WidgetsConstructor().makeButton(Colors.blue, Colors.transparent, widthPercent*0.85, heightPercent*0.08,
                            2.0, 4.0, "Aceitar o preço e agendar", Colors.white, 18.0),
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

  Widget chooseTruckerPage(){

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
            child: ScopedModelDescendant<UserModel>(
                builder: (BuildContext context, Widget widget, UserModel userModel){


                  /*
                  if(isUpdating==false) {
                    isUpdating = true;
                    checkIfExistsAscheduledMoveInFb(userModel);
                  }

                   */

                  final double lat = moveClass.latEnderecoOrigem;
                  final double long = moveClass.longEnderecoOrigem;
                  final double latlong = lat + long;  //esta latlong é um double para calculos
                  //double startAtval = latlong-(0.01*0.6);
                  double startAtval = latlong-(0.05*5.0);
                  //final double endAtval = latlong+(0.01*0.6);
                  final double endAtval = latlong+(0.05*5.0);
                  final double dif = -0.07576889999999992;
                  startAtval = (dif+startAtval); //ajusta erro que percebi testando


                  /*
                  Query query =
                  FirebaseFirestore.instance.collection(moveClass.carro).where('latlong', isGreaterThanOrEqualTo: startAtval)
                      .where('latlong', isLessThan: endAtval).where('banido', isEqualTo: false);
                   */

                  Query query = FirebaseFirestore.instance.collection('truckers').where('latlong', isGreaterThanOrEqualTo: startAtval)
                      .where('latlong', isLessThan: endAtval).where('banido', isEqualTo: false).where('listed', isEqualTo: true)
                      .where('vehicle', isEqualTo: moveClass.carro);




                  //https://morioh.com/p/b7b4a0b44c9c
                  //video para seguir

                  return Stack(
                    children: [

                      Column(
                        children: [
                          //barra superior
                          topCustomBar(heightPercent, widthPercent, "Escolher profissional", 4),

                          SizedBox(height: 20.0,),

                          moveClass.nomeFreteiro != null ?
                          Container(
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                children: [

                                  WidgetsConstructor().makeText("Você já selecionou um profissional", Colors.blue, 17.0, 15.0, 12.0, "center"),
                                  Row(
                                    children: [
                                      moveClass.freteiroImage != null
                                          ? CircleAvatar(
                                        backgroundImage: NetworkImage(moveClass.freteiroImage),
                                      )
                                          : Image.asset('images/carrinhobaby'),
                                      WidgetsConstructor().makeText(moveClass.nomeFreteiro, Colors.blue, 16.0, 10.0, 10.0, "center"),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  ),

                                ],
                              ),
                            ),
                            width: widthPercent*0.8,
                            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 4.0),
                          ) : Container(),

                          SizedBox(height: 20.0,),

                          Container(
                            height: heightPercent*0.6,
                            width: widthPercent*0.9,
                            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 4.0),
                            child: Column(
                              children: [
                                WidgetsConstructor().makeText("Freteiros próximos de você", Colors.blue, 15.0, 15.0, 15.0, "center"),
                                SizedBox(height: 20.0,),

                                //tentando modelo do site do fireastore update
                                StreamBuilder<QuerySnapshot>(
                                  stream: query.snapshots(),
                                  builder: (context, stream){

                                    if (stream.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }

                                    if (stream.hasError) {
                                      return Center(child: Text(stream.error.toString()));
                                    }

                                    QuerySnapshot querySnapshot = stream.data;

                                    return
                                      querySnapshot.size == 0
                                          ? Center(child: Text("Não encontramos profissionais próximos."),)
                                          : Expanded(child: ListView.builder(
                                          itemCount: querySnapshot.size,
                                          //itemBuilder: (context, index) => Trucker(querySnapshot.docs[index]),
                                          itemBuilder: (context, index) {

                                            Map<String, dynamic> map = querySnapshot.docs[index].data();
                                            return GestureDetector(
                                              onTap: (){

                                                setState(() {

                                                  print(querySnapshot.docs[index].id);

                                                  //agendar
                                                  truckerClass.image=map['image'];
                                                  truckerClass.id=querySnapshot.docs[index].id;
                                                  truckerClass.name=map['apelido'];
                                                  truckerClass.aval=map['aval'].toDouble();

                                                  //print(documents[index].documentID); apareceu deprecated
                                                  //moveClass.freteiroId = documents[index].documentID; apareceu deprecated;
                                                  moveClass.freteiroId = querySnapshot.docs[index].id;
                                                  moveClass.userId = UserModel().Uid;
                                                  moveClass.nomeFreteiro = map['apelido']; //antigamente pegava de 'name'.
                                                  moveClass.freteiroImage = map['image'];
                                                  moveClass.placa = map['placa'];
                                                  SharedPrefsUtils().saveDataFromSelectTruckERPage(moveClass);


                                                  showPopupFinal=true;
                                                  //scheduleAmove();

                                                });



                                              },
                                              //child: Text(map['name']),
                                              child: truckerSelectListViewLine(map),
                                            );
                                            //return Trucker(querySnapshot.docs[index]);

                                          } ),);

                                  },
                                ),


                              ],
                            ),
                          ),



                        ],
                      ),



                      showPopupFinal == true ? Positioned(

                        top: 25.0,
                        left: 25.0,
                        right: 25.0,
                        child: Container(
                          decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 4.0, 5.0),
                          width: 100.0,
                          child: Column(
                            children: [
                              //titulo
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    child:WidgetsConstructor().makeButton(Colors.grey, Colors.black, widthPercent*0.1, 40.0, 1.0, 3.0, "X", Colors.black, 40.0),
                                    onTap: (){
                                      setState(() {
                                        showPopupFinal=false;
                                      });

                                    },
                                  ),

                                ],
                              ),
                              WidgetsConstructor().makeText("Confirmar agendamento", Colors.blue, 17.0, 30.0, 10.0, "center"),
                              SizedBox(height: 20.0,),
                              //imagem perfil
                              Container(
                                width: 150.0,
                                height: 150.0,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(truckerClass.image),
                                ),
                              ),
                              WidgetsConstructor().makeText(truckerClass.name, Colors.blue, 20.0, 15.0, 10.0, "center"),
                              WidgetsConstructor().makeText("Classificação: "+truckerClass.aval.toStringAsFixed(2), Colors.black, 18.0, 5.0, 15.0, "center"),
                              SizedBox(height: 30.0,),
                              GestureDetector(
                                child: WidgetsConstructor().makeButton(Colors.blue, Colors.blue, widthPercent*0.5, 50.0, 2.0, 10.0, "agendar", Colors.white, 18.0),
                                onTap: (){

                                  setState(() {

                                    showChooseTruckerPage=false;
                                    showDatePage=true;
                                  });
                                  //scheduleAmove();
                                },
                              ),
                              SizedBox(height: 40.0,)

                              //Image.network(truckerClass.image, width: 200.0, height: 200.0,),

                            ],
                          ),),
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

  Widget datePage(){

    double heightPercent = MediaQuery
        .of(context)
        .size
        .height;
    double widthPercent = MediaQuery
        .of(context)
        .size
        .width;

    if(moveClass.dateSelected!=null){
      selectedDate = DateServices().convertToDateFromString(moveClass.dateSelected);
    }

    if(moveClass.timeSelected!=null){
      selectedtime = DateServices().convertStringToTimeOfDay(moveClass.timeSelected);
    }


    return ScopedModelDescendant<SelectedItemsChartModel>(
      builder: (BuildContext context, Widget widget, SelectedItemsChartModel selectedItemsChartModel){
        return ScopedModelDescendant<UserModel>(
          builder: (BuildContext context, Widget widget, UserModel userModel){
            return Scaffold(
                key: _scaffoldKey,
                body: Stack(
                  children: [

                    Container(
                      width: widthPercent,
                      height: heightPercent,
                      color: Colors.white,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [

                            //barra superior
                            topCustomBar(heightPercent, widthPercent, "Detalhamento", 5),

                            SizedBox(height: 60.0,),

                            //botao que abre o seletor de data
                            GestureDetector(
                              child: WidgetsConstructor().makeButton(Colors.blue, Colors.blue, widthPercent*0.75, 50.0, 2.0, 10.0, "Escolher data", Colors.white, 18.0),
                              onTap: (){
                                setState(() {

                                  _selectDate(context);

                                });


                              },

                            ),

                            SizedBox(height: 35.0,),
                            WidgetsConstructor().makeText("Data escolhida:", Colors.black, 20.0, 0.0, 10.0, "center"),
                            WidgetsConstructor().makeText(DateServices().convertToStringFromDate(selectedDate), Colors.blue, 20.0, 10.0, 30.0, "center"),

                            SizedBox(height: 60.0,),

                            //botao que abre o seletor de horario
                            GestureDetector(
                              child: WidgetsConstructor().makeButton(Colors.blueAccent, Colors.blueAccent, widthPercent*0.75, 50.0, 2.0, 10.0, "Escolher horário", Colors.white, 18.0),
                              onTap: (){
                                setState(() {

                                  _selectTime(context);

                                });


                              },

                            ),
                            SizedBox(height: 35.0,),

                            WidgetsConstructor().makeText("Horário escolhido:", Colors.black, 20.0, 0.0, 10.0, "center"),
                            WidgetsConstructor().makeText(selectedtime.format(context), Colors.blue, 20.0, 10.0, 30.0, "center"),

                            SizedBox(height: 35.0,),

                            //botao final
                            GestureDetector(
                              child: WidgetsConstructor().makeButton(Colors.redAccent, Colors.redAccent, widthPercent*0.9, 50.0, 2.0, 10.0, "Confirmar com freteiro", Colors.white, 18.0),
                              onTap: (){
                                setState(() {

                                  moveClass.dateSelected = DateServices().convertToStringFromDate(selectedDate);
                                  moveClass.timeSelected = selectedtime.format(context);

                                  _displaySnackBar(context, "Contactando o freteiro...");

                                  moveClass.situacao = "aguardando_freteiro";

                                  moveClass.userId = userModel.Uid;
                                  SharedPrefsUtils().saveMoveClassToShared(moveClass);
                                  scheduleAmove(userModel);

                                  waitAmoment(3);
                                  showDatePage=false;
                                  showFinalPage=true;
                                  //agora salvar no bd (o metodo ja existe).
                                  //precisa adicionar os campos do horario e data no salvamento.

                                });


                              },

                            ),


                          ],
                        ) ,
                      ),
                    ),

                  ],
                )
            );
          },
        );
      },
    );

  }

  Widget finalPage(){

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
          children: [
            Container(
                width: widthPercent,
                height: heightPercent,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    children: [

                      SizedBox(height: 15.0,),
                      WidgetsConstructor().makeText("Pronto. Agora aguarde a confirmação de "+moveClass.nomeFreteiro.toString(), Colors.blue, 17.0, 20.0, 20.0, "center"),
                      WidgetsConstructor().makeText("Resumo", Colors.black, 15.0, 0.0, 20.0, "center"),
                      WidgetsConstructor().makeText("Endereço de origem: "+moveClass.enderecoOrigem.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
                      WidgetsConstructor().makeText("Endereço de destino: "+moveClass.enderecoDestino.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
                      WidgetsConstructor().makeText("Data: "+moveClass.dateSelected.toString()+" às "+moveClass.timeSelected.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
                      WidgetsConstructor().makeText("Freteiro: "+moveClass.nomeFreteiro.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
                      WidgetsConstructor().makeText("Veículo: "+TruckClass().formatCodeToHumanName(moveClass.carro), Colors.black, 15.0, 0.0, 10.0, "no"),
                      WidgetsConstructor().makeText("Nº ajudantes: "+moveClass.ajudantes.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
                      WidgetsConstructor().makeText("Preço: R\$"+moveClass.preco.toStringAsFixed(2), Colors.black, 15.0, 0.0, 10.0, "no"),
                      WidgetsConstructor().makeText("Situação: "+MoveClass().formatSituationToHuman(moveClass.situacao), Colors.redAccent, 15.0, 0.0, 12.0, "no"),

                      SizedBox(height: 25.0,),
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).pop();
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => HomePage()));
                        },
                        child:WidgetsConstructor().makeButton(Colors.blue, Colors.blue, widthPercent*0.75, 50.0, 2.0, 4.0, "Fechar", Colors.white, 16.0),
                      ),

                      SizedBox(height: 10.0,),
                      GestureDetector(
                        onTap: (){
                          SharedPrefsUtils().clearScheduledMove();
                          FirestoreServices().deleteAscheduledMove(moveClass, () {_onSucessDelete(); }, () { _onFailureDelete(); });
                          setState(() {
                            isLoading=true;
                          });
                        },
                        child:WidgetsConstructor().makeButton(Colors.redAccent, Colors.redAccent, widthPercent*0.75, 50.0, 2.0, 4.0, "Cancelar", Colors.white, 16.0),
                      ),



                    ],
                  ),
                )
            ),
          ],
        )
    );

  }

  Widget editListOfItemsPage(){

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

        print("Teste 3 "+selectedItemsChartModel.getItemsChartSize().toString());

        moveClass.itemsSelectedCart = selectedItemsChartModel.getList;
        print("Teste 4 "+moveClass.itemsSelectedCart.length.toString());

        return Scaffold(
            key: _scaffoldKey,
            body:  Container(
              child: Column(
                children: [

                  SizedBox(height: 30.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CloseButton(
                        onPressed: (){
                          setState(() {
                            showListOfItemsEdit=false;
                            showSelectItemPage=true;
                          });
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 10.0),
                  WidgetsConstructor().makeText("Seus itens na mudança", Colors.blue, 17.0, 0.0, 10.0, "center"),
                  SizedBox(height: heightPercent*0.7,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: moveClass.itemsSelectedCart.length,
                      itemBuilder: (context, index) {
                        final item = moveClass.itemsSelectedCart[index];

                        //obs TUDO QUE MEXER NA LISTA ATUALIZAR NA MOVECLASS E NA MODEL PRA N DAR ERRO EM NENHUM LUGAR
                        return Card(
                          child: ListTile(
                            title: Text(item.name),
                            leading: Image.asset(item.image),
                            trailing: CloseButton(
                              color: Colors.red,
                              onPressed: (){
                                setState(() {
                                  moveClass.itemsSelectedCart.removeAt(index);
                                  _displaySnackBar(context, "Item removido");
                                });
                              },
                            ),
                          ),
                        );

                      },

                    ),
                  ),
                ],
              ),
            )
        );
      },
    );
  }

  Widget listAnywhere(){

    int cont=0;
    List <String> dynamicListName = [];
    List <int> dynamicListQuant = [];
    while(cont<moveClass.itemsSelectedCart.length){
      String item = moveClass.itemsSelectedCart[cont].name;
      if(cont==0){
        dynamicListName.add(item);
      }
    }

    return Container(
      width: widthPercent,
      color: Colors.white,
      height: heightPercent,
      child: ListView(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CloseButton(
                    onPressed: (){
                      setState(() {
                        _showListAnywhere=false;
                      });
                    },
                  )
                ],
              ),
              SizedBox(height: heightPercent*0.05,),

              WidgetsConstructor().makeResponsiveText(context, 'Itens selecionados', CustomColors.blue, 3, 0.0, 15.0, 'center'),

              Container(
                width: widthPercent,
                height: heightPercent*0.80,
                color: Colors.red,
                child: ListView.builder(
                    itemCount: moveClass.itemsSelectedCart.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: widthPercent,
                        height: 70.0,
                        child: WidgetsConstructor().makeResponsiveText(context, moveClass.itemsSelectedCart[index].name, Colors.black,
                            2.5, 0.0, 0.0, 'center'),
                      );
                    }
                )
              ),


            ],
          )
        ],
      ),
    );
  }




  //elementos do layout
  Widget customFakeAppBar(){

    void _customBackButton(){

      if(showSelectItemPage==true){
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomePage()));
      } else if(showDetalhesLocalPage==true){
        setState(() {
          showSelectItemPage=true;
          showDetalhesLocalPage=false;
        });
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
      setState(() {
        _showListAnywhere=true;
      });
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
                    Text(appBarTextBack, style: TextStyle(color: Colors.grey[400], fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
                  ],
                ),
              ),
              WidgetsConstructor().makeResponsiveText(context, appBarTitleText, _showTip==true ? Colors.white : CustomColors.blue, 3, 10.0, 0.0, 'no'),
              showSelectItemPage == true && _showTip==false ? IconButton(icon: Icon(Icons.help_outline, color: CustomColors.blue, size: 35,), onPressed: (){
                setState(() {
                  _showTip=true;
                });
              })
                  : showSelectItemPage == true && _showTip==true ? IconButton(icon: Icon(Icons.arrow_circle_up, color: CustomColors.blue, size: 35,), onPressed: (){
                setState(() {
                  _showTip=false;
                });
              },)
                  : IconButton(icon: Icon(Icons.assignment), onPressed: (){
                setState(() {
                  _showListAnywhere=true;
                  showDetalhesLocalPage=false;
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

  Widget _itemCard(int index, bool lastItem){

    int qnt=0;


    if(itensMap.length!=0){
      if(itensMap.containsKey(myData[index]["name"])){
        qnt = itensMap[myData[index]["name"]];
      }
    }

    return ScopedModelDescendant<SelectedItemsChartModel>(
      builder: (BuildContext context, Widget widget, SelectedItemsChartModel selectedItemsChartModel){

        return Container(
            height: heightPercent*0.10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Image.asset(myData[index]['image']),
                    WidgetsConstructor().makeResponsiveText(context, myData[index]["name"], Colors.black, 2.5, 2.5, 2.5, 'no'),

                    Container(
                      height: heightPercent*0.09,
                      width: widthPercent*0.35,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly  ,
                        children: [
                          //minus btn
                          GestureDetector(
                            onTap: (){

                              if(qnt!=0){
                                if(qnt==1){
                                  qnt--;
                                  _removeItemToTextLine(myData[index]["name"]);
                                  itensIndex.removeWhere((key, value) => key == myData[index]["name"]);  //remove da lista de index
                                  itensMap.removeWhere((key, value) => key == myData[index]["name"]);  //remove da lista de index
                                  //moveClass = MoveClass().deleteOneItem(moveClass, myData[index]["name"]);

                                  //remove from classmodel
                                  ItemClass itemClass = ItemClass(myData[index]['name'], myData[index]['weight'], myData[index]['singlePerson'], myData[index]['volume']);
                                  //selectedItemsChartModel.addItemToChart(itemClass);
                                  selectedItemsChartModel.removeItemFromChart(itemClass);
                                  moveClass.itemsSelectedCart = selectedItemsChartModel.itemsSelectedCart;

                                  SharedPrefsUtils().saveListOfItemsInShared(selectedItemsChartModel.itemsSelectedCart);

                                } else {
                                  qnt--;
                                  itensMap[myData[index]["name"]]=qnt;
                                  //moveClass = MoveClass().deleteOneItem(moveClass, myData[index]["name"]);

                                  //remove from classmodel
                                  ItemClass itemClass = ItemClass(myData[index]['name'], myData[index]['weight'], myData[index]['singlePerson'], myData[index]['volume']);
                                  //selectedItemsChartModel.addItemToChart(itemClass);
                                  selectedItemsChartModel.removeItemFromChart(itemClass);
                                  moveClass.itemsSelectedCart = selectedItemsChartModel.itemsSelectedCart;

                                  SharedPrefsUtils().saveListOfItemsInShared(selectedItemsChartModel.itemsSelectedCart);
                                }

                                //atualiza a tela
                                setState(() {
                                });
                              }

                            },
                            child: Container(
                              width: widthPercent*0.07,
                              height: heightPercent*0.040,
                              decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 1.0, 2.0),
                              child: WidgetsConstructor().makeResponsiveText(context, '-', CustomColors.blue, 2,
                                  0.0, 0.0, 'center'),
                            ),
                          ),


                          Container(
                            width: widthPercent*0.095,
                            height: heightPercent*0.050,
                            decoration: WidgetsConstructor().myBoxDecoration(CustomColors.blue, CustomColors.blue, 1.0, 2.0),
                            child: WidgetsConstructor().makeResponsiveText(context, qnt.toString(), Colors.white, 3,
                                0.0, 0.0, 'center'),
                          ),

                          //btn plus
                          GestureDetector(
                            onTap: (){


                              if(qnt>=10){
                                //exibir mensagem avisando se tem certeza da quantidade
                                _displaySnackBar(context, "Hum, parece que temos muitos itens iguais. Tem certeza da quantidade?");
                              }
                              qnt++;
                              _addItemToTextLine(myData[index]["name"]);
                              itensIndex[myData[index]["name"]] = index; //salva o index para depois sabermos como alvar os itens

                              //add a moveClass
                              ItemClass itemClass = ItemClass(myData[index]['name'], myData[index]['weight'], myData[index]['singlePerson'], myData[index]['volume']);
                              selectedItemsChartModel.addItemToChart(itemClass);
                              moveClass.itemsSelectedCart = selectedItemsChartModel.itemsSelectedCart;

                              //ItemClass itemClass = ItemClass(myData[index]['name'], myData[index]['weight'], myData[index]['singlePerson'], myData[index]['volume']);
                              //moveClass.itemsSelectedCart.add(itemClass);
                              //moveClass = MoveClass().addOneItem(moveClass, myData, index);

                              SharedPrefsUtils().saveListOfItemsInShared(selectedItemsChartModel.itemsSelectedCart);

                              setState(() {
                                itensMap[myData[index]["name"]]=qnt;
                                //qnt++;
                              });


                            },
                            child: Container(
                              width: widthPercent*0.07,
                              height: heightPercent*0.040,
                              decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 1.0, 2.0),
                              child: WidgetsConstructor().makeResponsiveText(context, '+', CustomColors.blue, 2,
                                  0.0, 0.0, 'center'),
                            ),
                          ),


                        ],
                      ),
                    )

                  ],
                ),
                Container(
                  height: 2.0,
                  width: widthPercent*0.8,
                  color: Colors.grey[200],
                )
              ],
            )
        );

      },
    );
  }

  Widget _itensPageAnim(){

    _TopAnimcrollController = ScrollController();

    //para animação da tela
    _TopAnimcrollController.addListener(() {
      setState(() {
        offset = _TopAnimcrollController.hasClients ? _TopAnimcrollController.offset : 0.1;

      });
      print(offset);
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
                physics: canScroll == false ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
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

  void _topAnimScroll(){
    double offsetAcrescim=widthPercent*0.20;

    canScroll=true;
    offset=offset+offsetAcrescim;
    _TopAnimcrollController.animateTo(offset, duration: Duration(milliseconds: 450), curve:Curves.easeInOut);
    canScroll=false;
    setState(() {
      step=step+1;
    });
  }

  void _topAnimScrollBack(){
    double offsetAcrescim=widthPercent*0.19;

    canScroll=true;
    offset<0.1 ? 0.0 : offset=offset-offsetAcrescim;
    _TopAnimcrollController.animateTo(offset, duration: Duration(milliseconds: 200), curve:Curves.easeInOut);
    canScroll=false;

    if(step!=0){
      setState(() {
        step=step-1;
      });
    }

  }

  void _addItemToTextLine(String item){

    if(_selectedItensLine1.contains(item)){
      //já foi adicionado
    } else {

      String newEntry = '  #'+item.trim();
      print('foi');
      setState(() {
        _selectedItensLine1=_selectedItensLine1+newEntry;
      });

    }

  }

  void _removeItemToTextLine(String item){
    setState(() {
      _selectedItensLine1 = _selectedItensLine1.replaceAll('  #'+item.trim(), '');
    });

  }

  Future<bool> checkIfExistsAscheduledMoveInFb(UserModel userModel) async {

    FirestoreServices().checkIfExistsAmoveScheduledForItensPage(userModel.Uid, () {_onSucessScheduled(userModel);}, () {_onFailureScheduled(userModel);});

  }

  Future<void> _onSucessScheduled(UserModel userModel) async {

    _displaySnackBar(context, "Opa. Parece que você já tem uma mudança agendada.");

    void _onSucess(){

      print(moveClass);
      setState(() {
        showFinalPage=true;
        showSelectItemPage=false;
        isLoading=false;
      });

    }

    //moveClass = await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClass, userModel);
    await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClass, userModel,() {_onSucess();});

    /*
    await SharedPrefsUtils().saveMoveClassToShared(moveClass);

    setState(() {
      showFinalPage=true;
      showSelectItemPage=false;
      isLoading=false;
    });
     */

  }


  void _onFailureScheduled(UserModel userModel){
    //do nothing, open normal next page
    _checkIfNeedNewTrucker(userModel); //verifica se precisa trocar o motorista
    setState(() {
      //showChooseTruckerPage=true;
      //showAddressesPage=false;
      isLoading=false;
    });

  }

  Future<Widget> checkIfExistsInShared(UserModel userModel) async {

    checkIfExistsAscheduledMoveInFb(userModel); //se quiser voltar com o shared, apagar esta linha. Ela fica no else abaixo

    //disabled. Agora n pega mais no shared
    /*
    if(await SharedPrefsUtils().checkIfThereIsScheduledMove()==true){

      moveClass = await SharedPrefsUtils().loadMoveClassFromSharedPrefs(moveClass);

      setState((){
        showFinalPage = true;
        showSelectItemPage=false;

      });

      _checkIfNeedNewTrucker();

    } else {
      //if there is no data in shared, check in firebase
      checkIfExistsAscheduledMoveInFb(userModel);
    }

     */

  }

  Widget truckerSelectListViewLine(Map map){

    return Padding(
        padding: EdgeInsets.only(bottom: 4, top: 4, right: 5, left: 5),
        child: Container(
            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 3.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [

                    Padding(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Text(map['name']),
                            Text(map['apelido']),
                            //Text(map['aval'].toString()),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                map['rate']<0.4
                                    ? Icon(Icons.star_border, color: Colors.yellow[600], size: 20.0,)
                                    : map['rate']<1
                                    ? Icon(Icons.star_half, color: Colors.yellow[600], size: 20.0,)
                                    : Icon(Icons.star, color: Colors.yellow[600], size: 20.0,),

                                map['rate']<=1.4
                                    ?Icon(Icons.star_border, color: Colors.yellow[600], size: 20.0,)
                                    : map['rate']<2
                                    ? Icon(Icons.star_half, color: Colors.yellow[600], size: 20.0,)
                                    : Icon(Icons.star, color: Colors.yellow[600], size: 20.0,),

                                map['rate']<=2.4
                                    ?Icon(Icons.star_border, color: Colors.yellow[600], size: 20.0,)
                                    : map['rate']<3
                                    ? Icon(Icons.star_half, color: Colors.yellow[600], size: 20.0,)
                                    : Icon(Icons.star, color: Colors.yellow[600], size: 20.0,),


                                map['rate']<=3.4
                                    ?Icon(Icons.star_border, color: Colors.yellow[600], size: 20.0,)
                                    : map['rate']<4
                                    ? Icon(Icons.star_half, color: Colors.yellow[600], size: 20.0,)
                                    : Icon(Icons.star, color: Colors.yellow[600], size: 20.0,),

                                map['rate']<=4.4
                                    ?Icon(Icons.star_border, color: Colors.yellow[600], size: 20.0,)
                                    : map['rate']<5
                                    ? Icon(Icons.star_half, color: Colors.yellow[600], size: 20.0,)
                                    : Icon(Icons.star, color: Colors.yellow[600], size: 20.0,),


                              ],
                            ),

                            //metadata,
                            //genres,
                          ],
                        )),
                    Container(width: 100, child: Center(child: Image.network(map['image']))),


                  ],
                ),
                WidgetsConstructor().makeText('Corridas no app: '+map['aval'].toString(), Colors.black, 16.0, 15.0, 15.0, 'no'),
                WidgetsConstructor().makeText('Placa do veículo: '+map['placa'].toString(), Colors.black, 16.0, 15.0, 15.0, 'no'),
                //foto do carro
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(width: 75, child: Center(child: Image.network(map['vehicle_image']))),
                  ],
                )
              ],
            )
        ));

  }

  Future<void> fakeClickIncludeEndereco() async {

    moveClass = await MoveClass().getTheCoordinates(moveClass, origemAddressVerified, destinyAddressVerified);
    setState(() {
      moveClass.enderecoOrigem = origemAddressVerified;
      moveClass.enderecoDestino = destinyAddressVerified;
    });

    calculateThePrice();

    scrollToBottom();

  }

  Future<void> loadMoveClassFromShared() async {
    setState(() async {

      SharedPrefsUtils().saveListOfItemsInShared().then((value) {

      });

      moveClass = await SharedPrefsUtils().loadMoveClassFromSharedPrefs(moveClass);
      //moveClass = await SharedPrefsUtils().loadListOfItemsInSharedToMoveClass(moveClass);
      shouldOpenOnlyResume();
    });



  }

  void shouldOpenOnlyResume(){
    if(moveClass.situacao!=null){
      setState(() {
        showSelectItemPage=false;
        showFinalPage=true;
      });
    }
  }

  Future<void> loadItemsFromShared( SelectedItemsChartModel selectedItemsChartModel, [VoidCallback onFinish()]) async {

    bool shouldRead = await SharedPrefsUtils().thereIsItemsSavedInShared(); //verifica se tem algum item salvo
    if(shouldRead==true){

      List<ItemClass> list = await SharedPrefsUtils().loadListOfItemsInShared(); //carrega os dados salvos
      selectedItemsChartModel.updateItemsSelectedCartList(list);  //adiciona na model para compartilhar com a app
      moveClass = await SharedPrefsUtils().loadListOfItemsInSharedToMoveClass(moveClass); // salva a lista na classe pra acessar mais rápdio
      onFinish();
    }

  }



  TextEditingController alturaController = TextEditingController();
  TextEditingController larguraController = TextEditingController();
  TextEditingController profundidadeController = TextEditingController();
  TextEditingController pesoController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  double altura = 0.0;
  double largura = 0.0;
  double profundidade = 0.0;

  Widget popUpCustomItem(index, heightP, widhtP){


    alturaController.addListener(() {
      setState(() {
        altura = double.parse(alturaController.text);
      });
    });

    larguraController.addListener(() {
      setState(() {
        largura = double.parse(larguraController.text);
      });
    });

    profundidadeController.addListener(() {
      setState(() {
        profundidade= double.parse(profundidadeController.text);
      });
    });

    return ScopedModelDescendant<SelectedItemsChartModel>(
      builder: (BuildContext context, Widget widget, SelectedItemsChartModel selectedItemsChartModel){
        return Container(
          height: heightP,
          width: widhtP,
          color: Colors.white,
          child: SingleChildScrollView(
              child: Column(
                children: [

                  WidgetsConstructor().makeText('Especificando item', Colors.black, 17.0, 15.0, 15.0, 'center'),
                  WidgetsConstructor().makeText('Considere sempre como se o item estivesse dentro de uma caixa. Desenhe o tamanho da caixa para que ele possa caber.', Colors.black, 15.0, 0.0, 10.0, 'no'),


                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Transform(
                        transform: Matrix4.identity()..setEntry(3,2, 0.01)..rotateY(0.6),
                        alignment: FractionalOffset.centerRight,
                        child: Container(
                          color: Colors.brown,
                          height: altura,
                          width: profundidade,
                        ),
                      ),
                      Container(
                        color: CustomColors.brown,
                        width: largura,
                        height: altura,
                      ),

                    ],
                  ),

                  SizedBox(height: 20.0,),

                  Container(
                    width: widhtP*0.75,
                    child: WidgetsConstructor().makeEditTextNumberOnly(alturaController, 'Altura em cm'),
                  ),
                  Container(
                    width: widhtP*0.75,
                    child: WidgetsConstructor().makeEditTextNumberOnly(larguraController, 'Largura em cm'),
                  ),
                  Container(
                    width: widhtP*0.75,
                    child: WidgetsConstructor().makeEditTextNumberOnly(profundidadeController, 'Profundidade em cm'),
                  ),
                  Container(
                    width: widhtP*0.75,
                    child: WidgetsConstructor().makeEditTextNumberOnly(pesoController, 'Peso em kg'),
                  ),

                  SizedBox(height: 15.0,),

                  Container(
                    width: widhtP*0.60,
                    child: WidgetsConstructor().makeEditText(nameController, 'Nome', null),
                  ),

                  SizedBox(height: 30.0,),

                  Column(
                    children: [
                      WidgetsConstructor().makeText("Ajuste a quantidade", Colors.blue, 18.0, 10.0, 10.0, "center"), //titulo
                      WidgetsConstructor().makeText(nameController.text, Colors.blue, 15.0, 10.0, 5.0, "center"),
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
                      SizedBox(height: heightP*0.04),//li

                      /*// nha com a quantidade escolhida deste item
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
                                if(moveClass.itemsSelectedCart == null){
                                  List<ItemClass>list=[];
                                  list.add(item);
                                  moveClass.itemsSelectedCart = list;
                                  selectedItemsChartModel.addItemToChart(item);
                                  //moveClass.itemsSelectedCart.add(item);
                                } else {
                                  selectedItemsChartModel.addItemToChart(item);
                                  moveClass.itemsSelectedCart.add(item);
                                }

                                cont++;
                              }
                            }
                            selectedOfSameItens=0;
                            showPopUpQuant=false;

                            //salva no shared para continuar de onde parou em outra sessão
                            SharedPrefsUtils().saveListOfItemsInShared(moveClass.itemsSelectedCart);

                            isLoading = false;

                          });
                        },
                        child: WidgetsConstructor().makeButton(Colors.blue, Colors.blue, widhtP*0.30, 50.0, 1.0, 5.0, "Fechar", Colors.white, 15.0),
                      )
                       */

                    ],
                  ),

                  Container(
                    height: 60.0,
                    width: widhtP*0.90,
                    child: RaisedButton(
                      onPressed: (){
                        alturaController.dispose();
                        larguraController.dispose();
                        pesoController.dispose();

                        if(selectedOfSameItens!=0){

                          isLoading=true;
                          //então adicionar este item ao carrinho
                          int cont=0;
                          while(cont<selectedOfSameItens){

                            bool needtwo=false;
                            //cria um objeto
                            if(double.parse(pesoController.text)>60.0){
                              needtwo=true;
                            }


                            //ItemClass item = ItemClass(nameController.text, double.parse(pesoController.text), needtwo, ItemClass.empty().calculateVolume(altura, largura, profundidade), myData[selectedIndex]['image']);
                            ItemClass item = ItemClass(nameController.text, double.parse(pesoController.text), needtwo, ItemClass.empty().calculateVolume(altura, largura, profundidade));
                            //adiciona a lista disponivel no model
                            if(moveClass.itemsSelectedCart == null){
                              List<ItemClass>list=[];
                              list.add(item);
                              moveClass.itemsSelectedCart = list;
                              selectedItemsChartModel.addItemToChart(item);
                              //moveClass.itemsSelectedCart.add(item);
                            } else {
                              selectedItemsChartModel.addItemToChart(item);
                              moveClass.itemsSelectedCart.add(item);
                            }

                            cont++;
                          }
                        }
                        selectedOfSameItens=0;

                        //salva no shared para continuar de onde parou em outra sessão
                        SharedPrefsUtils().saveListOfItemsInShared(moveClass.itemsSelectedCart);

                        isLoading = false;

                        setState(() {
                          customItem=false;
                        });

                      },
                      color: CustomColors.blue,
                      child: WidgetsConstructor().makeText('Adicionar à mudança', Colors.white, 17.0, 0.0, 0.0, 'center'),
                    ),
                  ),

                ],
              )
          ),
        );

      },
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
                            //ItemClass item = ItemClass(myData[selectedIndex]['name'].toString(), myData[selectedIndex]['weigth'], myData[selectedIndex]['singlePerson'], myData[selectedIndex]['volume'], myData[selectedIndex]['image']);
                            ItemClass item = ItemClass(myData[selectedIndex]['name'].toString(), myData[selectedIndex]['weigth'], myData[selectedIndex]['singlePerson'], myData[selectedIndex]['volume']);
                            //adiciona a lista disponivel no model
                            if(moveClass.itemsSelectedCart == null){
                              List<ItemClass>list=[];
                              list.add(item);
                              moveClass.itemsSelectedCart = list;
                              selectedItemsChartModel.addItemToChart(item);
                              //moveClass.itemsSelectedCart.add(item);
                            } else {
                              selectedItemsChartModel.addItemToChart(item);
                              moveClass.itemsSelectedCart.add(item);
                            }

                            cont++;
                          }
                        }
                        selectedOfSameItens=0;
                        showPopUpQuant=false;

                        //salva no shared para continuar de onde parou em outra sessão
                        SharedPrefsUtils().saveListOfItemsInShared(moveClass.itemsSelectedCart);

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

        print("teste "+selectedItemsChartModel.getItemsChartSize().toString());

        return Container(
          child: Padding(
            padding: EdgeInsets.all(1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: (){
                    setState(() {
                      showListOfItemsEdit=true;
                      showSelectItemPage=false;
                      showDetalhesLocalPage=false;
                    });
                  },
                  child: Container(
                    width: widthPercent*0.60,
                    height: heightPercent*0.10,
                    child: Row(
                      children: [
                        moveClass.itemsSelectedCart == null || moveClass.itemsSelectedCart.length == 0
                            ? WidgetsConstructor().makeSimpleText(
                            "Nenhum item escolhido", Colors.redAccent, 15.0)
                            : GestureDetector(
                          onTap: (){

                            setState(() {
                              showListOfItemsEdit=true;
                              showSelectItemPage=false;
                              showDetalhesLocalPage=false; //fecha as duas pq uso o mesmo widget. O user pode querer editar a lista na página 2
                            });

                          },
                          child: WidgetsConstructor().makeSimpleText(
                              "Itens: ", Colors.blue, 15.0),
                        ),
                        moveClass.itemsSelectedCart == null || moveClass.itemsSelectedCart.length == 0
                            ? Container()
                            : WidgetsConstructor().makeSimpleText(moveClass.itemsSelectedCart.length.toString(), Colors.blue, 15.0),

                      ],
                    ),
                  ),
                ),

                moveClass.itemsSelectedCart == null || moveClass.itemsSelectedCart.length == 0
                    ? Container() :
                Positioned(
                  right: 5.0, child: Container(width: 40.0,
                  height: 40.0,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.redAccent,),
                    onPressed: () {
                      setState(() {
                        SharedPrefsUtils().clearListInShared(moveClass.itemsSelectedCart.length);
                        selectedItemsChartModel.clearChart();
                        moveClass.itemsSelectedCart.clear();

                        _displaySnackBar(context, "Todos os itens foram removidos");
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
                    showDetalhesLocalPage=false;
                    showSelectItemPage=true;
                  } else if(option==2) {
                    //volta pra pagina 2 (customItemPage)
                    isLoading=false;
                    showDetalhesLocalPage=true;
                    showSelectTruckPage=false;
                  } else if(option==3){
                    //volta pra página 3 (select car)
                    showSelectTruckPage=true;
                    showAddressesPage=false;
                    origemAddressVerified="";
                  } else if(option==4){
                    //volta para pagina 4 (selectAdress)
                    showAddressesPage=true;
                    showChooseTruckerPage=false;
                  } else if(option==5){
                    //volta para a página de selecionar o freiteiro , fecha a pagina de selecionar data
                    showChooseTruckerPage=true;
                    showDatePage=false;
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

    if(precoCadaAjudante==0.0){
      precoCadaAjudante = await FirestoreServices().loadCommoditiesAjudanteFromDb();
      precoBaseFreteiro = await FirestoreServices().loadCommoditiesFreteiroFromDb();
      precoGasolina = await FirestoreServices().loadCommoditiesGasolinaFromDb();
    }

    //print('preco ajudante '+precoCadaAjudante.toString());

    /*
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

     */

  }

  void calculateThePrice() async {
    setState(() {
      isLoading=true;
    });
    //carrega o preco das coisas do bd
    //loadDataFromDb();

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

      //custo com ajudantes
      custoAjudantes = moveClass.ajudantes*precoCadaAjudante;
      custoTotal=custoTotal+custoAjudantes;

      //custo de cada caminhão adicionado
      custoTotal=custoTotal+precoBaseFreteiro+moveClass.giveMeThePriceOfEachvehicle(moveClass.carro);

      //custo de cada móvel
      totalExtraProducts = 0.0;
      moveClass.itemsSelectedCart.forEach((element) {

        totalExtraProducts = totalExtraProducts+3.00;
      });
      custoTotal = custoTotal+totalExtraProducts;

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

  void scheduleAmove(UserModel userModel) async {

    FirestoreServices().scheduleAmoveInBd(moveClass,() {_onSucess(userModel); }, () {_onFailure();});

  }

  void _onSucess(UserModel userModel){

    //set it on userModel
    userModel.updateThisUserHasAmove(true);

    //lets schedule a notification for 24 earlyer
    DateTime moveDate = MoveClass().formatMyDateToNotify(moveClass.dateSelected, moveClass.timeSelected);
    DateTime notifyDateTime = dateUtils.DateServices().subHoursFromDate(moveDate, 24); //ajusta 24 horas antes
    NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, moveClass.userId, "Lembrete: Sua mudança é amanhã às "+moveClass.timeSelected, notifyDateTime);


    //notificação com 2 horas de antecedencia (obs: o id da notificação é moveID (id do cliente+2)
    notifyDateTime = dateUtils.DateServices().subHoursFromDate(moveDate, 2); //ajusta 2 horas antes
    NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, moveClass.userId+'2', "Lembrete: Mudança em duas horas. Realize pagamento para confirmar." , notifyDateTime);


    _displaySnackBar(context, "agendado");
    //continuar aqui
    /*
    adicionar uma variavel bool e criar uma nova tela para agendar horário e data antes de salvar no fb
     */
  }

  void _onFailure(){
    _displaySnackBar(context, "Ocorreu um erro. O agendamento não foi feito. Verifique sua internet e tente novamente");
    setState(() {
      isLoading=false;
    });
  }

  void _onSucessDelete(){
    _displaySnackBar(context, "O agendamento está sendo cancelado.");
    waitAmoment(3);


    FirestoreServices().notifyTruckerThatHeWasChanged(moveClass.freteiroId, moveClass.userId); //alerta ao freteiro que ele foi cancelado na mudança. No freteiro vai recuperar isso para cancelar as notificações locais.
    //cancelar as notificações neste caso
    NotificationMeths().turnOffNotification(flutterLocalNotificationsPlugin); //apaga todas as notificações deste user

    //retorna pra página principal
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => HomePage()));
    //continuar aqui
    /*
    adicionar uma variavel bool e criar uma nova tela para agendar horário e data antes de salvar no fb
     */
  }

  void _onFailureDelete(){
    _displaySnackBar(context, "Ocorreu um erro. O agendamento não foi cancelado. Tente novamente em instantes.");
  }

  _selectDate(BuildContext context) async {

    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year+5),
      helpText: "Escolha data da mudança", //opcional
      //confirmText: "ok" //opcional
      //cancelText: "ok"  //opcional
    );
    setState(() {
      if (picked != null && picked != selectedDate)
        setState(() {
          selectedDate = picked;
        });
    });

  }

  _selectTime(BuildContext context) async {

    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: "Escolha o horário", //opcional
    );
    setState(() {
      if (picked != null && picked != selectedDate)
        setState(() {
          selectedtime = picked;
        });
    });

  }

  Future<void> _makeAddressConfig () async {

    moveClass = await MoveClass().getTheCoordinates(moveClass, origemAddressVerified, destinyAddressVerified);

    setState(() {
      moveClass.enderecoOrigem = origemAddressVerified;
      moveClass.enderecoDestino = destinyAddressVerified;
    });

    calculateThePrice();

  }

  void _checkIfNeedNewTrucker(UserModel userModel) async {

    setState(() {
      isLoading=true;
    });

    Future<void> _loadMoveClassCallBack() async {

      if(moveClass.situacao=="sem motorista" || moveClass.situacao == 'trucker_quit_after_payment'){

        moveClass = await MoveClass().getTheCoordinates(moveClass, moveClass.enderecoOrigem, moveClass.enderecoDestino).whenComplete(() {

          _displaySnackBar(context, 'Selecione um novo motorista e horário');

          //await _makeAddressConfig();

          showChooseTruckerPage=true;
          showSelectItemPage=false;
          showFinalPage=false;

          setState(() {
            isLoading=false;
          });

        });



      }

    }

    FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClass, userModel, () { _loadMoveClassCallBack();} );


  }


}




/*
class SelectItensPage extends StatefulWidget {
  @override
  _SelectItensPageState createState() => _SelectItensPageState();
}

class _SelectItensPageState extends State<SelectItensPage>  with AfterLayoutMixin<SelectItensPage> {

  //variaveis da busca
  TextEditingController _searchController = TextEditingController();
  String _filter;

  //fim das variaveis da busca

  bool initialLoad=false;

  int selectedOfSameItens=0;
  var myData;
  int selectedIndex;

  bool showPopUpQuant=false;

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  ScrollController _scrollController; //scroll screen to bottom

  bool isLoading=false;

  bool showSelectItemPage=true;
  bool showDetalhesLocalPage=false;
  bool showSelectTruckPage=false;
  bool showAddressesPage=false;
  bool showChooseTruckerPage=false;
  bool showDatePage=false;
  bool showFinalPage=false;
  bool showListOfItemsEdit=false;

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

  double precoCadaAjudante=50.0;
  double precoGasolina=5.30;
  double precoBaseFreteiro=80.0;

  double finalGasCosts=0.00;
  double distance=0.0;
  double totalExtraProducts = 0.00;

  bool showResume=false;
  bool isUpdating=false;

  //String carSelected="nao";

  TruckerClass truckerClass = TruckerClass();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedtime = TimeOfDay.now();

  bool customItem=false;

  double heightPercent;
  double widthPercent;

  String appBarTextBack='Início';
  String appBarTitleText='Itens Grandes';

  //animação do topo
  bool canScroll=false; //vai liberar o scroll so na hora da animacao
  double offset=0.0;
  ScrollController _TopAnimcrollController;
  int step=0;


  String _selectedItensLine1='';
  Map<String, int> itensMap = Map();
  Map<String, int> itensIndex = Map();

  bool _showTip=true;

  bool _showListAnywhere=false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  @override
  Future<void> afterFirstLayout(BuildContext context) async {


      Future.delayed(Duration(seconds: 2)).then((value) {
        setState(() {
          _showTip=false;
        });
      });



  }

  @override
  Future<void> initState(){
    super.initState();

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
    _TopAnimcrollController.dispose();
    super.dispose();
  }

  Future<void> deleteForTests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('situacao');
    FirestoreServices().deleteAscheduledMove(moveClass);
  }

  Future<void> _loadTheListFromAndPutInScreen(UserModel userModel, SelectedItemsChartModel selectedItemsChartModel) async {

    void _listIsUpToRead(){

      moveClass.itemsSelectedCart = selectedItemsChartModel.itemsSelectedCart;

      //preenche os itens da primeira página
      if(moveClass.itemsSelectedCart.isNotEmpty){
        int cont=0;
        while(cont<moveClass.itemsSelectedCart.length){
          String item = moveClass.itemsSelectedCart[cont].name;
          if(itensMap.containsKey(item)){
            int total = itensMap[item];
            itensMap[item]=total+1;
          } else {
            itensMap[item]=1;
          }
          cont++;
          //moveClass.itemsSelectedCart['name'];
        }
      }
      if(itensMap.length!=0){
        setState(() {
          itensMap=itensMap;
        });
      }

    }

    if(initialLoad==false){
      initialLoad=true;
      checkIfExistsInShared(userModel); //it will also check if there is in firebase if there is no data in shared

      await loadItemsFromShared(selectedItemsChartModel, () {_listIsUpToRead();});
      //moveClass.itemsSelectedCart = selectedItemsChartModel.itemsSelectedCart;
    }

  }

  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<SelectedItemsChartModel>(
      builder: (BuildContext context, Widget child, SelectedItemsChartModel selectedItemsChartModel) {
        return ScopedModelDescendant<UserModel>(
          builder: (BuildContext context, Widget child, UserModel userModel){

            _loadTheListFromAndPutInScreen(userModel, selectedItemsChartModel);

            return SafeArea(child:
                Scaffold(
                  body: Stack(
                    children: [

                      showSelectItemPage==true ? selectItemsPage()
                          : showDetalhesLocalPage==true ? detalhesLocalPage()
                          : showSelectTruckPage==true ? selectTruckPage()
                          : showAddressesPage==true ?  selectAdressPage()
                          : showChooseTruckerPage==true ? chooseTruckerPage()
                          : showDatePage==true ? datePage()
                          : showFinalPage==true ? finalPage()
                          :showListOfItemsEdit==true ? editListOfItemsPage()
                          : _showListAnywhere==true ? listAnywhere()
                          : Container(),

                      //animação
                      Positioned(
                          top: heightPercent*0.07,
                          width: widthPercent,
                          child: _itensPageAnim()),

                      //appbar
                      Positioned(
                        top: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: customFakeAppBar(),),



                    ],
                  ),
                )

            );

          },
        );



    },
    );

    /*
    return  showCustomItemPage==false && showSelectTruckPage==false
        ? selectItemsPage() :
        showCustomItemPage==true ? customItemPage() : selectTruckPage();

     */
  }

  Widget selectItemsPage (){

    heightPercent = MediaQuery
        .of(context)
        .size
        .height;

    widthPercent = MediaQuery
        .of(context)
        .size
        .width;


    bool lastItem=false;

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        return ScopedModelDescendant<SelectedItemsChartModel>(
          builder: (BuildContext context, Widget child, SelectedItemsChartModel selectedItemsChartModel){



            return Scaffold(
              key: _scaffoldKey,
              floatingActionButton: FloatingActionButton(
                  backgroundColor: CustomColors.yellow,
                  child: Icon(Icons.navigate_next, size: 50.0,),
                  onPressed: () {

                    if(itensMap.length!=0){

                      if(moveClass.itemsSelectedCart!=null){
                        SharedPrefsUtils().clearListInShared(moveClass.itemsSelectedCart.length);
                        selectedItemsChartModel.clearChart();
                        moveClass.itemsSelectedCart.clear();
                      }

                      itensMap.forEach((key, value) {

                        int cont=0;
                        while(cont<value){
                          int indexHere = itensIndex[key];
                          ItemClass item = ItemClass(myData[indexHere]['name'].toString(), myData[indexHere]['weigth'], myData[indexHere]['singlePerson'], myData[indexHere]['volume']);
                          if(moveClass.itemsSelectedCart == null){
                            List<ItemClass>list=[];
                            list.add(item);
                            moveClass.itemsSelectedCart = list;
                            selectedItemsChartModel.addItemToChart(item);
                            //moveClass.itemsSelectedCart.add(item);
                          } else {
                            selectedItemsChartModel.addItemToChart(item);
                            moveClass.itemsSelectedCart.add(item);
                          }
                          cont++;
                        }


                      });

                      selectedItemsChartModel.updateItemsSelectedCartList(moveClass.itemsSelectedCart);
                      SharedPrefsUtils().saveListOfItemsInShared(moveClass.itemsSelectedCart);


                      //exibe a proxima página
                      showSelectItemPage=false;
                      showDetalhesLocalPage=true;
                      appBarTextBack='Itens';
                      setState(() {
                        appBarTitleText='Observações';
                      });

                    } else {
                      _displaySnackBar(context, "Você não selecionou nenhum item para a mudança");
                    }


                    /*
                    if(selectedItemsChartModel.getItemsChartSize()!=0){

                      //update the moveClass for the firstTime
                      moveClass.itemsSelectedCart = selectedItemsChartModel.itemsSelectedCart;
                      //salva no shared para continuar de onde parou em outra sessão
                      SharedPrefsUtils().saveListOfItemsInShared(moveClass.itemsSelectedCart);
                      //exibe a proxima página
                      showSelectItemPage=false;
                      showDetalhesLocalPage=true;
                      appBarTextBack='Itens';
                      setState(() {
                        appBarTitleText='Observações';
                      });


                      /*
                      setState(() {
                        _topAnimScroll();
                      });

                       */

                    } else {
                      _displaySnackBar(context, "Você não selecionou nenhum item para a mudança");
                    }

                     */



                  }),

              body: Container(
                width: widthPercent,
                height: heightPercent,
                color: Colors.white,
                child: Stack(
                  children: [


                    //barra de busca
                    Positioned(
                      top: heightPercent*0.27,
                      left: widthPercent*0.05,
                      right: widthPercent*0.05,
                      child: Container(
                        height: 60.0,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(suffixIcon: Icon(
                              Icons.search),labelText: 'Busque aqui'),
                        ),
                      ),),

                    //barra marrom com os itens selecionados
                    //query com futurebuilder
                    Positioned(

                      top: heightPercent*0.37,
                      left: widthPercent*0.05,
                      right: widthPercent*0.05,
                      bottom: heightPercent*0.10,
                      child: Column(
                        children: [

                          _selectedItensLine1.isNotEmpty
                              ? Container(
                            color: CustomColors.brown,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                WidgetsConstructor().makeText('Itens Selecionados', Colors.black, 16.0, 2.0, 0.0, 'no'),
                                WidgetsConstructor().makeText(_selectedItensLine1, Colors.black, 13.0, 5.0, 3.0, 'no'),
                              ],
                            ),
                          ) : Container(),

                          Expanded(child:FutureBuilder(
                            future: DefaultAssetBundle.of(context).loadString(
                                'loadjson/itens.json'),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(child: CircularProgressIndicator(),);
                              }
                              myData = json.decode(snapshot.data);
                              print(myData);

                              return ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  print(index+1);
                                  print(myData.length);
                                  if(index+1==myData.length){
                                    lastItem=true;
                                    print('last item enocntrado em index '+index.toString());
                                  }
                                  return _filter == null || _filter == ""
                                      ? InkWell(
                                    onTap: (){
                                      selectedIndex = index;

                                      /*
                                      setState(() {
                                        if(myData[index]['name'].toString() == 'Outro'){
                                          print('outro');
                                          customItem = true;
                                        }
                                      });

                                       */

                                    },
                                    child: _itemCard(index, lastItem),
                                  ) //card com resultado se não tiver filtro
                                      : myData[index]['name'].toString().toLowerCase().contains(_filter)
                                      ? InkWell(
                                    onTap: (){
                                      selectedIndex = index;

                                      /*
                                      setState(() {
                                        if(myData[index]['name'].toString() == 'Outro'){
                                          print('outro');
                                          customItem = true;
                                        }
                                      });
                                       */
                                    },
                                    child: _itemCard(index, lastItem),
                                  ) //card com resultado com filtro
                                      : Container(); //card caso nao tenha nada para exibir por causa do filtro


                                },
                                itemCount: myData == null ? 0 : myData.length,
                                //itemCount: myData == null ? 0 : 5,  //mudar aqui para alterar quantidade de itens

                              );
                            },
                          ) ),



                        ],
                      ),
                    ),


                    isLoading == true
                        ? Center(
                      child: CircularProgressIndicator(),
                    ): Container(),

                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _currentSliderValue = 0.0;

  Widget detalhesLocalPage(){

    loadDataFromDb();

    TextEditingController _psController = TextEditingController();
    TextEditingController _qntLancesEscadaController = TextEditingController();


    //verifica para lembrar a opção que o user deixou
    if(moveClass.escada==true){
      if(moveClass.lancesEscada.toString()!="null"){
        _qntLancesEscadaController.text = moveClass.lancesEscada.toString();
      }
    }

    if(moveClass.ps!=null){
      _psController.text=moveClass.ps;
    }


    _qntLancesEscadaController.addListener(() {
      moveClass.lancesEscada= int.parse(_qntLancesEscadaController.text);
    });

    _psController.addListener(() {
      moveClass.ps = _psController.text;
    });

    if(moveClass.ps!=null){
      _psController.text = moveClass.ps;
    }

    if(moveClass.escada==null){
      moveClass.escada=false;
    }


    return ScopedModelDescendant<SelectedItemsChartModel>(
      builder: (BuildContext context, Widget widget, SelectedItemsChartModel selectedItemsChartModel){
        return Scaffold(
            key: _scaffoldKey,
            floatingActionButton: FloatingActionButton(
                backgroundColor: CustomColors.yellow,
                child: Icon(Icons.navigate_next, size: 50.0,),
                onPressed: () {

                  if(_currentSliderValue!=0){
                    moveClass.escada=true;
                    moveClass.lancesEscada = _currentSliderValue.round().toInt();
                  } else {
                    moveClass.escada=false;
                    moveClass.lancesEscada=0;
                  }
                  if(_psController.text.isEmpty){
                    moveClass.ps = "nao";
                  } else {
                    moveClass.ps = _psController.text;
                  }
                  SharedPrefsUtils().saveDataFromCustomItemPage(moveClass);

                  //exibe a proxima página
                  showDetalhesLocalPage=false;
                  showSelectTruckPage=true;
                  appBarTextBack='Obs';
                  appBarTitleText='Selecionar veículo';

                  setState(() {
                    _topAnimScroll();
                  });

                }),

            body: Container(
              width: widthPercent,
              height: heightPercent,
              color: Colors.white,
              child: Stack(
                children: [

                  Positioned(
                    top: heightPercent*0.29,
                    left: 0.5,
                    right: 0.5,
                    child:
                      Column(
                        children: [

                          Container(

                            //titulo
                            child: WidgetsConstructor().makeResponsiveText(context,
                                'Características do local', CustomColors.blue, 3, 0.0, 0.0, 'center'),),
                            SizedBox(height: heightPercent*0.04,),

                          Container(
                            width: widthPercent*0.9,
                            child: WidgetsConstructor().makeResponsiveText(context,
                                'Lances de escada', CustomColors.blue, 2.5, 0.0, 10.0, 'no'),
                          ),
                          Container(
                              width: widthPercent*0.90,
                              height: heightPercent*0.15,
                              decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 2.0, 0.0),
                            child: Column(
                              children: [

                                SizedBox(height: heightPercent*0.02,),
                                Slider(
                                  value: _currentSliderValue,
                                  min: 0,
                                  max: 20,
                                  divisions: 20,
                                  label: _currentSliderValue.round().toString(),
                                  onChanged: (double value) {
                                    setState(() {
                                      _currentSliderValue = value;
                                    });
                                  },
                                ),
                                WidgetsConstructor().makeResponsiveText(context,
                                    _currentSliderValue==0.0 ? 'Sem escada' : 'lances: '+_currentSliderValue.round().toString(),
                                    Colors.grey[400], 2.0, 5.0, 0.0, 'center'),

                              ],
                            ),
                          ),

                          SizedBox(height: heightPercent*0.05,),
                          //observacoes
                          Container(
                            width: widthPercent*0.9,
                            child: WidgetsConstructor().makeResponsiveText(context,
                                'Observações', CustomColors.blue, 2.5, 0.0, 10.0, 'no'),
                          ),

                          Container(
                            width: widthPercent*0.90,
                            height: heightPercent*0.15,
                            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 2.0, 0.0),
                            child: TextField(
                              controller: _psController,
                              decoration: new InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                                  hintText: 'Suas observações aqui, se houver.'
                              ),
                            ),
                          ),

                          //slider



                        ],
                      )
                  ),


                ],
              ),
            )

          /*
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
                              value: moveClass.escada,
                              onChanged: (bool value){
                                setState(() {
                                  if(value==true){
                                    moveClass.escada=true;
                                  } else {
                                    moveClass.escada=false;
                                  }
                                  //_escadaCheckBoxvar = value;

                                });
                              }
                          ),
                        ],
                      ),
                      //linha para dizer quantos lances
                      moveClass.escada== true ? Container(
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
            ),

           */

        );
      },
    );
  }

  /*
  Widget detalhesLocalPage(){

    loadDataFromDb();

    TextEditingController _psController = TextEditingController();
    TextEditingController _qntLancesEscadaController = TextEditingController();


    //verifica para lembrar a opção que o user deixou
    if(moveClass.escada==true){
      if(moveClass.lancesEscada.toString()!="null"){
        _qntLancesEscadaController.text = moveClass.lancesEscada.toString();
      }
    }

    if(moveClass.ps!=null){
      _psController.text=moveClass.ps;
    }


    _qntLancesEscadaController.addListener(() {
      moveClass.lancesEscada= int.parse(_qntLancesEscadaController.text);
    });

    _psController.addListener(() {
      moveClass.ps = _psController.text;
    });

    if(moveClass.ps!=null){
      _psController.text = moveClass.ps;
    }

    if(moveClass.escada==null){
      moveClass.escada=false;
    }


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
                        showDetalhesLocalPage=false;
                      showSelectTruckPage=true;

                      //save em shared
                      SharedPrefsUtils().saveDataFromCustomItemPage(moveClass);

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
                                  value: moveClass.escada,
                                  onChanged: (bool value){
                                    setState(() {
                                      if(value==true){
                                        moveClass.escada=true;
                                      } else {
                                        moveClass.escada=false;
                                      }
                                      //_escadaCheckBoxvar = value;

                                    });
                                  }
                              ),
                            ],
                          ),
                          //linha para dizer quantos lances
                          moveClass.escada== true ? Container(
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

   */
  Widget selectTruckPage(){

    initialLoad=false; //ajusta para as proximas telas

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

                if(moveClass.carro!=null){
                  //ajusta a quantidade de ajudantes desta mudança
                  moveClass.ajudantes = helpersContracted;
                  //moveClass.carro = carSelected;
                  SharedPrefsUtils().saveDataFromSelectTruckPage(moveClass);
                  initialLoad=false;
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
                                //carSelected="pickupP";
                                moveClass.carro="pickupP";
                              } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="carroça"){
                                //carSelected="carroca";
                                moveClass.carro="carroca";
                              } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="pickup grande"){
                                //carSelected="pickupG";
                                moveClass.carro="pickupG";
                              } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="kombi aberta"){
                                //carSelected="kombiA";
                                moveClass.carro="kombiA";
                              } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="kombi fechada"){
                                //carSelected="kombiF";
                                moveClass.carro="kombiF";
                              } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="caminhao pequeno aberto"){
                                //carSelected="caminhaoPA";
                                moveClass.carro="caminhaoPA";
                              } else if(TruckClass.empty().discoverTheBestTruck(selectedItemsChartModel.getTotalVolumeOfChart())=="caminhao baú pequeno") {
                                //carSelected = "caminhaoBP";
                                moveClass.carro= "caminhaoBP";
                              } else {
                                //carSelected = "caminhaoBG";
                                moveClass.carro= "caminhaoBG";
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
                                  //carSelected = "carroca";
                                  moveClass.carro = "carroca";
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
                                  //carSelected = "pickupP";
                                  moveClass.carro = "pickupP";
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
                                  //carSelected = "pickupG";
                                  moveClass.carro = "pickupG";
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
                                  //carSelected = "kombiA";
                                  moveClass.carro = "kombiA";
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
                                  //carSelected = "caminhaoPA";
                                  moveClass.carro = "caminhaoPA";
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
                                  //carSelected = "kombiF";
                                  moveClass.carro = "kombiF";
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
                                  //carSelected = "caminhaoBP";
                                  moveClass.carro = "caminhaoBP";
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
                                  //carSelected = "caminhaoBG";
                                  moveClass.carro = "caminhaoBG";
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
                          child: WidgetsConstructor().makeText("Veículo selecionado: "+TruckClass.empty().formatCodeToHumanName(moveClass.carro.toString()), Colors.blue, 18.0, 10.0, 30.0, null),
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

                              if(moveClass.carro!=null){
                                //ajusta a quantidade de ajudantes desta mudança
                                moveClass.ajudantes = helpersContracted;
                                //moveClass.carro = carSelected;
                                SharedPrefsUtils().saveDataFromSelectTruckPage(moveClass);
                                initialLoad=false;
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


    String enderecoOrigem = moveClass.enderecoOrigem?? 'nao';

    if(enderecoOrigem!='nao' && initialLoad==false){
      _sourceAdress.text = moveClass.enderecoOrigem;
      findAddress(_sourceAdress, "origem");
      fakeClickIncludeEndereco();
    }

    String enderecoDest = moveClass.enderecoDestino?? 'nao';

    if(enderecoDest!='nao' && initialLoad==false){
      initialLoad=true;
      _destinyAdress.text = moveClass.enderecoDestino;
      findAddress(_destinyAdress, "destiny");
      fakeClickIncludeEndereco();
    }

    //loadDataFromDb();

    return Scaffold(
      key: _scaffoldKey,

      body: ListView(
        controller: _scrollController,
        children: [
          Container(
            color: Colors.white,
            child: ScopedModelDescendant<UserModel>(
                builder: (BuildContext context, Widget widget, UserModel userModel){

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
                                              scrollToBottom();
                                            } else {
                                              _displaySnackBar(context, "O CEP deve ter apenas números");
                                            }

                                          } else {

                                            if(_destinyAdress.text.contains("0") || _destinyAdress.text.contains("1") || _destinyAdress.text.contains("2") || _destinyAdress.text.contains("3") || _destinyAdress.text.contains("4") || _destinyAdress.text.contains("5") || _destinyAdress.text.contains("6") || _destinyAdress.text.contains("7") || _destinyAdress.text.contains("8") || _destinyAdress.text.contains("9") ){
                                              findAddress(_destinyAdress, "destiny");
                                              scrollToBottom();
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
                          await _makeAddressConfig();
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
                                //WidgetsConstructor().makeText(custoAjudantes.toStringAsFixed(2), Colors.black, 14.0, 15.0, 5.0, null),
                                WidgetsConstructor().makeText((precoCadaAjudante*moveClass.ajudantes).toStringAsFixed(2), Colors.black, 14.0, 15.0, 5.0, null),

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
                        onTap: () async {

                          await SharedPrefsUtils().saveDataFromSelectAddressPage(moveClass);

                          /*
                          setState(() {
                            isLoading=true;

                          });
                          
                           */


                          setState(() {
                            isLoading=true;
                            showChooseTruckerPage=true;
                            //isUpdating=false;
                            showAddressesPage=false;
                          });



                        },
                        child: WidgetsConstructor().makeButton(Colors.blue, Colors.transparent, widthPercent*0.85, heightPercent*0.08,
                            2.0, 4.0, "Aceitar o preço e agendar", Colors.white, 18.0),
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

  Widget chooseTruckerPage(){

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
            child: ScopedModelDescendant<UserModel>(
                builder: (BuildContext context, Widget widget, UserModel userModel){


                  /*
                  if(isUpdating==false) {
                    isUpdating = true;
                    checkIfExistsAscheduledMoveInFb(userModel);
                  }

                   */

                  final double lat = moveClass.latEnderecoOrigem;
                  final double long = moveClass.longEnderecoOrigem;
                  final double latlong = lat + long;  //esta latlong é um double para calculos
                  //double startAtval = latlong-(0.01*0.6);
                  double startAtval = latlong-(0.05*5.0);
                  //final double endAtval = latlong+(0.01*0.6);
                  final double endAtval = latlong+(0.05*5.0);
                  final double dif = -0.07576889999999992;
                  startAtval = (dif+startAtval); //ajusta erro que percebi testando

                  
                  /*
                  Query query =
                  FirebaseFirestore.instance.collection(moveClass.carro).where('latlong', isGreaterThanOrEqualTo: startAtval)
                      .where('latlong', isLessThan: endAtval).where('banido', isEqualTo: false);
                   */
                  
                  Query query = FirebaseFirestore.instance.collection('truckers').where('latlong', isGreaterThanOrEqualTo: startAtval)
                      .where('latlong', isLessThan: endAtval).where('banido', isEqualTo: false).where('listed', isEqualTo: true)
                      .where('vehicle', isEqualTo: moveClass.carro);




                  //https://morioh.com/p/b7b4a0b44c9c
                  //video para seguir

                  return Stack(
                    children: [

                      Column(
                        children: [
                          //barra superior
                          topCustomBar(heightPercent, widthPercent, "Escolher profissional", 4),

                          SizedBox(height: 20.0,),
                          moveClass.nomeFreteiro != null ?
                          Container(
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                children: [

                                  WidgetsConstructor().makeText("Você já selecionou um profissional", Colors.blue, 17.0, 15.0, 12.0, "center"),
                                  Row(
                                    children: [
                                      moveClass.freteiroImage != null
                                      ? CircleAvatar(
                                        backgroundImage: NetworkImage(moveClass.freteiroImage),
                                      )
                                      : Image.asset('images/carrinhobaby'),
                                      WidgetsConstructor().makeText(moveClass.nomeFreteiro, Colors.blue, 16.0, 10.0, 10.0, "center"),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  ),

                                ],
                              ),
                            ),
                            width: widthPercent*0.8,
                            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 4.0),
                          ) : Container(),

                          SizedBox(height: 20.0,),

                          Container(
                            height: heightPercent*0.6,
                            width: widthPercent*0.9,
                            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 4.0),
                            child: Column(
                              children: [
                                WidgetsConstructor().makeText("Freteiros próximos de você", Colors.blue, 15.0, 15.0, 15.0, "center"),
                                SizedBox(height: 20.0,),

                                //tentando modelo do site do fireastore update
                                StreamBuilder<QuerySnapshot>(
                                  stream: query.snapshots(),
                                    builder: (context, stream){

                                      if (stream.connectionState == ConnectionState.waiting) {
                                        return Center(child: CircularProgressIndicator());
                                      }

                                      if (stream.hasError) {
                                        return Center(child: Text(stream.error.toString()));
                                      }

                                      QuerySnapshot querySnapshot = stream.data;

                                      return
                                          querySnapshot.size == 0
                                          ? Center(child: Text("Não encontramos profissionais próximos."),)
                                          : Expanded(child: ListView.builder(
                                              itemCount: querySnapshot.size,
                                              //itemBuilder: (context, index) => Trucker(querySnapshot.docs[index]),
                                              itemBuilder: (context, index) {

                                                Map<String, dynamic> map = querySnapshot.docs[index].data();
                                                return GestureDetector(
                                                  onTap: (){

                                                    setState(() {

                                                      print(querySnapshot.docs[index].id);

                                                      //agendar
                                                      truckerClass.image=map['image'];
                                                      truckerClass.id=querySnapshot.docs[index].id;
                                                      truckerClass.name=map['apelido'];
                                                      truckerClass.aval=map['aval'].toDouble();

                                                      //print(documents[index].documentID); apareceu deprecated
                                                      //moveClass.freteiroId = documents[index].documentID; apareceu deprecated;
                                                      moveClass.freteiroId = querySnapshot.docs[index].id;
                                                      moveClass.userId = UserModel().Uid;
                                                      moveClass.nomeFreteiro = map['apelido']; //antigamente pegava de 'name'.
                                                      moveClass.freteiroImage = map['image'];
                                                      moveClass.placa = map['placa'];
                                                      SharedPrefsUtils().saveDataFromSelectTruckERPage(moveClass);


                                                      showPopupFinal=true;
                                                      //scheduleAmove();

                                                    });



                                                  },
                                                  //child: Text(map['name']),
                                                  child: truckerSelectListViewLine(map),
                                                );
                                                //return Trucker(querySnapshot.docs[index]);

                                              } ),);

                                    },
                                ),


                              ],
                            ),
                          ),



                        ],
                      ),



                      showPopupFinal == true ? Positioned(

                        top: 25.0,
                        left: 25.0,
                        right: 25.0,
                        child: Container(
                          decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 4.0, 5.0),
                          width: 100.0,
                          child: Column(
                            children: [
                              //titulo
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    child:WidgetsConstructor().makeButton(Colors.grey, Colors.black, widthPercent*0.1, 40.0, 1.0, 3.0, "X", Colors.black, 40.0),
                                    onTap: (){
                                      setState(() {
                                        showPopupFinal=false;
                                      });

                                    },
                                  ),

                                ],
                              ),
                              WidgetsConstructor().makeText("Confirmar agendamento", Colors.blue, 17.0, 30.0, 10.0, "center"),
                              SizedBox(height: 20.0,),
                              //imagem perfil
                              Container(
                                width: 150.0,
                                height: 150.0,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(truckerClass.image),
                                ),
                              ),
                              WidgetsConstructor().makeText(truckerClass.name, Colors.blue, 20.0, 15.0, 10.0, "center"),
                              WidgetsConstructor().makeText("Classificação: "+truckerClass.aval.toStringAsFixed(2), Colors.black, 18.0, 5.0, 15.0, "center"),
                              SizedBox(height: 30.0,),
                              GestureDetector(
                                child: WidgetsConstructor().makeButton(Colors.blue, Colors.blue, widthPercent*0.5, 50.0, 2.0, 10.0, "agendar", Colors.white, 18.0),
                                onTap: (){

                                  setState(() {

                                    showChooseTruckerPage=false;
                                    showDatePage=true;
                                  });
                                  //scheduleAmove();
                                },
                              ),
                              SizedBox(height: 40.0,)

                              //Image.network(truckerClass.image, width: 200.0, height: 200.0,),

                            ],
                          ),),
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

  Widget datePage(){

    double heightPercent = MediaQuery
        .of(context)
        .size
        .height;
    double widthPercent = MediaQuery
        .of(context)
        .size
        .width;

    if(moveClass.dateSelected!=null){
        selectedDate = DateServices().convertToDateFromString(moveClass.dateSelected);
    }

    if(moveClass.timeSelected!=null){
      selectedtime = DateServices().convertStringToTimeOfDay(moveClass.timeSelected);
    }


    return ScopedModelDescendant<SelectedItemsChartModel>(
      builder: (BuildContext context, Widget widget, SelectedItemsChartModel selectedItemsChartModel){
        return ScopedModelDescendant<UserModel>(
          builder: (BuildContext context, Widget widget, UserModel userModel){
            return Scaffold(
                key: _scaffoldKey,
                body: Stack(
                  children: [

                    Container(
                      width: widthPercent,
                      height: heightPercent,
                      color: Colors.white,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [

                            //barra superior
                            topCustomBar(heightPercent, widthPercent, "Detalhamento", 5),

                            SizedBox(height: 60.0,),

                            //botao que abre o seletor de data
                            GestureDetector(
                              child: WidgetsConstructor().makeButton(Colors.blue, Colors.blue, widthPercent*0.75, 50.0, 2.0, 10.0, "Escolher data", Colors.white, 18.0),
                              onTap: (){
                                setState(() {

                                  _selectDate(context);

                                });


                              },

                            ),

                            SizedBox(height: 35.0,),
                            WidgetsConstructor().makeText("Data escolhida:", Colors.black, 20.0, 0.0, 10.0, "center"),
                            WidgetsConstructor().makeText(DateServices().convertToStringFromDate(selectedDate), Colors.blue, 20.0, 10.0, 30.0, "center"),

                            SizedBox(height: 60.0,),

                            //botao que abre o seletor de horario
                            GestureDetector(
                              child: WidgetsConstructor().makeButton(Colors.blueAccent, Colors.blueAccent, widthPercent*0.75, 50.0, 2.0, 10.0, "Escolher horário", Colors.white, 18.0),
                              onTap: (){
                                setState(() {

                                  _selectTime(context);

                                });


                              },

                            ),
                            SizedBox(height: 35.0,),

                            WidgetsConstructor().makeText("Horário escolhido:", Colors.black, 20.0, 0.0, 10.0, "center"),
                            WidgetsConstructor().makeText(selectedtime.format(context), Colors.blue, 20.0, 10.0, 30.0, "center"),

                            SizedBox(height: 35.0,),

                            //botao final
                            GestureDetector(
                              child: WidgetsConstructor().makeButton(Colors.redAccent, Colors.redAccent, widthPercent*0.9, 50.0, 2.0, 10.0, "Confirmar com freteiro", Colors.white, 18.0),
                              onTap: (){
                                setState(() {

                                  moveClass.dateSelected = DateServices().convertToStringFromDate(selectedDate);
                                  moveClass.timeSelected = selectedtime.format(context);

                                  _displaySnackBar(context, "Contactando o freteiro...");

                                  moveClass.situacao = "aguardando_freteiro";

                                  moveClass.userId = userModel.Uid;
                                  SharedPrefsUtils().saveMoveClassToShared(moveClass);
                                  scheduleAmove(userModel);

                                  waitAmoment(3);
                                  showDatePage=false;
                                  showFinalPage=true;
                                  //agora salvar no bd (o metodo ja existe).
                                  //precisa adicionar os campos do horario e data no salvamento.

                                });


                              },

                            ),


                          ],
                        ) ,
                      ),
                      ),

                  ],
                )
            );
          },
        );
      },
    );

  }

  Widget finalPage(){

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
        children: [
          Container(
              width: widthPercent,
              height: heightPercent,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [

                    SizedBox(height: 15.0,),
                    WidgetsConstructor().makeText("Pronto. Agora aguarde a confirmação de "+moveClass.nomeFreteiro.toString(), Colors.blue, 17.0, 20.0, 20.0, "center"),
                    WidgetsConstructor().makeText("Resumo", Colors.black, 15.0, 0.0, 20.0, "center"),
                    WidgetsConstructor().makeText("Endereço de origem: "+moveClass.enderecoOrigem.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
                    WidgetsConstructor().makeText("Endereço de destino: "+moveClass.enderecoDestino.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
                    WidgetsConstructor().makeText("Data: "+moveClass.dateSelected.toString()+" às "+moveClass.timeSelected.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
                    WidgetsConstructor().makeText("Freteiro: "+moveClass.nomeFreteiro.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
                    WidgetsConstructor().makeText("Veículo: "+TruckClass().formatCodeToHumanName(moveClass.carro), Colors.black, 15.0, 0.0, 10.0, "no"),
                    WidgetsConstructor().makeText("Nº ajudantes: "+moveClass.ajudantes.toString(), Colors.black, 15.0, 0.0, 10.0, "no"),
                    WidgetsConstructor().makeText("Preço: R\$"+moveClass.preco.toStringAsFixed(2), Colors.black, 15.0, 0.0, 10.0, "no"),
                    WidgetsConstructor().makeText("Situação: "+MoveClass().formatSituationToHuman(moveClass.situacao), Colors.redAccent, 15.0, 0.0, 12.0, "no"),

                    SizedBox(height: 25.0,),
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop();
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => HomePage()));
                      },
                      child:WidgetsConstructor().makeButton(Colors.blue, Colors.blue, widthPercent*0.75, 50.0, 2.0, 4.0, "Fechar", Colors.white, 16.0),
                    ),

                    SizedBox(height: 10.0,),
                    GestureDetector(
                      onTap: (){
                          SharedPrefsUtils().clearScheduledMove();
                          FirestoreServices().deleteAscheduledMove(moveClass, () {_onSucessDelete(); }, () { _onFailureDelete(); });
                          setState(() {
                            isLoading=true;
                          });
                      },
                      child:WidgetsConstructor().makeButton(Colors.redAccent, Colors.redAccent, widthPercent*0.75, 50.0, 2.0, 4.0, "Cancelar", Colors.white, 16.0),
                    ),



                  ],
                ),
              )
          ),
        ],
      )
    );

  }

  Widget editListOfItemsPage(){

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

        print("Teste 3 "+selectedItemsChartModel.getItemsChartSize().toString());

        moveClass.itemsSelectedCart = selectedItemsChartModel.getList;
        print("Teste 4 "+moveClass.itemsSelectedCart.length.toString());

        return Scaffold(
          key: _scaffoldKey,
          body:  Container(
              child: Column(
                children: [

                  SizedBox(height: 30.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CloseButton(
                        onPressed: (){
                          setState(() {
                            showListOfItemsEdit=false;
                            showSelectItemPage=true;
                          });
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 10.0),
                  WidgetsConstructor().makeText("Seus itens na mudança", Colors.blue, 17.0, 0.0, 10.0, "center"),
                  SizedBox(height: heightPercent*0.7,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: moveClass.itemsSelectedCart.length,
                    itemBuilder: (context, index) {
                      final item = moveClass.itemsSelectedCart[index];

                      //obs TUDO QUE MEXER NA LISTA ATUALIZAR NA MOVECLASS E NA MODEL PRA N DAR ERRO EM NENHUM LUGAR
                      return Card(
                        child: ListTile(
                          title: Text(item.name),
                          leading: Image.asset(item.image),
                          trailing: CloseButton(
                            color: Colors.red,
                            onPressed: (){
                              setState(() {
                                moveClass.itemsSelectedCart.removeAt(index);
                                _displaySnackBar(context, "Item removido");
                              });
                            },
                          ),
                        ),
                      );

                    },

                  ),
                  ),
                ],
              ),
              )
        );
      },
    );
  }

  Widget listAnywhere(){

    return Container(
      width: widthPercent,
      height: heightPercent,
      child: Column(
        children: [
          Row(
            children: [
              CloseButton(
                onPressed: (){
                  setState(() {
                    _showListAnywhere=false;
                  });
                },
              )
            ],
          ),
          selectItemsPage(),
        ],
      )
    );
  }



  //elementos do layout
  Widget customFakeAppBar(){

    void _customBackButton(){

      if(showSelectItemPage==true){
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomePage()));
      } else if(showDetalhesLocalPage==true){
        setState(() {
          showSelectItemPage=true;
          showDetalhesLocalPage=false;
        });
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
      setState(() {
        _showListAnywhere=true;
      });
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
                    Text(appBarTextBack, style: TextStyle(color: Colors.grey[400], fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
                  ],
                ),
              ),
              WidgetsConstructor().makeResponsiveText(context, appBarTitleText, _showTip==true ? Colors.white : CustomColors.blue, 3, 10.0, 0.0, 'no'),
              showSelectItemPage == true && _showTip==false ? IconButton(icon: Icon(Icons.help_outline, color: CustomColors.blue, size: 35,), onPressed: (){
                setState(() {
                  _showTip=true;
                });
              }) 
                  : showSelectItemPage == true && _showTip==true ? IconButton(icon: Icon(Icons.arrow_circle_up, color: CustomColors.blue, size: 35,), onPressed: (){
                setState(() {
                  _showTip=false;
                });
              },)
                  : IconButton(icon: Icon(Icons.assignment), onPressed: (){
                    setState(() {
                      _showListAnywhere=true;
                      showDetalhesLocalPage=false;
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

  Widget _itemCard(int index, bool lastItem){

    int qnt=0;


    if(itensMap.length!=0){
      if(itensMap.containsKey(myData[index]["name"])){
          qnt = itensMap[myData[index]["name"]];
      }
    }



    return ScopedModelDescendant<SelectedItemsChartModel>(
      builder: (BuildContext context, Widget widget, SelectedItemsChartModel selectedItemsChartModel){

        return Container(
            height: heightPercent*0.10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Image.asset(myData[index]['image']),
                    WidgetsConstructor().makeResponsiveText(context, myData[index]["name"], Colors.black, 2.5, 2.5, 2.5, 'no'),

                    Container(
                      height: heightPercent*0.09,
                      width: widthPercent*0.35,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly  ,
                        children: [
                          //minus btn
                          GestureDetector(
                            onTap: (){

                              if(qnt!=0){
                                if(qnt==1){
                                  qnt--;
                                  _removeItemToTextLine(myData[index]["name"]);
                                  itensIndex.removeWhere((key, value) => key == myData[index]["name"]);  //remove da lista de index
                                  itensMap.removeWhere((key, value) => key == myData[index]["name"]);  //remove da lista de index
                                } else {
                                  qnt--;
                                  itensMap[myData[index]["name"]]=qnt;
                                }

                                //atualiza a tela
                                setState(() {
                                });
                              }

                            },
                            child: Container(
                              width: widthPercent*0.07,
                              height: heightPercent*0.040,
                              decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 1.0, 2.0),
                              child: WidgetsConstructor().makeResponsiveText(context, '-', CustomColors.blue, 2,
                                  0.0, 0.0, 'center'),
                            ),
                          ),


                          Container(
                            width: widthPercent*0.095,
                            height: heightPercent*0.050,
                            decoration: WidgetsConstructor().myBoxDecoration(CustomColors.blue, CustomColors.blue, 1.0, 2.0),
                            child: WidgetsConstructor().makeResponsiveText(context, qnt.toString(), Colors.white, 3,
                                0.0, 0.0, 'center'),
                          ),

                          //btn plus
                          GestureDetector(
                            onTap: (){


                              if(qnt>=10){
                                //exibir mensagem avisando se tem certeza da quantidade
                                _displaySnackBar(context, "Hum, parece que temos muitos itens iguais. Tem certeza da quantidade?");
                              }
                              qnt++;
                              _addItemToTextLine(myData[index]["name"]);
                              itensIndex[myData[index]["name"]] = index; //salva o index para depois sabermos como alvar os itens
                              setState(() {
                                itensMap[myData[index]["name"]]=qnt;
                                //qnt++;
                              });


                            },
                            child: Container(
                              width: widthPercent*0.07,
                              height: heightPercent*0.040,
                              decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 1.0, 2.0),
                              child: WidgetsConstructor().makeResponsiveText(context, '+', CustomColors.blue, 2,
                                  0.0, 0.0, 'center'),
                            ),
                          ),


                        ],
                      ),
                    )

                  ],
                ),
                Container(
                  height: 2.0,
                  width: widthPercent*0.8,
                  color: Colors.grey[200],
                )
              ],
            )
            );

      },
    );
  }

  Widget _itensPageAnim(){

    _TopAnimcrollController = ScrollController();

    //para animação da tela
    _TopAnimcrollController.addListener(() {
      setState(() {
        offset = _TopAnimcrollController.hasClients ? _TopAnimcrollController.offset : 0.1;

      });
      print(offset);
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
                physics: canScroll == false ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
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

  void _topAnimScroll(){
    double offsetAcrescim=widthPercent*0.20;

    canScroll=true;
    offset=offset+offsetAcrescim;
    _TopAnimcrollController.animateTo(offset, duration: Duration(milliseconds: 450), curve:Curves.easeInOut);
    canScroll=false;
    setState(() {
      step=step+1;
    });
  }

  void _topAnimScrollBack(){
    double offsetAcrescim=widthPercent*0.19;

    canScroll=true;
    offset<0.1 ? 0.0 : offset=offset-offsetAcrescim;
    _TopAnimcrollController.animateTo(offset, duration: Duration(milliseconds: 200), curve:Curves.easeInOut);
    canScroll=false;

    if(step!=0){
      setState(() {
        step=step-1;
      });
    }

  }

  void _addItemToTextLine(String item){

    if(_selectedItensLine1.contains(item)){
      //já foi adicionado
    } else {

      String newEntry = '  #'+item.trim();
      print('foi');
      setState(() {
        _selectedItensLine1=_selectedItensLine1+newEntry;
      });

    }

  }

  void _removeItemToTextLine(String item){
    setState(() {
      _selectedItensLine1 = _selectedItensLine1.replaceAll('  #'+item.trim(), '');
    });

  }

  Future<bool> checkIfExistsAscheduledMoveInFb(UserModel userModel) async {

    FirestoreServices().checkIfExistsAmoveScheduledForItensPage(userModel.Uid, () {_onSucessScheduled(userModel);}, () {_onFailureScheduled(userModel);});

  }

  Future<void> _onSucessScheduled(UserModel userModel) async {

    _displaySnackBar(context, "Opa. Parece que você já tem uma mudança agendada.");

    void _onSucess(){

      print(moveClass);
      setState(() {
        showFinalPage=true;
        showSelectItemPage=false;
        isLoading=false;
      });

    }

    //moveClass = await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClass, userModel);
    await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClass, userModel,() {_onSucess();});

    /*
    await SharedPrefsUtils().saveMoveClassToShared(moveClass);

    setState(() {
      showFinalPage=true;
      showSelectItemPage=false;
      isLoading=false;
    });
     */

  }


  void _onFailureScheduled(UserModel userModel){
    //do nothing, open normal next page
    _checkIfNeedNewTrucker(userModel); //verifica se precisa trocar o motorista
    setState(() {
      //showChooseTruckerPage=true;
      //showAddressesPage=false;
      isLoading=false;
    });

  }

  Future<Widget> checkIfExistsInShared(UserModel userModel) async {

    checkIfExistsAscheduledMoveInFb(userModel); //se quiser voltar com o shared, apagar esta linha. Ela fica no else abaixo

    //disabled. Agora n pega mais no shared
    /*
    if(await SharedPrefsUtils().checkIfThereIsScheduledMove()==true){

      moveClass = await SharedPrefsUtils().loadMoveClassFromSharedPrefs(moveClass);

      setState((){
        showFinalPage = true;
        showSelectItemPage=false;

      });

      _checkIfNeedNewTrucker();

    } else {
      //if there is no data in shared, check in firebase
      checkIfExistsAscheduledMoveInFb(userModel);
    }

     */

  }

  Widget truckerSelectListViewLine(Map map){

    return Padding(
        padding: EdgeInsets.only(bottom: 4, top: 4, right: 5, left: 5),
        child: Container(
            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 3.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Text(map['name']),
                          Text(map['apelido']),
                          //Text(map['aval'].toString()),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              map['rate']<0.4
                                  ? Icon(Icons.star_border, color: Colors.yellow[600], size: 20.0,)
                                  : map['rate']<1
                                  ? Icon(Icons.star_half, color: Colors.yellow[600], size: 20.0,)
                                  : Icon(Icons.star, color: Colors.yellow[600], size: 20.0,),

                              map['rate']<=1.4
                                  ?Icon(Icons.star_border, color: Colors.yellow[600], size: 20.0,)
                                  : map['rate']<2
                                  ? Icon(Icons.star_half, color: Colors.yellow[600], size: 20.0,)
                                  : Icon(Icons.star, color: Colors.yellow[600], size: 20.0,),

                              map['rate']<=2.4
                                  ?Icon(Icons.star_border, color: Colors.yellow[600], size: 20.0,)
                                  : map['rate']<3
                                  ? Icon(Icons.star_half, color: Colors.yellow[600], size: 20.0,)
                                  : Icon(Icons.star, color: Colors.yellow[600], size: 20.0,),


                              map['rate']<=3.4
                                  ?Icon(Icons.star_border, color: Colors.yellow[600], size: 20.0,)
                                  : map['rate']<4
                                  ? Icon(Icons.star_half, color: Colors.yellow[600], size: 20.0,)
                                  : Icon(Icons.star, color: Colors.yellow[600], size: 20.0,),

                              map['rate']<=4.4
                                  ?Icon(Icons.star_border, color: Colors.yellow[600], size: 20.0,)
                                  : map['rate']<5
                                  ? Icon(Icons.star_half, color: Colors.yellow[600], size: 20.0,)
                                  : Icon(Icons.star, color: Colors.yellow[600], size: 20.0,),


                            ],
                          ),

                          //metadata,
                          //genres,
                        ],
                      )),
                  Container(width: 100, child: Center(child: Image.network(map['image']))),


                ],
              ),
              WidgetsConstructor().makeText('Corridas no app: '+map['aval'].toString(), Colors.black, 16.0, 15.0, 15.0, 'no'),
              WidgetsConstructor().makeText('Placa do veículo: '+map['placa'].toString(), Colors.black, 16.0, 15.0, 15.0, 'no'),
              //foto do carro
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(width: 75, child: Center(child: Image.network(map['vehicle_image']))),
                ],
              )
            ],
          )
        ));
    
  }

  Future<void> fakeClickIncludeEndereco() async {

    moveClass = await MoveClass().getTheCoordinates(moveClass, origemAddressVerified, destinyAddressVerified);
    setState(() {
      moveClass.enderecoOrigem = origemAddressVerified;
      moveClass.enderecoDestino = destinyAddressVerified;
    });

    calculateThePrice();

    scrollToBottom();

  }

  Future<void> loadMoveClassFromShared() async {
    setState(() async {
      moveClass = await SharedPrefsUtils().loadMoveClassFromSharedPrefs(moveClass);
      //moveClass = await SharedPrefsUtils().loadListOfItemsInSharedToMoveClass(moveClass);
      shouldOpenOnlyResume();
    });



  }

  void shouldOpenOnlyResume(){
    if(moveClass.situacao!=null){
      setState(() {
        showSelectItemPage=false;
        showFinalPage=true;
      });
    }
  }

  Future<void> loadItemsFromShared( SelectedItemsChartModel selectedItemsChartModel, [VoidCallback onFinish()]) async {

    bool shouldRead = await SharedPrefsUtils().thereIsItemsSavedInShared(); //verifica se tem algum item salvo
    if(shouldRead==true){

      List<ItemClass> list = await SharedPrefsUtils().loadListOfItemsInShared(); //carrega os dados salvos
      selectedItemsChartModel.updateItemsSelectedCartList(list);  //adiciona na model para compartilhar com a app
      moveClass = await SharedPrefsUtils().loadListOfItemsInSharedToMoveClass(moveClass); // salva a lista na classe pra acessar mais rápdio
      onFinish();
    }

  }



  TextEditingController alturaController = TextEditingController();
  TextEditingController larguraController = TextEditingController();
  TextEditingController profundidadeController = TextEditingController();
  TextEditingController pesoController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  double altura = 0.0;
  double largura = 0.0;
  double profundidade = 0.0;

  Widget popUpCustomItem(index, heightP, widhtP){


    alturaController.addListener(() {
      setState(() {
        altura = double.parse(alturaController.text);
      });
    });

    larguraController.addListener(() {
      setState(() {
        largura = double.parse(larguraController.text);
      });
    });

    profundidadeController.addListener(() {
      setState(() {
        profundidade= double.parse(profundidadeController.text);
      });
    });

    return ScopedModelDescendant<SelectedItemsChartModel>(
      builder: (BuildContext context, Widget widget, SelectedItemsChartModel selectedItemsChartModel){
        return Container(
          height: heightP,
          width: widhtP,
          color: Colors.white,
          child: SingleChildScrollView(
              child: Column(
                children: [

                  WidgetsConstructor().makeText('Especificando item', Colors.black, 17.0, 15.0, 15.0, 'center'),
                  WidgetsConstructor().makeText('Considere sempre como se o item estivesse dentro de uma caixa. Desenhe o tamanho da caixa para que ele possa caber.', Colors.black, 15.0, 0.0, 10.0, 'no'),


                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Transform(
                        transform: Matrix4.identity()..setEntry(3,2, 0.01)..rotateY(0.6),
                        alignment: FractionalOffset.centerRight,
                        child: Container(
                          color: Colors.brown,
                          height: altura,
                          width: profundidade,
                        ),
                      ),
                      Container(
                        color: CustomColors.brown,
                        width: largura,
                        height: altura,
                      ),

                    ],
                  ),

                  SizedBox(height: 20.0,),

                  Container(
                    width: widhtP*0.75,
                    child: WidgetsConstructor().makeEditTextNumberOnly(alturaController, 'Altura em cm'),
                  ),
                  Container(
                    width: widhtP*0.75,
                    child: WidgetsConstructor().makeEditTextNumberOnly(larguraController, 'Largura em cm'),
                  ),
                  Container(
                    width: widhtP*0.75,
                    child: WidgetsConstructor().makeEditTextNumberOnly(profundidadeController, 'Profundidade em cm'),
                  ),
                  Container(
                    width: widhtP*0.75,
                    child: WidgetsConstructor().makeEditTextNumberOnly(pesoController, 'Peso em kg'),
                  ),

                  SizedBox(height: 15.0,),

                  Container(
                    width: widhtP*0.60,
                    child: WidgetsConstructor().makeEditText(nameController, 'Nome', null),
                  ),

                  SizedBox(height: 30.0,),

                  Column(
                    children: [
                      WidgetsConstructor().makeText("Ajuste a quantidade", Colors.blue, 18.0, 10.0, 10.0, "center"), //titulo
                      WidgetsConstructor().makeText(nameController.text, Colors.blue, 15.0, 10.0, 5.0, "center"),
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
                      SizedBox(height: heightP*0.04),//li

                      /*// nha com a quantidade escolhida deste item
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
                                if(moveClass.itemsSelectedCart == null){
                                  List<ItemClass>list=[];
                                  list.add(item);
                                  moveClass.itemsSelectedCart = list;
                                  selectedItemsChartModel.addItemToChart(item);
                                  //moveClass.itemsSelectedCart.add(item);
                                } else {
                                  selectedItemsChartModel.addItemToChart(item);
                                  moveClass.itemsSelectedCart.add(item);
                                }

                                cont++;
                              }
                            }
                            selectedOfSameItens=0;
                            showPopUpQuant=false;

                            //salva no shared para continuar de onde parou em outra sessão
                            SharedPrefsUtils().saveListOfItemsInShared(moveClass.itemsSelectedCart);

                            isLoading = false;

                          });
                        },
                        child: WidgetsConstructor().makeButton(Colors.blue, Colors.blue, widhtP*0.30, 50.0, 1.0, 5.0, "Fechar", Colors.white, 15.0),
                      )
                       */

                    ],
                  ),

                  Container(
                    height: 60.0,
                    width: widhtP*0.90,
                    child: RaisedButton(
                      onPressed: (){
                        alturaController.dispose();
                        larguraController.dispose();
                        pesoController.dispose();

                        if(selectedOfSameItens!=0){

                          isLoading=true;
                          //então adicionar este item ao carrinho
                          int cont=0;
                          while(cont<selectedOfSameItens){

                            bool needtwo=false;
                            //cria um objeto
                            if(double.parse(pesoController.text)>60.0){
                              needtwo=true;
                            }


                            //ItemClass item = ItemClass(nameController.text, double.parse(pesoController.text), needtwo, ItemClass.empty().calculateVolume(altura, largura, profundidade), myData[selectedIndex]['image']);
                            ItemClass item = ItemClass(nameController.text, double.parse(pesoController.text), needtwo, ItemClass.empty().calculateVolume(altura, largura, profundidade));
                            //adiciona a lista disponivel no model
                            if(moveClass.itemsSelectedCart == null){
                              List<ItemClass>list=[];
                              list.add(item);
                              moveClass.itemsSelectedCart = list;
                              selectedItemsChartModel.addItemToChart(item);
                              //moveClass.itemsSelectedCart.add(item);
                            } else {
                              selectedItemsChartModel.addItemToChart(item);
                              moveClass.itemsSelectedCart.add(item);
                            }

                            cont++;
                          }
                        }
                        selectedOfSameItens=0;

                        //salva no shared para continuar de onde parou em outra sessão
                        SharedPrefsUtils().saveListOfItemsInShared(moveClass.itemsSelectedCart);

                        isLoading = false;

                        setState(() {
                          customItem=false;
                        });

                      },
                      color: CustomColors.blue,
                      child: WidgetsConstructor().makeText('Adicionar à mudança', Colors.white, 17.0, 0.0, 0.0, 'center'),
                    ),
                  ),

                ],
              )
          ),
        );

      },
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
                            //ItemClass item = ItemClass(myData[selectedIndex]['name'].toString(), myData[selectedIndex]['weigth'], myData[selectedIndex]['singlePerson'], myData[selectedIndex]['volume'], myData[selectedIndex]['image']);
                            ItemClass item = ItemClass(myData[selectedIndex]['name'].toString(), myData[selectedIndex]['weigth'], myData[selectedIndex]['singlePerson'], myData[selectedIndex]['volume']);
                            //adiciona a lista disponivel no model
                            if(moveClass.itemsSelectedCart == null){
                              List<ItemClass>list=[];
                              list.add(item);
                              moveClass.itemsSelectedCart = list;
                              selectedItemsChartModel.addItemToChart(item);
                              //moveClass.itemsSelectedCart.add(item);
                            } else {
                              selectedItemsChartModel.addItemToChart(item);
                              moveClass.itemsSelectedCart.add(item);
                            }

                            cont++;
                          }
                        }
                        selectedOfSameItens=0;
                        showPopUpQuant=false;

                        //salva no shared para continuar de onde parou em outra sessão
                        SharedPrefsUtils().saveListOfItemsInShared(moveClass.itemsSelectedCart);

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

        print("teste "+selectedItemsChartModel.getItemsChartSize().toString());

        return Container(
          child: Padding(
            padding: EdgeInsets.all(1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: (){
                    setState(() {
                      showListOfItemsEdit=true;
                      showSelectItemPage=false;
                      showDetalhesLocalPage=false;
                    });
                  },
                  child: Container(
                    width: widthPercent*0.60,
                    height: heightPercent*0.10,
                    child: Row(
                      children: [
                        moveClass.itemsSelectedCart == null || moveClass.itemsSelectedCart.length == 0
                            ? WidgetsConstructor().makeSimpleText(
                            "Nenhum item escolhido", Colors.redAccent, 15.0)
                            : GestureDetector(
                          onTap: (){

                            setState(() {
                              showListOfItemsEdit=true;
                              showSelectItemPage=false;
                              showDetalhesLocalPage=false; //fecha as duas pq uso o mesmo widget. O user pode querer editar a lista na página 2
                            });

                          },
                          child: WidgetsConstructor().makeSimpleText(
                              "Itens: ", Colors.blue, 15.0),
                        ),
                        moveClass.itemsSelectedCart == null || moveClass.itemsSelectedCart.length == 0
                            ? Container()
                            : WidgetsConstructor().makeSimpleText(moveClass.itemsSelectedCart.length.toString(), Colors.blue, 15.0),

                      ],
                    ),
                  ),
                ),

                moveClass.itemsSelectedCart == null || moveClass.itemsSelectedCart.length == 0
                ? Container() :
                Positioned(
                  right: 5.0, child: Container(width: 40.0,
                  height: 40.0,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.redAccent,),
                    onPressed: () {
                      setState(() {
                        SharedPrefsUtils().clearListInShared(moveClass.itemsSelectedCart.length);
                        selectedItemsChartModel.clearChart();
                        moveClass.itemsSelectedCart.clear();

                        _displaySnackBar(context, "Todos os itens foram removidos");
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
                    showDetalhesLocalPage=false;
                    showSelectItemPage=true;
                  } else if(option==2) {
                    //volta pra pagina 2 (customItemPage)
                    isLoading=false;
                    showDetalhesLocalPage=true;
                    showSelectTruckPage=false;
                  } else if(option==3){
                    //volta pra página 3 (select car)
                    showSelectTruckPage=true;
                    showAddressesPage=false;
                    origemAddressVerified="";
                  } else if(option==4){
                    //volta para pagina 4 (selectAdress)
                    showAddressesPage=true;
                    showChooseTruckerPage=false;
                  } else if(option==5){
                    //volta para a página de selecionar o freiteiro , fecha a pagina de selecionar data
                    showChooseTruckerPage=true;
                    showDatePage=false;
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

    if(precoCadaAjudante==0.0){
      precoCadaAjudante = await FirestoreServices().loadCommoditiesAjudanteFromDb();
      precoBaseFreteiro = await FirestoreServices().loadCommoditiesFreteiroFromDb();
      precoGasolina = await FirestoreServices().loadCommoditiesGasolinaFromDb();
    }

    //print('preco ajudante '+precoCadaAjudante.toString());

    /*
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

     */

  }

  void calculateThePrice() async {
    setState(() {
      isLoading=true;
    });
    //carrega o preco das coisas do bd
    //loadDataFromDb();

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
      
      //custo com ajudantes
      custoAjudantes = moveClass.ajudantes*precoCadaAjudante;
      custoTotal=custoTotal+custoAjudantes;

      //custo de cada caminhão adicionado
      custoTotal=custoTotal+precoBaseFreteiro+moveClass.giveMeThePriceOfEachvehicle(moveClass.carro);

      //custo de cada móvel
      totalExtraProducts = 0.0;
      moveClass.itemsSelectedCart.forEach((element) {

        totalExtraProducts = totalExtraProducts+3.00;
      });
      custoTotal = custoTotal+totalExtraProducts;

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

  void scheduleAmove(UserModel userModel) async {

    FirestoreServices().scheduleAmoveInBd(moveClass,() {_onSucess(userModel); }, () {_onFailure();});

  }

  void _onSucess(UserModel userModel){

    //set it on userModel
    userModel.updateThisUserHasAmove(true);

    //lets schedule a notification for 24 earlyer
    DateTime moveDate = MoveClass().formatMyDateToNotify(moveClass.dateSelected, moveClass.timeSelected);
    DateTime notifyDateTime = DateUtils().subHoursFromDate(moveDate, 24); //ajusta 24 horas antes
    NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, moveClass.userId, "Lembrete: Sua mudança é amanhã às "+moveClass.timeSelected, notifyDateTime);


    //notificação com 2 horas de antecedencia (obs: o id da notificação é moveID (id do cliente+2)
    notifyDateTime = DateUtils().subHoursFromDate(moveDate, 2); //ajusta 2 horas antes
    NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, moveClass.userId+'2', "Lembrete: Mudança em duas horas. Realize pagamento para confirmar." , notifyDateTime);


    _displaySnackBar(context, "agendado");
    //continuar aqui
    /*
    adicionar uma variavel bool e criar uma nova tela para agendar horário e data antes de salvar no fb
     */
  }

  void _onFailure(){
    _displaySnackBar(context, "Ocorreu um erro. O agendamento não foi feito. Verifique sua internet e tente novamente");
    setState(() {
      isLoading=false;
    });
  }

  void _onSucessDelete(){
    _displaySnackBar(context, "O agendamento está sendo cancelado.");
    waitAmoment(3);


    FirestoreServices().notifyTruckerThatHeWasChanged(moveClass.freteiroId, moveClass.userId); //alerta ao freteiro que ele foi cancelado na mudança. No freteiro vai recuperar isso para cancelar as notificações locais.
    //cancelar as notificações neste caso
    NotificationMeths().turnOffNotification(flutterLocalNotificationsPlugin); //apaga todas as notificações deste user

    //retorna pra página principal
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => HomePage()));
    //continuar aqui
    /*
    adicionar uma variavel bool e criar uma nova tela para agendar horário e data antes de salvar no fb
     */
  }

  void _onFailureDelete(){
    _displaySnackBar(context, "Ocorreu um erro. O agendamento não foi cancelado. Tente novamente em instantes.");
  }

  _selectDate(BuildContext context) async {

    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year+5),
      helpText: "Escolha data da mudança", //opcional
      //confirmText: "ok" //opcional
      //cancelText: "ok"  //opcional
    );
    setState(() {
      if (picked != null && picked != selectedDate)
        setState(() {
          selectedDate = picked;
        });
    });

  }

  _selectTime(BuildContext context) async {

    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: "Escolha o horário", //opcional
    );
    setState(() {
      if (picked != null && picked != selectedDate)
        setState(() {
          selectedtime = picked;
        });
    });

  }

  Future<void> _makeAddressConfig () async {

    moveClass = await MoveClass().getTheCoordinates(moveClass, origemAddressVerified, destinyAddressVerified);

    setState(() {
      moveClass.enderecoOrigem = origemAddressVerified;
      moveClass.enderecoDestino = destinyAddressVerified;
    });

    calculateThePrice();

  }

  void _checkIfNeedNewTrucker(UserModel userModel) async {

    setState(() {
      isLoading=true;
    });

    Future<void> _loadMoveClassCallBack() async {

      if(moveClass.situacao=="sem motorista" || moveClass.situacao == 'trucker_quit_after_payment'){

        moveClass = await MoveClass().getTheCoordinates(moveClass, moveClass.enderecoOrigem, moveClass.enderecoDestino).whenComplete(() {

          _displaySnackBar(context, 'Selecione um novo motorista e horário');

          //await _makeAddressConfig();

          showChooseTruckerPage=true;
          showSelectItemPage=false;
          showFinalPage=false;

          setState(() {
            isLoading=false;
          });

        });



      }

    }

    FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClass, userModel, () { _loadMoveClassCallBack();} );


  }


}


 */








/*
FLUXOS

cancelamento:
ao cancelar são cancelados as notificações todas do user.
cria um campo no bd 'notificacoes_cancelamento' com o bd do freteiro. Serve para fazer verificações de freteiros canceladas
 */