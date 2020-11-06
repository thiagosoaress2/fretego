import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class MyMoves extends StatefulWidget {
  @override
  _MyMovesState createState() => _MyMovesState();
}

class _MyMovesState extends State<MyMoves> {

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  Map mapSelected;
  int indexSelected;

  bool isLoading=false;

  bool showPopUp=false;

  bool isMovesLoadedFromFb=false;

  MoveClass _moveClass = MoveClass();

  double heightPercent;
  double widthPercent;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel){

        loadInfoFromFb(userModel);

        heightPercent = MediaQuery.of(context).size.height;
        widthPercent = MediaQuery.of(context).size.width;

        //Query query = FirebaseFirestore.instance.collection("agendamentos_aguardando").where('moveId', isEqualTo: userModel.Uid);
        return Scaffold(
          key: _scaffoldKey,
          appBar: (
              AppBar(
                title: Text("Minhas mudanças"),
                backgroundColor: Colors.blue,
                centerTitle: true,
              )
          ),
          body: SingleChildScrollView(
            child: Stack(
              children: [

                //listview
                Column(
                  children: [

                    _moveClass.moveId != null
                    ? ListLine2()
                    : Text("Nao tem mudança"),

                    SizedBox(height: heightPercent*0.35,),

                    Positioned(
                      child: WidgetsConstructor().makeButton(Colors.red, Colors.white, widthPercent*0.95, 60.0, 3.0, 4.0, "Ver histórico", Colors.white, 17.0),
                      bottom: 0.5,
                      left: 0.5,
                      right: 0.5,
                    ),

                    /*
                    //list
                    Container(
                      height: 300.0,
                      child: ListOfMoves(userModel),
                    ),
                     */
                  ],

                ),


                showPopUp==true
                ? popUp()
                : Container(),

              ],
            )
          ),
        );
      },
    );
  }

  void loadInfoFromFb(UserModel userModel){
    if(isMovesLoadedFromFb==false){
      isMovesLoadedFromFb=true;
      FirestoreServices().checkIfExistsAmoveScheduled(userModel.Uid, () {_onSucessExistsMove(userModel);}, () {_onFailExistsMove(); });
    }
  }

  Future<void> _onSucessExistsMove(UserModel userModel) async {
    //existe uma mudança para você
    _moveClass = await FirestoreServices().loadScheduledMoveInFb(_moveClass, userModel, () {_onSucessLoadScheduledMoveInFb();});
  }

  void _onFailExistsMove(){
    _displaySnackBar(context, "Você não possui mudança agendada");
  }

  void _onSucessLoadScheduledMoveInFb(){
    //update the screen
    setState(() {
      _moveClass = _moveClass;
    });
  }

  /* DESCONTINUADO POIS NAO USAMOS MAIS LISTA
  Widget ListOfMoves(UserModel userModel){ //metodo descontinuado pois retornava uma lista. Mas nosso usuário vai ter apenas uma mudança por vez, entao n precisa lista.

    Query query = FirebaseFirestore.instance.collection("agendamentos_aguardando").where('moveId', isEqualTo: userModel.Uid);

    return  StreamBuilder<QuerySnapshot>(
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
                ? Center(child: Text("Sem mudança agendada"),)
                : Expanded(child: ListView.builder(
                itemCount: querySnapshot.size,
                //itemBuilder: (context, index) => Trucker(querySnapshot.docs[index]),
                itemBuilder: (context, index) {


                  Map<String, dynamic> map = querySnapshot.docs[index].data();
                  return GestureDetector(
                    onTap: (){

                      indexSelected = index;
                      mapSelected = map;
                      //calculateDistance();
                      setState(() {
                        showPopUp=true;
                      });

                    },
                    //child: Text(map['name']),
                    child: ListLine(map),
                  );
                  //return Trucker(querySnapshot.docs[index]);

                } ),);

        }
    );

  }

  Widget ListLine(Map map){

    return Padding(padding: EdgeInsets.all(10.0),
      child: Container(
          decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 3.0),
          child: Column(
            children: [
              Row(
                children: [
                  WidgetsConstructor().makeText("Situação: ", Colors.blue, 15.0, 10.0, 5.0, null),
                  //WidgetsConstructor().makeText(returnSituation(map['situacao']), Colors.blue, 15.0, 10.0, 15.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Origem: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['endereco_origem'], Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Destino: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['endereco_destino'], Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Data: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['selectedDate'], Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Horário: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['selectedTime'], Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Valor: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText("R\$ "+map['valor'].toStringAsFixed(2), Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),

            ],
          )
      ),
    );
  }
   */

  Widget ListLine2(){

    return GestureDetector(
      onTap: (){
        setState(() {
          showPopUp=true;
        });
      },
      child: Padding(padding: EdgeInsets.all(10.0),
        child: Container(
            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 3.0),
            child: Column(
              children: [
                Row(
                  children: [
                    WidgetsConstructor().makeText("Situação: ", Colors.blue, 15.0, 10.0, 5.0, null),
                    WidgetsConstructor().makeText(MoveClass().returnSituation(_moveClass.situacao), Colors.blue, 15.0, 10.0, 15.0, null),
                  ],
                ),
                Row(
                  children: [
                    WidgetsConstructor().makeText("Origem: ", Colors.black, 15.0, 0.0, 5.0, null),
                    WidgetsConstructor().makeText(_moveClass.enderecoOrigem, Colors.black, 15.0, 0.0, 5.0, null),
                  ],
                ),
                Row(
                  children: [
                    WidgetsConstructor().makeText("Destino: ", Colors.black, 15.0, 0.0, 5.0, null),
                    WidgetsConstructor().makeText(_moveClass.enderecoDestino, Colors.black, 15.0, 0.0, 5.0, null),
                  ],
                ),
                Row(
                  children: [
                    WidgetsConstructor().makeText("Data: ", Colors.black, 15.0, 0.0, 5.0, null),
                    WidgetsConstructor().makeText(_moveClass.dateSelected, Colors.black, 15.0, 0.0, 5.0, null),
                  ],
                ),
                Row(
                  children: [
                    WidgetsConstructor().makeText("Horário: ", Colors.black, 15.0, 0.0, 5.0, null),
                    WidgetsConstructor().makeText(_moveClass.timeSelected, Colors.black, 15.0, 0.0, 5.0, null),
                  ],
                ),
                Row(
                  children: [
                    WidgetsConstructor().makeText("Valor: ", Colors.black, 15.0, 0.0, 5.0, null),
                    WidgetsConstructor().makeText("R\$ "+_moveClass.preco.toStringAsFixed(2), Colors.black, 15.0, 0.0, 5.0, null),
                  ],
                ),

              ],
            )
        ),
      ),
    );
  }

  Widget popUp(){

    return Container(
      width: widthPercent,
        height: heightPercent,
      child: Center(
        child: Container(
          decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 4.0, 4.0),
          height: heightPercent*0.5,
          width: widthPercent*0.8,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CloseButton(
                      onPressed: (){
                        setState(() {
                          showPopUp=false;
                        });
                      },
                    )
                  ],
                ),

                WidgetsConstructor().makeText("Atenção", Colors.black, 18.0, 20.0, 20.0, "center"),
                WidgetsConstructor().makeText("Você tem certeza que deseja cancelar esta mudança?", Colors.black, 16.0, 0.0, 25.0, null),
                SizedBox(height: heightPercent*0.05,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    WidgetsConstructor().makeButton(Colors.red, Colors.white, _moveClass.situacao == "aguardando" ? widthPercent*0.3 : widthPercent*0.7, 60.0, 2.0, 4.0, "Cancelar", Colors.white, 18.0),
                    _moveClass.situacao == "aguardando"
                    ? WidgetsConstructor().makeButton(Colors.blue, Colors.white, widthPercent*0.3, 60.0, 2.0, 4.0, "Trocar motorista", Colors.white, 18.0)
                        : Container(),
                    
                  ],
                )

              ],
            ),
          ),
        ),
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




