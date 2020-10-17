import 'dart:io';

import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();

    //fetchData();

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
                        var myData = json.decode(snapshot.data);
                        print(myData);

                        /*
                        const sizeJson = 2;
                        int cont =0;
                        while(cont<sizeJson){
                          nameJson.add(myData[cont]['name']);
                          imageJson.add(myData[cont]['image']);
                          cont++;
                        }

                         */


                        return ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return _filter == null || _filter == ""
                                ? Padding(
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
                            )
                                : myData[index]['name'].toString()
                                .toLowerCase()
                                .contains(_filter)
                                ? Padding(
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
                            )
                                : Container();


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
                )

              ],
            )
        );
      },
    );
  }

}
