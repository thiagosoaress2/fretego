import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/classes/truck_class.dart';
import 'package:fretego/classes/trucker_class.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/pages/home_page_internals/widget_loading_screen.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/custom_expansion_tile.dart';
import 'package:fretego/widgets/fakeLine.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/responsive_text_custom_withmargin.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

class Page5Trucker extends StatefulWidget {
  double heightPercent;
  double widthPercent;
  String uid;
  Page5Trucker(this.heightPercent, this.widthPercent, this.uid);

  @override
  _Page5TruckerState createState() => _Page5TruckerState();
}


bool _didTheUserUndestood=false; //vamos testar se o usuário entendeu o que é pra fazer. Caso seja negativo depois de um tempo vai dar dica.
bool _showToTheDumb=false; //quamdo for true vai mostrar a ajuda

class _Page5TruckerState extends State<Page5Trucker> {
  ScrollController _scrollController;
  Map<String, dynamic> _mapGlobal;

  String truckId;

  Query _query;
  Query _alternativeQuery; //query caso n encontre resultados do tipo preferido

  bool _showUserPreferredTruckerTypeCar=true;

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  bool _showWindowInformingNoTruckerFound=false;

  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget child, MoveModel moveModel){


        /*
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
         */

        print(moveModel.moveClass.pago);
        if(moveModel.LoadInitialData==true){
          moveModel.updateLoadInitialData(false);
          print('antes de entrar em _loadData');
          _loadData(moveModel);
          _helperMeth(moveModel); //ajusta a ajuda do user
        }

        return Scaffold(
          key: _scaffoldKey,
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
                  //bottom: widget.heightPercent*0.02,
                  child: Column(
                    //controller: _scrollController,
                    children: [

                      //aviso de que estamos exibindo profissionais que não tem o tipo de carro escolhido. Só vai ser triggado quando a primeira busca não encontrar nada
                      //_showUserPreferredTruckerTypeCar==false ? Text('Não encontramos profissionais próximos com o veículo desejado mas temos estes disponíveis próximos', textAlign: TextAlign.center, style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.0))) : Text('Profissionais próximos', textAlign: TextAlign.center, style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
                      _showUserPreferredTruckerTypeCar==false ? Text('Profissionais próximos', textAlign: TextAlign.center, style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))) : Text('Profissionais próximos', textAlign: TextAlign.center, style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),

                      SizedBox(height: widget.heightPercent*0.05,),

                      _query != null && _showUserPreferredTruckerTypeCar==true
                          ? _streamWithPreferredCar(moveModel) //query com o carro da preferencia
                          : _alternativeQuery != null && _showUserPreferredTruckerTypeCar==false
                            ? _streamListWithoutUserPreferred(moveModel) //aqui a outra query, com todos motoristas próximos
                              : Container(), //aqui query é null e n exibe nada


                    ],
                  ),
                ),

                moveModel.ShowPopup ? Positioned(
                    top: widget.heightPercent*0.32,
                    left: 10.0,
                    right: 10.0,
                    child: _ConfirmationWindow(_mapGlobal, moveModel, context, truckId)
                ) : SizedBox(),


                moveModel.IsLoadingData==true
                    ? WidgetLoadingScreeen('Aguarde', 'Recuperando dados')
                    : Container(),

                _showToTheDumb==true ? _help() : Container(),

                _showWindowInformingNoTruckerFound==true ? _showPopupInformingPreferredTruckerNotAvailable(moveModel) : Container(),



              ],
            ),
          ),

        );

      },
    );

  }

  Widget _streamWithPreferredCar(MoveModel moveModel){

    return Container(
        width: widget.widthPercent,
        height: widget.heightPercent*0.60,
        child:Column(
          mainAxisSize: MainAxisSize.max,
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
                      ? _noDataFromPreferred()
                      : Expanded(child: ListView.builder(
                      itemCount: querySnapshot.size,
                      //itemBuilder: (context, index) => Trucker(querySnapshot.docs[index]),
                      itemBuilder: (context, index) {

                        Map<String, dynamic> map = querySnapshot.docs[index].data();
                        return GestureDetector(
                          onTap: (){

                            truckId = querySnapshot.docs[index].id;
                            _mapGlobal = map;
                            moveModel.updateShowPopup(true);
                            _didTheUserUndestood=true;

                          },
                          //child: Text(map['name']),
                          child: _truckerSelectListViewLine(map, context, moveModel),
                        );
                        //return Trucker(querySnapshot.docs[index]);

                      } ),);

              },
            ),
          ],
        )
    );

  }

  //este método é chamado quando a query do carro preferido não enocntra nada
  Widget _streamListWithoutUserPreferred(MoveModel moveModel){

    return Container(
        width: widget.widthPercent,
        height: widget.heightPercent*0.60,
        child:Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _alternativeQuery.snapshots(),
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
                            _mapGlobal = map;
                            moveModel.updateShowPopup(true);
                            _didTheUserUndestood=true;

                          },
                          //child: Text(map['name']),
                          child: _truckerSelectListViewLine(map, context, moveModel),
                        );
                        //return Trucker(querySnapshot.docs[index]);

                      } ),);

              },
            ),
          ],
        )
    );

  }

  Widget _truckerSelectListViewLine(Map map, BuildContext context, MoveModel moveModel){

    final double _rateFinal = map['rate'].toDouble()?? 0.0;
    final int _avalFinal = map['aval']?? 0;

    final _car = TruckClass().formatCodeToHumanName(map['vehicle']);

    bool _precoEmenor;

    Widget _imageCarMiniaturePlaceholder(Image _image){

      return Container(
        height: widget.heightPercent*0.05,
        width: widget.widthPercent*0.20, child: _image,);
    }

    Widget _diferencaDePrecoPlaceHolder(){

      String _DiferencaDePreco = MoveClass.empty().returnThePriceDiferenceWithNumberOnly(TruckClass().formatCodeToHumanName(moveModel.TruckSuggested), _car);
      if(_DiferencaDePreco.contains('-')){
        _precoEmenor = true;
      } else {
        _precoEmenor = false;
      }
      _DiferencaDePreco = _DiferencaDePreco.replaceAll('R\$', '').replaceAll('-', '').replaceAll('+', '').trim();

      return Container(
        height: widget.heightPercent*0.05,
        color: _precoEmenor==true ? Colors.yellow : Colors.redAccent,
        child: Padding(
          padding: EdgeInsets.all(widget.heightPercent*0.002),
          child: Text(_DiferencaDePreco, style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
        ),
      );
    }

    //moveModel.TruckSuggested;

    return Column(
      children: [

        //se estiver mostrando o carro preferido nao vai exibir esta linha
        _showUserPreferredTruckerTypeCar==false ?
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            //primeira coluna dentro da linha
            Column(
              children: [

                _car=='pickup pequena' ? _imageCarMiniaturePlaceholder(Image.asset('images/itensselect/trucks/truck_pickupp.png', fit: BoxFit.fill,),) //Container(width: widget.widthPercent*0.10, child: Image.asset('images/itensselect/trucks/truck_pickupp.png', fit: BoxFit.fill,),)
                    : _car=='carroça' ? _imageCarMiniaturePlaceholder(Image.asset('images/itensselect/trucks/truck_carroca.png', fit: BoxFit.fill,))
                    : _car=='pickup grande' ? _imageCarMiniaturePlaceholder(Image.asset('images/itensselect/trucks/truck_pickupg.png', fit: BoxFit.fill,))
                    : _car=='kombi aberta' ? _imageCarMiniaturePlaceholder(Image.asset('images/itensselect/trucks/truck_kombia.png', fit: BoxFit.fill,))
                    : _car=='kombi fechada' ? _imageCarMiniaturePlaceholder(Image.asset('images/itensselect/trucks/truck_kombi.png', fit: BoxFit.fill,))
                    : _car=='caminhao aberto' ? _imageCarMiniaturePlaceholder(Image.asset('images/itensselect/trucks/truck_aberto.png', fit: BoxFit.fill,))
                    : _car=='caminhao baú pequeno' ? _imageCarMiniaturePlaceholder(Image.asset('images/itensselect/trucks/truck_baup.png', fit: BoxFit.fill,))
                    :  _imageCarMiniaturePlaceholder(Image.asset('images/itensselect/trucks/truck_baug.png', fit: BoxFit.fill,)),

                SizedBox(height: widget.heightPercent*0.01,),

                Text(_car, style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(1.8))),

              ],
            ),

            SizedBox(width: widget.widthPercent*0.05,),

            Column(
              children: [
                _diferencaDePrecoPlaceHolder(),

                SizedBox(height: widget.heightPercent*0.01,),

                _TextWithTheNewPrice(TruckClass().formatCodeToHumanName(moveModel.TruckSuggested), _car, moveModel, _precoEmenor),

              ],
            )
            //precisa traduzir....no bd tá pickupP e aqui pickup pequena. Tem o método pra isso





          ],
        ) : Container(),

        //elementos do tile
        CustomExpansionTile(
          childrenPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(map['image']),
            radius: 35,
          ),
          title: ResponsiveTextCustomWithMargin(map['apelido'], context, Colors.blue, 2.5, 0.0, 5.0, 0.0, 0.0, 'no'),
          //subtitle: ResponsiveTextCustomWithMargin(map['aval'].toStringAsFixed(0)+' avaliações', context, Colors.black, 1.8, 0.0, 20.0, 0.0, 0.0, 'no'),
          subtitle: ResponsiveTextCustomWithMargin(_avalFinal.toStringAsFixed(0)+' avaliações', context, Colors.black, 1.8, 0.0, 20.0, 0.0, 0.0, 'no'),
          //rate: map['rate'],
          rate: _rateFinal,
          //aval: map['aval'],
          aval: _avalFinal,
          linkImgCarro: map['vehicle_image'],
          width: widget.widthPercent*0.9,
          heightOfScreen: widget.heightPercent,

        )
      ],
    );

  }

  Widget _TextWithTheNewPrice(String TruckSuggested, String _car, MoveModel moveModel, bool _eMenor){

    final String _text =  MoveClass.empty().returnThePriceDiferenceWithNumberOnly(TruckSuggested, _car).replaceAll('R\$', '').replaceAll('-', '').replaceAll('+', '').trim();
    final double diferenca = double.parse(_text);
    print(diferenca);
    double novoTotal;
    if(_eMenor==true){
      novoTotal = moveModel.moveClass.preco-diferenca;
    } else {
      novoTotal = moveModel.moveClass.preco+diferenca;
    }

    print(novoTotal);

    return Text('total: R\$'+novoTotal.toStringAsFixed(2), style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)));
  }

  Widget _ConfirmationWindow(Map map, MoveModel moveModel, BuildContext context, String truckId ) {

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

                //se o user pegou um carro dos não sueridos e mudou o preço entra nesse if
                if(_showUserPreferredTruckerTypeCar==false) {
                  //update o novo preco com o novo tipo escolhido pelo usuario
                  final _car = TruckClass().formatCodeToHumanName(
                      map['vehicle']);
                  String _text = MoveClass.empty()
                      .returnThePriceDiferenceWithNumberOnly(
                      TruckClass().formatCodeToHumanName(
                          moveModel.TruckSuggested), _car).replaceAll('R\$', '')
                      .trim();
                  bool _precoEmenor;
                  if (_text.contains('-')) {
                    _precoEmenor = true;
                  } else {
                    _precoEmenor = false;
                  }
                  _text = _text.replaceAll('-', '').replaceAll('+', '').trim();
                  final double diferenca = double.parse(_text);
                  double _novoTotal;
                  if (_precoEmenor == true) {
                    _novoTotal = moveModel.moveClass.preco - diferenca;
                  } else {
                    _novoTotal = moveModel.moveClass.preco + diferenca;
                  }
                  moveModel.moveClass.preco = _novoTotal;
                  //novo preco incluido na classe

                  moveModel.moveClass.carro = map['vehicle'];
                }

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

  void _loadData(MoveModel moveModel){

    print('testando uid da pagina'+widget.uid);

    void thisDataCanBeLoaded(){


      moveModel.updateOrigemAddressVerified(moveModel.moveClass.enderecoOrigem);
      moveModel.updateDestinyAddressVerified(moveModel.moveClass.enderecoDestino);
      print('//entrou em thisDataCanBeLoaded');

      //procedimento padrão quando o user está preenchendo a mudança
      print('verifica se adicionou o endereço');
      print(moveModel.DestinyAddress);
      print(moveModel.OrigemAddress);
      print(moveModel.moveClass.enderecoOrigem);
      print(moveModel.moveClass.enderecoDestino);
      print(moveModel.moveClass.pago);

      _scrollController = ScrollController();

      final double latlong = moveModel.moveClass.latEnderecoOrigem+moveModel.moveClass.longEnderecoOrigem;
      double startAtval = latlong-(0.05*5.0);
      final double endAtval = latlong+(0.05*5.0);
      final double dif = -0.07576889999999992;
      startAtval = (dif+startAtval);

      _query = FirebaseFirestore.instance.collection('truckers').where('latlong', isGreaterThanOrEqualTo: startAtval)
          .where('latlong', isLessThan: endAtval).where('banido', isEqualTo: false).where('listed', isEqualTo: true)
          .where('vehicle', isEqualTo: moveModel.carInMoveClass);

      //qualquer veículo
      _alternativeQuery = FirebaseFirestore.instance.collection('truckers').where('latlong', isGreaterThanOrEqualTo: startAtval)
          .where('latlong', isLessThan: endAtval).where('banido', isEqualTo: false).where('listed', isEqualTo: true);


    }

    if(moveModel.moveClass.pago==true){ //significa que está voltando para trocar de motorista
      //entao vamos recuperar os dados da mudança para poder pegar latitude e longitude
      moveModel.updateIsLoadingData(true); //abre o loading

      Future<void> onSucessLoad() async {
        //carrega as latitudes e longitudes
        moveModel.moveClass = await MoveClass().getTheCoordinates(moveModel.moveClass, moveModel.moveClass.enderecoOrigem, moveModel.moveClass.enderecoDestino);
        thisDataCanBeLoaded();
        moveModel.updateIsLoadingData(false);
      }

      FirestoreServices().loadScheduledMoveInMoveMovelToChangeTrucker(moveModel, widget.uid, (){onSucessLoad();});


    } else {
      thisDataCanBeLoaded();
    }





  }

  Widget _noDataFromPreferred(){

    /*
    setState(() {
      _showUserPreferredTruckerTypeCar=false;
      _showWindowInformingNoTruckerFound=true;
    });

     */

    WidgetsBinding.instance
        .addPostFrameCallback((_) => setState(() {
      _showUserPreferredTruckerTypeCar=false;
      _showWindowInformingNoTruckerFound=true;
    }));

    //_displaySnackBar(context, 'Não encontramos profissionais com o carro escolhido. Mas nós temos estes motoristas disponíveis');

    return Text('aguarde...');



  }

  void _helperMeth(MoveModel moveModel){

    Future.delayed(Duration(seconds: 15)).then((_) {
      if(_didTheUserUndestood==false){
        /*
        setState(() {
          _showToTheDumb=true;
        });
         */
        _showToTheDumb=true;
        moveModel.updateHelpIsOnScreen(true);

        Future.delayed(Duration(seconds: 10)).then((_) {
          /*
          setState(() {
            _showToTheDumb=false;
          });
             */
          _showToTheDumb=false;
          moveModel.updateHelpIsOnScreen(false);
        });
      }
    });
  }

  Widget _help(){
    return GestureDetector(
      onTap: (){
        setState(() {
          _showToTheDumb=false;
        });
      },
      child: Container(
        height: widget.heightPercent,
        width: widget.widthPercent,
        color: Colors.black.withOpacity(0.6),
        child: Column(
          children: [
            SizedBox(height: widget.heightPercent*0.75,),
            Icon(Icons.arrow_upward, color: CustomColors.yellow, size: 45,),
            ResponsiveTextCustom('Selecione um dos\nprofissionais desta lista', context, CustomColors.yellow, 3.0, 0.0, 0.0, 'center')
          ],
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

  Widget _showPopupInformingPreferredTruckerNotAvailable(MoveModel moveModel){

    moveModel.updateHelpIsOnScreen(true);

    return Container(
      width: widget.widthPercent,
      height: widget.heightPercent,
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          width: widget.widthPercent*0.85,
          height: widget.heightPercent*0.55,
          decoration: BoxDecoration(
            border: Border.all(
              color: CustomColors.blue,
              width: 2.0, //                   <--- border width here
            ),
            color: Colors.white, boxShadow: [BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 3,
            offset: Offset(0, 3), // changes position of shadow
          ),
          ],),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(height: widget.heightPercent*0.05,),

              Text('Que pena', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(4.0))),

              SizedBox(height: widget.heightPercent*0.02,),

              Text('não encontramos motoristas disponíveis com o tipo de veículo selecionado.', textAlign: TextAlign.center, style: TextStyle(color: CustomColors.brown, fontSize: ResponsiveFlutter.of(context).fontSize(2.5))),

              SizedBox(height: widget.heightPercent*0.05,),

              Text('Exibindo lista com profissionais próximos', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),

              SizedBox(height: widget.heightPercent*0.10,),

              Container(
                width: widget.widthPercent*0.60,
                height: widget.heightPercent*0.10,
                child: RaisedButton(
                  color: CustomColors.yellow,
                  onPressed: (){

                    _showWindowInformingNoTruckerFound=false;
                    moveModel.updateHelpIsOnScreen(false);  //usei o método da ajuda. Aqui ele tira da tela a barra de animação que ficava em cima da janela popup

                    /*
                    setState(() {
                      _showWindowInformingNoTruckerFound=false;
                    });

                     */
                  },
                  child: Text('Ok', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(4.0))),
                ),
              )

            ],
          ),
        ),
      ),
    );

  }
}






















/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/classes/trucker_class.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/pages/home_page_internals/widget_loading_screen.dart';
import 'package:fretego/services/firestore_services.dart';
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


  bool _didTheUserUndestood=false; //vamos testar se o usuário entendeu o que é pra fazer. Caso seja negativo depois de um tempo vai dar dica.
  bool _showToTheDumb=false; //quamdo for true vai mostrar a ajuda

class _Page5TruckerState extends State<Page5Trucker> {
  ScrollController _scrollController;
  Map<String, dynamic> mapGlobal;

  String truckId;

  Query query;

  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget child, MoveModel moveModel){


        /*
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
         */

        print(moveModel.moveClass.pago);
        if(moveModel.LoadInitialData==true){
          moveModel.updateLoadInitialData(false);
          print('antes de entrar em _loadData');
          _loadData(moveModel);
          _helperMeth(moveModel); //ajusta a ajuda do user
        }

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

                        query != null
                        ? Container(
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
                                                moveModel.updateShowPopup(true);
                                                _didTheUserUndestood=true;

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
                            : Container(),


                      ],
                    ),
                ),

                moveModel.ShowPopup ? Positioned(
                    top: widget.heightPercent*0.32,
                    left: 10.0,
                    right: 10.0,
                    child: ConfirmationWindow(mapGlobal, moveModel, context, truckId)
                ) : SizedBox(),


                moveModel.IsLoadingData==true
                ? WidgetLoadingScreeen('Aguarde', 'Recuperando dados')
                    : Container(),

                _showToTheDumb==true ? _help() : Container(),



              ],
            ),
          ),

        );

      },
    );

  }

  Widget truckerSelectListViewLine(Map map, BuildContext context){

    final double _rateFinal = map['rate'].toDouble()?? 0.0;
    final int _avalFinal = map['aval']?? 0;

    return CustomExpansionTile(
      childrenPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(map['image']),
        radius: 35,
      ),
      title: ResponsiveTextCustomWithMargin(map['apelido'], context, Colors.blue, 2.5, 0.0, 5.0, 0.0, 0.0, 'no'),
      //subtitle: ResponsiveTextCustomWithMargin(map['aval'].toStringAsFixed(0)+' avaliações', context, Colors.black, 1.8, 0.0, 20.0, 0.0, 0.0, 'no'),
      subtitle: ResponsiveTextCustomWithMargin(_avalFinal.toStringAsFixed(0)+' avaliações', context, Colors.black, 1.8, 0.0, 20.0, 0.0, 0.0, 'no'),
      //rate: map['rate'],
      rate: _rateFinal,
      //aval: map['aval'],
      aval: _avalFinal,
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

  void _loadData(MoveModel moveModel){

    print('testando uid da pagina'+widget.uid);

    void thisDataCanBeLoaded(){


      moveModel.updateOrigemAddressVerified(moveModel.moveClass.enderecoOrigem);
      moveModel.updateDestinyAddressVerified(moveModel.moveClass.enderecoDestino);
      print('//entrou em thisDataCanBeLoaded');

      //procedimento padrão quando o user está preenchendo a mudança
      print('verifica se adicionou o endereço');
      print(moveModel.DestinyAddress);
      print(moveModel.OrigemAddress);
      print(moveModel.moveClass.enderecoOrigem);
      print(moveModel.moveClass.enderecoDestino);
      print(moveModel.moveClass.pago);

      _scrollController = ScrollController();

      final double latlong = moveModel.moveClass.latEnderecoOrigem+moveModel.moveClass.longEnderecoOrigem;
      double startAtval = latlong-(0.05*5.0);
      final double endAtval = latlong+(0.05*5.0);
      final double dif = -0.07576889999999992;
      startAtval = (dif+startAtval);

      query = FirebaseFirestore.instance.collection('truckers').where('latlong', isGreaterThanOrEqualTo: startAtval)
          .where('latlong', isLessThan: endAtval).where('banido', isEqualTo: false).where('listed', isEqualTo: true)
          .where('vehicle', isEqualTo: moveModel.carInMoveClass);



    }

    if(moveModel.moveClass.pago==true){ //significa que está voltando para trocar de motorista
      //entao vamos recuperar os dados da mudança para poder pegar latitude e longitude
      moveModel.updateIsLoadingData(true); //abre o loading

      Future<void> onSucessLoad() async {
        //carrega as latitudes e longitudes
        moveModel.moveClass = await MoveClass().getTheCoordinates(moveModel.moveClass, moveModel.moveClass.enderecoOrigem, moveModel.moveClass.enderecoDestino);
        thisDataCanBeLoaded();
        moveModel.updateIsLoadingData(false);
      }

      FirestoreServices().loadScheduledMoveInMoveMovelToChangeTrucker(moveModel, widget.uid, (){onSucessLoad();});


    } else {
      thisDataCanBeLoaded();
    }





  }


  void _helperMeth(MoveModel moveModel){

    Future.delayed(Duration(seconds: 15)).then((_) {
      if(_didTheUserUndestood==false){
        /*
        setState(() {
          _showToTheDumb=true;
        });
         */
        _showToTheDumb=true;
        moveModel.updateHelpIsOnScreen(true);

        Future.delayed(Duration(seconds: 10)).then((_) {
            /*
          setState(() {
            _showToTheDumb=false;
          });
             */
          _showToTheDumb=false;
          moveModel.updateHelpIsOnScreen(false);
        });
      }
    });
  }

  Widget _help(){
    return GestureDetector(
      onTap: (){
        setState(() {
          _showToTheDumb=false;
        });
      },
      child: Container(
        height: widget.heightPercent,
        width: widget.widthPercent,
        color: Colors.black.withOpacity(0.6),
        child: Column(
          children: [
            SizedBox(height: widget.heightPercent*0.75,),
            Icon(Icons.arrow_upward, color: CustomColors.yellow, size: 45,),
            ResponsiveTextCustom('Selecione um dos\nprofissionais desta lista', context, CustomColors.yellow, 3.0, 0.0, 0.0, 'center')
          ],
        ),
      ),
    );
  }
}




 */