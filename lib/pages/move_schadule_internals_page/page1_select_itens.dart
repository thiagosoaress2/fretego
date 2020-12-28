import 'dart:convert';

import 'package:after_layout/after_layout.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/item_class.dart';
import 'package:fretego/classes/truck_class.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/models/selected_items_chart_model.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/custom_expansion_tile.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/responsive_text_custom_withmargin.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:fretego/classes/move_class.dart';








class Page1SelectItens extends StatefulWidget {
  double heightPercent;
  double widthPercent;
  String uid;
  Page1SelectItens(this.heightPercent, this.widthPercent, this.uid);


  @override
  _Page1SelectItensState createState() => _Page1SelectItensState();
}


String _filter;

bool _initialLoad=false;
bool isLoading=false;

var myData;
int selectedIndex;
Map<String, int> itensMap = Map(); //guarda o nome do item e a quantidade do item que existe
Map<String, int> _itensIndex = Map(); //guarda a posicao do item na itensMap

MoveModel moveModelGlobal = MoveModel();

class _Page1SelectItensState extends State<Page1SelectItens> with AfterLayoutMixin<Page1SelectItens> {


  TextEditingController _searchController = TextEditingController();

  String userId;

  @override
  void initState() {

    _filter='';

    _searchController.addListener(() {
      setState(() {
        _filter = _searchController.text.toLowerCase(); //a cada clique atualiza
        print('valoe de filter no listener');
        print(_filter);
        print('valor de textcontroller');
        print(_searchController.text);
      });

    });




  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  void afterFirstLayout(BuildContext context) {
    moveModelGlobal.updateAppBarText('Início', 'Itens grandes');

    //SharedPrefsUtils().saveListOfItemsInShared();
  }

  Future<void> _loadTheListFromAndPutInScreen(MoveModel moveModel) async {

    void _listIsUpToRead(){

      print('cheogu aqui no update');

      //moveClass.itemsSelectedCart = selectedItemsChartModel.itemsSelectedCart;

      //preenche os itens da primeira página
      if(moveModel.itemsSelectedCart.isNotEmpty){
        int cont=0;
        while(cont<moveModel.itemsSelectedCart.length){
          String item = moveModel.itemsSelectedCart[cont].name;
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

      MoveModel model = ScopedModel.of(context);
      model.updatePage1IsOk(true);
      print(itensMap.length);
      //moveModel.updatePage1IsOk(true);
      print(moveModel.Page1isOk);
      print('acima valor de page1isOk');
      if(itensMap.length!=0){
        setState(() {
          itensMap=itensMap;
        });
      }

    }

    if(_initialLoad==false){
      _initialLoad=true;
      print('cheogu em initload');
      checkIfExistsInShared(moveModel); //it will also check if there is in firebase if there is no data in shared

      await loadItemsFromShared(moveModel, () {_listIsUpToRead();});
      //moveClass.itemsSelectedCart = selectedItemsChartModel.itemsSelectedCart;


    }

  }


  bool canClickFloatingBtn=true;

  @override
  Widget build(BuildContext context) {
    userId=widget.uid;

    return ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget child, MoveModel moveModel){


        moveModelGlobal = moveModel;
        _loadTheListFromAndPutInScreen(moveModel);



        return Container(
          color: Colors.white,
          height: widget.heightPercent,
          width: widget.widthPercent,
          child: Stack(
            children: [

              //barra de busca
              selectItemPageElement_searchBar(),


              selectItemPageElement_productList(moveModel, widget.heightPercent, widget.widthPercent),




              Positioned(
                  bottom: 15.0,
                  right: 10.0,
                  child: FloatingActionButton(
                    onPressed: (){

                      if(canClickFloatingBtn==true){
                        canClickFloatingBtn=false; //trava o botão

                        //este floatig button é especial somente para esta página. As outras o floting fica na pagina move_schedule_page
                        if(itensMap.length==0 || itensMap == null){
                          canClickFloatingBtn=true;
                          MyBottomSheet().settingModalBottomSheet(context, 'Ops...', 'Lista vazia', 'Você não selecionou nenhum item para a mudança.', Icons.info, widget.heightPercent, widget.widthPercent, 0, true);
                        } else {
                          if(moveModel.itemsSelectedCart.length==0 || moveModel.itemsSelectedCart == null){
                            itensMap.forEach((key, value) { //por algum motivo os itens não estão na classe, apenas no mapa. Mas o mapa não é passado adiante. Então vamos armazenar. (isto ocorre pois pegou do shared e nao foi feito pelo user em tempo de compição)
                              int index=0;
                              while(index<myData.length){
                                if(myData[index]['name']==key){
                                  int repeat = value; //value é a quantidade do mesmo item. Entao vai adicionar o item quantas vezes for necessário
                                  int cont=0;
                                  while(cont<repeat){ //coloca um item no carrinho para cada item adicionado pelo user
                                    final ItemClass itemClass = ItemClass(myData[index]['name'], myData[index]['weight'], myData[index]['singlePerson'], myData[index]['volume']);
                                    moveModel.addItemToChart(itemClass);
                                    cont++;
                                  }
                                  index=myData.length; //se já achou, n precisa continuar vasculhando. Saltar logo pro final pra ganhar velocidade.

                                }
                                index++;
                              }

                            });
                          }
                          //vamos garantir que os dados vão pra proxima tela dentro de itemsSelectedCart.
                          moveModel.moveClass.itemsSelectedCart = moveModel.itemsSelectedCart; //atualiza a lista no moveclass que agora fica dentro do moveMovel
                          moveModel.changePageForward('obs', 'Itens', 'Observações');
                          canClickFloatingBtn=true;
                        }



                      }

                    },
                    backgroundColor: CustomColors.yellow,
                    splashColor: Colors.yellow,
                    child: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 50.0,),
                  )
              ),

              isLoading==true ? const Center(child: CircularProgressIndicator(),) : const SizedBox(),



            ],
          ),
        );
      },
    );
  }

  Widget selectItemPageElement_searchBar(){

    return Positioned(
      top: widget.heightPercent*0.32,
      left: widget.widthPercent*0.05,
      right: widget.widthPercent*0.05,
      child: Container(
        height: 60.0,
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(suffixIcon: Icon(
              Icons.search),labelText: 'Busque aqui'),
        ),
      ),);

  }

  Widget selectItemPageElement_productList(MoveModel moveModel, double heightPercent, double widthPercent){

    bool lastItem=false;

    return Positioned(

      top: widget.heightPercent*0.37,
      left: widget.widthPercent*0.05,
      right: widget.widthPercent*0.05,
      bottom: widget.heightPercent*0.10,

      child: Column(
        children: [


          Expanded(child:FutureBuilder(
            future: DefaultAssetBundle.of(context).loadString(
                'loadjson/itens.json'),
            builder: (context, snapshot) {
              print(_searchController.text);
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator(),);
              }
              myData = json.decode(snapshot.data);

              return ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  if(index+1==myData.length){
                    lastItem=true;
                  }
                  return _filter == null || _filter == ""
                      ? InkWell(
                    onTap: (){
                      selectedIndex = index;

                    },
                    child: _itemCard(index, lastItem, heightPercent, widthPercent, moveModel),
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
                    child: _itemCard(index, lastItem, heightPercent, widthPercent, moveModel),
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

  Widget _itemCard(int index, bool lastItem, double heightPercent, double widthPercent, MoveModel moveModel){

    int qnt=0;


    if(itensMap.length!=0){
      if(itensMap.containsKey(myData[index]["name"])){
        qnt = itensMap[myData[index]["name"]];
      }
    }

    return Container(
        height: heightPercent*0.10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Image.asset(myData[index]['image']),
                new ResponsiveTextCustom(myData[index]["name"], context, Colors.black, 2.5, 2.5, 2.5, 'no'),
                //WidgetsConstructor().makeResponsiveText(context, myData[index]["name"], Colors.black, 2.5, 2.5, 2.5, 'no'),

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
                              _itensIndex.removeWhere((key, value) => key == myData[index]["name"]);  //remove da lista de index
                              itensMap.removeWhere((key, value) => key == myData[index]["name"]);  //remove da lista de index
                              //moveClass = MoveClass().deleteOneItem(moveClass, myData[index]["name"]);

                              //remove from classmodel
                              final ItemClass itemClass = ItemClass(myData[index]['name'], myData[index]['weight'], myData[index]['singlePerson'], myData[index]['volume']);
                              moveModel.removeItemFromChart(itemClass);
                              //selectedItemsChartModel.removeItemFromChart(itemClass);
                              //moveClass.itemsSelectedCart = selectedItemsChartModel.itemsSelectedCart;
                              moveModel.moveClass.itemsSelectedCart = moveModel.itemsSelectedCart;

                              SharedPrefsUtils().saveListOfItemsInShared(moveModel.itemsSelectedCart);


                            } else {
                              qnt--;
                              itensMap[myData[index]["name"]]=qnt;
                              //moveClass = MoveClass().deleteOneItem(moveClass, myData[index]["name"]);

                              //remove from classmodel
                              final ItemClass itemClass = ItemClass(myData[index]['name'], myData[index]['weight'], myData[index]['singlePerson'], myData[index]['volume']);
                              //selectedItemsChartModel.addItemToChart(itemClass);
                              moveModel.removeItemFromChart(itemClass);
                              moveModel.updateItemsSelectedCartList(moveModel.itemsSelectedCart);

                              SharedPrefsUtils().saveListOfItemsInShared(moveModel.itemsSelectedCart);
                            }

                            if(moveModel.itemsSelectedCart.length==0 || moveModel.itemsSelectedCart == null){
                              moveModel.updatePage1IsOk(false);
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

                          qnt++;
                          _itensIndex[myData[index]["name"]] = index; //salva o index para depois sabermos como alvar os itens

                          //add a moveClass
                          final ItemClass itemClass = ItemClass(myData[index]['name'], myData[index]['weight'], myData[index]['singlePerson'], myData[index]['volume']);
                          moveModel.addItemToChart(itemClass);
                          //moveModel.moveClass.itemsSelectedCart = moveModel.itemsSelectedCart;
                          moveModel.itemsSelectedCart = moveModel.itemsSelectedCart;

                          SharedPrefsUtils().saveListOfItemsInShared(moveModel.itemsSelectedCart);

                          setState(() {
                            itensMap[myData[index]["name"]]=qnt;
                            //qnt++;
                          });

                          moveModel.updatePage1IsOk(true);

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
  }


  Future<Widget> checkIfExistsInShared(MoveModel moveModel) async {

    checkIfExistsAscheduledMoveInFb(moveModel); //se quiser voltar com o shared, apagar esta linha. Ela fica no else abaixo

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

  Future<bool> checkIfExistsAscheduledMoveInFb(MoveModel moveModel) async {

    FirestoreServices().checkIfExistsAmoveScheduledForItensPage(userId, () {_onSucessScheduled(moveModel);}, () {_onFailureScheduled(moveModel);});

  }

  Future<void> _onSucessScheduled(MoveModel moveModel) async {

    //_displaySnackBar(context, "Opa. Parece que você já tem uma mudança agendada.");

    void _onSucess(){

      setState(() {
        moveModel.updateActualPage('final');
        //showFinalPage=true;
        //showSelectItemPage=false;
        isLoading=false;
      });

    }

    //moveClass = await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClass, userModel);
    await FirestoreServices().copyOfloadScheduledMoveInFbWithCallBack(moveModel.moveClass, userId,() {_onSucess();});

    /*
    await SharedPrefsUtils().saveMoveClassToShared(moveClass);

    setState(() {
      showFinalPage=true;
      showSelectItemPage=false;
      isLoading=false;
    });
     */

  }


  void _onFailureScheduled(MoveModel moveModel){
    //do nothing, open normal next page
    _checkIfNeedNewTrucker(moveModel, userId); //verifica se precisa trocar o motorista
    setState(() {
      //showChooseTruckerPage=true;
      //showAddressesPage=false;
      isLoading=false;
    });

  }

  void _checkIfNeedNewTrucker(MoveModel moveModel, String uid) async {

    setState(() {
      isLoading=true;
    });

    Future<void> _loadMoveClassCallBack() async {

      if(moveModel.moveClass.situacao=="sem motorista" || moveModel.moveClass.situacao == 'trucker_quit_after_payment'){

        moveModel.moveClass = await MoveClass().getTheCoordinates(moveModel.moveClass, moveModel.moveClass.enderecoOrigem, moveModel.moveClass.enderecoDestino).whenComplete(() {

          //_displaySnackBar(context, 'Selecione um novo motorista e horário');

          //await _makeAddressConfig();

          moveModel.updateActualPage('motorista');
          //showChooseTruckerPage=true;
          //showSelectItemPage=false;
          //showFinalPage=false;

          setState(() {
            isLoading=false;
          });

        });



      }

    }

    FirestoreServices().copyOfloadScheduledMoveInFbWithCallBack(moveModel.moveClass, userId, () { _loadMoveClassCallBack();} );


  }

  Future<void> loadItemsFromShared(MoveModel moveModel , [VoidCallback onFinish()]) async {

    bool shouldRead = await SharedPrefsUtils().thereIsItemsSavedInShared(); //verifica se tem algum item salvo
    if(shouldRead==true){

      final List<ItemClass> list = await SharedPrefsUtils().loadListOfItemsInShared(); //carrega os dados salvos
      moveModel.updateItemsSelectedCartList(list);  //adiciona na model para compartilhar com a app
      moveModel.moveClass = await SharedPrefsUtils().loadListOfItemsInSharedToMoveClass(moveModel.moveClass); // salva a lista na classe pra acessar mais rápdio
      print('chegou no onFinish');
      onFinish();
    }

  }



}






/*
class Page1SelectItens extends StatefulWidget {
  double heightPercent;
  double widthPercent;
  String uid;
  Page1SelectItens(this.heightPercent, this.widthPercent, this.uid);


  @override
  _Page1SelectItensState createState() => _Page1SelectItensState();
}


String _filter;

bool _initialLoad=false;
bool isLoading=false;

var myData;
int selectedIndex;
Map<String, int> itensMap = Map(); //guarda o nome do item e a quantidade do item que existe
Map<String, int> itensIndex = Map(); //guarda a posicao do item na itensMap

MoveModel moveModelGlobal = MoveModel();

class _Page1SelectItensState extends State<Page1SelectItens> with AfterLayoutMixin<Page1SelectItens> {


  TextEditingController _searchController = TextEditingController();

  String userId;

  @override
  void initState() {

    _filter='';

    _searchController.addListener(() {
      setState(() {
        _filter = _searchController.text.toLowerCase(); //a cada clique atualiza
        print('valoe de filter no listener');
        print(_filter);
        print('valor de textcontroller');
        print(_searchController.text);
      });

    });




  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  void afterFirstLayout(BuildContext context) {
    moveModelGlobal.updateAppBarText('Início', 'Itens grandes');

    //SharedPrefsUtils().saveListOfItemsInShared();
  }

  Future<void> _loadTheListFromAndPutInScreen(MoveModel moveModel) async {

    void _listIsUpToRead(){

      print('cheogu aqui no update');

      //moveClass.itemsSelectedCart = selectedItemsChartModel.itemsSelectedCart;

      //preenche os itens da primeira página
      if(moveModel.itemsSelectedCart.isNotEmpty){
        int cont=0;
        while(cont<moveModel.itemsSelectedCart.length){
          String item = moveModel.itemsSelectedCart[cont].name;
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

      MoveModel model = ScopedModel.of(context);
      model.updatePage1IsOk(true);
      print(itensMap.length);
      //moveModel.updatePage1IsOk(true);
      print(moveModel.Page1isOk);
      print('acima valor de page1isOk');
      if(itensMap.length!=0){
        setState(() {
          itensMap=itensMap;
        });
      }

    }

    if(_initialLoad==false){
      _initialLoad=true;
      print('cheogu em initload');
      checkIfExistsInShared(moveModel); //it will also check if there is in firebase if there is no data in shared

      await loadItemsFromShared(moveModel, () {_listIsUpToRead();});
      //moveClass.itemsSelectedCart = selectedItemsChartModel.itemsSelectedCart;


    }

  }

  @override
  Widget build(BuildContext context) {
    userId=widget.uid;

    return ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget child, MoveModel moveModel){


        moveModelGlobal = moveModel;
        _loadTheListFromAndPutInScreen(moveModel);



        return Container(
          color: Colors.white,
          height: widget.heightPercent,
          width: widget.widthPercent,
          child: Stack(
            children: [

              //barra de busca
              selectItemPageElement_searchBar(),

              selectItemPageElement_productList(moveModel, widget.heightPercent, widget.widthPercent),


              Positioned(
                  bottom: 15.0,
                  right: 10.0,
                  child: FloatingActionButton(
                    onPressed: (){


                      //este floatig button é especial somente para esta página. As outras o floting fica na pagina move_schedule_page
                      if(itensMap.length==0 || itensMap == null){
                        MyBottomSheet().settingModalBottomSheet(context, 'Ops...', 'Lista vazia', 'Você não selecionou nenhum item para a mudança.', Icons.info, widget.heightPercent, widget.widthPercent, 0, true);
                      } else {
                        //vamos garantir que os dados vão pra proxima tela dentro de itemsSelectedCart.
                        moveModel.moveClass.itemsSelectedCart = moveModel.itemsSelectedCart; //atualiza a lista no moveclass que agora fica dentro do moveMovel
                        moveModel.changePageForward('obs', 'Itens', 'Observações');
                      }


                    },
                    backgroundColor: CustomColors.yellow,
                    splashColor: Colors.yellow,
                    child: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 50.0,),
                  )
              ),

              isLoading==true ? const Center(child: CircularProgressIndicator(),) : const SizedBox(),



            ],
          ),
        );
      },
    );
  }

  Widget selectItemPageElement_searchBar(){

    return Positioned(
      top: widget.heightPercent*0.32,
      left: widget.widthPercent*0.05,
      right: widget.widthPercent*0.05,
      child: Container(
        height: 60.0,
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(suffixIcon: Icon(
              Icons.search),labelText: 'Busque aqui'),
        ),
      ),);

  }

  Widget selectItemPageElement_productList(MoveModel moveModel, double heightPercent, double widthPercent){

    bool lastItem=false;

    return Positioned(

      top: widget.heightPercent*0.37,
      left: widget.widthPercent*0.05,
      right: widget.widthPercent*0.05,
      bottom: widget.heightPercent*0.10,

      child: Column(
        children: [


          Expanded(child:FutureBuilder(
            future: DefaultAssetBundle.of(context).loadString(
                'loadjson/itens.json'),
            builder: (context, snapshot) {
              print(_searchController.text);
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator(),);
              }
              myData = json.decode(snapshot.data);

              return ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  if(index+1==myData.length){
                    lastItem=true;
                  }
                  return _filter == null || _filter == ""
                      ? InkWell(
                    onTap: (){
                      selectedIndex = index;

                    },
                    child: _itemCard(index, lastItem, heightPercent, widthPercent, moveModel),
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
                    child: _itemCard(index, lastItem, heightPercent, widthPercent, moveModel),
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

  Widget _itemCard(int index, bool lastItem, double heightPercent, double widthPercent, MoveModel moveModel){

    int qnt=0;


    if(itensMap.length!=0){
      if(itensMap.containsKey(myData[index]["name"])){
        qnt = itensMap[myData[index]["name"]];
      }
    }

    return Container(
        height: heightPercent*0.10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Image.asset(myData[index]['image']),
                new ResponsiveTextCustom(myData[index]["name"], context, Colors.black, 2.5, 2.5, 2.5, 'no'),
                //WidgetsConstructor().makeResponsiveText(context, myData[index]["name"], Colors.black, 2.5, 2.5, 2.5, 'no'),

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
                              itensIndex.removeWhere((key, value) => key == myData[index]["name"]);  //remove da lista de index
                              itensMap.removeWhere((key, value) => key == myData[index]["name"]);  //remove da lista de index
                              //moveClass = MoveClass().deleteOneItem(moveClass, myData[index]["name"]);

                              //remove from classmodel
                              final ItemClass itemClass = ItemClass(myData[index]['name'], myData[index]['weight'], myData[index]['singlePerson'], myData[index]['volume']);
                              moveModel.removeItemFromChart(itemClass);
                              //selectedItemsChartModel.removeItemFromChart(itemClass);
                              //moveClass.itemsSelectedCart = selectedItemsChartModel.itemsSelectedCart;
                              moveModel.moveClass.itemsSelectedCart = moveModel.itemsSelectedCart;

                              SharedPrefsUtils().saveListOfItemsInShared(moveModel.itemsSelectedCart);


                            } else {
                              qnt--;
                              itensMap[myData[index]["name"]]=qnt;
                              //moveClass = MoveClass().deleteOneItem(moveClass, myData[index]["name"]);

                              //remove from classmodel
                              final ItemClass itemClass = ItemClass(myData[index]['name'], myData[index]['weight'], myData[index]['singlePerson'], myData[index]['volume']);
                              //selectedItemsChartModel.addItemToChart(itemClass);
                              moveModel.removeItemFromChart(itemClass);
                              moveModel.updateItemsSelectedCartList(moveModel.itemsSelectedCart);

                              SharedPrefsUtils().saveListOfItemsInShared(moveModel.itemsSelectedCart);
                            }

                            if(moveModel.itemsSelectedCart.length==0 || moveModel.itemsSelectedCart == null){
                              moveModel.updatePage1IsOk(false);
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

                          qnt++;
                          itensIndex[myData[index]["name"]] = index; //salva o index para depois sabermos como alvar os itens

                          //add a moveClass
                          final ItemClass itemClass = ItemClass(myData[index]['name'], myData[index]['weight'], myData[index]['singlePerson'], myData[index]['volume']);
                          moveModel.addItemToChart(itemClass);
                          //moveModel.moveClass.itemsSelectedCart = moveModel.itemsSelectedCart;
                          moveModel.itemsSelectedCart = moveModel.itemsSelectedCart;

                          SharedPrefsUtils().saveListOfItemsInShared(moveModel.itemsSelectedCart);

                          setState(() {
                            itensMap[myData[index]["name"]]=qnt;
                            //qnt++;
                          });

                          moveModel.updatePage1IsOk(true);

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
  }


  Future<Widget> checkIfExistsInShared(MoveModel moveModel) async {

    checkIfExistsAscheduledMoveInFb(moveModel); //se quiser voltar com o shared, apagar esta linha. Ela fica no else abaixo

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

  Future<bool> checkIfExistsAscheduledMoveInFb(MoveModel moveModel) async {

    FirestoreServices().checkIfExistsAmoveScheduledForItensPage(userId, () {_onSucessScheduled(moveModel);}, () {_onFailureScheduled(moveModel);});

  }

  Future<void> _onSucessScheduled(MoveModel moveModel) async {

    //_displaySnackBar(context, "Opa. Parece que você já tem uma mudança agendada.");

    void _onSucess(){

      setState(() {
        moveModel.updateActualPage('final');
        //showFinalPage=true;
        //showSelectItemPage=false;
        isLoading=false;
      });

    }

    //moveClass = await FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClass, userModel);
    await FirestoreServices().copyOfloadScheduledMoveInFbWithCallBack(moveModel.moveClass, userId,() {_onSucess();});

    /*
    await SharedPrefsUtils().saveMoveClassToShared(moveClass);

    setState(() {
      showFinalPage=true;
      showSelectItemPage=false;
      isLoading=false;
    });
     */

  }


  void _onFailureScheduled(MoveModel moveModel){
    //do nothing, open normal next page
    _checkIfNeedNewTrucker(moveModel, userId); //verifica se precisa trocar o motorista
    setState(() {
      //showChooseTruckerPage=true;
      //showAddressesPage=false;
      isLoading=false;
    });

  }

  void _checkIfNeedNewTrucker(MoveModel moveModel, String uid) async {

    setState(() {
      isLoading=true;
    });

    Future<void> _loadMoveClassCallBack() async {

      if(moveModel.moveClass.situacao=="sem motorista" || moveModel.moveClass.situacao == 'trucker_quit_after_payment'){

        moveModel.moveClass = await MoveClass().getTheCoordinates(moveModel.moveClass, moveModel.moveClass.enderecoOrigem, moveModel.moveClass.enderecoDestino).whenComplete(() {

          //_displaySnackBar(context, 'Selecione um novo motorista e horário');

          //await _makeAddressConfig();

          moveModel.updateActualPage('motorista');
          //showChooseTruckerPage=true;
          //showSelectItemPage=false;
          //showFinalPage=false;

          setState(() {
            isLoading=false;
          });

        });



      }

    }

    FirestoreServices().copyOfloadScheduledMoveInFbWithCallBack(moveModel.moveClass, userId, () { _loadMoveClassCallBack();} );


  }

  Future<void> loadItemsFromShared(MoveModel moveModel , [VoidCallback onFinish()]) async {

    bool shouldRead = await SharedPrefsUtils().thereIsItemsSavedInShared(); //verifica se tem algum item salvo
    if(shouldRead==true){

      final List<ItemClass> list = await SharedPrefsUtils().loadListOfItemsInShared(); //carrega os dados salvos
      moveModel.updateItemsSelectedCartList(list);  //adiciona na model para compartilhar com a app
      moveModel.moveClass = await SharedPrefsUtils().loadListOfItemsInSharedToMoveClass(moveModel.moveClass); // salva a lista na classe pra acessar mais rápdio
      print('chegou no onFinish');
      onFinish();
    }

  }



}


 */

