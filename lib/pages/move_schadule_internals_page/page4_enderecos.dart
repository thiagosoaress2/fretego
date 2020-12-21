import 'dart:async';

import 'package:fretego/classes/move_class.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/models/adress_add_model.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/services/distance_latlong_calculation.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:fretego/widgets/ContainerBorderedCustom.dart';
import 'package:fretego/widgets/fakeLine.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/responsive_text_custom_withmargin.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:geocoder/geocoder.dart';
import 'package:scoped_model/scoped_model.dart';

final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar,

const double precoCadaAjudante=50.0;
const double precoGasolina=5.30;
const double precoBaseFreteiro=80.0;

class Page4Enderecos extends StatefulWidget {

  @override
  _Page4EnderecosState createState() => _Page4EnderecosState();
}

class _Page4EnderecosState extends State<Page4Enderecos> {
  ScrollController _scrollController;
  double offset = 1.0;

  ListView list;

  double heightPercent;
  double widthPercent;

  TextEditingController _sourceAdress = TextEditingController();
  TextEditingController _destinyAdress = TextEditingController();
  TextEditingController _destinyAdressNumber = TextEditingController();
  TextEditingController _destinyAdressComplement = TextEditingController();
  TextEditingController _sourceAdressNumber = TextEditingController();
  TextEditingController _sourceAdressComplement = TextEditingController();

  double custoVeiculo=0.0;


  @override
  void initState() {
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {

    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;
    
    


    return ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget widget, MoveModel moveModel) {

        list = ListView(
          controller: _scrollController,
          children: [

            SizedBox(height: 25.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //search by address button
                GestureDetector(
                  child: moveModel.SearchCep == false ? WidgetsConstructor().makeButton(Colors.lightBlueAccent, Colors.white, widthPercent * 0.40, 50.0, 1.0, 3.0,
                      "Endereço",
                      Colors.white,
                      15.0)
                      : WidgetsConstructor().makeButton(
                      Colors.grey[10],
                      Colors.white,
                      widthPercent * 0.40,
                      50.0,
                      1.0,
                      3.0,
                      "Endereço",
                      Colors.white,
                      15.0),
                  onTap: () {
                    moveModel.updateSearchCep(false);
                  },
                ),
                //search by CEP button
                GestureDetector(
                  child: moveModel.SearchCep == true
                      ? WidgetsConstructor().makeButton(
                      Colors.lightBlueAccent,
                      Colors.white,
                      widthPercent * 0.40,
                      50.0,
                      1.0,
                      3.0,
                      "CEP",
                      Colors.white,
                      15.0)
                      : WidgetsConstructor().makeButton(
                      Colors.grey[10],
                      Colors.white,
                      widthPercent * 0.40,
                      50.0,
                      1.0,
                      3.0,
                      "CEP",
                      Colors.white,
                      15.0),
                  onTap: () {
                    moveModel.updateSearchCep(true);
                  },
                )

              ],
            ),
            SizedBox(height: 10.0,),
            moveModel.SearchCep == true ? WidgetsConstructor()
                .makeSimpleText(
                "Digíte o CEP somente com números",
                Colors.blue, 12.0) : Container(),
            SizedBox(height: 10.0,),
            //first searchbox of origem address
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceEvenly,
              children: [
                Container(
                  height: heightPercent * 0.08,
                  width: widthPercent * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(
                        Radius.circular(4.0)),),
                  child: TextField(controller: _sourceAdress,
                    //enabled: _permissionGranted==true ? true : false,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.home),
                        labelText: "Origem",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                        EdgeInsets.only(left: 5,
                            bottom: 5,
                            top: 5,
                            right: 5),
                        hintText: "De onde?"),

                  ),
                ), //search adress origem
                GestureDetector(
                  onTap: () {
                    //remove the focus to close the keyboard
                    FocusScopeNode currentFocus = FocusScope
                        .of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }

                    if (_sourceAdress.text.isNotEmpty) {
                      //if the user meant to search by CEP
                      if (moveModel.SearchCep == true &&
                          _sourceAdress.text.length == 8) {
                        if (isNumeric(_sourceAdress.text)) {
                          findAddress(_sourceAdress, "origem",
                              moveModel, context);
                        } else {
                          MyBottomSheet()
                              .settingModalBottomSheet(
                              context,
                              'Ops...',
                              'Cep em formato errado',
                              'O CEP deve conter apenas números e possuir 8 dígitos',
                              Icons.info,
                              heightPercent,
                              widthPercent,
                              0,
                              true);
                        }
                      } else {
                        //if the user meant to search by adress name
                        if (_sourceAdress.text.contains(
                            "0") ||
                            _sourceAdress.text.contains(
                                "1") ||
                            _sourceAdress.text.contains(
                                "2") ||
                            _sourceAdress.text.contains(
                                "3") ||
                            _sourceAdress.text.contains(
                                "4") ||
                            _sourceAdress.text.contains(
                                "5") ||
                            _sourceAdress.text.contains(
                                "6") ||
                            _sourceAdress.text.contains(
                                "7") ||
                            _sourceAdress.text.contains(
                                "8") ||
                            _sourceAdress.text.contains(
                                "9")) {
                          findAddress(_sourceAdress, "origem",
                              moveModel, context);
                        } else {
                          _displaySnackBar(context,
                              "Informe o número da residência");
                        }
                      }
                    }
                  },
                  child: Container(
                    child: Icon(
                      Icons.search, color: Colors.white,),
                    decoration: WidgetsConstructor()
                        .myBoxDecoration(
                        Colors.blue, Colors.blue, 1.0, 5.0),
                    width: widthPercent * 0.15,
                    height: heightPercent * 0.08,
                  ),
                ),
              ],
            ),
            //Row with the number and complement of the origemAdress if provided by CEP
            SizedBox(height: 10.0,),
            moveModel.SearchCep == true ? Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(
                        Radius.circular(4.0)),),
                  width: widthPercent * 0.20,
                  child: TextField(
                      controller: _sourceAdressNumber,
                      decoration: InputDecoration(
                        hintText: " Nº",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                        EdgeInsets.only(left: 5,
                            bottom: 5,
                            top: 5,
                            right: 5),),
                      keyboardType: TextInputType.number
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(
                        Radius.circular(4.0)),),
                  width: widthPercent * 0.50,
                  child: TextField(
                    controller: _sourceAdressComplement,
                    decoration: InputDecoration(
                      hintText: " Complemento",
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding:
                      EdgeInsets.only(left: 5,
                          bottom: 5,
                          top: 5,
                          right: 5),),

                  ),
                ),
                /*
                                  WidgetsConstructor().makeEditTextNumberOnly(_sourceAdressNumber, "Nº"),
                                  WidgetsConstructor().makeEditTextNumberOnly(_sourceAdressComplement, "Complemento"),

                                   */
              ],
            ) : Container(),
            //text informing user that address was found
            moveModel.OrigemAddress != "" ? WidgetsConstructor().makeText("Endereço localizado", Colors.blue, 15.0, 10.0, 5.0, "center") : Container(),
            //address found
            moveModel.OrigemAddress != "" || moveModel.OrigemAddress != null ? WidgetsConstructor().makeText(moveModel.OrigemAddress, Colors.black, 12.0, 5.0, 10.0, "center") : Container(),
            SizedBox(height: 20.0,),
            //second searchbox of destiny address
            moveModel.OrigemAddress != "" ? Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceEvenly,
              children: [
                Container(
                  height: heightPercent * 0.08,
                  width: widthPercent * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(
                        Radius.circular(4.0)),),
                  child: TextField(controller: _destinyAdress,
                    //enabled: _permissionGranted==true ? true : false,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.home),
                        labelText: "Destino",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                        EdgeInsets.only(left: 5,
                            bottom: 5,
                            top: 5,
                            right: 5),
                        hintText: "Para onde?"),

                  ),
                ), //search adress origem
                GestureDetector(
                  onTap: () {
                    //remove the focus to close the keyboard
                    FocusScopeNode currentFocus = FocusScope
                        .of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }

                    if (_destinyAdress.text.isNotEmpty) {
                      if (moveModel.SearchCep == true &&
                          _sourceAdress.text.length == 8) {
                        if (isNumeric(_destinyAdress.text)) {
                          findAddress(
                              _destinyAdress, "destiny",
                              moveModel, context);
                          //scroll down to end of screen
                          waitAmoment(1, moveModel);
                          //scrollToBottom();

                        } else {
                          _displaySnackBar(context,
                              "O CEP deve ter apenas números");
                        }
                      } else {
                        if (_destinyAdress.text.contains(
                            "0") ||
                            _destinyAdress.text.contains(
                                "1") ||
                            _destinyAdress.text.contains(
                                "2") ||
                            _destinyAdress.text.contains(
                                "3") ||
                            _destinyAdress.text.contains(
                                "4") ||
                            _destinyAdress.text.contains(
                                "5") ||
                            _destinyAdress.text.contains(
                                "6") ||
                            _destinyAdress.text.contains(
                                "7") ||
                            _destinyAdress.text.contains(
                                "8") ||
                            _destinyAdress.text.contains(
                                "9")) {
                          findAddress(
                              _destinyAdress, "destiny",
                              moveModel, context);
                          //scrollToBottom();
                          waitAmoment(1, moveModel);
                        } else {
                          _displaySnackBar(context,
                              "Informe o número da residência do destino");
                        }
                      }
                    }
                  },
                  child: Container(
                    child: Icon(
                      Icons.search, color: Colors.white,),
                    decoration: WidgetsConstructor()
                        .myBoxDecoration(
                        Colors.blue, Colors.blue, 1.0, 5.0),
                    width: widthPercent * 0.15,
                    height: heightPercent * 0.08,
                  ),
                ),
              ],
            ) : Container(),

            SizedBox(height: 10.0,),
            //second Row with the number and complementing textfields for destiny address
            moveModel.OrigemAddress != "" && moveModel.SearchCep == true ? Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(
                        Radius.circular(4.0)),),
                  width: widthPercent * 0.20,
                  child: TextField(
                      controller: _destinyAdressNumber,
                      decoration: InputDecoration(
                        hintText: " Nº",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                        EdgeInsets.only(left: 5,
                            bottom: 5,
                            top: 5,
                            right: 5),),
                      keyboardType: TextInputType.number
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(
                        Radius.circular(4.0)),),
                  width: widthPercent * 0.50,
                  child: TextField(
                    controller: _destinyAdressComplement,
                    decoration: InputDecoration(
                      hintText: " Complemento",
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding:
                      EdgeInsets.only(left: 5,
                          bottom: 5,
                          top: 5,
                          right: 5),),

                  ),
                ),
                /*
                                  WidgetsConstructor().makeEditTextNumberOnly(_sourceAdressNumber, "Nº"),
                                  WidgetsConstructor().makeEditTextNumberOnly(_sourceAdressComplement, "Complemento"),

                                   */
              ],
            ) : Container(),
            //text informing user that the address of destiny was found
            moveModel.DestinyAddress != "" ? WidgetsConstructor().makeText("Destino localizado", Colors.blue, 15.0, 10.0, 5.0, "center") : Container(),
            //address found
            moveModel.DestinyAddress != "" ? WidgetsConstructor().makeText(moveModel.DestinyAddress, Colors.black, 12.0, 5.0, 10.0, "center") : Container(),

            SizedBox(height: 20.0,),
            //botao calcular
            moveModel.SearchCep == false && moveModel.OrigemAddress != "" && moveModel.DestinyAddress != "" || moveModel.SearchCep == true && moveModel.OrigemAddress !="" && moveModel.DestinyAddress != "" && _sourceAdressNumber.text.isNotEmpty && _destinyAdressNumber.text.isNotEmpty
                ? GestureDetector(
              child: WidgetsConstructor().makeButton(Colors.blue, Colors.blue, widthPercent*0.8, 50.0, 0.0, 4.0, "Calcular", Colors.white, 20.0),
              onTap: () async {


                //o endereço é colocado logo para n precisa esperar o assyncrono
                await _makeAddressConfig(moveModel, context);
                waitAmoment(3, moveModel);
                scrollToBottom();

              },
            ) : Container(height: 60.0,),
            SizedBox(height: 30.0,),
            moveModel.ShowResume == true ?
            Container(
              width: widthPercent*0.85,
              decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  ResponsiveTextCustom('Resumo e orçamento', context, CustomColors.blue, 2, 10.0, 20.0, 'center'),
                  //linha: inicio da mudança
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ResponsiveTextCustomWithMargin('Início da mudança: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 10.0, 0.0, 'no'),
                      Container(
                        alignment: Alignment.bottomCenter,
                        width: widthPercent*0.60,
                        child: ResponsiveTextCustomWithMargin(moveModel.OrigemAddress, context, Colors.black, 1.5, 0.0, 10.0, 10.0, 0.0, 'no'),
                      ),

                    ],
                  ),

                  SizedBox(height: 10.0,),
                  const FakeLine(Colors.grey),
                  SizedBox(height: 10.0,),
                  //linha: destino mudança
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ResponsiveTextCustomWithMargin('Final da mudança: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 10.0, 0.0, 'no'),
                      Container(
                        alignment: Alignment.bottomCenter,
                        width: widthPercent*0.60,
                        child: ResponsiveTextCustomWithMargin(moveModel.DestinyAddress, context, Colors.black, 1.5, 0.0, 10.0, 10.0, 0.0, 'no'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0,),
                  const FakeLine(Colors.grey),
                  SizedBox(height: 10.0,),

                  //linha: Distância
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ResponsiveTextCustomWithMargin('Distância: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 10.0, 0.0, 'no'),
                      ResponsiveTextCustomWithMargin(moveModel.Distance.toStringAsFixed(2)+' Km', context, Colors.black, 1.5, 0.0, 10.0, 10.0, 0.0, 'no'),
                    ],
                  ),

                  FakeLine(Colors.grey),

                  ResponsiveTextCustom('Resumo e orçamento', context, CustomColors.blue, 1.8, 20.0, 20.0, 'center'),

                  //linha custo combustivel
                  Row(mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ResponsiveTextCustomWithMargin('Combustível: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 20.0, 0.0, 'no'),
                      ResponsiveTextCustomWithMargin(moveModel.GasCosts.toStringAsFixed(2), context, Colors.black, 1.8, 0.0, 10.0, 0.0, 20.0, 'no'),
                    ],
                  ),
                  //linha ajudantes
                  Row(mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ResponsiveTextCustomWithMargin('Ajudantes: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 20.0, 0.0, 'no'),
                      ResponsiveTextCustomWithMargin(moveModel.CustoAjudantes.toStringAsFixed(2), context, Colors.black, 1.5, 0.0, 10.0, 0.0, 20.0, 'no'),
                    ],
                  ),
                  //linha custo veiculo
                  Row(mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ResponsiveTextCustomWithMargin('Adicional de tipo de veículo: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 20.0, 0.0, 'no'),
                      ResponsiveTextCustomWithMargin(custoVeiculo.toStringAsFixed(2) , context, Colors.black, 1.5, 0.0, 10.0, 0.0, 20.0, 'no'),
                      
                    ],
                  ),
                  //linha custo do freteiro
                  Row(mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ResponsiveTextCustomWithMargin('Profissional: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 20.0, 0.0, 'no'),
                      ResponsiveTextCustomWithMargin(precoBaseFreteiro.toStringAsFixed(2) , context, Colors.black, 1.5, 0.0, 10.0, 0.0, 20.0, 'no'),

                    ],
                  ),
                  //custo móveis
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ResponsiveTextCustomWithMargin('Móveis: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 20.0, 0.0, 'no'),
                      ResponsiveTextCustomWithMargin(moveModel.TotalExtraProducts.toStringAsFixed(2) , context, Colors.black, 1.5, 0.0, 10.0, 00.0, 20.0, 'no'),

                    ],
                  ),

                  FakeLine(Colors.blue),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ResponsiveTextCustom('Total  ', context, CustomColors.blue, 3, 20.0, 20.0, 'center'),
                      ResponsiveTextCustom('R\$'+moveModel.PrecoMudanca.toStringAsFixed(2), context, Colors.black, 3, 20.0, 20.0, 'center'),

                    ],
                  ),

                ],
              ),
            ): SizedBox(),


          ],
        );


        return Scaffold(
          key: _scaffoldKey,
          body: Container(
            height: heightPercent,
            width: widthPercent,
            color: Colors.white,
            child: Stack(
              children: [

                Positioned(
                    top: heightPercent * 0.26,
                    left: 10.0,
                    right: 10.0,
                    bottom: 50.0,
                    child: list),

                moveModel.ShowResume==true ? Positioned(
                    bottom: 15.0,
                    right: 10.0,
                    child: FloatingActionButton(
                      onPressed: (){

                        moveModel.updateOrigemAddressVerified(moveModel.OrigemAddress);
                        moveModel.updateDestinyAddressVerified(moveModel.DestinyAddress);
                        //coloca na classe mudança para popular o bd no final com ela
                        moveModel.moveClass.enderecoOrigem = moveModel.OrigemAddress;
                        moveModel.moveClass.enderecoDestino = moveModel.DestinyAddress;
                        moveModel.changePageForward('trucker', 'End.', 'Profissional');

                      },
                      backgroundColor: CustomColors.yellow,
                      splashColor: Colors.yellow,
                      child: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 50.0,),
                    )
                ) : SizedBox(),

                moveModel.isLoading == true ? Center(
                  child: CircularProgressIndicator(),) : SizedBox(),

              ],
            ),
          ),
        );
      },
    );



  }

  bool isNumeric(String str) {

    RegExp _numeric = RegExp(r'^-?[0-9]+$');

    return _numeric.hasMatch(str);
  }

  void findAddress(TextEditingController controller, String opcao, MoveModel moveModel, BuildContext context) async {

    moveModel.setIsLoading(true);

    String addressInformed = controller.text;

    try{

      var addresses = await Geocoder.local.findAddressesFromQuery(addressInformed);
      var first = addresses.first;

      if(addresses.length==1){
        if(opcao=='origem'){
          moveModel.updateOrigemAddressVerified(first.addressLine + " - " + first.adminArea);
        } else {
          moveModel.updateDestinyAddressVerified(first.addressLine + " - " + first.adminArea);
        }

      } else {

        if(opcao=='origem'){
          moveModel.updateOrigemAddressVerified('');
        } else {
          moveModel.updateDestinyAddressVerified('');
        }

        MyBottomSheet().settingModalBottomSheet(context, 'Não encontramos', 'Estamos tendo multiplos resultados.', 'Experimente ser mais específico.', Icons.house_outlined, heightPercent, widthPercent, 0, true);

      }

    } catch (e){

      moveModel.updateOrigemAddressVerified('');
      _displaySnackBar(context, "Formato de endereço inválido");

    }

    moveModel.setIsLoading(false);

  }

  void waitAmoment(int seconds, MoveModel moveModel){

    moveModel.setIsLoading(true);
    Future.delayed(Duration(seconds: seconds)).then((_){

      moveModel.setIsLoading(false);

      scrollToBottom();



    });

  }

  Future<void> _makeAddressConfig (MoveModel moveModel, BuildContext context) async {

    moveModel.setIsLoading(true);

    moveModel.moveClass = await MoveClass().getTheCoordinates(moveModel.moveClass, moveModel.OrigemAddress, moveModel.DestinyAddress);

    moveModel.updateAdressIsAllOk();

    calculateThePrice(moveModel, context);

    waitAmoment(2, moveModel);

  }

  void calculateThePrice(MoveModel moveModel, BuildContext context) async {

    //carrega o preco das coisas do bd
    //loadDataFromDb();

    if(moveModel.moveClass.longEnderecoDestino == null || moveModel.moveClass.longEnderecoOrigem == null || moveModel.moveClass.latEnderecoDestino == null || moveModel.moveClass.latEnderecoOrigem == null){
      _displaySnackBar(context, "Ops, encontramos um erro nos endereços. Por favor refaça o processo de infomar os endereços");
      moveModel.updateOrigemAddressVerified('');
      moveModel.updateDestinyAddressVerified('');
      moveModel.moveClass.enderecoOrigem=null;
      moveModel.moveClass.enderecoDestino=null;
      _sourceAdress.text="";
      _destinyAdress.text="";
      _sourceAdressNumber.text="";
      _destinyAdressNumber.text="";
      _sourceAdressComplement.text="";
      _destinyAdressComplement.text="";

    } else if(moveModel.moveClass.enderecoDestino=="" || moveModel.moveClass.enderecoOrigem==""){
      _displaySnackBar(context, "Verifique os endereços informados");
    } else {

      //tudo ok. Vamos calcular as coisas
      double custoTotal=0.0;

      //distancia entre dois pontos
      moveModel.updateDistance(DistanceLatLongCalculation().calculateDistance(moveModel.moveClass.latEnderecoOrigem, moveModel.moveClass.longEnderecoOrigem, moveModel.moveClass.latEnderecoDestino, moveModel.moveClass.longEnderecoDestino));
      //distance = DistanceLatLongCalculation().calculateDistance(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem, moveClass.latEnderecoDestino, moveClass.longEnderecoDestino);

      //calculo dos custos com gasolina considerando 8km/L
      moveModel.updateGasCosts((moveModel.Distance/7)*precoGasolina);
      //finalGasCosts = (distance/7)*precoGasolina;
      if(moveModel.GasCosts<5.00){
        moveModel.updateGasCosts(5.00);
      }

      custoTotal=custoTotal+moveModel.GasCosts;

      //custo com ajudantes
      if(moveModel.moveClass.ajudantes==null){
        moveModel.moveClass.ajudantes=1;
      }
      moveModel.updateCustoAjudantes(moveModel.moveClass.ajudantes*precoCadaAjudante);
      custoTotal=custoTotal+moveModel.CustoAjudantes;

      //custo de cada caminhão adicionado
      custoTotal=custoTotal+precoBaseFreteiro+moveModel.moveClass.giveMeThePriceOfEachvehicle(moveModel.moveClass.carro);
      custoVeiculo = moveModel.moveClass.giveMeThePriceOfEachvehicle(moveModel.moveClass.carro); //esta variavel é usada depois para exibir o resumo

      print('o tamanho da lista em moveclass é');
      print(moveModel.moveClass.itemsSelectedCart.length);
      print('o tamanho da lista em moveModel');
      print(moveModel.itemsSelectedCart.length);

      //custo de cada móvel
      double totalExtraProducts = 0.0;
      moveModel.moveClass.itemsSelectedCart.forEach((element) {
        totalExtraProducts = totalExtraProducts+3.00;
      });
      moveModel.updateTotalExtraProducts(totalExtraProducts);
      custoTotal = custoTotal+totalExtraProducts;

      custoTotal = calculateTheCostsOfLadder(moveModel)+custoTotal;

      moveModel.updatePrecoMudanca(custoTotal);
      //moveClass.preco = custoTotal;

      moveModel.updateShowResume(true);

      Future.delayed(Duration(seconds: 5)).then((value) {
        scrollToBottom();
        moveModel.setIsLoading(false);
      });
      //scrollToBottom();




    }


  }

  double calculateTheCostsOfLadder(MoveModel moveModel){
    double value=0.00;
    if(moveModel.moveClass.escada==true){
      final int multiplicador = moveModel.moveClass.lancesEscada;
      value = multiplicador*20.0;
    }
    return value;
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


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {

    if(_scrollController.hasClients) {
      double bottomOffset = _scrollController.position.maxScrollExtent;
      setState(() {
        _scrollController.animateTo(
          bottomOffset,
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      });

    }


    /*
    if(_scrollController.hasClients){
      double bottomOffset = _scrollController.position.maxScrollExtent;
      print('tinha cliente');
      _scrollController.animateTo(
        bottomOffset,
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    }

     */


  }

}





/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/models/adress_add_model.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/services/distance_latlong_calculation.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:fretego/widgets/ContainerBorderedCustom.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/responsive_text_custom_withmargin.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:geocoder/geocoder.dart';
import 'package:scoped_model/scoped_model.dart';

final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar,

TextEditingController _sourceAdress = TextEditingController();
TextEditingController _destinyAdress = TextEditingController();
TextEditingController _destinyAdressNumber = TextEditingController();
TextEditingController _destinyAdressComplement = TextEditingController();
TextEditingController _sourceAdressNumber = TextEditingController();
TextEditingController _sourceAdressComplement = TextEditingController();

const double precoCadaAjudante=50.0;
const double precoGasolina=5.30;
const double precoBaseFreteiro=80.0;

class Page4Enderecos extends StatelessWidget {
  final double heightPercent;
  final double widthPercent;
  String uid;
  Page4Enderecos(this.heightPercent, this.widthPercent, this.uid);

  ScrollController _scrollController; //scroll screen to bottom
  double offset = 1.0;

  ListView list;

  @override
  Widget build(BuildContext context) {

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      offset = _scrollController.hasClients ? _scrollController.offset : 0.1;
    });

    return ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget widget, MoveModel moveModel) {

        list = ListView(
          controller: _scrollController,
          children: [

            SizedBox(height: 25.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //search by address button
                GestureDetector(
                  child: moveModel.SearchCep == false ? WidgetsConstructor().makeButton(Colors.lightBlueAccent, Colors.white, widthPercent * 0.40, 50.0, 1.0, 3.0,
                      "Endereço",
                      Colors.white,
                      15.0)
                      : WidgetsConstructor().makeButton(
                      Colors.grey[10],
                      Colors.white,
                      widthPercent * 0.40,
                      50.0,
                      1.0,
                      3.0,
                      "Endereço",
                      Colors.white,
                      15.0),
                  onTap: () {
                    moveModel.updateSearchCep(false);
                  },
                ),
                //search by CEP button
                GestureDetector(
                  child: moveModel.SearchCep == true
                      ? WidgetsConstructor().makeButton(
                      Colors.lightBlueAccent,
                      Colors.white,
                      widthPercent * 0.40,
                      50.0,
                      1.0,
                      3.0,
                      "CEP",
                      Colors.white,
                      15.0)
                      : WidgetsConstructor().makeButton(
                      Colors.grey[10],
                      Colors.white,
                      widthPercent * 0.40,
                      50.0,
                      1.0,
                      3.0,
                      "CEP",
                      Colors.white,
                      15.0),
                  onTap: () {
                    moveModel.updateSearchCep(true);
                  },
                )

              ],
            ),
            SizedBox(height: 10.0,),
            moveModel.SearchCep == true ? WidgetsConstructor()
                .makeSimpleText(
                "Digíte o CEP somente com números",
                Colors.blue, 12.0) : Container(),
            SizedBox(height: 10.0,),
            //first searchbox of origem address
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceEvenly,
              children: [
                Container(
                  height: heightPercent * 0.08,
                  width: widthPercent * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(
                        Radius.circular(4.0)),),
                  child: TextField(controller: _sourceAdress,
                    //enabled: _permissionGranted==true ? true : false,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.home),
                        labelText: "Origem",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                        EdgeInsets.only(left: 5,
                            bottom: 5,
                            top: 5,
                            right: 5),
                        hintText: "De onde?"),

                  ),
                ), //search adress origem
                GestureDetector(
                  onTap: () {
                    //remove the focus to close the keyboard
                    FocusScopeNode currentFocus = FocusScope
                        .of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }

                    if (_sourceAdress.text.isNotEmpty) {
                      //if the user meant to search by CEP
                      if (moveModel.SearchCep == true &&
                          _sourceAdress.text.length == 8) {
                        if (isNumeric(_sourceAdress.text)) {
                          findAddress(_sourceAdress, "origem",
                              moveModel, context);
                        } else {
                          MyBottomSheet()
                              .settingModalBottomSheet(
                              context,
                              'Ops...',
                              'Cep em formato errado',
                              'O CEP deve conter apenas números e possuir 8 dígitos',
                              Icons.info,
                              heightPercent,
                              widthPercent,
                              0,
                              true);
                        }
                      } else {
                        //if the user meant to search by adress name
                        if (_sourceAdress.text.contains(
                            "0") ||
                            _sourceAdress.text.contains(
                                "1") ||
                            _sourceAdress.text.contains(
                                "2") ||
                            _sourceAdress.text.contains(
                                "3") ||
                            _sourceAdress.text.contains(
                                "4") ||
                            _sourceAdress.text.contains(
                                "5") ||
                            _sourceAdress.text.contains(
                                "6") ||
                            _sourceAdress.text.contains(
                                "7") ||
                            _sourceAdress.text.contains(
                                "8") ||
                            _sourceAdress.text.contains(
                                "9")) {
                          findAddress(_sourceAdress, "origem",
                              moveModel, context);
                        } else {
                          _displaySnackBar(context,
                              "Informe o número da residência");
                        }
                      }
                    }
                  },
                  child: Container(
                    child: Icon(
                      Icons.search, color: Colors.white,),
                    decoration: WidgetsConstructor()
                        .myBoxDecoration(
                        Colors.blue, Colors.blue, 1.0, 5.0),
                    width: widthPercent * 0.15,
                    height: heightPercent * 0.08,
                  ),
                ),
              ],
            ),
            //Row with the number and complement of the origemAdress if provided by CEP
            SizedBox(height: 10.0,),
            moveModel.SearchCep == true ? Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(
                        Radius.circular(4.0)),),
                  width: widthPercent * 0.20,
                  child: TextField(
                      controller: _sourceAdressNumber,
                      decoration: InputDecoration(
                        hintText: " Nº",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                        EdgeInsets.only(left: 5,
                            bottom: 5,
                            top: 5,
                            right: 5),),
                      keyboardType: TextInputType.number
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(
                        Radius.circular(4.0)),),
                  width: widthPercent * 0.50,
                  child: TextField(
                    controller: _sourceAdressComplement,
                    decoration: InputDecoration(
                      hintText: " Complemento",
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding:
                      EdgeInsets.only(left: 5,
                          bottom: 5,
                          top: 5,
                          right: 5),),

                  ),
                ),
                /*
                                  WidgetsConstructor().makeEditTextNumberOnly(_sourceAdressNumber, "Nº"),
                                  WidgetsConstructor().makeEditTextNumberOnly(_sourceAdressComplement, "Complemento"),

                                   */
              ],
            ) : Container(),
            //text informing user that address was found
            moveModel.OrigemAddress != "" ? WidgetsConstructor().makeText("Endereço localizado", Colors.blue, 15.0, 10.0, 5.0, "center") : Container(),
            //address found
            moveModel.OrigemAddress != "" || moveModel.OrigemAddress != null ? WidgetsConstructor().makeText(moveModel.OrigemAddress, Colors.black, 12.0, 5.0, 10.0, "center") : Container(),
            SizedBox(height: 20.0,),
            //second searchbox of destiny address
            moveModel.OrigemAddress != "" ? Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceEvenly,
              children: [
                Container(
                  height: heightPercent * 0.08,
                  width: widthPercent * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(
                        Radius.circular(4.0)),),
                  child: TextField(controller: _destinyAdress,
                    //enabled: _permissionGranted==true ? true : false,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.home),
                        labelText: "Destino",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                        EdgeInsets.only(left: 5,
                            bottom: 5,
                            top: 5,
                            right: 5),
                        hintText: "Para onde?"),

                  ),
                ), //search adress origem
                GestureDetector(
                  onTap: () {
                    //remove the focus to close the keyboard
                    FocusScopeNode currentFocus = FocusScope
                        .of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }

                    if (_destinyAdress.text.isNotEmpty) {
                      if (moveModel.SearchCep == true &&
                          _sourceAdress.text.length == 8) {
                        if (isNumeric(_destinyAdress.text)) {
                          findAddress(
                              _destinyAdress, "destiny",
                              moveModel, context);
                          //scroll down to end of screen
                          //waitAmoment(2, moveModel);
                          scrollToBottom();

                        } else {
                          _displaySnackBar(context,
                              "O CEP deve ter apenas números");
                        }
                      } else {
                        if (_destinyAdress.text.contains(
                            "0") ||
                            _destinyAdress.text.contains(
                                "1") ||
                            _destinyAdress.text.contains(
                                "2") ||
                            _destinyAdress.text.contains(
                                "3") ||
                            _destinyAdress.text.contains(
                                "4") ||
                            _destinyAdress.text.contains(
                                "5") ||
                            _destinyAdress.text.contains(
                                "6") ||
                            _destinyAdress.text.contains(
                                "7") ||
                            _destinyAdress.text.contains(
                                "8") ||
                            _destinyAdress.text.contains(
                                "9")) {
                          findAddress(
                              _destinyAdress, "destiny",
                              moveModel, context);
                          //scrollToBottom();
                          waitAmoment(10, moveModel);
                        } else {
                          _displaySnackBar(context,
                              "Informe o número da residência do destino");
                        }
                      }
                    }
                  },
                  child: Container(
                    child: Icon(
                      Icons.search, color: Colors.white,),
                    decoration: WidgetsConstructor()
                        .myBoxDecoration(
                        Colors.blue, Colors.blue, 1.0, 5.0),
                    width: widthPercent * 0.15,
                    height: heightPercent * 0.08,
                  ),
                ),
              ],
            ) : Container(),

            SizedBox(height: 10.0,),
            //second Row with the number and complementing textfields for destiny address
            moveModel.OrigemAddress != "" && moveModel.SearchCep == true ? Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(
                        Radius.circular(4.0)),),
                  width: widthPercent * 0.20,
                  child: TextField(
                      controller: _destinyAdressNumber,
                      decoration: InputDecoration(
                        hintText: " Nº",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                        EdgeInsets.only(left: 5,
                            bottom: 5,
                            top: 5,
                            right: 5),),
                      keyboardType: TextInputType.number
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(
                        Radius.circular(4.0)),),
                  width: widthPercent * 0.50,
                  child: TextField(
                    controller: _destinyAdressComplement,
                    decoration: InputDecoration(
                      hintText: " Complemento",
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding:
                      EdgeInsets.only(left: 5,
                          bottom: 5,
                          top: 5,
                          right: 5),),

                  ),
                ),
                /*
                                  WidgetsConstructor().makeEditTextNumberOnly(_sourceAdressNumber, "Nº"),
                                  WidgetsConstructor().makeEditTextNumberOnly(_sourceAdressComplement, "Complemento"),

                                   */
              ],
            ) : Container(),
            //text informing user that the address of destiny was found
            moveModel.DestinyAddress != "" ? WidgetsConstructor().makeText("Destino localizado", Colors.blue, 15.0, 10.0, 5.0, "center") : Container(),
            //address found
            moveModel.DestinyAddress != "" ? WidgetsConstructor().makeText(moveModel.DestinyAddress, Colors.black, 12.0, 5.0, 10.0, "center") : Container(),

            SizedBox(height: 20.0,),
            moveModel.SearchCep == false && moveModel.OrigemAddress != "" && moveModel.DestinyAddress != "" || moveModel.SearchCep == true && moveModel.OrigemAddress !="" && moveModel.DestinyAddress != "" && _sourceAdressNumber.text.isNotEmpty && _destinyAdressNumber.text.isNotEmpty
                ? GestureDetector(
              child: WidgetsConstructor().makeButton(Colors.blue, Colors.blue, widthPercent*0.8, 50.0, 0.0, 4.0, "Incluir endereços", Colors.white, 20.0),
              onTap: () async {

                waitAmoment(3, moveModel);
                //o endereço é colocado logo para n precisa esperar o assyncrono
                await _makeAddressConfig(moveModel, context);
                scrollToBottom();

              },
            ) : Container(height: 60.0,),
            SizedBox(height: 30.0,),
            moveModel.ShowResume == true ?
            Container(
              height: heightPercent*0.50,
              width: widthPercent*0.85,
              decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  ResponsiveTextCustom('Resumo e orçamento', context, CustomColors.blue, 2, 10.0, 20.0, 'center'),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ResponsiveTextCustomWithMargin('Início da mudança: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 10.0, 0.0, 'no'),
                      ResponsiveTextCustomWithMargin(moveModel.OrigemAddress, context, Colors.black, 1.5, 0.0, 10.0, 10.0, 0.0, 'no'),
                    ],
                  )

                ],
              ),
            ): SizedBox(height: heightPercent*0.50,),


          ],
        );


        return Scaffold(
          key: _scaffoldKey,
          body: Container(
            height: heightPercent,
            width: widthPercent,
            color: Colors.white,
            child: Stack(
              children: [

                Positioned(
                    top: heightPercent * 0.26,
                    left: 10.0,
                    right: 10.0,
                    bottom: 50.0,
                    child: list),

                moveModel.isLoading == true ? Center(
                  child: CircularProgressIndicator(),) : SizedBox(),

              ],
            ),
          ),
        );
      },
    );



  }




  bool isNumeric(String str) {

    RegExp _numeric = RegExp(r'^-?[0-9]+$');

    return _numeric.hasMatch(str);
  }

  void findAddress(TextEditingController controller, String opcao, MoveModel moveModel, BuildContext context) async {

    moveModel.setIsLoading(true);

    String addressInformed = controller.text;

    try{

      var addresses = await Geocoder.local.findAddressesFromQuery(addressInformed);
      var first = addresses.first;

      if(addresses.length==1){
        if(opcao=='origem'){
          moveModel.updateOrigemAddressVerified(first.addressLine + " - " + first.adminArea);
        } else {
          moveModel.updateDestinyAddressVerified(first.addressLine + " - " + first.adminArea);
        }

      } else {

        if(opcao=='origem'){
          moveModel.updateOrigemAddressVerified('');
        } else {
          moveModel.updateDestinyAddressVerified('');
        }

        MyBottomSheet().settingModalBottomSheet(context, 'Não encontramos', 'Estamos tendo multiplos resultados.', 'Experimente ser mais específico.', Icons.house_outlined, heightPercent, widthPercent, 0, true);

      }

    } catch (e){

      moveModel.updateOrigemAddressVerified('');
      _displaySnackBar(context, "Formato de endereço inválido");

    }

    moveModel.setIsLoading(false);

  }

  void waitAmoment(int seconds, MoveModel moveModel){

    moveModel.setIsLoading(true);
    Future.delayed(Duration(seconds: seconds)).then((_){

      moveModel.setIsLoading(false);

      scrollToBottom();



    });

  }

  Future<void> _makeAddressConfig (MoveModel moveModel, BuildContext context) async {

    moveModel.setIsLoading(true);

    moveModel.moveClass = await MoveClass().getTheCoordinates(moveModel.moveClass, moveModel.OrigemAddress, moveModel.DestinyAddress);

    moveModel.updateAdressIsAllOk();

    calculateThePrice(moveModel, context);

    waitAmoment(3, moveModel);

  }

  void calculateThePrice(MoveModel moveModel, BuildContext context) async {

    //carrega o preco das coisas do bd
    //loadDataFromDb();

    if(moveModel.moveClass.longEnderecoDestino == null || moveModel.moveClass.longEnderecoOrigem == null || moveModel.moveClass.latEnderecoDestino == null || moveModel.moveClass.latEnderecoOrigem == null){
      _displaySnackBar(context, "Ops, encontramos um erro nos endereços. Por favor refaça o processo de infomar os endereços");
      moveModel.updateOrigemAddressVerified('');
      moveModel.updateDestinyAddressVerified('');
      moveModel.moveClass.enderecoOrigem=null;
      moveModel.moveClass.enderecoDestino=null;
      _sourceAdress.text="";
      _destinyAdress.text="";
      _sourceAdressNumber.text="";
      _destinyAdressNumber.text="";
      _sourceAdressComplement.text="";
      _destinyAdressComplement.text="";

    } else if(moveModel.moveClass.enderecoDestino=="" || moveModel.moveClass.enderecoOrigem==""){
      _displaySnackBar(context, "Verifique os endereços informados");
    } else {

      //tudo ok. Vamos calcular as coisas
      double custoTotal=0.0;

      //distancia entre dois pontos
      moveModel.updateDistance(DistanceLatLongCalculation().calculateDistance(moveModel.moveClass.latEnderecoOrigem, moveModel.moveClass.longEnderecoOrigem, moveModel.moveClass.latEnderecoDestino, moveModel.moveClass.longEnderecoDestino));
      //distance = DistanceLatLongCalculation().calculateDistance(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem, moveClass.latEnderecoDestino, moveClass.longEnderecoDestino);

      //calculo dos custos com gasolina considerando 8km/L
      moveModel.updateGasCosts((moveModel.Distance/7)*precoGasolina);
      //finalGasCosts = (distance/7)*precoGasolina;
      if(moveModel.GasCosts<5.00){
        moveModel.updateGasCosts(5.00);
      }

      custoTotal=custoTotal+moveModel.GasCosts;

      //custo com ajudantes
      if(moveModel.moveClass.ajudantes==null){
        moveModel.moveClass.ajudantes=1;
      }
      moveModel.updateCustoAjudantes(moveModel.moveClass.ajudantes*precoCadaAjudante);
      custoTotal=custoTotal+moveModel.CustoAjudantes;

      //custo de cada caminhão adicionado
      custoTotal=custoTotal+precoBaseFreteiro+moveModel.moveClass.giveMeThePriceOfEachvehicle(moveModel.moveClass.carro);

      print('o tamanho da lista em moveclass é');
      print(moveModel.moveClass.itemsSelectedCart.length);
      print('o tamanho da lista em moveModel');
      print(moveModel.itemsSelectedCart.length);

      //custo de cada móvel
      double totalExtraProducts = 0.0;
      moveModel.moveClass.itemsSelectedCart.forEach((element) {
        totalExtraProducts = totalExtraProducts+3.00;
      });
      moveModel.updateTotalExtraProducts(totalExtraProducts);
      custoTotal = custoTotal+totalExtraProducts;

      custoTotal = calculateTheCostsOfLadder(moveModel)+custoTotal;

      moveModel.updatePrecoMudanca(custoTotal);
      //moveClass.preco = custoTotal;

      moveModel.updateShowResume(true);

      Future.delayed(Duration(seconds: 5)).then((value) {
        scrollToBottom();
        moveModel.setIsLoading(false);
      });
      //scrollToBottom();




    }


  }

  double calculateTheCostsOfLadder(MoveModel moveModel){
    double value=0.00;
    if(moveModel.moveClass.escada==true){
      final int multiplicador = moveModel.moveClass.lancesEscada;
      value = multiplicador*20.0;
    }
    return value;
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

  void scrollToBottom() {


    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer.periodic(Duration(seconds: 4), (Timer timer) {

        if(_scrollController.hasClients) {
          double bottomOffset = _scrollController.position.maxScrollExtent;
          _scrollController.animateTo(
            bottomOffset,
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
          );
        } else {
          list.controller.positions.last;
          //_scrollController.
          //scrollToBottom();
        }

      });
    });


    /*
    if(_scrollController.hasClients){
      double bottomOffset = _scrollController.position.maxScrollExtent;
      print('tinha cliente');
      _scrollController.animateTo(
        bottomOffset,
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    }

     */


  }

}


 */