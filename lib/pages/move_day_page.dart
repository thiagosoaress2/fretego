import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:fretego/classes/avaliation_class.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/classes/trucker_movement_class.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/avalatiation_page.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:scoped_model/scoped_model.dart';


bool isFirstLoad=true;

class MoveDayPage extends StatefulWidget {
  MoveClass _moveClass = MoveClass();

  MoveDayPage(this._moveClass);

  @override
  _MoveDayPageState createState() => _MoveDayPageState();
}


final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

class _MoveDayPageState extends State<MoveDayPage> {


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

  BitmapDescriptor pinLocationIcon; //somente para o icone customizado
  BitmapDescriptor userLocationIcon; //imagem para o icone do user

  LatLng userLocationLatLng;

  Completer<GoogleMapController> _controller = Completer();

  bool _showAlertFinishMove=false;

  Location location = new Location();

  bool showWhatsappBtn=false;

  String phone;


  @override
  void initState() {

    //_getCurrentLocation();


    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/markerico.png').then((onValue) {
      pinLocationIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        //'images/carrinhobaby.jpg').then((value) {  //usar a imagem correta
        'images/markerico.png').then((value) {
      userLocationIcon = value;
    });

  }

  @override
  Widget build(BuildContext context) {

    moveClass = widget._moveClass;
    if(isFirstLoad==true){
      isFirstLoad=false;
      _loadInitialData();
      _loadTruckerPhone();
      _loadFirst();
    }

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

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(

            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              iconSize: 20.0,
              onPressed: () {
                _goBack(context);
              },
            ),

            title: Text('Mapa'), centerTitle: true,
          ),

          body: Stack(
            children: [

              Column(
                children: [

                  _googleMap(heightPercent*0.55),

                  _bottomBar(),

                ],
              ),

              showWhatsappBtn == true
              ? Positioned(
                  top: heightPercent*0.2,
                  right: 10.0,
                  child: _whatsappBtn())
              : Container(),

              _showAlertFinishMove==true
                  ? _confirmFinishMovePopup()
                  : Container(),

            ],
          ),

        );
      },
    );
  }



  Future<void> _loadFirst() async {

    await FirestoreServices().loadLastKnownTruckerPosition(moveClass.moveId, _truckerMovementClass, () {_onSucessLoadLastKnownPosition(); });

  }

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

  void _addMarkerTrucker(){

    markers.add(
      Marker(
        markerId: MarkerId('trucker'),
        position: userLocationLatLng,
        icon: userLocationIcon,
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
        icon: pinLocationIcon,
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
        icon: pinLocationIcon,
        infoWindow: InfoWindow(
            title: "Destino"),
      ),
    );

  }

  void _loadInitialData(){
    print('lat endereço origem'+moveClass.latEnderecoOrigem.toString());
    _initialcameraposition = LatLng(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem);
    _origemPos = LatLng(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem);
    _destinyPos = LatLng(moveClass.latEnderecoDestino, moveClass.longEnderecoDestino);
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
