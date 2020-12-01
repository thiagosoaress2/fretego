import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:group_radio_button/group_radio_button.dart';
import 'package:location/location.dart';
import 'package:scoped_model/scoped_model.dart';


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

  BitmapDescriptor pinLocationIcon; //somente para o icone customizado
  BitmapDescriptor userLocationIcon; //imagem para o icone do user

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

  /*
  @override
  Future<void> afterFirstLayout(BuildContext context) {
    // isto é exercutado após todo o layout ser renderizado

    _loadInitialData();
    _loadTruckerPhone();
    _loadFirst();
    _placeListenerToFinish();

  }

   */

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
      _placeListenerToFinish();
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

            title: Text('Acompanhe sua mudança'), centerTitle: true,
          ),

          body: Stack(
            children: [

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
                  child: _whatsappBtn())
              : Container(),

              _showProblemInformPage==false
              ? Positioned(
                top: heightPercent*0.4,
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
