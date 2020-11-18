
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/date_utils.dart';
import 'package:fretego/utils/globals_strings.dart';
import 'package:fretego/utils/mp_globals.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:mercado_pago_mobile_checkout/mercado_pago_mobile_checkout.dart';
import 'package:scoped_model/scoped_model.dart';


//https://www.youtube.com/watch?v=AAROFgR5Pzo   parei em 1:15
//https://github.com/Gazer/px-flutter

bool isLoading=false;
bool showSucessScreen=false;

double heightPercent;
double widthPercent;

MoveClass _moveClass = MoveClass();

String email;
String _name;


final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

class MercadoPago2 extends StatefulWidget {
  @override
  _MercadoPago2State createState() => _MercadoPago2State();
}



class _MercadoPago2State extends State<MercadoPago2> {



  createOrder () async {

    var orderRef = FirebaseFirestore.instance.collection('orders').doc();
    await orderRef.set(
        {
          'name': _moveClass.moveId,
          'email': email,
          'price' : _moveClass.preco,
          'quantity' : 1,
          'name' : _name,
          'statement_descriptor' : GlobalsStrings.appName,
          'data_pgto' : DateUtils().giveMeTheDateToday(),
        }
    );

    orderRef.snapshots().listen((DocumentSnapshot event) async {

      print(event.data());

      if(event.data()['preference_id'] !=  null){

        //print('o code é'+event.data()['code']);
        print(event.id);

        var result = await MercadoPagoMobileCheckout.startCheckout(
          //MpGlobals.mpPublicKey,
            event.data()['code_global'],
            event.data()['preference_id']
        );

        setState(() {
          isLoading=false;
        });

        if(result.status == 'approved'){

          setState(() {
            showSucessScreen=true;
          });

          FirestoreServices().deleteCode(event.id);
           _sucessScreen();
          //print('aprovado');
          //print(result.paymentMethodId);
          //print(result.paymentTypeId);
          FirestoreServices().updateOrderafterPayment(event.id, result.paymentMethodId.toString(), result.paymentTypeId.toString());

        } else {

          FirestoreServices().deleteOrder(event.id);

          if(result.statusDetail == "cc_rejected_insufficient_amount"){
            //print('ocorreu um erro. Tente novamente');

            _displaySnackBar(context, 'Ops, o pagamento não foi efetuado. Motivo: Saldo insuficiente', 15);

          } else if(result.statusDetail == "cc_rejected_bad_filled_card_number"){
            //print('ocorreu um erro. Tente novamente');

            _displaySnackBar(context, 'Ops, o pagamento não foi efetuado. Motivo: Número do cartão inválido', 15);

          } else if(result.statusDetail == "cc_rejected_bad_filled_date"){
            //print('ocorreu um erro. Tente novamente');

            _displaySnackBar(context, 'Ops, o pagamento não foi efetuado. Motivo: Data de validade inválida', 15);

          } else if(result.statusDetail == "cc_rejected_bad_filled_security_code"){
            //print('ocorreu um erro. Tente novamente');

            _displaySnackBar(context, 'Ops, o pagamento não foi efetuado. Motivo: Código de segurança inválido', 15);

          } else {

            _displaySnackBar(context, 'Ops, o pagamento não foi efetuado. Motivo: Sua operadora recusou o pagamento. Tente outro cartão.', 15);

          }

        }



      }

    });

  }

  @override
  Widget build(BuildContext context) {

    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){

        _moveClass.moveId = 'moveIdCode';
        _moveClass.preco = 200.0;
        //email = userModel.Email;
        email = 'teste@emailteste.com';
        _name = userModel.FullName;


        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: Text("Mercado Pago"), centerTitle: true,),
          body: Center(
              child: Stack(
                children: [

                  showSucessScreen == false
                  ? Column(
                    children: <Widget>[
                      SizedBox(height: 40.0,),
                      RaisedButton(
                        onPressed: () async {

                          if(isLoading==false){
                            setState(() {
                              isLoading=true;
                            });
                            _displaySnackBar(context, 'aguarde, iniciando pagamento', 5);
                            createOrder();

                          } else {
                            //do nothing
                          }

                        },
                        child: Center(
                          child: Text("Pagar"),
                        ),
                      ),
                    ],
                  )
                  : Container(),

                  showSucessScreen==true
                  ? _sucessScreen()
                  : Container(),

                  isLoading == true
                      ? Center(
                    child: CircularProgressIndicator(),
                  ) : Container(),

                ],
              )
          ),
        );

      },
    );
  }



  Widget _sucessScreen(){

    return Container(
      width: widthPercent,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [

            WidgetsConstructor().makeText("Pagamento confirmado!", Colors.blue, 18.0, 20.0, 20.0, 'center'),

            GestureDetector(
              onTap: (){

                Navigator.of(context).pop();


              },
              child: WidgetsConstructor().makeButton(Colors.blue, Colors.white, widthPercent*0.75, 65.0, 2.0, 4.0, 'Finalizar', Colors.white, 18.0),
            )


          ],
        ),
      ),
    );
  }

  _displaySnackBar(BuildContext context, String msg, int duration) {

    final snackBar = SnackBar(
      content: Text(msg),
      duration: Duration(seconds: duration),
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/mp_globals.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:mercado_pago_mobile_checkout/mercado_pago_mobile_checkout.dart';


//https://www.youtube.com/watch?v=AAROFgR5Pzo   parei em 1:15
//https://github.com/Gazer/px-flutter

bool isLoading=false;

double heightPercent;
double widthPercent;

MoveClass _moveClass = MoveClass();

class MercadoPago2 extends StatefulWidget {
  @override
  _MercadoPago2State createState() => _MercadoPago2State();
}

createOrder () async {

  var orderRef = FirebaseFirestore.instance.collection('orders').doc();
  await orderRef.set(
      {
        'name': 'productname',
        'email': 'email',
        'price' : 10.0,
        'quantity' : 5,
        'binary_mode' : true,
      }
  );

  orderRef.snapshots().listen((DocumentSnapshot event) async {

    print(event.data());

      if(event.data()['preference_id'] !=  null){

        //print('o code é'+event.data()['code']);
        print(event.id);

        var result = await MercadoPagoMobileCheckout.startCheckout(
        //MpGlobals.mpPublicKey,
        event.data()['code_global'],
        event.data()['preference_id']
        );
        if(result.status == 'approved'){
          FirestoreServices().deleteCode(event.id);
          print('aprovado');
          print(result.paymentMethodId);
          print(result.paymentTypeId);
        } else {
          print('ocorreu um erro. Tente novamente');
        }
      }

  });

}

class _MercadoPago2State extends State<MercadoPago2> {

  @override
  Widget build(BuildContext context) {

    _moveClass.moveId = 'moveIdCode';

    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text("Mercado Pago"), centerTitle: true,),
      body: Center(
        child: Stack(
          children: [

            Column(
              children: <Widget>[
                SizedBox(height: 40.0,),
                RaisedButton(
                  onPressed: () async {

                    setState(() {
                      isLoading=true;
                    });
                    createOrder();

                  },
                  child: Center(
                    child: Text("Pagar"),
                  ),
                ),
              ],
            ),

            isLoading == true
            ? Center(
              child: CircularProgressIndicator(),
            ) : Container(),

          ],
        )
      ),
    );
  }
}

Widget _sucessScreen(){

  return Container(
    width: widthPercent,
    child: Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [

          WidgetsConstructor().makeText("Pagamento confirmado!", Colors.blue, 18.0, 20.0, 20.0, 'center'),


        ],
      ),
    ),
  );
}


 */