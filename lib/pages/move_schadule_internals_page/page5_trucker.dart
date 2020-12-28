import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/trucker_class.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/custom_expansion_tile.dart';
import 'package:fretego/widgets/fakeLine.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/responsive_text_custom_withmargin.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class Page5Trucker extends StatefulWidget {
  double heightPercent;
  double widthPercent;
  String uid;
  Page5Trucker(this.heightPercent, this.widthPercent, this.uid);

  @override
  _Page5TruckerState createState() => _Page5TruckerState();
}

class _Page5TruckerState extends State<Page5Trucker> {
  ScrollController _scrollController;
  Map<String, dynamic> mapGlobal;

  String truckId;

  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget child, MoveModel moveModel){


        print('verifica se adicionou o endereço');
        print(moveModel.DestinyAddress);
        print(moveModel.OrigemAddress);
        print(moveModel.moveClass.enderecoOrigem);
        print(moveModel.moveClass.enderecoDestino);

        _scrollController = ScrollController();

        final double latlong = moveModel.moveClass.latEnderecoOrigem+moveModel.moveClass.longEnderecoOrigem;
        print('latlong'+latlong.toString());
        double startAtval = latlong-(0.05*5.0);
        final double endAtval = latlong+(0.05*5.0);
        final double dif = -0.07576889999999992;
        startAtval = (dif+startAtval);

        Query query = FirebaseFirestore.instance.collection('truckers').where('latlong', isGreaterThanOrEqualTo: startAtval)
            .where('latlong', isLessThan: endAtval).where('banido', isEqualTo: false).where('listed', isEqualTo: true)
            .where('vehicle', isEqualTo: moveModel.carInMoveClass);

        return Scaffold(

          body: Container(
            height: widget.heightPercent,
            width: widget.widthPercent,
            color: Colors.white,
            child: Stack(
              children: [

                Positioned(
                    top: widget.heightPercent*0.30,
                    left: 0.5,
                    right: 0.5,
                    bottom: widget.heightPercent*0.10,
                    child: ListView(
                      controller: _scrollController,
                      children: [

                        ResponsiveTextCustomWithMargin('Profissionais próximos', context, CustomColors.blue, 3, 0.0, 10.0, 10.0, 20.0, 'center'),

                        Container(
                          width: widget.widthPercent,
                          height: widget.heightPercent*0.80,
                            child:Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
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

                                                truckId = querySnapshot.docs[index].id;
                                                mapGlobal = map;
                                                print('clicl');
                                                print('mapGlobal ');
                                                print(map);
                                                print(mapGlobal);
                                                print(truckId);
                                                moveModel.updateShowPopup(true);

                                                /*
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


                                           */



                                              },
                                              //child: Text(map['name']),
                                              child: truckerSelectListViewLine(map, context),
                                            );
                                            //return Trucker(querySnapshot.docs[index]);

                                          } ),);

                                  },
                                ),
                              ],
                            )
                        )


                      ],
                    ),
                ),

                moveModel.ShowPopup ? Positioned(
                    top: widget.heightPercent*0.32,
                    left: 10.0,
                    right: 10.0,
                    child: ConfirmationWindow(mapGlobal, moveModel, context, truckId)
                ) : SizedBox(),



              ],
            ),
          ),

        );

      },
    );

  }

  Widget truckerSelectListViewLine(Map map, BuildContext context){


    return CustomExpansionTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(map['image']),
        radius: 35,
      ),
      title: ResponsiveTextCustomWithMargin(map['apelido'], context, Colors.blue, 2.5, 0.0, 5.0, 0.0, 0.0, 'no'),
      subtitle: ResponsiveTextCustomWithMargin(map['aval'].toStringAsFixed(0)+' avaliações', context, Colors.black, 1.8, 0.0, 20.0, 0.0, 0.0, 'no'),
      rate: map['rate'],
      aval: map['aval'],
      linkImgCarro: map['vehicle_image'],
      width: widget.widthPercent*0.9,
      heightOfScreen: widget.heightPercent,

    );

  }

  Widget ConfirmationWindow(Map map, MoveModel moveModel, BuildContext context, String truckId ) {

    return Container(

      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CloseButton(
                onPressed: (){
                  moveModel.updateShowPopup(false);
                },)
            ],
          ),
          SizedBox(height: 15.0,),
          CircleAvatar(
            radius: 60.0,
            backgroundImage: NetworkImage(map['image']),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ResponsiveTextCustom('Escolher ', context, Colors.black, 2.5, 20.0, 20.0, 'no'),
              ResponsiveTextCustom(map['apelido'], context, CustomColors.blue, 2.5, 20.0, 20.0, 'no'),
              ResponsiveTextCustom('?', context, Colors.black, 2.5, 20.0, 20.0, 'no'),
            ],
          ),
          ResponsiveTextCustomWithMargin('Ao clicar abaixo iremos definir a data e hora da mudança. ', context, Colors.grey[400], 2.0, 0.0, 20.0, 20.0, 20.0, 'no'),
          Container(
            width: widget.widthPercent*0.50,
            height: widget.heightPercent*0.10,
            child: RaisedButton(
              onPressed: (){

                //agendar
                TruckerClass truckerClass = TruckerClass();
                truckerClass.image=map['image'];
                truckerClass.id=truckId;
                truckerClass.name=map['apelido'];
                truckerClass.aval=map['aval'].toDouble();

                //print(documents[index].documentID); apareceu deprecated
                //moveClass.freteiroId = documents[index].documentID; apareceu deprecated;
                moveModel.moveClass.freteiroId = truckId;
                moveModel.moveClass.userId = widget.uid;
                moveModel.moveClass.nomeFreteiro = map['apelido']; //antigamente pegava de 'name'.
                moveModel.moveClass.freteiroImage = map['image'];
                moveModel.moveClass.placa = map['placa'];
                SharedPrefsUtils().saveDataFromSelectTruckERPage(moveModel.moveClass);
                moveModel.changePageForward('data', 'profissional', 'Agendar');

                //showPopupFinal=true;
                //scheduleAmove();

              },
              color: CustomColors.blue,
              child: ResponsiveTextCustom('Escolher', context, Colors.white, 3.0, 0.0, 0.0, 'center'),
            ),
          )


        ],
      ),

      width: widget.widthPercent*0.75,
      height: widget.heightPercent*0.60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.white,
          width: 0.0, //                   <--- border width here
        ),

        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 10,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],

      ),
    );

  }
}


