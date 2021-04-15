import 'dart:async';

import 'package:fretego/classes/move_class.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/models/adress_add_model.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/pages/home_page_internals/widget_loading_screen.dart';
import 'package:fretego/pages/move_schadule_internals_page/components/page4_searchbox.dart';
import 'package:fretego/services/distance_latlong_calculation.dart';
import 'package:fretego/utils/calculos_percentagem.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:fretego/widgets/ContainerBorderedCustom.dart';
import 'package:fretego/widgets/fakeLine.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/responsive_text_custom_withmargin.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:geocoder/geocoder.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
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

  double _custoVeiculo=0.0;

  double _taxaServico=0.0;

  //variaveis do help
  String _msg;
  double _spaceBefore;
  String _alignArrow;

  @override
  void initState() {
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget widget, MoveModel moveModel) {

        if(heightPercent==null){
          heightPercent = MediaQuery.of(context).size.height;
          widthPercent = MediaQuery.of(context).size.width;
          _helperMeth(moveModel);
        }

        if(moveModel.OrigemAddress!='' && _sourceAdress.text.isEmpty){
          //significa que o user está voltando. Vamos preencher o endereço que ele já informou
          _sourceAdress.text = moveModel.OrigemAddress;
          scrollToBottom();
        }
        if(moveModel.DestinyAddress!='' && _destinyAdress.text.isEmpty){
          //significa que o user está voltando. Vamos preencher o endereço que ele já informou
          _destinyAdress.text = moveModel.DestinyAddress;
          scrollToBottom();
        }

        //obs: Este ajuste abaixo é para funcioanr a página seguinte.
        moveModel.updateLoadInitialData(true); //ajusta a proxima página. Pois quando o user voltava aquie  depois avançava novamente não carregava as informações.

        return _buildBody(moveModel);
      },
    );

  }












  Widget _buildBody(MoveModel moveModel){

    //todos os elementos da lista
    list = ListView(
      controller: _scrollController,
      children: [

        SizedBox(height: 25.0,),
        //linha dos botoes endereço ou cep. aqui chama uma atualização no model
        //linha com fudno azul escuro escrito endereços

        SizedBox(height: 10.0,),

        //aviso que nao aparece mais pois n trabalhamos mais com cep
        if(moveModel.SearchCep == true) Container(
          alignment: Alignment.center,
          child: Text('Digite o CEP somente com números', style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(1.5), color: CustomColors.blue),),
        ),

        SizedBox(height: 10.0,),

        //first searchbox of origem address
        Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceEvenly,
          children: [

            /*
            Container(
              height: heightPercent * 0.08,
              width: widthPercent * 0.6,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.all(
                    Radius.circular(4.0)),),
              child: TextField(controller: _sourceAdress,
                //enabled: _permissionGranted==true ? true : false,
                keyboardType: moveModel.SearchCep == true ? TextInputType.number : TextInputType.streetAddress,
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
             */
            //primeiro searchbox
            Page4Searchbox(heightPercent: heightPercent, widthPercent: widthPercent, controller: _sourceAdress, tip: 'De onde?', label: 'Origem', moveModel: moveModel,),
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
                  if(moveModel.SearchCep == true){
                    //se for buscando cep entra aqui
                    if(_sourceAdress.text.length == 8){

                      if(isNumeric(_sourceAdress.text)){

                        moveModel.updateShowAddiotionalInfoToCEP(true);
                        //aqui é o método de busca que deve migrar pro botão da popuo
                        //findAddress(_sourceAdress, "origem", moveModel, context);
                      } else {
                        _displaySnackBar(context, 'Formato inválido para CEP');
                      }

                    } else {
                      _displaySnackBar(context, 'O CEP deve conter apenas números e possuir 8 dígitos.');
                    }

                  } else {

                    if(isNumeric(_sourceAdress.text)){
                      _displaySnackBar(context, 'Não aceitamos busca por CEP. Por favor digite o endereço');
                    } else {

                      //user está buscando por endereço
                      if (_sourceAdress.text.contains("0") || _sourceAdress.text.contains("1") ||
                          _sourceAdress.text.contains("2") ||
                          _sourceAdress.text.contains("3") ||
                          _sourceAdress.text.contains("4") ||
                          _sourceAdress.text.contains("5") ||
                          _sourceAdress.text.contains("6") ||
                          _sourceAdress.text.contains("7") ||
                          _sourceAdress.text.contains("8") ||
                          _sourceAdress.text.contains("9")) {
                        findAddress(_sourceAdress, "origem", moveModel, context);
                      } else {
                        _displaySnackBar(context,
                            "Informe o número da residência");
                      }


                    }

                  }

                } else {
                  _displaySnackBar(context, 'Informe um endereço ou CEP');
                }
              },
              child: Container(
                child: Icon(
                  Icons.search, color: Colors.white,),
                decoration: WidgetsConstructor()
                    .myBoxDecoration(
                    moveModel.OrigemAddress == "" ? CustomColors.yellow : Colors.black26, moveModel.OrigemAddress == "" ? CustomColors.yellow : Colors.black26, 1.0, 5.0),
                width: widthPercent * 0.15,
                height: heightPercent * 0.08,
              ),
            ),
          ],
        ),

        SizedBox(height: 10.0,),

        /*
            //Row with the number and complement of the origemAdress if provided by CEP
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
             */

        //text informing user that address was found
        if(moveModel.OrigemAddress != '') Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: widthPercent*0.07,),
            Container(alignment: Alignment.center, child: Text("Endereço de origem localizado", textAlign: TextAlign.start, style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(1.9), color: Colors.blue)),),
          ],
        ),

        //address found
        SizedBox(height: 10.0,),

        if(moveModel.OrigemAddress != "" || moveModel.OrigemAddress != null) Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: widthPercent*0.07,),
            Container(width: widthPercent*0.80,alignment: Alignment.center, child: Text(moveModel.OrigemAddress, textAlign: TextAlign.start, style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(1.7), color: Colors.black)),)
          ],
        ),

        SizedBox(height: heightPercent*0.05,),

        //second searchbox of destiny address
        if(moveModel.OrigemAddress != '') Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceEvenly,
          children: [

            Page4Searchbox(moveModel: moveModel, label: 'Destino', heightPercent: heightPercent, widthPercent: widthPercent, controller: _destinyAdress, tip: 'Para onde?',),
            GestureDetector(
              onTap: () {
                //remove the focus to close the keyboard
                FocusScopeNode currentFocus = FocusScope
                    .of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }

                if (_destinyAdress.text.isNotEmpty) {

                  if(moveModel.SearchCep == true){

                    if(_destinyAdress.text.length == 8){

                      if(isNumeric(_destinyAdress.text)){

                        //funcoes da busca do cep que serão implementadas no futuro
                      } else {
                        _displaySnackBar(context, 'Formato inválido para CEP');
                      }
                    } else{
                      _displaySnackBar(context, 'O CEP deve conter apenas números e possuir 8 dígitos.');
                    }
                  } else {

                    if (_destinyAdress.text.contains("0") || _destinyAdress.text.contains("1") ||_destinyAdress.text.contains("2") || _destinyAdress.text.contains("3") || _destinyAdress.text.contains("4") || _destinyAdress.text.contains("5") || _destinyAdress.text.contains("6") || _destinyAdress.text.contains("7") || _destinyAdress.text.contains("8") || _destinyAdress.text.contains("9")) {
                      findAddress(
                          _destinyAdress, "destiny",
                          moveModel, context);
                      //scrollToBottom();
                      waitAmoment(1, moveModel);
                    } else {
                      _displaySnackBar(context,
                          "Informe o número do destino");
                    }

                  }


                }
              },
              child: Container(
                child: Icon(
                  Icons.search, color: Colors.white,),
                decoration: WidgetsConstructor()
                    .myBoxDecoration(
                    moveModel.DestinyAddress == "" ? CustomColors.yellow : Colors.black26, moveModel.DestinyAddress == "" ? CustomColors.yellow : Colors.black26, 1.0, 5.0),
                width: widthPercent * 0.15,
                height: heightPercent * 0.08,
              ),
            ),
          ],
        ),

        SizedBox(height: 10.0,),
        //second Row with the number and complementing textfields for destiny address
        if(moveModel.OrigemAddress != "" && moveModel.SearchCep == true) Row(
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
        ),


        //text informing user that the address of destiny was found
        if(moveModel.DestinyAddress != "") Row(
          children: [
            SizedBox(width: widthPercent*0.07,),
            WidgetsConstructor().makeText("Destino localizado", Colors.blue, 15.0, 10.0, 5.0, "no"),
          ],
        ),

        //address found
        if(moveModel.DestinyAddress != "") Row(
          children: [
            SizedBox(width: widthPercent*0.07,),
            Container(
              width: widthPercent*0.8,
              child: WidgetsConstructor().makeText(moveModel.DestinyAddress, Colors.black, 12.0, 5.0, 10.0, "no"),
            )

          ],
        ),

        SizedBox(height: 20.0,),
        //mensagem
        //FakeLine(Colors.blue),
        moveModel.SearchCep == false && moveModel.OrigemAddress != "" && moveModel.DestinyAddress != "" || moveModel.SearchCep == true && moveModel.OrigemAddress !="" && moveModel.DestinyAddress != "" && _sourceAdressNumber.text.isNotEmpty && _destinyAdressNumber.text.isNotEmpty
            ? ResponsiveTextCustomWithMargin('Pronto! Já temos todas informações para calcular o orçamento.', context, CustomColors.blue, 2.5,
            25.0, 25.0, 15.0, 15.0, 'center') : SizedBox(),
        moveModel.SearchCep == false && moveModel.OrigemAddress != "" && moveModel.DestinyAddress != "" || moveModel.SearchCep == true && moveModel.OrigemAddress !="" && moveModel.DestinyAddress != "" && _sourceAdressNumber.text.isNotEmpty && _destinyAdressNumber.text.isNotEmpty
            ? Icon(Icons.keyboard_arrow_down_outlined, color: CustomColors.yellow, size: 50.0,) : SizedBox(),
        SizedBox(height: 15.0,),


        //botao calcular
        moveModel.SearchCep == false && moveModel.OrigemAddress != "" && moveModel.DestinyAddress != "" || moveModel.SearchCep == true && moveModel.OrigemAddress !="" && moveModel.DestinyAddress != "" && _sourceAdressNumber.text.isNotEmpty && _destinyAdressNumber.text.isNotEmpty
            ? Container(
          width: widthPercent*0.70,
          height: heightPercent*0.10,
          child: RaisedButton(
            child: Text(moveModel.ShowResume==false ? 'Calcular' : 'Calcular novamente',
                style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(moveModel.ShowResume==false ? 3.0 : 2.5), color: Colors.white)),
            color: moveModel.ShowResume==false ? CustomColors.yellow : CustomColors.blue,
            onPressed: () async {

              moveModel.updateItsCalculating(true);

              //o endereço é colocado logo para n precisar esperar o assyncrono
              await _makeAddressConfig(moveModel, context);
              waitAmoment(3, moveModel);
              scrollToBottom();

            },
          ),
        ) : Container(height: 60.0,),


        SizedBox(height: 30.0,),
        if(moveModel.ShowResume == true)  _newResume(moveModel),

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

            if(moveModel.showAdditionalInfoToCEP == true) Center(
              child: Padding(
                padding: EdgeInsets.only(top: heightPercent*0.2),
                child: complementAddresswindow(moveModel),
              ),
            ),

            if(moveModel.ShowResume==true) _nextButton(moveModel),

            if(moveModel.isLoading == true) const Center(
              child: CircularProgressIndicator(),),

            if(moveModel.HelpIsOnScreen == true) Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: _help(moveModel, _msg, _spaceBefore, _alignArrow)),

            if(moveModel.ItsCalculating==true) WidgetLoadingScreeen('Calculando', '           é rapidinho'),


          ],
        ),
      ),
    );

  }

  Widget _nextButton(MoveModel moveModel){

    return Positioned(
        bottom: 15.0,
        right: 10.0,
        child: FloatingActionButton(
          onPressed: (){

            moveModel.updateOrigemAddressVerified(moveModel.OrigemAddress);
            moveModel.updateDestinyAddressVerified(moveModel.DestinyAddress);
            //coloca na classe mudança para popular o bd no final com ela
            moveModel.moveClass.enderecoOrigem = moveModel.OrigemAddress;
            moveModel.moveClass.enderecoDestino = moveModel.DestinyAddress;
            //moveModel.changePageForward('trucker', 'Endereço', 'Profissional');
            //agora salta direto para data
            moveModel.changePageForward('data', 'profissional', 'Agendar');

          },
          backgroundColor: CustomColors.yellow,
          splashColor: Colors.yellow,
          child: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 50.0,),
        )
    );
  }

  Widget complementAddresswindow(MoveModel moveModel){

    String numberHere = 'Nº';
    String complementHere = 'Complemento';

    return Material(
      elevation: 20,
      child: Container(
        width: widthPercent*0.90,
        height: heightPercent*0.35,
        color: Colors.white,
        child: Column(
          children: [
            //botão de fechar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CloseButton(
                  onPressed: (){
                    moveModel.updateShowAddiotionalInfoToCEP(false);
                  },
                )
              ],
            ),
            SizedBox(height: heightPercent*0.015,),
            //titulo
            Container(
              child: Text('Complemento do endereço', style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2.2), color: CustomColors.blue)),
            ),
            SizedBox(height: heightPercent*0.05,),
            //textviews com numero e complemento do endereço
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //complemento do número
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
                //complemento do complemento
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
              ],
            ),
            SizedBox(height: heightPercent*0.025,),
            //botao de buscar
            Container(
              child:RaisedButton(
                onPressed: (){

                  //buscar endereco
                  if(_sourceAdressNumber.text.isEmpty){
                    _displaySnackBar(context, 'Informe o número da residência');
                  } else {
                    //aqui implementar a busca
                    moveModel.updateShowAddiotionalInfoToCEP(false); //fecha a popup
                    findAddress(_sourceAdress, "origem", moveModel, context);
                  }

                },
                color: CustomColors.blue,
                child: Text('Buscar endereço', style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2.5), color: Colors.white),),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _Resume(MoveModel moveModel){

    return Column(
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
            ResponsiveTextCustomWithMargin(_custoVeiculo.toStringAsFixed(2) , context, Colors.black, 1.5, 0.0, 10.0, 0.0, 20.0, 'no'),

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
        //custo nossa taxa
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ResponsiveTextCustomWithMargin('Taxa do serviço: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 20.0, 0.0, 'no'),
            ResponsiveTextCustomWithMargin(_taxaServico.toStringAsFixed(2) , context, Colors.black, 1.5, 0.0, 10.0, 00.0, 20.0, 'no'),

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
    );

  }

  Widget _newResume(MoveModel moveModel){

    return Container(
      margin: EdgeInsets.only(left: 15, top: 40, right: 15, bottom: 50),
      width: widthPercent,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10)
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [

          SizedBox(height: 10,),

          Container(
            child: Icon(Icons.wysiwyg, color: CustomColors.blue, size: widthPercent*0.10,),
          ),
          
          SizedBox(height: 20,),

          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', textAlign: TextAlign.start ,style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
                Text('R\$'+moveModel.PrecoMudanca.toStringAsFixed(2), textAlign: TextAlign.start ,style: TextStyle(color: CustomColors.blue, fontWeight: FontWeight.bold, fontSize: ResponsiveFlutter.of(context).fontSize(3.5)))
              ],
            ),
          ),

          //combustivel
          Padding(padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResponsiveTextCustomWithMargin('Combustível: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 20.0, 0.0, 'no'),
              ResponsiveTextCustomWithMargin('R\$'+moveModel.GasCosts.toStringAsFixed(2), context, Colors.black, 1.5, 0.0, 10.0, 0.0, 20.0, 'no'),
            ],
          ),
          ),

          //ajudantes
          Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ResponsiveTextCustomWithMargin('Ajudantes: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 20.0, 0.0, 'no'),
                ResponsiveTextCustomWithMargin('R\$'+moveModel.CustoAjudantes.toStringAsFixed(2), context, Colors.black, 1.5, 0.0, 10.0, 0.0, 20.0, 'no'),
              ],
            ),
          ),

          //custo veiculo
          Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ResponsiveTextCustomWithMargin('Custo de tipo de veículo: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 20.0, 0.0, 'no'),
                ResponsiveTextCustomWithMargin('R\$'+_custoVeiculo.toStringAsFixed(2) , context, Colors.black, 1.5, 0.0, 10.0, 0.0, 20.0, 'no'),
              ],
            ),
          ),

          //custo freteiro
          Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ResponsiveTextCustomWithMargin('Serviço do profissional: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 20.0, 0.0, 'no'),
                ResponsiveTextCustomWithMargin('R\$'+precoBaseFreteiro.toStringAsFixed(2) , context, Colors.black, 1.5, 0.0, 10.0, 0.0, 20.0, 'no'),
              ],
            ),
          ),

          //custo móveis
          Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ResponsiveTextCustomWithMargin('Móveis: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 20.0, 0.0, 'no'),
                ResponsiveTextCustomWithMargin('R\$'+moveModel.TotalExtraProducts.toStringAsFixed(2) , context, Colors.black, 1.5, 0.0, 10.0, 00.0, 20.0, 'no'),
              ],
            ),
          ),

          //taxa mudejá
          Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ResponsiveTextCustomWithMargin('Taxa de serviço: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 20.0, 0.0, 'no'),
                ResponsiveTextCustomWithMargin('R\$'+_taxaServico.toStringAsFixed(2) , context, Colors.black, 1.5, 0.0, 10.0, 00.0, 20.0, 'no'),
              ],
            ),
          ),

        ],
      ),
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

          if(moveModel.SearchCep==true){
            //precisa adicioanr número e complemento
            moveModel.updateOrigemAddressVerified(first.addressLine + _sourceAdressNumber.text + _sourceAdressComplement.text + " - " + first.adminArea);
          } else {
            moveModel.updateOrigemAddressVerified(first.addressLine + " - " + first.adminArea);
          }

        } else {
          moveModel.updateDestinyAddressVerified(first.addressLine + " - " + first.adminArea);
        }

      } else {

        if(opcao=='origem'){
          moveModel.updateOrigemAddressVerified('');
        } else {
          moveModel.updateDestinyAddressVerified('');
        }

        MyBottomSheet().settingModalBottomSheet(context, 'Não encontramos', 'Estamos tendo multiplos resultados.', 'Tente ser mais específico.', Icons.house_outlined, heightPercent, widthPercent, 0, true);

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

      if(seconds!=2){
        moveModel.setIsLoading(false);
      }


      scrollToBottom();


      if(seconds==3){
        //aqui é o último evento a acontecer quando começam os calculos. Terminando no caso
        moveModel.updateItsCalculating(false);
      }

    });

  }


  Future<void> _makeAddressConfig (MoveModel moveModel, BuildContext context) async {

    moveModel.setIsLoading(true);

    moveModel.moveClass = await MoveClass().getTheCoordinates(moveModel.moveClass, moveModel.OrigemAddress, moveModel.DestinyAddress);

    moveModel.updateAdressIsAllOk();

    calculateThePrice(moveModel, context);

    waitAmoment(2, moveModel);

    print('fim de makeAddressconfig');

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
      double _custoTotal=0.0;

      //distancia entre dois pontos
      moveModel.updateDistance(DistanceLatLongCalculation().calculateDistance(moveModel.moveClass.latEnderecoOrigem, moveModel.moveClass.longEnderecoOrigem, moveModel.moveClass.latEnderecoDestino, moveModel.moveClass.longEnderecoDestino));
      //distance = DistanceLatLongCalculation().calculateDistance(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem, moveClass.latEnderecoDestino, moveClass.longEnderecoDestino);

      //calculo dos custos com gasolina considerando 8km/L
      moveModel.updateGasCosts((moveModel.Distance/7)*precoGasolina);
      //finalGasCosts = (distance/7)*precoGasolina;
      if(moveModel.GasCosts<5.00){
        moveModel.updateGasCosts(5.00);
      }

      _custoTotal=_custoTotal+moveModel.GasCosts;

      //custo com ajudantes
      if(moveModel.moveClass.ajudantes==null){
        moveModel.moveClass.ajudantes=1;
      }
      moveModel.updateCustoAjudantes(moveModel.moveClass.ajudantes*precoCadaAjudante);
      _custoTotal=_custoTotal+moveModel.CustoAjudantes;

      //custo de cada caminhão adicionado
      _custoTotal=_custoTotal+precoBaseFreteiro+moveModel.moveClass.giveMeThePriceOfEachvehicle(moveModel.moveClass.carro);
      _custoVeiculo = moveModel.moveClass.giveMeThePriceOfEachvehicle(moveModel.moveClass.carro); //esta variavel é usada depois para exibir o resumo

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
      _custoTotal = _custoTotal+totalExtraProducts;

      _custoTotal = calculateTheCostsOfLadder(moveModel)+_custoTotal;

      //calcular a porcentagem e adicionar taxa. Para editar a taxa mudar a const dentro da classe
      _taxaServico = CalculosPercentagem().CalculePorcentagemDesteValor(CalculosPercentagem.taxaServico, _custoTotal);

      _custoTotal = _custoTotal+_taxaServico;

      moveModel.updatePrecoMudanca(_custoTotal);
      //moveClass.preco = custoTotal;

      //exibe o botão de avançar somente após a tela rolar até o fim exibindo o resumo dos custos
      /*
      Future.delayed(Duration(milliseconds: 4900)).then((_) {
        moveModel.updateShowResume(true);
      });

       */
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

  void _helperMeth(MoveModel moveModel){

    Future.delayed(Duration(seconds: 15)).then((_) {

      if(_sourceAdress.text.isEmpty){
        //user nao digitou nada.
        _msg = 'Informe aqui o endereço\nde partida da mudança';
        _spaceBefore = heightPercent*0.55;
        _alignArrow='center';
        FocusScope.of(context).unfocus();
        moveModel.updateHelpIsOnScreen(true);

        Future.delayed(Duration(seconds: 10)).then((_) {
          setState(() {
            moveModel.updateHelpIsOnScreen(false);
          });
        });

      } else if(_sourceAdress.text.isNotEmpty && moveModel.OrigemAddress==''){
        //user digitou mas não soube clicar na lupa.
        _msg = 'Clique na lupa\npara validar endereço';
        _spaceBefore = heightPercent*0.55;
        _alignArrow='right';
        FocusScope.of(context).unfocus();
        moveModel.updateHelpIsOnScreen(true);

        Future.delayed(Duration(seconds: 10)).then((_) {
          setState(() {
            moveModel.updateHelpIsOnScreen(false);
          });
        });
      }

    });
  }

  Widget _help(MoveModel moveModel, String mensagem, double spaceBefore, String align){
    return GestureDetector(
      onTap: (){
        moveModel.updateHelpIsOnScreen(false);
      },
      child: Container(
        height: heightPercent,
        width: widthPercent,
        color: Colors.black.withOpacity(0.6),
        child: Column(
          children: [
            //SizedBox(height: heightPercent*0.55,),
            SizedBox(height: spaceBefore,),
            Row(
              mainAxisAlignment: align=='left' ? MainAxisAlignment.start : align=='center' ? MainAxisAlignment.center : MainAxisAlignment.end,
              children: [
                align=='left' ? SizedBox(width: widthPercent*0.10,) : Container(),
                Icon(Icons.arrow_upward, color: CustomColors.yellow, size: 45,),
                align=='right' ? SizedBox(width: widthPercent*0.10,) : Container(),

              ],
            ),
            Text(mensagem, textAlign: TextAlign.center ,style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(3.0), color: CustomColors.yellow),),
          ],
        ),
      ),
    );
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





//backup antes de mudar o esquema dos motoristas
/*
import 'dart:async';

import 'package:fretego/classes/move_class.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/models/adress_add_model.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/pages/home_page_internals/widget_loading_screen.dart';
import 'package:fretego/pages/move_schadule_internals_page/components/page4_searchbox.dart';
import 'package:fretego/services/distance_latlong_calculation.dart';
import 'package:fretego/utils/calculos_percentagem.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:fretego/widgets/ContainerBorderedCustom.dart';
import 'package:fretego/widgets/fakeLine.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/responsive_text_custom_withmargin.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:geocoder/geocoder.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
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

  double _custoVeiculo=0.0;

  double _taxaServico=0.0;

  //variaveis do help
  String _msg;
  double _spaceBefore;
  String _alignArrow;

  @override
  void initState() {
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget widget, MoveModel moveModel) {

        if(heightPercent==null){
          heightPercent = MediaQuery.of(context).size.height;
          widthPercent = MediaQuery.of(context).size.width;
          _helperMeth(moveModel);
        }

        if(moveModel.OrigemAddress!='' && _sourceAdress.text.isEmpty){
          //significa que o user está voltando. Vamos preencher o endereço que ele já informou
          _sourceAdress.text = moveModel.OrigemAddress;
          scrollToBottom();
        }
        if(moveModel.DestinyAddress!='' && _destinyAdress.text.isEmpty){
          //significa que o user está voltando. Vamos preencher o endereço que ele já informou
          _destinyAdress.text = moveModel.DestinyAddress;
          scrollToBottom();
        }

        //obs: Este ajuste abaixo é para funcioanr a página seguinte.
        moveModel.updateLoadInitialData(true); //ajusta a proxima página. Pois quando o user voltava aquie  depois avançava novamente não carregava as informações.

        return _buildBody(moveModel);
      },
    );

  }












  Widget _buildBody(MoveModel moveModel){

    list = ListView(
      controller: _scrollController,
      children: [

        SizedBox(height: 25.0,),
        //linha dos botoes endereço ou cep. aqui chama uma atualização no model
        //linha com fudno azul escuro escrito endereços
        //banner escrito endereços
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //search by address button
            GestureDetector(
              child: moveModel.SearchCep == false ? WidgetsConstructor().makeButton(Colors.lightBlueAccent, Colors.white, widthPercent * 0.80, 50.0, 1.0, 3.0, "Endereço", Colors.white, 15.0)
                  : WidgetsConstructor().makeButton(Colors.grey[10], Colors.white, widthPercent * 0.40, 50.0, 1.0, 3.0, "Endereços", Colors.white, 15.0),
              onTap: () {
                moveModel.updateSearchCep(false);
              },
            ),
            //search by CEP button
            /*
                GestureDetector(
                  child: moveModel.SearchCep == true
                      ? WidgetsConstructor().makeButton(Colors.lightBlueAccent, Colors.white, widthPercent * 0.40, 50.0, 1.0, 3.0, "CEP", Colors.white, 15.0)
                      : WidgetsConstructor().makeButton(
                      Colors.grey[10], Colors.white, widthPercent * 0.40, 50.0, 1.0, 3.0, "CEP", Colors.white, 15.0),
                  onTap: () {
                    moveModel.updateSearchCep(true);
                  },
                )
                */
          ],
        ),

        SizedBox(height: 10.0,),

        //aviso que nao aparece mais pois n trabalhamos mais com cep
        if(moveModel.SearchCep == true) Container(
          alignment: Alignment.center,
          child: Text('Digite o CEP somente com números', style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(1.5), color: CustomColors.blue),),
        ),

        SizedBox(height: 10.0,),

        //first searchbox of origem address
        Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceEvenly,
          children: [

            /*
            Container(
              height: heightPercent * 0.08,
              width: widthPercent * 0.6,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.all(
                    Radius.circular(4.0)),),
              child: TextField(controller: _sourceAdress,
                //enabled: _permissionGranted==true ? true : false,
                keyboardType: moveModel.SearchCep == true ? TextInputType.number : TextInputType.streetAddress,
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
             */
            //primeiro searchbox
            Page4Searchbox(heightPercent: heightPercent, widthPercent: widthPercent, controller: _sourceAdress, tip: 'De onde?', label: 'Origem', moveModel: moveModel,),
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
                  if(moveModel.SearchCep == true){
                    //se for buscando cep entra aqui
                    if(_sourceAdress.text.length == 8){

                      if(isNumeric(_sourceAdress.text)){

                        moveModel.updateShowAddiotionalInfoToCEP(true);
                        //aqui é o método de busca que deve migrar pro botão da popuo
                        //findAddress(_sourceAdress, "origem", moveModel, context);
                      } else {
                        _displaySnackBar(context, 'Formato inválido para CEP');
                      }

                    } else {
                      _displaySnackBar(context, 'O CEP deve conter apenas números e possuir 8 dígitos.');
                    }

                  } else {

                    if(isNumeric(_sourceAdress.text)){
                      _displaySnackBar(context, 'Não aceitamos busca por CEP. Por favor digite o endereço');
                    } else {

                      //user está buscando por endereço
                      if (_sourceAdress.text.contains("0") || _sourceAdress.text.contains("1") ||
                          _sourceAdress.text.contains("2") ||
                          _sourceAdress.text.contains("3") ||
                          _sourceAdress.text.contains("4") ||
                          _sourceAdress.text.contains("5") ||
                          _sourceAdress.text.contains("6") ||
                          _sourceAdress.text.contains("7") ||
                          _sourceAdress.text.contains("8") ||
                          _sourceAdress.text.contains("9")) {
                        findAddress(_sourceAdress, "origem", moveModel, context);
                      } else {
                        _displaySnackBar(context,
                            "Informe o número da residência");
                      }


                    }

                  }

                } else {
                  _displaySnackBar(context, 'Informe um endereço ou CEP');
                }
              },
              child: Container(
                child: Icon(
                  Icons.search, color: Colors.white,),
                decoration: WidgetsConstructor()
                    .myBoxDecoration(
                    moveModel.OrigemAddress == "" ? CustomColors.yellow : Colors.black26, moveModel.OrigemAddress == "" ? CustomColors.yellow : Colors.black26, 1.0, 5.0),
                width: widthPercent * 0.15,
                height: heightPercent * 0.08,
              ),
            ),
          ],
        ),

        SizedBox(height: 10.0,),

        /*
            //Row with the number and complement of the origemAdress if provided by CEP
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
             */

        //text informing user that address was found
        if(moveModel.OrigemAddress != '') Container( width: widthPercent*0.80,alignment: Alignment.center, child: Text("Endereço de origem localizado", textAlign: TextAlign.center, style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(1.9), color: Colors.blue)),),

        //address found
        SizedBox(height: 10.0,),

        if(moveModel.OrigemAddress != "" || moveModel.OrigemAddress != null) Container( width: widthPercent*0.80,alignment: Alignment.center, child: Text(moveModel.OrigemAddress, textAlign: TextAlign.center, style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(1.7), color: Colors.black)),),

        SizedBox(height: 20.0,),

        //second searchbox of destiny address
        if(moveModel.OrigemAddress != '') Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceEvenly,
          children: [

            Page4Searchbox(moveModel: moveModel, label: 'Destino', heightPercent: heightPercent, widthPercent: widthPercent, controller: _destinyAdress, tip: 'Para onde?',),
            GestureDetector(
              onTap: () {
                //remove the focus to close the keyboard
                FocusScopeNode currentFocus = FocusScope
                    .of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }

                if (_destinyAdress.text.isNotEmpty) {

                  if(moveModel.SearchCep == true){

                    if(_destinyAdress.text.length == 8){

                      if(isNumeric(_destinyAdress.text)){

                        //funcoes da busca do cep que serão implementadas no futuro
                      } else {
                        _displaySnackBar(context, 'Formato inválido para CEP');
                      }
                    } else{
                      _displaySnackBar(context, 'O CEP deve conter apenas números e possuir 8 dígitos.');
                    }
                  } else {

                    if (_destinyAdress.text.contains("0") || _destinyAdress.text.contains("1") ||_destinyAdress.text.contains("2") || _destinyAdress.text.contains("3") || _destinyAdress.text.contains("4") || _destinyAdress.text.contains("5") || _destinyAdress.text.contains("6") || _destinyAdress.text.contains("7") || _destinyAdress.text.contains("8") || _destinyAdress.text.contains("9")) {
                      findAddress(
                          _destinyAdress, "destiny",
                          moveModel, context);
                      //scrollToBottom();
                      waitAmoment(1, moveModel);
                    } else {
                      _displaySnackBar(context,
                          "Informe o número do destino");
                    }

                  }


                }
              },
              child: Container(
                child: Icon(
                  Icons.search, color: Colors.white,),
                decoration: WidgetsConstructor()
                    .myBoxDecoration(
                    moveModel.DestinyAddress == "" ? CustomColors.yellow : Colors.black26, moveModel.DestinyAddress == "" ? CustomColors.yellow : Colors.black26, 1.0, 5.0),
                width: widthPercent * 0.15,
                height: heightPercent * 0.08,
              ),
            ),
          ],
        ),

        SizedBox(height: 10.0,),
        //second Row with the number and complementing textfields for destiny address
        if(moveModel.OrigemAddress != "" && moveModel.SearchCep == true) Row(
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
        ),

        //text informing user that the address of destiny was found
        if(moveModel.DestinyAddress != "") WidgetsConstructor().makeText("Destino localizado", Colors.blue, 15.0, 10.0, 5.0, "center"),

        //address found
        if(moveModel.DestinyAddress != "") WidgetsConstructor().makeText(moveModel.DestinyAddress, Colors.black, 12.0, 5.0, 10.0, "center"),

        SizedBox(height: 20.0,),
        //mensagem
        //FakeLine(Colors.blue),
        moveModel.SearchCep == false && moveModel.OrigemAddress != "" && moveModel.DestinyAddress != "" || moveModel.SearchCep == true && moveModel.OrigemAddress !="" && moveModel.DestinyAddress != "" && _sourceAdressNumber.text.isNotEmpty && _destinyAdressNumber.text.isNotEmpty
            ? ResponsiveTextCustomWithMargin('Pronto! Já temos todas informações para calcular o orçamento.', context, CustomColors.blue, 2.5,
            25.0, 25.0, 15.0, 15.0, 'center') : SizedBox(),
        moveModel.SearchCep == false && moveModel.OrigemAddress != "" && moveModel.DestinyAddress != "" || moveModel.SearchCep == true && moveModel.OrigemAddress !="" && moveModel.DestinyAddress != "" && _sourceAdressNumber.text.isNotEmpty && _destinyAdressNumber.text.isNotEmpty
            ? Icon(Icons.keyboard_arrow_down_outlined, color: CustomColors.yellow, size: 50.0,) : SizedBox(),
        SizedBox(height: 15.0,),


        //botao calcular
        moveModel.SearchCep == false && moveModel.OrigemAddress != "" && moveModel.DestinyAddress != "" || moveModel.SearchCep == true && moveModel.OrigemAddress !="" && moveModel.DestinyAddress != "" && _sourceAdressNumber.text.isNotEmpty && _destinyAdressNumber.text.isNotEmpty
            ? Container(
          width: widthPercent*0.70,
          height: heightPercent*0.10,
          child: RaisedButton(
            child: Text(moveModel.ShowResume==false ? 'Calcular' : 'Calcular novamente',
                style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(moveModel.ShowResume==false ? 3.0 : 2.5), color: Colors.white)),
            color: moveModel.ShowResume==false ? CustomColors.yellow : CustomColors.blue,
            onPressed: () async {

              moveModel.updateItsCalculating(true);

              //o endereço é colocado logo para n precisar esperar o assyncrono
              await _makeAddressConfig(moveModel, context);
              waitAmoment(3, moveModel);
              scrollToBottom();

            },
          ),
        ) : Container(height: 60.0,),


        SizedBox(height: 30.0,),
        moveModel.ShowResume == true ?
        Container(
          width: widthPercent*0.85,
          decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 2.0),
          child: _Resume(moveModel),
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

            if(moveModel.showAdditionalInfoToCEP == true) Center(
              child: Padding(
                padding: EdgeInsets.only(top: heightPercent*0.2),
                child: complementAddresswindow(moveModel),
              ),
            ),

            if(moveModel.ShowResume==true) Positioned(
                bottom: 15.0,
                right: 10.0,
                child: FloatingActionButton(
                  onPressed: (){

                    moveModel.updateOrigemAddressVerified(moveModel.OrigemAddress);
                    moveModel.updateDestinyAddressVerified(moveModel.DestinyAddress);
                    //coloca na classe mudança para popular o bd no final com ela
                    moveModel.moveClass.enderecoOrigem = moveModel.OrigemAddress;
                    moveModel.moveClass.enderecoDestino = moveModel.DestinyAddress;
                    moveModel.changePageForward('trucker', 'Endereço', 'Profissional');

                  },
                  backgroundColor: CustomColors.yellow,
                  splashColor: Colors.yellow,
                  child: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 50.0,),
                )
            ),

            if(moveModel.isLoading == true) const Center(
              child: CircularProgressIndicator(),),

            if(moveModel.HelpIsOnScreen == true) Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: _help(moveModel, _msg, _spaceBefore, _alignArrow)),

            if(moveModel.ItsCalculating==true) WidgetLoadingScreeen('Calculando', '           é rapidinho'),


          ],
        ),
      ),
    );

  }

  Widget complementAddresswindow(MoveModel moveModel){

    String numberHere = 'Nº';
    String complementHere = 'Complemento';

    return Material(
        elevation: 20,
      child: Container(
        width: widthPercent*0.90,
        height: heightPercent*0.35,
        color: Colors.white,
        child: Column(
          children: [
            //botão de fechar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CloseButton(
                  onPressed: (){
                    moveModel.updateShowAddiotionalInfoToCEP(false);
                  },
                )
              ],
            ),
            SizedBox(height: heightPercent*0.015,),
            //titulo
            Container(
              child: Text('Complemento do endereço', style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2.2), color: CustomColors.blue)),
            ),
            SizedBox(height: heightPercent*0.05,),
            //textviews com numero e complemento do endereço
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //complemento do número
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
                //complemento do complemento
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
              ],
            ),
            SizedBox(height: heightPercent*0.025,),
            //botao de buscar
            Container(
              child:RaisedButton(
                onPressed: (){

                  //buscar endereco
                  if(_sourceAdressNumber.text.isEmpty){
                    _displaySnackBar(context, 'Informe o número da residência');
                  } else {
                    //aqui implementar a busca
                    moveModel.updateShowAddiotionalInfoToCEP(false); //fecha a popup
                    findAddress(_sourceAdress, "origem", moveModel, context);
                  }

                },
                color: CustomColors.blue,
                child: Text('Buscar endereço', style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2.5), color: Colors.white),),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _Resume(MoveModel moveModel){

    return Column(
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
            ResponsiveTextCustomWithMargin(_custoVeiculo.toStringAsFixed(2) , context, Colors.black, 1.5, 0.0, 10.0, 0.0, 20.0, 'no'),

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
        //custo nossa taxa
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ResponsiveTextCustomWithMargin('Taxa do serviço: ', context, CustomColors.blue, 1.5, 0.0, 10.0, 20.0, 0.0, 'no'),
            ResponsiveTextCustomWithMargin(_taxaServico.toStringAsFixed(2) , context, Colors.black, 1.5, 0.0, 10.0, 00.0, 20.0, 'no'),

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

          if(moveModel.SearchCep==true){
            //precisa adicioanr número e complemento
            moveModel.updateOrigemAddressVerified(first.addressLine + _sourceAdressNumber.text + _sourceAdressComplement.text + " - " + first.adminArea);
          } else {
            moveModel.updateOrigemAddressVerified(first.addressLine + " - " + first.adminArea);
          }

        } else {
          moveModel.updateDestinyAddressVerified(first.addressLine + " - " + first.adminArea);
        }

      } else {

        if(opcao=='origem'){
          moveModel.updateOrigemAddressVerified('');
        } else {
          moveModel.updateDestinyAddressVerified('');
        }

        MyBottomSheet().settingModalBottomSheet(context, 'Não encontramos', 'Estamos tendo multiplos resultados.', 'Tente ser mais específico.', Icons.house_outlined, heightPercent, widthPercent, 0, true);

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

      if(seconds!=2){
        moveModel.setIsLoading(false);
      }


      scrollToBottom();


      if(seconds==3){
        //aqui é o último evento a acontecer quando começam os calculos. Terminando no caso
        moveModel.updateItsCalculating(false);
      }

    });

  }


  Future<void> _makeAddressConfig (MoveModel moveModel, BuildContext context) async {

    moveModel.setIsLoading(true);

    moveModel.moveClass = await MoveClass().getTheCoordinates(moveModel.moveClass, moveModel.OrigemAddress, moveModel.DestinyAddress);

    moveModel.updateAdressIsAllOk();

    calculateThePrice(moveModel, context);

    waitAmoment(2, moveModel);

    print('fim de makeAddressconfig');

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
      double _custoTotal=0.0;

      //distancia entre dois pontos
      moveModel.updateDistance(DistanceLatLongCalculation().calculateDistance(moveModel.moveClass.latEnderecoOrigem, moveModel.moveClass.longEnderecoOrigem, moveModel.moveClass.latEnderecoDestino, moveModel.moveClass.longEnderecoDestino));
      //distance = DistanceLatLongCalculation().calculateDistance(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem, moveClass.latEnderecoDestino, moveClass.longEnderecoDestino);

      //calculo dos custos com gasolina considerando 8km/L
      moveModel.updateGasCosts((moveModel.Distance/7)*precoGasolina);
      //finalGasCosts = (distance/7)*precoGasolina;
      if(moveModel.GasCosts<5.00){
        moveModel.updateGasCosts(5.00);
      }

      _custoTotal=_custoTotal+moveModel.GasCosts;

      //custo com ajudantes
      if(moveModel.moveClass.ajudantes==null){
        moveModel.moveClass.ajudantes=1;
      }
      moveModel.updateCustoAjudantes(moveModel.moveClass.ajudantes*precoCadaAjudante);
      _custoTotal=_custoTotal+moveModel.CustoAjudantes;

      //custo de cada caminhão adicionado
      _custoTotal=_custoTotal+precoBaseFreteiro+moveModel.moveClass.giveMeThePriceOfEachvehicle(moveModel.moveClass.carro);
      _custoVeiculo = moveModel.moveClass.giveMeThePriceOfEachvehicle(moveModel.moveClass.carro); //esta variavel é usada depois para exibir o resumo

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
      _custoTotal = _custoTotal+totalExtraProducts;

      _custoTotal = calculateTheCostsOfLadder(moveModel)+_custoTotal;

      //calcular a porcentagem e adicionar taxa. Para editar a taxa mudar a const dentro da classe
      _taxaServico = CalculosPercentagem().CalculePorcentagemDesteValor(CalculosPercentagem.taxaServico, _custoTotal);

      _custoTotal = _custoTotal+_taxaServico;

      moveModel.updatePrecoMudanca(_custoTotal);
      //moveClass.preco = custoTotal;

      //exibe o botão de avançar somente após a tela rolar até o fim exibindo o resumo dos custos
      /*
      Future.delayed(Duration(milliseconds: 4900)).then((_) {
        moveModel.updateShowResume(true);
      });

       */
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

  void _helperMeth(MoveModel moveModel){

    Future.delayed(Duration(seconds: 15)).then((_) {

      if(_sourceAdress.text.isEmpty){
        //user nao digitou nada.
        _msg = 'Informe aqui o endereço\nde partida da mudança';
        _spaceBefore = heightPercent*0.55;
        _alignArrow='center';
        FocusScope.of(context).unfocus();
        moveModel.updateHelpIsOnScreen(true);

        Future.delayed(Duration(seconds: 10)).then((_) {
          setState(() {
            moveModel.updateHelpIsOnScreen(false);
          });
        });

      } else if(_sourceAdress.text.isNotEmpty && moveModel.OrigemAddress==''){
        //user digitou mas não soube clicar na lupa.
        _msg = 'Clique na lupa\npara validar endereço';
        _spaceBefore = heightPercent*0.55;
        _alignArrow='right';
        FocusScope.of(context).unfocus();
        moveModel.updateHelpIsOnScreen(true);

        Future.delayed(Duration(seconds: 10)).then((_) {
          setState(() {
            moveModel.updateHelpIsOnScreen(false);
          });
        });
      }

    });
  }

  Widget _help(MoveModel moveModel, String mensagem, double spaceBefore, String align){
    return GestureDetector(
      onTap: (){
        moveModel.updateHelpIsOnScreen(false);
      },
      child: Container(
        height: heightPercent,
        width: widthPercent,
        color: Colors.black.withOpacity(0.6),
        child: Column(
          children: [
            //SizedBox(height: heightPercent*0.55,),
            SizedBox(height: spaceBefore,),
            Row(
              mainAxisAlignment: align=='left' ? MainAxisAlignment.start : align=='center' ? MainAxisAlignment.center : MainAxisAlignment.end,
              children: [
                align=='left' ? SizedBox(width: widthPercent*0.10,) : Container(),
                Icon(Icons.arrow_upward, color: CustomColors.yellow, size: 45,),
                align=='right' ? SizedBox(width: widthPercent*0.10,) : Container(),

              ],
            ),
            Text(mensagem, textAlign: TextAlign.center ,style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(3.0), color: CustomColors.yellow),),
          ],
        ),
      ),
    );
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



 */