import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fretego/utils/mp_globals.dart';
import 'package:mercado_pago_mobile_checkout/mercado_pago_mobile_checkout.dart';
import 'package:mercadopago_sdk/mercadopago_sdk.dart';


//outro para tentar
//https://www.youtube.com/watch?v=AAROFgR5Pzo


//use este link minuto 8:50
//https://www.youtube.com/watch?v=3BAnvS-alSA  >> voltei pra esse agora que entendo melhor

//https://pub.dev/packages/mercado_pago_mobile_checkout/install


//agora seguindo esse aqui
//https://www.youtube.com/watch?v=jumlRs29sEM
//28 min



/* utilizados na ultima tentativa
https://pub.dev/packages/mercadopago_sdk   <<<aqui cria a preference (venda)
https://pub.dev/packages/mercado_pago_mobile_checkout/example  <<<este é o sdk que exibe os cartões
https://github.com/mercadopago/px-android <<<pagina do projeto acima no github
https://www.youtube.com/watch?v=jumlRs29sEM  <<<video longo
https://www.youtube.com/watch?v=3BAnvS-alSA   <<<video curto

 */




class MercadoPago extends StatefulWidget {
  @override
  _MercadoPagoState createState() => _MercadoPagoState();
}

class _MercadoPagoState extends State<MercadoPago> {


  var mp = MP(MpGlobals.mpclientId, MpGlobals.mpClientSecret);
  var mp2 = MP.fromAccessToken(MpGlobals.mpAccessToken);

  Future<Map<String, dynamic>> index() async {
    var preference = {
    "items": [
    {
    "id" : 'id_fake_do_item',
    "title": "Test",
    "quantity": 1,
    "currency_id": "BRL",
    "unit_price": 10.4
    }
    ],

      "payer" : [
        {
          "name": "Joana",
          "surname": "Albuquerque",
          "email": "hazle.dach@gmail.com",
          "date_created": "2015-06-02T12:58:41.425-04:00",
          "phone": {
            "area_code": "",
            "number": "(966) 173-3677"
          }
        }
    ],

  };

    var result = await mp.createPreference(preference);

    return result;
  }


  Future<void> makePayment() async {

    PaymentResult result;
    index().then((value) async => {

      if(value!=null){

            result = await MercadoPagoMobileCheckout.startCheckout(
            MpGlobals.mpPublicKey,
            value['response']['id'],).whenComplete(() => print("resultado "+result.toString()))

      }



    });

    /*
    index2().then((result) => {
      print('resultado 2'+result.toString())
    });
    
     */

  }


  Future<Map<String, dynamic>> getPayer() async {
    var preference = {
      "payer": [

        {
          "name": "Joana",
          "surname": "Albuquerque",
          "email": "hazle.dach@gmail.com",
          "date_created": "2015-06-02T12:58:41.425-04:00",
          "phone": {
            "area_code": "",
            "number": "(966) 173-3677"
          },

          "identification": {
            "type": "DNI",
            "number": "123456789"
          },

          "address": {
            "street_name": "Alessandro Alameda",
            "street_number": 450,
            "zip_code": "7409"
          }
        },
      ]
    };

    var result = await mp2.updatePreference('1234', preference);

    return result;
  }


  @override
  void initState() {
    super.initState();

  }


  /*
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

   */




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mercado Pago"), centerTitle: true,),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              onPressed: () async {

                makePayment();
                //makePayment3();

                /*
                PaymentResult result =
                await MercadoPagoMobileCheckout.startCheckout(
                  MpGlobals.mpPublicKey,
                  MpGlobals.mpclientId,
                );
                print(result.toString());
                 */
              },
              child: Text("Pagar"),
            ),
          ],
        ),
      ),
    );
  }
}
