import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fretego/models/home_page_model.dart';
import 'package:fretego/utils/date_utils.dart';
import 'package:fretego/utils/globals_strings.dart';

class TesteClass {

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> criarNovoTrucker(){
    var _random = new Random();
    final int _randomInt = _random.nextInt(100);

    print('criando user teste');
    CollectionReference users = FirebaseFirestore.instance.collection('truckers');

    return users
        .doc('teste'+_randomInt.toString())
        .set({
      'address': 'R. Arídio Martins, 50 - Fátima, Niterói - RJ, 24070-110, Brasil - Rio de Janeiro',
      'all_info_done': 4,
      'apelido' : 'motorista'+_randomInt.toString(),
      'aval' : 0,
      'banido' : false,
      'cnh' : 'smsomso',
      'email' : 'msm@smsm.com.br',
      'image' : 'https://lh3.googleusercontent.com/proxy/MSWNrKNBZU12VvIESVOjgSGesM8HZdvUGfdvlLZEpoSKGiqzyhv9X8VU3sKOl3x-8chdF9Q3znHAnwmGGCGaO5MA1kgogv4QFSrs66cNdm7UC1x-pQ',
      'listed': true,
      'name' : 'motorista'+_randomInt.toString(),
      'phone' : '(21)969455333',
      'placa' : 'kvp8h60',
      'rate' : 0,
      'vehicle' : 'kombiA',
      'vehicle_image' : 'https://lh3.googleusercontent.com/proxy/npIrxiJ1EOWBOP_6LZ_NygFO4sKLT1hPcL2_zMC68xI9PX1nN8-upRu97zgmnVoJIaRPx9JDagXm6Nk3jAz5Nz6siICPy011bayLpj_vM-qN_aHp6gtQjQyEMvxbO5tzEvmveyy_Mmo7TqpP',
      'latlong' : -66.00850499999999,


    })
        .then((value) {
      print('user added');
    })
        .catchError((error) => print("Failed to add user: $error"));

  }

  Future<void> criarNovaMudanca(String userId){

    //userId = moveIid
    String date = DateServices().giveMeTheDateToday();
    String time = DateServices().giveMeTheTimeNow();
    print(time);

    CollectionReference users = FirebaseFirestore.instance.collection('agendamentos_aguardando');

    return users
        .doc('teste3')
        .set({

      'ajudantes' : 1,
      'alert' : 'trucker',
      'alert_saw' : false,
      'carro' : 'pickupP',
      'endereco_destino' : 'Estr. Monan Grande, 31 - Badu, Niterói - RJ, 24320-040, Brasil - Rio de Janeiro',
      'endereco_origem' : 'Tv. Petronilha Miranda, 49 - Barreto, Niterói - RJ, 24110-657, Brasil - Rio de Janeiro',
      'escada' : false,
      'id_contratante' : 'teste2',
      'id_freteiro' : 'nao',
      'lances_escada' : 0,
      'moveId' : 'teste2',
      'nome_freteiro' : 'nao',
      'pago' : null,
      'placa' : 'nao',
      'ps' : null,
      'selectedDate': date,
      'selectedTime' : '18:00',
      'situacao' : 'aguardando',
      'situacao_backup' : 'nao',
      'latlong' : -65.9587629,
      'distancia' : 12.4994,
      'valor' : 250.000,


    })
        .then((value) {
      print('mudanca added');
    })
        .catchError((error) => print("Failed to add user: $error"));


  }


  String popupCodeTruckerRejeitouServico(){
    return GlobalsStrings.popupCodeTruckerDeny;
  }

  String popupCodeMudancaAcabou({HomePageModel homePageModel}){
    homePageModel.moveClass.nomeFreteiro = 'Nome do sujeito';
    return GlobalsStrings.popupCodeTruckerFinished;
  }

  String popupCodeDevolverDinheiroPorDesistenciaMotorista({HomePageModel homePageModel}){
    return GlobalsStrings.popupCodeTruckerquitedAfterPayment;
  }

  String popupCodeSolvingProblems(){
    return GlobalsStrings.popupCodeSolvingProblems;
  }

  String popupCodeAcceptedLittleNegative({HomePageModel homePageModel}){
    homePageModel.moveClass.nomeFreteiro = 'Nome do sujeito';
    return GlobalsStrings.popupCodeAccepptedLittleNegative;
  }



}