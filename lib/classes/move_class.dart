import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/item_class.dart';
import 'package:fretego/utils/date_utils.dart';
import 'package:geocoder/geocoder.dart';

class MoveClass {

  List<ItemClass> itemsSelectedCart =[];
  String ps;
  String enderecoOrigem;
  String enderecoDestino;
  double latEnderecoOrigem;
  double longEnderecoOrigem;
  double latEnderecoDestino;
  double longEnderecoDestino;
  int ajudantes;
  String carro;
  double preco;
  bool escada;
  int lancesEscada;
  String freteiroId;
  String userId;
  String nomeFreteiro;
  String userImage;
  String freteiroImage;
  String situacao;

  String dateSelected;
  String timeSelected;
  String moveId;

  String alert;
  bool alertSaw;

  String placa;


  static const double priceCarroca = 0.00;
  static const double pricePickupP = 20.0;
  static const double pricePickupG = 40.0;
  static const double priceKombiF = 70.0;
  static const double priceKombiA = 100.0;
  static const double priceCaminhaoPa = 110.0;
  static const double priceCaminhaoBP = 130.0;
  static const double priceCaminhaoBG = 150.0;


  //MoveClass({this.itemsSelectedCart, this.ps, this.enderecoOrigem, this.enderecoDestino, this.latEnderecoOrigem, this.longEnderecoOrigem, this.latEnderecoDestino, this.longEnderecoDestino});
  MoveClass({this.itemsSelectedCart, this.ps, this.enderecoOrigem, this.enderecoDestino, this.ajudantes, this.carro, this.latEnderecoOrigem, this.longEnderecoOrigem, this.latEnderecoDestino, this.longEnderecoDestino, this.preco, this.escada, this.lancesEscada, this.freteiroId, this.userId, this.dateSelected, this.timeSelected, this.nomeFreteiro, this.userImage, this.freteiroImage, this.situacao, this.moveId, this.alert, this.alertSaw, this.placa});

  MoveClass.empty();

  //pega as coordenadas e coloca os dados na classe
  Future<MoveClass> getTheCoordinates(@required MoveClass moveclass,@required String addressOrigem, @required String adressDestino) async {


    var addresses = await Geocoder.local.findAddressesFromQuery(addressOrigem);
    var adresses2 = await Geocoder.local.findAddressesFromQuery(adressDestino);

    var first = addresses.first;
    moveclass.latEnderecoOrigem = first.coordinates.latitude;
    moveclass.longEnderecoOrigem = first.coordinates.longitude;

    var first2 = adresses2.first;
    moveclass.latEnderecoDestino = first2.coordinates.latitude;
    moveclass.longEnderecoDestino = first2.coordinates.longitude;

    return moveclass;

  }

  double giveMeThePriceOfEachvehicle(String vehicle){
    double price = 0.0;

    //price vai receber o custo adicional. O custo base é dado pelo banco de dados (neste momento é 80). E cada valor aqui é acrescido neste valor base.
    if(vehicle=="carroca" || vehicle=='carroça'){
      price=priceCarroca;
    } else if(vehicle=="pickupP" || vehicle=='pickup pequena'){
      //price=100.0;
      price=pricePickupP;
    } else if(vehicle=="pickupG" || vehicle=='pickup grande'){
      //price=120.0;
      price = pricePickupG;
    } else if(vehicle=="kombiF" || vehicle=='kombi' || vehicle=='kombi fechada'){
      //price=150.0;
      price=priceKombiF;
    } else if(vehicle=="kombiA" || vehicle=='kombi aberta'){
      //price=180.0;
      price=priceKombiA;
    } else if(vehicle=="caminhaoPA" || vehicle=='caminhao aberto'){
      //price=190.0;
      price= priceCaminhaoPa;
    } else if(vehicle=="caminhaoBP" || vehicle=='caminhao baú pequeno'){
      //price=210.0;
      price=priceCaminhaoBP;
    } else {//if(vehicle=="caminhaoBG"){
      //price=230.0;
      price = priceCaminhaoBG;
    }

    return price;

  }

  String returnThePriceDiference(String carSelected, String truckComparison){

    double dif = 0.0;

    if (carSelected == "carroca") {
      dif = priceCarroca-giveMeThePriceOfEachvehicle(truckComparison);
    } else if (carSelected == "pickupP") {
      dif = pricePickupP-giveMeThePriceOfEachvehicle(truckComparison);
    } else if (carSelected == "pickupG") {
      dif = pricePickupG-giveMeThePriceOfEachvehicle(truckComparison);
    } else if (carSelected == "kombiF") {
      dif = priceKombiF-giveMeThePriceOfEachvehicle(truckComparison);
    } else if (carSelected == "kombiA") {
      dif = priceKombiA-giveMeThePriceOfEachvehicle(truckComparison);
    } else if (carSelected == "caminhaoPA") {
      dif = priceCaminhaoPa-giveMeThePriceOfEachvehicle(truckComparison);
    } else if (carSelected == "caminhaoBP") {
      dif = priceCaminhaoBP-giveMeThePriceOfEachvehicle(truckComparison);
    } else { //if(truck=="caminhaoBG"){
      dif = priceCaminhaoBG-giveMeThePriceOfEachvehicle(truckComparison);
    }

    if(dif>0){
      return "- R\$"+dif.toStringAsFixed(2)+" (mais barato)";
    } else  {
      return "+ R\$"+dif.toStringAsFixed(2)+" (mais caro)";
    }
    /*
    if(dif<0){
      return dif-dif*2;  //aqui ele converte o numero negativo para o equivalente positivo
    } else {
      return dif;
    }

     */

    //return dif;

  }

  String returnThePriceDiferenceWithNumberOnly(String carSelected, String truckComparison){

    double dif = 0.0;

    if (carSelected == "carroça") {
      dif = priceCarroca-giveMeThePriceOfEachvehicle(truckComparison);
    } else if (carSelected == "pickup pequena") {
      dif = pricePickupP-giveMeThePriceOfEachvehicle(truckComparison);
    } else if (carSelected == "pickup grande") {
      dif = pricePickupG-giveMeThePriceOfEachvehicle(truckComparison);
    } else if (carSelected == "kombi") {
      dif = priceKombiF-giveMeThePriceOfEachvehicle(truckComparison);
    } else if (carSelected == "kombi aberta") {
      dif = priceKombiA-giveMeThePriceOfEachvehicle(truckComparison);
    } else if (carSelected == "caminhao aberto") {
      dif = priceCaminhaoPa-giveMeThePriceOfEachvehicle(truckComparison);
    } else if (carSelected == "caminhao baú pequeno") {
      dif = priceCaminhaoBP-giveMeThePriceOfEachvehicle(truckComparison);
    } else { //if(truck=="caminhaoBG"){
      dif = priceCaminhaoBG-giveMeThePriceOfEachvehicle(truckComparison);
    }

    if(dif>0){
      //return "- R\$"+dif.toStringAsFixed(2);
      print('o valor negativo é em moveclass é '+"R\$"+(dif*-1).toStringAsFixed(2));
      return "R\$"+(dif*-1).toStringAsFixed(2);
    } else  {
      if(dif==0){
        return "R\$"+(dif*-1).toStringAsFixed(2);
      } else {
        return "+R\$"+(dif*-1).toStringAsFixed(2);
      }
      //return "+ R\$"+dif.toStringAsFixed(2);
      print('o valor positivo é em moveclass é '+"R\$"+(dif*-1).toStringAsFixed(2));
      return "R\$"+(dif*-1).toStringAsFixed(2);
    }
    /*
    if(dif<0){
      return dif-dif*2;  //aqui ele converte o numero negativo para o equivalente positivo
    } else {
      return dif;
    }

     */

    //return dif;

  }

  String formatSituationToHuman(String sit){
    String formatedSit="nao";

    if(sit == "aguardando_freteiro"){
      formatedSit = "Aguardando confirmação do profissional";
    } else if(sit == 'nao'){
      formatedSit = "Aguardando confirmação do profissional";
    } else if(sit == 'aguardando'){
      formatedSit = "Aguardando confirmação do profissional";
    }
    return formatedSit;
  }


  String returnSituation (String sit){

    String newStr;
    if(sit=='aguardando confirmação do profissional'){
      newStr = sit;
    } else if(sit=='aguardando'){
      newStr = 'aguardando confirmação do profissional';
    } else if(sit=='accepted'){
      newStr = "O profissional aceitou o serviço";
    } else if(sit=='sem motorista'){
      newStr = 'Sem motorista escolhido';
    } else if(sit=='deny'){
      newStr = 'O profissional rejeitou o serviço';
    } else if(sit=='pago'){
      newStr = "Está tudo certo. Apenas aguarde o profissional. Se preciso, entre em contato com ele no botão abaixo.";
    }

    return newStr?? 'ERRO';
  }

  String returnSituationWithNextAction(String sit){

    String newStr;
    if(sit=='aguardando confirmação do profissional'){
      newStr = sit;
    } else if(sit=='aguardando'){
      newStr = 'aguardando confirmação do profissional';
    } else if(sit=='accepted'){
      newStr = "O profissional aceitou o serviço. Você pode realizar o pagamento.";
    } else if(sit=='sem motorista'){
      newStr = 'Sem motorista definido. Vamos escolher?';
    } else if(sit=='deny'){
      newStr = 'O profissional rejeitou o serviço. Vamos escolher outro?';
    } else if(sit=='pago'){
      newStr = "Está tudo certo. Apenas aguarde o profissional no momento agendado. Se preciso, entre em contato com ele.";
    } else if(sit == 'aguardando'){
      sit = 'Aguardando resposta do profissional';
    }

    return newStr?? 'ERRO';

  }

  String returnResumeSituationToUser(String sit){
    sit = '';
    if(sit == 'accepted_little_negative'){
      sit = 'Hora de pagar a mudança.';
    } else if (sit == 'accepted_much_negative'){
      sit = 'Mudança cancelada por falta e pagamento';
    } else if (sit == 'accepted_timeToMove'){
      sit = 'Profissional aguardando pagamento para iniciar. Pague agora.';
    } else if (sit == 'pago_little_negative'){
      sit = 'Mudança agendada para agora';
    } else if (sit == 'pago_much_negative'){
      sit = 'Mudança agendada para agora';
    } else if (sit == 'pago_almost_time'){
      sit = 'Mudança inicia logo';
    } else if (sit == 'pago_timeToMove'){
      sit = 'Mudança agendada para agora';
    } else if (sit == 'sistem_canceled'){
      sit = 'Cancelada por falta de pagamento';
    } else if (sit == 'trucker_quited_after_payment'){
      sit = 'Profissional desistiu';
    } else if (sit == 'trucker_finished'){
      sit = 'Mudança finalizada pelo profissional';
    } else if(sit == 'aguardando'){
      sit = 'Aguardando resposta do profissional';
    }

    return sit;
  }

  DateTime formatMyDateToNotify(String originalDate, String time){

    DateTime moveDate = DateUtils().convertDateFromString(originalDate);
    moveDate = DateUtils().addMinutesAndHoursFromStringToAdate(moveDate, time);
    return moveDate;

  }


  //List functions
  MoveClass clearTheList(MoveClass moveClass){

    List<ItemClass> itemsSelectedCart2 =[];
    moveClass.itemsSelectedCart = itemsSelectedCart2;
    return moveClass;
  }

  MoveClass deleteOneItem(MoveClass moveClass, String itemName){

    int cont=0;
    while(cont<moveClass.itemsSelectedCart.length){
      //se for item com mesmo nome, remove um
      if(moveClass.itemsSelectedCart[cont].name==itemName){
       moveClass.itemsSelectedCart.removeAt(cont);
       cont=moveClass.itemsSelectedCart.length;  //cont pega valor máximo para parar a verificação
     } else {
       cont++;
     }
    }

    return moveClass;
  }

  MoveClass addOneItem(MoveClass moveClass, List<dynamic> myData, int index){

    print(myData[index]['name']);
    ItemClass itemClass = ItemClass(myData[index]['name'], myData[index]['weight'], myData[index]['singlePerson'], myData[index]['volume']);
    moveClass.itemsSelectedCart.add(itemClass);

    return moveClass;
  }

  /*  reference
  carSelected = "carroca";
carSelected = "pickupP";
carSelected = "pickupG";
carSelected = "kombiF";
carSelected = "kombiA";
carSelected = "caminhaoPA"; pequeno aberto
carSelected = "caminhaoBP"; bau pequeno
carSelected = "caminhaoBG"; bau grande


https://medium.com/flutter-community/a-deep-dive-into-datepicker-in-flutter-37e84f7d8d6c

   */

}