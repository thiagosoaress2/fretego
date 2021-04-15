import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/truck_class.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/pages/move_schadule_internals_page/page2_obs.dart';
import 'package:fretego/pages/move_schedule_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

class CodeSearchPage extends StatefulWidget {
  double heightPercent;
  double widthPercent;
  String uid;
  CodeSearchPage({this.heightPercent, this.widthPercent, this.uid});


  @override
  _CodeSearchPageState createState() => _CodeSearchPageState();
}

TextEditingController _searchController = TextEditingController();

  bool isLoading=false;

  Query _query;
  String _truckId;

class _CodeSearchPageState extends State<CodeSearchPage> {
  @override
  Widget build(BuildContext context) {

    double heightPercent = widget.heightPercent;
    double widthPercent = widget.widthPercent;

    return ScopedModelDescendant<UserModel>(

      builder: (BuildContext context, Widget widget, UserModel userModel){

        return ScopedModelDescendant<MoveModel>(
          builder: (BuildContext context, Widget child, MoveModel moveModel){

            return Scaffold(
              body: Container(
                width: widthPercent,
                height: heightPercent,
                color: Colors.white,
                child: Stack(
                  children: [


                    _customFakeAppBar(context),

                    _textFieldPlaca(),

                    _btnSearch(),

                    if(isLoading==true) Center(child: CircularProgressIndicator(),),

                    if(_query!=null) _buscaMotorista(moveModel),

                  ],
                ),

              ),
            );

          },
        );

      },
    );
  }

  Widget _textFieldPlaca(){
    return Positioned(
        top: widget.heightPercent*0.20,
        left: widget.widthPercent*0.15,
        right: widget.widthPercent*0.15,
        child: TextFormField(
          controller: _searchController,
          keyboardType: TextInputType.streetAddress,
          decoration: InputDecoration(
              hintText: 'Informe o código do motorista',
              labelText: 'Código',
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink, width: 2.0)
              )
          ),
        ));
  }

  Widget _btnSearch(){

    return Positioned(
        top: widget.heightPercent*0.35,
        left: widget.widthPercent*0.15,
        right: widget.widthPercent*0.15,
        child: Container(
          width: widget.widthPercent*0.70,
          height: widget.heightPercent*0.10,
          child: RaisedButton(
            onPressed: (){

              if(_searchController.text.isEmpty){
                print('vazio');
              } else {
                setState(() {
                  //atualizando a _query a busca é disparada no outro widget
                  _query = FirebaseFirestore.instance.collection('truckers')
                      .where('placa', isEqualTo: _searchController.text)
                      .where('listed', isEqualTo:true);

                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    //remove o foco (isto fecha o teclado)
                    currentFocus.unfocus();
                  }


                });
              }

            },
            color: CustomColors.yellow,
            child: Text('Buscar', style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
          ),
        ));

  }

  Widget _buscaMotorista(MoveModel moveModel){

    return Positioned(
        top: widget.heightPercent*0.50,
        bottom: 0.0,
        left: widget.widthPercent*0.05,
        right: widget.widthPercent*0.05,
        child: Container(
      width: widget.widthPercent,
      height: widget.heightPercent*0.50,
      child: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _query.snapshots(),
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
                    ? Text('Nenhum motorista encontrado', style: TextStyle(
                    color: Colors.black,
                    fontSize: ResponsiveFlutter.of(context).fontSize(3.0)))
                    : Expanded(child: ListView.builder(
                    itemCount: querySnapshot.size,
                    //itemBuilder: (context, index) => Trucker(querySnapshot.docs[index]),
                    itemBuilder: (context, index) {

                      Map<String, dynamic> map = querySnapshot.docs[index].data();

                      _truckId = querySnapshot.docs[index].id;

                      return GestureDetector(
                        onTap: (){

                          //truckId = querySnapshot.docs[index].id;
                          //_mapGlobal = map;
                          //moveModel.updateShowPopup(true);
                          //_didTheUserUndestood=true;

                        },
                        //child: Text(map['name']),
                        child: _queryResult(map, moveModel),
                      );
                      //return Trucker(querySnapshot.docs[index]);

                    } ),);

            },
          ),
        ],
      ),
    ));
  }

  Widget _queryResult(Map map, MoveModel moveModel){

    print(map.values);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: Container(
            width: widget.widthPercent*0.9,
            height: widget.heightPercent*0.20,
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

                Row(
                  children: [
                    SizedBox(width: widget.widthPercent*0.03,),
                    CircleAvatar(
                      radius: 30.0,
                      backgroundImage:
                      NetworkImage(map['image']),
                      backgroundColor: Colors.transparent,
                    ),
                    SizedBox(width: widget.widthPercent*0.05,),
                    Text(map['apelido'], style: TextStyle(
                        color: CustomColors.blue,
                        fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
                  ],
                ),
                SizedBox(height: widget.heightPercent*0.02,),
                Row(
                  children: [
                    SizedBox(width: widget.widthPercent*0.05,),
                    Text('Veículo: '+TruckClass.empty().formatCodeToHumanName(map['vehicle']), style: TextStyle(
                        color: Colors.black,
                        fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
                  ],
                ),

                Row(
                  children: [
                    SizedBox(width: widget.widthPercent*0.05,),
                    Text('Viagens realizadas: '+map['aval'].toString(), style: TextStyle(
                        color: Colors.black,
                        fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
                  ],
                ),

              ],
            ),
          ),
        ),
        SizedBox(height: widget.heightPercent*0.05,),
        _btnAgendarMudanca(map, moveModel),
      ],
    );

  }

  Widget _btnAgendarMudanca(Map map, MoveModel moveModel){

    return Positioned(
      bottom: widget.heightPercent*0.10,
      left: widget.widthPercent*0.05,
      right: widget.widthPercent*0.05,
      child: Container(
        width: widget.widthPercent*0.90,
        height: widget.heightPercent*0.10,
        child: RaisedButton(
          color: CustomColors.blue,
          onPressed: (){

            moveModel.moveClass.nomeFreteiro = map['apelido'];
            moveModel.moveClass.apelido = map['apelido'];
            moveModel.moveClass.freteiroId = _truckId;
            moveModel.moveClass.carro = map['carro'];
            moveModel.moveClass.placa = map['placa'];


            moveModel.updateActualPage('itens');


            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => MoveSchedulePage(widget.uid, true, true)));

          },
          child: Text('Agendar mudança com\n${map['apelido']}', textAlign: TextAlign.center ,style: TextStyle(color: Colors.white,
              fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
        ),
      ),
    );
  }

  Widget _customFakeAppBar(BuildContext context) {

    void _customBackButton() {

      _query=null;

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => HomePage()));
    }


    return Positioned(
        top: widget.heightPercent * 0.05,
        left: 0.0,
        right: 0.0,
        child: Container(
          decoration: BoxDecoration(color: Colors.transparent,),
          alignment: Alignment.topCenter,
          width: widget.widthPercent,
          height: widget.heightPercent * 0.15,
          //color:  _showTip==true ? Colors.white : Colors.transparent,
          child: Column(
            children: [
              Container(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back, color: CustomColors.blue, size: 35,),
                          onPressed: () {
                            _customBackButton();
                          },),
                        //WidgetsConstructor().makeText(appBarText, Colors.grey[400], 9.0, 0.0, 0.0, 'center'),
                        Text('Início', style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
                      ],
                    ),
                  ),
                  SizedBox(width: widget.widthPercent*0.12,),
                  WidgetsConstructor().makeResponsiveText(context, 'Encontrar motorista', CustomColors.blue, 3, 10.0, 0.0, 'no'),

                ],
              ),

            ],
          ),
        ));

  }

}
