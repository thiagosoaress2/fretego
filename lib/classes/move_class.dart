import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/item_class.dart';
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
  String idPedido;


  static const double priceCarroca = 0.00;
  static const double pricePickupP = 20.0;
  static const double pricePickupG = 40.0;
  static const double priceKombiF = 70.0;
  static const double priceKombiA = 100.0;
  static const double priceCaminhaoPa = 110.0;
  static const double priceCaminhaoBP = 130.0;
  static const double priceCaminhaoBG = 150.0;


  //MoveClass({this.itemsSelectedCart, this.ps, this.enderecoOrigem, this.enderecoDestino, this.latEnderecoOrigem, this.longEnderecoOrigem, this.latEnderecoDestino, this.longEnderecoDestino});
  MoveClass({this.itemsSelectedCart, this.ps, this.enderecoOrigem, this.enderecoDestino, this.ajudantes, this.carro, this.latEnderecoOrigem, this.longEnderecoOrigem, this.latEnderecoDestino, this.longEnderecoDestino, this.preco, this.escada, this.lancesEscada, this.freteiroId, this.userId, this.dateSelected, this.timeSelected, this.nomeFreteiro, this.userImage, this.freteiroImage, this.situacao, this.idPedido});

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
    if(vehicle=="carroca"){
      price=priceCarroca;
    } else if(vehicle=="pickupP"){
      //price=100.0;
      price=pricePickupP;
    } else if(vehicle=="pickupG"){
      //price=120.0;
      price = pricePickupG;
    } else if(vehicle=="kombiF"){
      //price=150.0;
      price=priceKombiF;
    } else if(vehicle=="kombiA"){
      //price=180.0;
      price=priceKombiA;
    } else if(vehicle=="caminhaoPA"){
      //price=190.0;
      price= priceCaminhaoPa;
    } else if(vehicle=="caminhaoBP"){
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

  String formatSituationToHuman(String sit){
    String formatedSit="nao";

    if(sit == "aguardando_freteiro"){
      formatedSit = "Aguardando confirmação do profissional";
    }
    return formatedSit;
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