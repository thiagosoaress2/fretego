import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fretego/utils/mp_globals.dart';
import 'package:mercado_pago_mobile_checkout/mercado_pago_mobile_checkout.dart';
import 'package:mercadopago_sdk/mercadopago_sdk.dart';



//use este link minuto 8:50
//https://www.youtube.com/watch?v=3BAnvS-alSA

//https://pub.dev/packages/mercado_pago_mobile_checkout/install


//agora seguindo esse aqui
//https://www.youtube.com/watch?v=jumlRs29sEM
//28 min





class MercadoPago extends StatefulWidget {
  @override
  _MercadoPagoState createState() => _MercadoPagoState();
}

class _MercadoPagoState extends State<MercadoPago> {

  @override
  void initState() {
    super.initState();

  }


  var mp = MP('3634171158634259', 'nr0biUuWZAwy1JnZll2pQtcCzNpVFnuO');

  Future<Map<String, dynamic>> armarPreferencia() async {
    var preference = {
      "items": [
        {
          "title": "Dummy Item",
          "description": "Multicolor Item",
          "quantity": 1,
          "currency_id": "BRL",
          "unit_price": 10.0
        }
      ]
    };

    var result = await mp.createPreference(preference);

    return result;
  }

  Future<void> ExecuteMercadoPago() async {

      armarPreferencia().then((result) {
        if(result != null){
          var preferenciaID = result['response']['id'];
          print('preference Id '+preferenciaID);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mercado Pago"), centerTitle: true,),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              onPressed: () async {

                ExecuteMercadoPago();
              },
              child: Text("Pagar"),
            ),
          ],
        ),
      ),
    );
  }
}
