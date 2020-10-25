import 'package:flutter/cupertino.dart';

class TruckClass {

  String name;
  double height;
  double width;
  double length;


  TruckClass({@required this.name, @required this.height, @required this.width, @required this.length });

  TruckClass.init(@required this.name);

  TruckClass.empty();

  double getVolume(TruckClass truckClass){
    return truckClass.height*truckClass.width*truckClass.length;
  }

  //preenche com altura, largura e comprimento cmo informações pesquisadas
  TruckClass populateTruckClass(TruckClass truckClass){

    if(truckClass.name=="carroca"){
      truckClass.height = 0.58;
      truckClass.width = 1.45;
      truckClass.length = 1.62;
    } else if(truckClass.name=="pickupP"){
      truckClass.height = 0.55;
      truckClass.width = 1.35;
      truckClass.length = 1.65;
    } else if(truckClass.name=="pickupG"){
      truckClass.height = 0.80;
      truckClass.width = 2.10;
      truckClass.length = 1.80;
    } else if(truckClass.name=="kombiF"){
      truckClass.height = 1.30;
      truckClass.width = 1.50;
      truckClass.length = 2.40;
    } else if(truckClass.name=="kombiA"){
      truckClass.height = 0.80;
      truckClass.width = 1.80;
      truckClass.length = 2.70;
    } else if(truckClass.name=="caminhaoPA"){
      truckClass.height = 1.00;
      truckClass.width = 2.30;
      truckClass.length = 5.50;
    } else if(truckClass.name=="caminhaoBP"){
      truckClass.height = 4.40;
      truckClass.width = 2.30;
      truckClass.length = 5.50;
    } else {//if(truckClass.name=="caminhaoBG"){
      truckClass.height = 4.40;
      truckClass.width = 2.60;
      truckClass.length = 6.30;
    }

    return truckClass;

  }

  String discoverTheBestTruck(double volumeMudanca){

    String bestChoice;
    if(volumeMudanca<1.18){
      bestChoice = "pickup pequena";
    } else if(volumeMudanca<1.30){
      //bestChoice = "carroca";
      bestChoice = "carroça";
    } else if(volumeMudanca<2.98){
      //bestChoice = "pickupG";
      bestChoice = "pickup grande";
    } else if(volumeMudanca<3.82){
      //bestChoice = "kombiA";
      bestChoice = "kombi aberta";
    } else if(volumeMudanca<4.62){
      //bestChoice = "kombiF";
      bestChoice = "kombi fechada";
    } else if(volumeMudanca<11.50){
      //bestChoice = "caminhaoPA";
      bestChoice = "caminhao pequeno aberto";
    } else if(volumeMudanca<52.00){
      //bestChoice = "caminhaoBP";
      bestChoice = "caminhao baú pequeno";
    } else {
      //bestChoice = "caminhaoBG";
      bestChoice = "caminhao baú grande";
    }

    print(0.58*1.45*1.62);

    return bestChoice;

  }

  String formatCodeToHumanName(String truck) {
    String formatedStr = "";

    if(truck == "null"){
      formatedStr = "Nenhum";
    } else if (truck == "carroca") {
      formatedStr = "carroça";
    } else if (truck == "pickupP") {
      formatedStr = "pickup pequena";
    } else if (truck == "pickupG") {
      formatedStr = "pickup grande";
    } else if (truck == "kombiF") {
      formatedStr = "kombi fechada";
    } else if (truck == "kombiA") {
      formatedStr = "kombi aberta";
    } else if (truck == "caminhaoPA") {
      formatedStr = "caminhao pequeno aberto";
    } else if (truck == "caminhaoBP") {
      formatedStr = "caminhao baú pequeno";
    } else { //if(truck=="caminhaoBG"){
      formatedStr = "caminhao baú grande";
    }

    return formatedStr;
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

/*
volume

carroca - 1,36
pickupp - 1,22
pickupg - 3,02
kombif - 4,68
kombia - 3,88
caminhaopa - 12,65
caminhaobp - 55,66
caminhaobG - 72,07
 */

  /*
  caminhão bau grande
altura:4,40m
largura 2,60m
cumprimento: 6,3m

caminhai bau medio
altura 4,40m
largura 2,30
cumprimento 5,5 m * (verificar)

caminhao pequeno aberto
altura: 1,00
largura: 2,30
cump 5,5m*

pickup grande
altura 0,80m
largura 2,10
comp 1,80

pickup pequena
altura 0,55m
largura 1,35
comp 1,65


kombi fechada
altura: 1,30m
largura: 1,50m
comp: 2,40

kombi aberta
altura: 0,80m
largura: 1,80
comp: 2,70

http://www.autoguide.com.br/tamanho-cacamba/2/
   */

}