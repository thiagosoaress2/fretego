
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/move_day_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/date_utils.dart';
import 'package:fretego/utils/globals_strings.dart';
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

String _email;
String _name;


final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

class PaymentPage extends StatefulWidget {
  MoveClass moveClass = MoveClass(); //tipo de data, poderia ser String. Aqui é uma classe

  PaymentPage(this.moveClass);  //receiver


  @override
  _PaymentPageState createState() => _PaymentPageState();
}



class _PaymentPageState extends State<PaymentPage> {


  createOrder (String uid) async {

    var orderRef = FirebaseFirestore.instance.collection('orders').doc();
    await orderRef.set(
        {
          'name': _moveClass.moveId,
          'email': _email,
          'price' : _moveClass.preco,
          'quantity' : 1,
          'name' : _name,
          'user' : uid,
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
            event.data()['preference_id'],
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


          await FirestoreServices().updatescheduldMoveAfterPayment(_moveClass.moveId);
          FirestoreServices().updateOrderafterPayment(event.id, result.paymentMethodId.toString(), result.paymentTypeId.toString(), _moveClass.freteiroId);

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

            _displaySnackBar(context, 'Ops, o pagamento não foi efetuado.', 15);

          }

        }



      }

    });

  }

  @override
  Widget build(BuildContext context) {

    _moveClass = widget.moveClass;

    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){

        //_moveClass.moveId = 'moveIdCode';
        //_moveClass.preco = 200.0;
        _email = userModel.Email;
        print(_email);
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

                      Padding(
                          padding: EdgeInsets.all(10.0),
                        child: Column(
                          children: [

                            WidgetsConstructor().makeText("Resumo da mudança", Colors.blue, 18.0, 25.0, 20.0, 'center'),
                            Row(
                              children: [
                                WidgetsConstructor().makeText('Origem: ', Colors.blue, 16.0, 0.0, 15.0, 'no'),
                                SizedBox(width: 5.0,),
                                WidgetsConstructor().makeText(_moveClass.enderecoOrigem, Colors.black, 16.0, 0.0, 15.0, 'no'),
                              ],
                            ),

                            Row(
                              children: [
                                WidgetsConstructor().makeText('Destino: ', Colors.blue, 16.0, 0.0, 15.0, 'no'),
                                SizedBox(width: 5.0,),
                                WidgetsConstructor().makeText(_moveClass.enderecoDestino, Colors.black, 16.0, 0.0, 15.0, 'no'),
                              ],
                            ),
                            SizedBox(height: 30.0,),
                            Row(
                              children: [
                                WidgetsConstructor().makeText('Total a ser pago: ', Colors.blue, 16.0, 15.0, 20.0, 'no'),
                                WidgetsConstructor().makeText('R\$'+_moveClass.preco.toStringAsFixed(2), Colors.black, 16.0, 15.0, 20.0, 'no'),

                              ],
                            )

                          ],
                        ),
                      ),


                      RaisedButton(
                        color: Colors.blue,
                        splashColor: Colors.blue[100],
                        onPressed: () async {
                          if(isLoading==false){
                            setState(() {
                              isLoading=true;
                            });
                            _displaySnackBar(context, 'aguarde, iniciando pagamento. Isto pode demorar um pouco.', 10);
                            createOrder(userModel.Uid);

                          } else {
                            //do nothing
                          }

                        },
                        child: Center(
                          child: Text("Efetuar pagamento",),
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

            WidgetsConstructor().makeText("Pagamento confirmado!", Colors.blue, 18.0, 20.0, 00.0, 'center'),
            WidgetsConstructor().makeText('O pagamento já foi efetuado. Você não precisa fazer mais nenhum tipo de pagamento ao profissional.', Colors.black, 16.0, 10.0, 20.0, 'no'),

            GestureDetector(
              onTap: () async {

                _displaySnackBar(context, "Carregando informações do freteiro", 5);
                setState(() {
                  isLoading=true;
                });

                _moveClass = await MoveClass().getTheCoordinates(_moveClass, _moveClass.enderecoOrigem, _moveClass.enderecoDestino).whenComplete((){

                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => MoveDayPage(_moveClass)));

                });


              },
              child: WidgetsConstructor().makeButton(Colors.blue, Colors.white, widthPercent*0.75, 65.0, 2.0, 4.0, 'Ir para a mudança', Colors.white, 18.0),
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
