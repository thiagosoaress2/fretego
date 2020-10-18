import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fretego/classes/item_class.dart';
import 'package:fretego/classes/selected_itens_chart.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:convert';

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

  int itensSelected = 0;
  int selectedOfSameItens=0;
  var myData;
  int selectedIndex;

  bool showPopUpQuant=false;

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  bool isLoading=false;

  SelectedItensChart listOfItems;

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
        return Scaffold(
            key: _scaffoldKey,
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.blue,
                child: Icon(Icons.skip_next, size: 50.0,),
                onPressed: () {
                  print("click");
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
                                : myData[index]['name'].toString()
                                .toLowerCase()
                                .contains(_filter)
                                ? InkWell(
                                  onTap: (){

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
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: [

                          itensSelected == 0
                              ? WidgetsConstructor().makeSimpleText(
                              "Nenhum item selecionado", Colors.redAccent, 15.0)
                              : WidgetsConstructor().makeSimpleText(
                              "Itens: ", Colors.blue, 15.0),
                          itensSelected == 0
                              ? Container()
                              : WidgetsConstructor().makeSimpleText(
                              itensSelected.toString(), Colors.blue, 15.0),
                          itensSelected == 0 ? Container() : SizedBox(
                            width: widthPercent * 0.42,),
                          //espaço vazio para colocar o X no cando direito
                          itensSelected == 0 ? Container() : Positioned(
                            right: 5.0, child: Container(width: 40.0,
                            height: 40.0,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.redAccent,),
                              onPressed: () {
                                setState(() {
                                  itensSelected = 0;
                                });
                              },),),)

                        ],
                      ),
                    ),
                    decoration: WidgetsConstructor().myBoxDecoration(
                        Colors.white, Colors.blue, 1.0, 4.0),
                    width: widthPercent * 0.75, height: heightPercent * 0.10,),
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
  }

  Widget popUpSelectItemQuantity(index, heightP, widhtP){
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
                  itensSelected = itensSelected+selectedOfSameItens;
                  if(selectedOfSameItens!=0){

                    isLoading=true;
                    //então adicionar este item ao carrinho
                    int cont=0;
                    while(cont<selectedOfSameItens){
                      String testeNome = myData[selectedIndex]['name'];
                      double testeweight = myData[selectedIndex]['weigth'];
                      bool testeSinglePerson = myData[selectedIndex]['singlePerson'];
                      double testevolume = myData[selectedIndex]['volume'];
                      String testeimage = myData[selectedIndex]['image'];
                      ItemClass item = ItemClass(myData[selectedIndex]['name'].toString(), myData[selectedIndex]['weigth'], myData[selectedIndex]['singlePerson'], myData[selectedIndex]['volume'], myData[selectedIndex]['image']);
                      listOfItems.addItemToChart(item);
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
