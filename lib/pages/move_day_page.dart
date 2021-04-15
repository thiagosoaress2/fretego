import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:fretego/classes/avaliation_class.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/classes/trucker_movement_class.dart';
import 'package:fretego/models/move_day_page_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/avalatiation_page.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/responsive_text_custom_withmargin.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:location/location.dart';
import 'package:scoped_model/scoped_model.dart';


class MoveDayPage extends StatelessWidget {
  MoveClass _moveClass = MoveClass();
  MoveDayPage(this._moveClass);

  double heightPercent;
  double widthPercent;

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  GoogleMapController mapController;
  Set<Marker> markers = {};
  BitmapDescriptor origemLocation; //somente para o icone customizado
  BitmapDescriptor destinoLocation;
  BitmapDescriptor truckerLocationIcon; //imagem para o icone do user
  Completer<GoogleMapController> _controller = Completer();
  Location location = new Location();


  @override
  Widget build(BuildContext context) {

    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;

    return ScopedModelDescendant<MoveDayPageModel>(
      builder: (BuildContext context, Widget widget, MoveDayPageModel moveDayPageModel){
        
        if(moveDayPageModel.IsLoadingInitialData==true){
          moveDayPageModel.updateIsLoadingInitialData(false);
          _prepareIcons();
          _loadInitialData(moveDayPageModel);
          _loadTruckerImages(moveDayPageModel);
          _loadTruckerPhone(moveDayPageModel);
          _loadFirst(moveDayPageModel);
          _placeListenerToFinish(moveDayPageModel);
        }

        return Scaffold(
          key: _scaffoldKey,
          body: Container(
            width: widthPercent,
            height: heightPercent,
            color: Colors.white,
            child: Stack(
              children: [

                //mapa
                moveDayPageModel.ShowProblemInformPage==false
                ? Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child:
                  moveDayPageModel.InitialDataIsLoaded==true && moveDayPageModel.ShowProblemInformPage==false
                      ? _googleMap(moveDayPageModel)
                      : Container(), //no futuro colocar uma animação aqui referente a mapa
                ) : Container(),

                /*
                //barra decorativa semistransparente
                Positioned(
                    top: heightPercent*0.09,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      height: heightPercent*0.10,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.5),
                              ],
                              stops: [
                                0.0,
                                1.0
                              ])),
                    )
                ),
                 */

                //fake app bar
                moveDayPageModel.ShowProblemInformPage==false
                ? Positioned(
                  top: 30.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    width: widthPercent,
                    height: heightPercent*0.10,

                    child: Row(
                      children: [

                        Column(
                          children: [
                            IconButton(icon: Icon(Icons.keyboard_arrow_left, size: 45.0, color: CustomColors.blue,), onPressed: (){
                              Navigator.of(context).pop();
                              moveDayPageModel.updateIsLoadingInitialData(true);
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => HomePage()));
                            }),
                            ResponsiveTextCustomWithMargin('Início', context, CustomColors.blue, 1.2, 0.0, 0.0, heightPercent*0.02, 0.0, 'no'),
                          ],
                        ),
                        SizedBox(width: widthPercent*0.03,),
                        Container(
                          width: widthPercent*0.70,
                          child: ResponsiveTextCustomWithMargin('Acompanhe sua mudança', context, CustomColors.blue, 2.5, 0.0, 0.0, 0.0, 0.0, 'center'),
                        )

                      ],
                    ),
                  ),
                ) : Container(),

                //botoes no alto como Floating - desaparecem quando a barra inferior se expande
                moveDayPageModel.ShowCompleteInfo==false && moveDayPageModel.ShowProblemInformPage==false ?
                Positioned(
                  top: heightPercent*0.20,
                  right: 0.0,
                  left: widthPercent*0.8,
                  child: Container(
                    color: Colors.white,
                    height: heightPercent*0.43,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: heightPercent*0.02,),
                        falarComFreteiroBtn(),
                        ResponsiveTextCustomWithMargin('Falar com ${_moveClass.nomeFreteiro}', context, Colors.black, 1.3, 2.0, 5.0, 5.0, 5.0, 'center'),
                        relatarProblemaBtn(moveDayPageModel),
                        ResponsiveTextCustomWithMargin('Relatar um problema', context, Colors.black, 1.3, 2.0, 5.0, 5.0, 5.0, 'center'),
                        finalizarSmallBtn(moveDayPageModel),
                        ResponsiveTextCustomWithMargin('Finalizar a mudança', context, Colors.black, 1.3, 2.0, 5.0, 5.0, 5.0, 'center'),

                      ],
                    ),
                  ),
                ) : Container(),

                //barra inferir que expande
                moveDayPageModel.ShowProblemInformPage==false
                    ? Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    height: moveDayPageModel.ShowCompleteInfo==false ? heightPercent*0.10 : heightPercent*0.8,
                    width: widthPercent,
                    color: Colors.white,
                    child:
                    moveDayPageModel.ShowCompleteInfo==false
                        //botao apenas
                    ? Column(
                      children: [
                        SizedBox(height: heightPercent*0.025,),
                        Container(
                          alignment: Alignment.center,
                          width: widthPercent*0.40,
                          height: heightPercent*0.06,
                          child: RaisedButton(
                              child: ResponsiveTextCustomWithMargin('Ver infos', context, Colors.white, 2.5, 2.0, 2.0, 10.0, 10.0, 'center'),
                              color: CustomColors.yellow,
                              onPressed: (){ moveDayPageModel.updateShowCompleteInfo(); }),

                        ),
                      ],
                    )
                    //lista com informações
                    : Padding(padding: EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 2.0),
                    child: Column(
                      children: [
                        //barra com botão para encolher novamente a tela
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blue, size: 40.0,),
                              onPressed: (){
                                moveDayPageModel.updateShowCompleteInfo();
                              },
                            )
                          ],
                        ),
                        ResponsiveTextCustom('ORIGEM: ${_moveClass.enderecoOrigem}', context, Colors.black, 1.8, 5.0, 0.0, 'no'),
                        Divider(),
                        ResponsiveTextCustom('DESTINO: ${_moveClass.enderecoDestino}', context, Colors.black, 1.8, 5.0, 0.0, 'no'),
                        Divider(color: Colors.blue,),
                        ResponsiveTextCustom('PLACA: ${_moveClass.placa}', context, Colors.black, 2.5, 10.0, 5.0, 'no'),
                        //linha com as imagens
                        Row(
                          children: [

                            Container(
                              child: moveDayPageModel.TruckerImage != null
                                  ? Column(
                                children: [
                                  ResponsiveTextCustom(_moveClass.nomeFreteiro, context, Colors.black, 2.5, 0.0, 5.0, 'center'),
                                  Container(
                                    height: heightPercent*0.15,
                                    width: widthPercent*0.45,
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          moveDayPageModel.TruckerImage
                                      ),
                                    ),
                                  )
                                ],
                              )
                                  : Container(),
                            ),
                            SizedBox(width: 10.0,),
                            //coluna com a foto do carro
                            Container(
                              child: moveDayPageModel.TruckerCarImage != null
                                  ? Column(
                                children: [
                                  ResponsiveTextCustom('Veículo', context, Colors.black, 2.5, 0.0, 5.0, 'center'),
                                  Container(
                                    height: heightPercent*0.15,
                                    width: widthPercent*0.45,
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          moveDayPageModel.TruckerCarImage
                                      ),
                                    ),
                                  )
                                ],
                              )
                                  : Container(),
                            ),
                          ],
                        ),
                        //linha com os botõs
                        SizedBox(height: heightPercent*0.04,),
                        //Linha com os botões de falar com freteiro e relatar problema
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: heightPercent*0.15,
                              width: widthPercent*0.32,
                              child: Column(
                                children: [
                                  falarComFreteiroBtn(),
                                  ResponsiveTextCustomWithMargin('Falar com ${_moveClass.nomeFreteiro}', context, Colors.black, 1.3, 2.0, 5.0, 5.0, 5.0, 'center'),
                                ],
                              ),
                            ),
                            Container(
                              height: heightPercent*0.15,
                              width: widthPercent*0.32,
                              child: Column(
                                children: [
                                  relatarProblemaBtn(moveDayPageModel),
                                  ResponsiveTextCustomWithMargin('Relatar problema', context, Colors.black, 1.3, 2.0, 5.0, 5.0, 5.0, 'center'),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: heightPercent*0.02,),
                        Container(
                          width: widthPercent*0.9,
                          height: heightPercent*0.08,
                          child: RaisedButton(
                            color: Colors.redAccent,
                            child: ResponsiveTextCustom('A mudança acabou?', context, Colors.white, 2.5, 0.0, 0.0, 'center'),
                            onPressed: (){
                              _finishMoveClick(moveDayPageModel);
                            },
                          ),
                        )
                      ],
                    ),
                    )
                  ),
                ): Container(),

                moveDayPageModel.ShowMessageThatTruckerFinishedTheMove==true
                    ? _popUpInformingTruckerFinishedMove(moveDayPageModel)
                    : Container(),

                moveDayPageModel.ShowMessageThatTruckerIsCommingBack==true
                    ? _popUpInformingTruckerIsCommingBack(moveDayPageModel)
                    : Container(),

                moveDayPageModel.ShowProblemInformPage==true
                ? ProblemPage(context, moveDayPageModel) : Container(),

                moveDayPageModel.ShowMoveIsFinished==true
                ? _confirmFinishMovePopup(moveDayPageModel, context) : Container(),


              ],
            ),
          ),
        );

      },
    );
  }

  Widget falarComFreteiroBtn(){

    return FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.phone, color: Colors.white,),
        onPressed: (){ }
    );

  }

  Widget relatarProblemaBtn(MoveDayPageModel model){

    return FloatingActionButton(
        backgroundColor: CustomColors.brown,
        child: Icon(Icons.report_problem, color: Colors.white,),
        onPressed: (){
          model.updateShowProblemInformPage(true);
        }
    );

  }

  Widget finalizarSmallBtn(MoveDayPageModel model){

    return FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.check, color: Colors.white,),
        onPressed: (){
          _finishMoveClick(model);
        }
    );

  }

  void _prepareIcons(){

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/maps/markerorigem.png').then((onValue) {
      origemLocation = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/maps/markerdestino.png').then((onValue) {
      destinoLocation = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        //'images/carrinhobaby.jpg').then((value) {  //usar a imagem correta
        'images/maps/truckerico.png').then((value) {
      truckerLocationIcon = value;
    });


  }

  Future<void> _loadInitialData(MoveDayPageModel model) async {

    model.initialcameraposition = await LatLng(_moveClass.latEnderecoOrigem, _moveClass.longEnderecoOrigem);
    model.updateOrigemPos(await LatLng(_moveClass.latEnderecoOrigem, _moveClass.longEnderecoOrigem));
    model.updateDestinyPos(await LatLng(_moveClass.latEnderecoDestino, _moveClass.longEnderecoDestino));



  }

  Future<void >_loadTruckerImages(MoveDayPageModel model) async {

    String imageTrucker = await FirestoreServices().getTruckerImage(_moveClass.freteiroId);
    //imagem
    model.updateTruckerImage(imageTrucker);
    imageTrucker = await FirestoreServices().getTruckerCarImage(_moveClass.freteiroId);
    model.updateTruckerCarImage(imageTrucker);

  }

  Future<void> _loadTruckerPhone(MoveDayPageModel model) async {

    if(model.Phone == null){
      model.updatePhone(await FirestoreServices().getTruckerPhone(_moveClass.freteiroId));
      model.updateShowWhatsappBtn(true);

    }

  }

  Future<void> _loadFirst(MoveDayPageModel model) async {

    await FirestoreServices().loadLastKnownTruckerPosition(_moveClass.freteiroId, model.truckerMovementClass, () {_onSucessLoadLastKnownPosition(model); });

  }

  void _loadLastKnownPositionOfTrucker(MoveDayPageModel model) {

    Future.delayed(Duration(seconds: 90)).whenComplete(() async {

      await FirestoreServices().loadLastKnownTruckerPosition(_moveClass.freteiroId, model.truckerMovementClass, () {_onSucessLoadLastKnownPosition(model); });

    });

  }

  void _onSucessLoadLastKnownPosition(MoveDayPageModel model){


    print('falta verificar se quando tiver lat long do trucker vai atualizar aqui direito');
    print(model.truckerMovementClass.latitude);
    model.updateTruckerLocationLatLng(LatLng(model.truckerMovementClass.latitude, model.truckerMovementClass.longitude));
    print(model.TruckerLocationLatLng);
    markers.removeWhere((item) => item.markerId.value == 'trucker');
    markers.removeWhere((item) => item.markerId.value == 'origem');
    markers.removeWhere((item) => item.markerId.value == 'destino');

    _addMarkerTrucker(model);
    _addMarkerOrigem(model);
    _addMarkerDestino(model);

    //userLocationLatLng = LatLng(_truckerMovementClass.latitude, _truckerMovementClass.longitude);


    model.updateInitialDataIsLoaded(true);

    //call next load
    _loadLastKnownPositionOfTrucker(model);

  }

  void _addMarkerTrucker(MoveDayPageModel model){

    if(model.TruckerLocationLatLng.toString() == 'LatLng(0.0, 0.0)'){
      print('localização do motorista ainda é desconhecida');
    } else {

      markers.add(
        Marker(
          markerId: MarkerId('trucker'),
          position: model.TruckerLocationLatLng,
          icon: truckerLocationIcon,
          infoWindow: InfoWindow(
              title: _moveClass.nomeFreteiro),
        ),
      );

    }


    /*
    setState(() {
      markers = markers;
    });

     */

  }

  void _addMarkerOrigem(MoveDayPageModel model){

    markers.add(
      Marker(
        markerId: MarkerId('origem'),
        position: model.OrigemPos,
        icon: origemLocation,
        infoWindow: InfoWindow(
            title: "Origem"),
      ),
    );

  }

  void _addMarkerDestino(MoveDayPageModel model){

    markers.add(
      Marker(
        markerId: MarkerId('destino'),
        position: model.DestinyPos,
        icon: destinoLocation,
        infoWindow: InfoWindow(
            title: "Destino"),
      ),
    );

  }

  void _finishMoveClick(MoveDayPageModel model){

    model.updateShowMoveIsFinished(true);

  }

  Widget _confirmFinishMovePopup(MoveDayPageModel model, BuildContext context){

    return Container(
      width: widthPercent,
      height: heightPercent,
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: heightPercent*0.05,),
          //botao fechar
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CloseButton(
                onPressed: (){
                  model.updateShowMoveIsFinished(false);
                },
              ),
            ],
          ),
          SizedBox(height: heightPercent*0.05,),
          ResponsiveTextCustom('Já terminou?', context, CustomColors.blue, 4.5, 0.0, 0.0, 'center'),
          SizedBox(height: heightPercent*0.05,),
          Container(
            width: widthPercent*0.45,
            height: heightPercent*0.25,
            child: Image.asset('images/popup/myboxes.png'),
          ),
          ResponsiveTextCustomWithMargin('Você tem certeza que deseja encerrar esta mudança e avaliar o serviço?', context,
              CustomColors.blue, 3, 20.0, 5.0, 10.0, 10.0, 'center'),
          ResponsiveTextCustomWithMargin('Após clicar em finalizar você não poderá volta a esta tela', context,
              Colors.black, 1.5, 0.0, 40.0, 10.0, 10.0, 'center'),

          Container(
            width: widthPercent*0.80,
            height: heightPercent*0.10,
            child: RaisedButton(
              color: CustomColors.yellow,
              child: ResponsiveTextCustom('Encerrar e avaliar', context, Colors.white, 3, 0.0, 0.0, 'center'),
              onPressed: (){

                _moveClass.freteiroImage = model.TruckerImage;
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => AvaliationPage(_moveClass)));


              },
            ),
          )


        ],
      ),
    );

  }


  Future<String> _placeListenerToFinish(MoveDayPageModel model){

    final docRef = FirebaseFirestore.instance.collection(FirestoreServices.agendamentosPath).doc(_moveClass.moveId);

    docRef.snapshots().listen((DocumentSnapshot event) async {

      print(event.data()['situacao']);
      if(event.data()['situacao'] ==  'trucker_finished'){   //trocar para pago
        model.updateShowMessageThatTruckerFinishedTheMove(true);
      } else if(event.data()['situacao'] == 'user_informs_trucker_didnt_finished_move_goingback'){
        model.updateShowMessageThatTruckerIsCommingBack(true);
      }
    });

  }

  Widget _popUpInformingTruckerFinishedMove(MoveDayPageModel model){

    void _onSucess(){
      model.updateShowMessageThatTruckerFinishedTheMove(false);
    }

    return WidgetsConstructor().customPopUp1Btn('Atenção', 'O profissional acaba de indicar que a mudança acabou. Finalize também para registrar que está tudo ok e encerrar o procedimento. Caso a mudança não tenha finalizado, não encerre, relate como problema..', Colors.blue, widthPercent, heightPercent, () { _onSucess();});


  }

  Widget _popUpInformingTruckerIsCommingBack(MoveDayPageModel model){

    void _onSucess(){
      model.updateShowMessageThatTruckerIsCommingBack(false);
    }

    return WidgetsConstructor().customPopUp1Btn('Atenção', 'O profissional voltando para finalizar a mudança.', Colors.blue, widthPercent, heightPercent, () { _onSucess();});


  }



  Widget _googleMap(MoveDayPageModel model){
    return Container(
      height: heightPercent*0.90,
      child: GoogleMap(
        myLocationEnabled: true,
        markers: markers,
        initialCameraPosition: CameraPosition(target: model.initialcameraposition, zoom: 12.0,),
        onMapCreated: (GoogleMapController controller) async {
          _controller.complete(controller);

          await location.getLocation().then((LocationData currentLocation) {
            model.updateUserLocationLatLng(LatLng(currentLocation.latitude, currentLocation.longitude));
            //userLocationLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
          });

          //setState(() {

            //_addMarkerTrucker();

            //_addMarkerOrigem();

            //_addMarkerDestino();

         // });

          _loadLastKnownPositionOfTrucker(model);
        },


      ),
    );
  }


  //pages
  Widget ProblemPage(BuildContext context, MoveDayPageModel model){

    Widget _buildRadioSelectProblem(BuildContext context) {
      return Column(
        children: [

          Container(
            width: widthPercent,
            child: RadioButton(
                description: "O profissional não fez a mudança.",
                value: "freteiro não fez a mudança",
                groupValue: model.Problem,
                onChanged: (value) => model.updateProblem(value)
            ),
          ),

          Container(
            width: widthPercent,
            child: RadioButton(
                description: "O profissional encerrou a \nmudança no aplicativo sem concluir.",
                value: "freteiro encerrou antes da hora",
                groupValue: model.Problem,
                onChanged: (value) => model.updateProblem(value)
            ),
          ),



        ],
      );
    }

    return ListView(
      children: [
        Padding(
            child: Column(
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(icon: Icon(Icons.arrow_back, size: 45.0, color: Colors.blue,), onPressed:() {

                      model.updateShowProblemInformPage(false);

                    }),

                  ],
                ),

                WidgetsConstructor().makeText('Relatando um problema', Colors.blue, 16.0, 25.0, 20.0, 'center'),

                _buildRadioSelectProblem(context),

                SizedBox(height: 25.0,),

                Container(
                  width: widthPercent*0.85,
                  height: 60.0,
                  child: RaisedButton(
                      splashColor: Colors.lightBlue,
                      color: Colors.blue,
                      child: WidgetsConstructor().makeText('Relatar problema', Colors.white, 17.0, 5.0, 5.0, 'center'),
                      onPressed:(){

                        String msg;
                        if(model.Problem!= null){

                          if(model.Problem=='freteiro não fez a mudança'){
                            msg = 'user_informs_trucker_didnt_make_move';
                          } else {
                            msg = 'user_informs_trucker_didnt_finished_move';
                          }
                          FirestoreServices().updateMoveSituation(msg, _moveClass.freteiroId, _moveClass);
                          MyBottomSheet().settingModalBottomSheet(context, 'Sentimos muito', 'Estamos trabalhando nisto', 'por favor aguarde e não finalize a mudança.',
                              Icons.report_problem, heightPercent, widthPercent, 0, true);
                          model.updateShowProblemInformPage(false);
                        } else {
                          _displaySnackBar(context, 'Informe o problema');
                        }

                      }),
                ),

                SizedBox(height: 25.0,),


              ],
            ),
            padding: EdgeInsets.all(10.0)),
      ],
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



/*
class MoveDayPage extends StatelessWidget {
  MoveClass _moveClass = MoveClass();
  double heightPercent;
  double widthPercent;
  MoveDayPage(this._moveClass, this.heightPercent, this.widthPercent);



  GoogleMapController mapController;
  Set<Marker> markers = {};
  BitmapDescriptor origemLocation; //somente para o icone customizado
  BitmapDescriptor destinoLocation;
  BitmapDescriptor truckerLocationIcon; //imagem para o icone do user
  Completer<GoogleMapController> _controller = Completer();
  Location location = new Location();


  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MoveDayPageModel>(
      builder: (BuildContext context, Widget child, MoveDayPageModel moveDayPageModel){

        return Container(
         // width: widthPercent,
          //height: heightPercent,
          color: Colors.white,
          child: Stack(
            children: [

              Positioned(
                top: 50.0,
                left: 0.0,
                right: 0.0,
                child: Row(
                  children: [
                    IconButton(icon: Icon(Icons.keyboard_arrow_left, size: 35.0, color: CustomColors.blue,), onPressed: _goBack(context)),
                  ],
                ),
              ),

            ],
          ),
        );

      },
    );
  }

  void _buildIcons(){

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/maps/markerorigem.png').then((onValue) {
      origemLocation = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/maps/markerdestino.png').then((onValue) {
      destinoLocation = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        //'images/carrinhobaby.jpg').then((value) {  //usar a imagem correta
        'images/maps/truckerico.png').then((value) {
      truckerLocationIcon = value;
    });

  }

  _goBack(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => HomePage()));
  }

}


 */



//ABAIXO VERSAO ORIGINAL

/*
bool isFirstLoad=true;

final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

class MoveDayPage extends StatefulWidget {
  MoveClass _moveClass = MoveClass();

  MoveDayPage(this._moveClass);

  @override
  _MoveDayPageState createState() => _MoveDayPageState();
}

class _MoveDayPageState extends State<MoveDayPage>{


  double heightPercent;
  double widthPercent;

  GoogleMapController mapController;

  MoveClass moveClass = MoveClass();

  TruckerMovementClass _truckerMovementClass = TruckerMovementClass();

  //final LatLng _center = const LatLng(45.521563, -122.677433);
  LatLng _initialcameraposition;
  LatLng _origemPos;
  LatLng _destinyPos;

  Set<Marker> markers = {};

  BitmapDescriptor origemLocation; //somente para o icone customizado
  BitmapDescriptor destinoLocation;
  BitmapDescriptor truckerLocationIcon; //imagem para o icone do user

  LatLng userLocationLatLng;

  Completer<GoogleMapController> _controller = Completer();

  bool _showAlertFinishMove=false;
  bool _showMessageThatTruckerFinishedTheMove=false;
  bool _showMessageThatTruckerIsCommingBack=false;

  bool _showProblemInformPage=false;

  Location location = new Location();

  bool showWhatsappBtn=false;

  String phone;

  bool _initialDataIsOk=false;
  String problem;


 */

/*
  @override
  Future<void> afterFirstLayout(BuildContext context) {
    // isto é exercutado após todo o layout ser renderizado

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/maps/markerorigem.png').then((onValue) {
      origemLocation = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/maps/markerdestino.png').then((onValue) {
      destinoLocation = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        //'images/carrinhobaby.jpg').then((value) {  //usar a imagem correta
        'images/maps/truckerico.png').then((value) {
      truckerLocationIcon = value;
    });

  }


 */

/*
  @override
  void initState() {

    //_getCurrentLocation();


    /*
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/maps/markerorigem.png').then((onValue) {
      origemLocation = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/maps/markerdestino.png').then((onValue) {
      destinoLocation = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        //'images/carrinhobaby.jpg').then((value) {  //usar a imagem correta
        'images/maps/truckerico.png').then((value) {
      truckerLocationIcon = value;
    });

     */

  }
 */

/*
  @override
  Widget build(BuildContext context) {

    moveClass = widget._moveClass;

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){


        heightPercent = MediaQuery
            .of(context)
            .size
            .height;
        widthPercent = MediaQuery
            .of(context)
            .size
            .width;


        if(isFirstLoad==true){
          isFirstLoad=false;
          _loadInitialData();
          _loadTruckerPhone();
          _loadFirst();
          _placeListenerToFinish();
        }

        return Scaffold(
          key: _scaffoldKey,

          body: Stack(
            children: [

              Positioned(
                top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Row(
                    children: [

                      Column(
                        children: [
                          IconButton(icon: Icon(Icons.keyboard_arrow_left), onPressed: _goBack(context), color: CustomColors.blue, iconSize: 35.0,),
                          ResponsiveTextCustom('Início', context, CustomColors.blue, 1.2, 2.0, 2.0, 'no'),
                        ],
                      ),

                      ResponsiveTextCustomWithMargin('Acompanhe sua mudança', context, CustomColors.blue, 2.5, 2.0, 2.0, 15.0, 15.0, 'center'),

                    ],
                  ),
              ),

              Column(
                children: [

                  _initialDataIsOk==true && _showProblemInformPage==false
                  ? _googleMap(heightPercent*0.55)
                  : Container(), //no futuro colocar uma animação aqui referente a mapa

                  _showProblemInformPage==false
                  ? _bottomBar()
                  : Container(),

                ],
              ),

              showWhatsappBtn == true && _showProblemInformPage==false
              ? Positioned(
                  top: heightPercent*0.2,
                  right: 10.0,
                  child: _placa())
                  : Container(),

              showWhatsappBtn == true && _showProblemInformPage==false
              ? Positioned(
                  top: heightPercent*0.4,
                  right: 10.0,
                  child: _whatsappBtn())
              : Container(),

              _showProblemInformPage==false
              ? Positioned(
                top: heightPercent*0.6,
                right: 10.0,
                child: _problemBtn(),
              )
              : Container(),

              _showAlertFinishMove==true
                  ? _confirmFinishMovePopup()
                  : Container(),

              _showProblemInformPage==true
                  ? ProblemPage()
                  : Container(),

              _showMessageThatTruckerFinishedTheMove==true
                ? _popUpInformingTruckerFinishedMove()
                  : Container(),

              _showMessageThatTruckerIsCommingBack==true
                  ? _popUpInformingTruckerIsCommingBack()
                  : Container(),

            ],
          ),

        );
      },
    );
  }


 */

/*
  //Pages
  Widget ProblemPage(){

    Widget _buildRadioSelectProblem(BuildContext context) {
      return Column(
        children: [

            RadioButton(
            description: "O profissional não fez a mudança.",
              value: "freteiro não fez a mudança",
              groupValue: problem,
              onChanged: (value) => setState(
                    () => problem = value,
              ),
            ),

          RadioButton(
            description: "O profissional encerrou a mudança no aplicativo sem concluir.",
            value: "freteiro encerrou antes da hora",
            groupValue: problem,
            onChanged: (value) => setState(
                  () => problem = value,
            ),
          ),


        ],
      );
    }

    return ListView(
      children: [
        Padding(
            child: Column(
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(icon: Icon(Icons.arrow_back, size: 45.0, color: Colors.blue,), onPressed:() {

                      setState(() {
                        _showProblemInformPage=false;
                      });

                    }),

                  ],
                ),

                WidgetsConstructor().makeText('Relatando um problema', Colors.blue, 16.0, 25.0, 20.0, 'center'),

                _buildRadioSelectProblem(context),

                SizedBox(height: 25.0,),

                Container(
                  width: widthPercent*0.85,
                  height: 60.0,
                  child: RaisedButton(
                      splashColor: Colors.lightBlue,
                      color: Colors.blue,
                      child: WidgetsConstructor().makeText('Relatar problema', Colors.white, 17.0, 5.0, 5.0, 'center'),
                      onPressed:(){

                        String msg;
                        if(problem!= null){

                          if(problem=='freteiro não fez a mudança'){
                            msg = 'user_informs_trucker_didnt_make_move';
                          } else {
                            msg = 'user_informs_trucker_didnt_finished_move';
                          }
                          FirestoreServices().updateMoveSituation(msg, moveClass.freteiroId, moveClass);
                          _displaySnackBar(context, 'Estamos trabalhando para resolver seu problema, por favor aguarde e não finalize a mudança.');
                          setState(() {
                            _showProblemInformPage=false;
                          });
                        } else {
                          _displaySnackBar(context, 'Informe o problema');
                        }

                      }),
                ),

                SizedBox(height: 25.0,),


              ],
            ),
            padding: EdgeInsets.all(10.0)),
      ],
    );



  }


 */


/*
  Future<void> _loadFirst() async {

    await FirestoreServices().loadLastKnownTruckerPosition(moveClass.moveId, _truckerMovementClass, () {_onSucessLoadLastKnownPosition(); });

  }

 */

/*
  //meths
  void _loadLastKnownPositionOfTrucker() {

    Future.delayed(Duration(seconds: 90)).whenComplete(() async {

      await FirestoreServices().loadLastKnownTruckerPosition(moveClass.moveId, _truckerMovementClass, () {_onSucessLoadLastKnownPosition(); });

    });

  }

  void _onSucessLoadLastKnownPosition(){

    userLocationLatLng = LatLng(_truckerMovementClass.latitude, _truckerMovementClass.longitude);

    markers.removeWhere((item) => item.markerId.value == 'trucker');
    markers.removeWhere((item) => item.markerId.value == 'origem');
    markers.removeWhere((item) => item.markerId.value == 'destino');

    setState(() {
      _addMarkerTrucker();
      _addMarkerOrigem();
      _addMarkerDestino();
    });

    //call next load
    _loadLastKnownPositionOfTrucker();

  }

 */

/*
  void _addMarkerTrucker(){

    markers.add(
      Marker(
        markerId: MarkerId('trucker'),
        position: userLocationLatLng,
        icon: truckerLocationIcon,
        infoWindow: InfoWindow(
            title: moveClass.nomeFreteiro),
      ),
    );

    setState(() {
      markers = markers;
    });

  }

  void _addMarkerOrigem(){

    markers.add(
      Marker(
        markerId: MarkerId('origem'),
        position: _origemPos,
        icon: origemLocation,
        infoWindow: InfoWindow(
            title: "Origem"),
      ),
    );

  }

  void _addMarkerDestino(){

    markers.add(
      Marker(
        markerId: MarkerId('destino'),
        position: _destinyPos,
        icon: destinoLocation,
        infoWindow: InfoWindow(
            title: "Destino"),
      ),
    );

  }


 */

/*
  Future<void> _loadInitialData() async {

    _initialcameraposition = await LatLng(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem);
    _origemPos = await LatLng(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem);
    _destinyPos = await LatLng(moveClass.latEnderecoDestino, moveClass.longEnderecoDestino);
    setState(() {
      _initialDataIsOk=true;
    });
  }

  _goBack(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => HomePage()));
  }

  Future<void> _loadTruckerPhone() async {

    if(phone == null){
      phone = await FirestoreServices().getTruckerPhone(moveClass.freteiroId);
      setState(() {
        showWhatsappBtn=true;
      });
    }

  }

  Future<String> _placeListenerToFinish(){

    final docRef = FirebaseFirestore.instance.collection(FirestoreServices.agendamentosPath).doc(moveClass.moveId);

    docRef.snapshots().listen((DocumentSnapshot event) async {

      print(event.data()['situacao']);
      if(event.data()['situacao'] ==  'trucker_finished'){   //trocar para pago
        setState(() {
          _showMessageThatTruckerFinishedTheMove=true;
        });
      } else if(event.data()['situacao'] == 'user_informs_trucker_didnt_finished_move_goingback'){
        setState(() {

        });
      }
    });


    /*
    Future<void> _onFinish() async {

      final docRef = FirebaseFirestore.instance.collection(FirestoreServices.agendamentosPath).doc(moveClass.moveId);

      docRef.snapshots().listen((DocumentSnapshot event) async {

        print(event.data()['situacao']);
        if(event.data()['situacao'] !=  'trucker_quited_after_payment'){   //trocar para pago
          print('foi em '+DateTime.now().toString());
        }
      });

    }

    FirestoreServices().loadScheduledMoveInFbWithCallBack(moveClass, userModel, () { _onFinish();});


     */


  }


 */



/*
  //Widgets
  Widget _googleMap(double heightSelected){
    return Container(
      height: heightSelected,
      child: GoogleMap(
        myLocationEnabled: true,
        markers: markers,
        initialCameraPosition: CameraPosition(target: _initialcameraposition, zoom: 12.0,),
        onMapCreated: (GoogleMapController controller) async {
          _controller.complete(controller);

          await location.getLocation().then((LocationData currentLocation) {
            userLocationLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
          });


          setState(() {

            _addMarkerTrucker();

            _addMarkerOrigem();

            _addMarkerDestino();

          });

          _loadLastKnownPositionOfTrucker();
        },


      ),
    );
  }

  Widget _bottomBar() {

    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
        child: Column(
          children: [
            WidgetsConstructor().makeText("Origem: ", Colors.blue, 15.0, 0.0, 2.0, null),
            Container(
              decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 1.0, 5.0),
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: WidgetsConstructor().makeText(moveClass.enderecoOrigem, Colors.black, 15.0, 0.0, 0.0, null),
              ),
            ),
            WidgetsConstructor().makeText("Destino: ", Colors.blue, 15.0, 0.0, 2.0, null),
            Container(
              decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 1.0, 5.0),
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: WidgetsConstructor().makeText(moveClass.enderecoDestino, Colors.black, 15.0, 0.0, 0.0, null),
              ),
            ),
            SizedBox(height: 5.0,),
            GestureDetector(
              onTap: (){
                setState(() {
                  _showAlertFinishMove=true;
                });
              },
              child: WidgetsConstructor().makeButton(Colors.blue, Colors.white, widthPercent*0.85, heightPercent*0.08, 2.0, 4.0, "Finalizar mudança", Colors.white, 17.0),
            ),

          ],
        ),
      ),
    );

  }

  Widget _confirmFinishMovePopup(){

    return GestureDetector(
      onTap: (){
        setState(() {
          _showAlertFinishMove=false;
        });
      },
      child: Container(
        height: heightPercent,
        width: widthPercent,
        child: Center(
          child: Container(
            width: widthPercent*0.8,
            height: heightPercent*0.6,
            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 3.0, 4.0),
            child: Column(
              children: [
                //close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CloseButton(
                      onPressed: () {
                        setState(() {
                          _showAlertFinishMove=false;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 80.0,),
                WidgetsConstructor().makeText("Você tem certeza que deseja encerrar esta mudança e avaliar o profissional?", Colors.blue, 18.0, 0.0, 20.0, 'center'),
                GestureDetector(
                  onTap: () async {


                    setState(() {
                      isLoading=true;
                    });


                    void _onFail(){
                      print('fail');
                    }

                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => AvaliationPage(moveClass)));



                    //await FirestoreServices().loadMoveClassForTests(moveIdSomenteParaTestarAvaliationPage, moveClass, () {_onFail();}, () {_onSucess();});



                    /*
                    AvaliationClass _avaliationClass = AvaliationClass();
                    _avaliationClass.enderecoOrigem = moveClass.enderecoOrigem;
                    _avaliationClass.enderecoDestino = moveClass.enderecoDestino;
                    _avaliationClass.nomeMotorista = moveClass.nomeFreteiro;
                    _avaliationClass.motoristaId = moveClass.freteiroId;
                    //_avaliationClass.distancia =  falta esse . é importante?
                    _avaliationClass.data = moveClass.dateSelected;
                    _avaliationClass.hora = moveClass.timeSelected;

                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => AvaliationPage(_avaliationClass)));

                     */

                  },
                  child: WidgetsConstructor().makeButton(Colors.blue, Colors.white, widthPercent*0.5, 60.0, 2.0, 4.0, 'Finalizar', Colors.white, 18.0),
                )
              ],
            ),
          ),
        ),
      ),

    );

  }

  Widget _placa(){

    return Container(
        decoration: WidgetsConstructor().myBoxDecoration(Colors.grey, Colors.black, 2.0, 4.0),
      child: Column(
        children: [
          WidgetsConstructor().makeText('Placa:', Colors.black, 17.0, 5.0, 10.0, 'no'),
          WidgetsConstructor().makeText(moveClass.placa, Colors.black, 50.0, 0.0, 0.0, 'center')
        ],
      ),

    );

  }

  Widget _whatsappBtn(){

    return Container(
      child: GestureDetector(
        onTap: (){
          FlutterOpenWhatsapp.sendSingleMessage("55"+phone, "Olá, sou o seu cliente");
        },
        child: WidgetsConstructor().makeButton(Colors.green, Colors.white, 100.0, 60.0, 2.0, 5.0, "Falar com motorista", Colors.white, 18.0),
      )
    );
  }

  Widget _problemBtn(){

    return Container(
        child: GestureDetector(
          onTap: (){
            setState(() {
              _showProblemInformPage=true;
            });
          },
          child: WidgetsConstructor().makeButton(Colors.red, Colors.white, 100.0, 60.0, 2.0, 5.0, "Relatar problema", Colors.white, 18.0),
        )
    );
  }

  Widget _popUpInformingTruckerFinishedMove(){

    void _onSucess(){
      setState(() {
        _showMessageThatTruckerFinishedTheMove=false;
      });
    }

    return WidgetsConstructor().customPopUp1Btn('Atenção', 'O profissional acaba de indicar que a mudança acabou. Finalize também para registrar que está tudo ok e encerrar o procedimento. Caso a mudança não tenha finalizado, não encerre, relate como problema..', Colors.blue, widthPercent, heightPercent, () { _onSucess();});


  }

  Widget _popUpInformingTruckerIsCommingBack(){

    void _onSucess(){
      setState(() {
        _showMessageThatTruckerIsCommingBack=false;
      });
    }

    return WidgetsConstructor().customPopUp1Btn('Atenção', 'O profissional voltando para finalizar a mudança.', Colors.blue, widthPercent, heightPercent, () { _onSucess();});


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

 */
