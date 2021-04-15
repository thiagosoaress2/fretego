import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/utils/my_bottom_sheet.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:fretego/widgets/responsive_text_custom_withmargin.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class Page2Obs extends StatefulWidget {
  double heightPercent;
  double widthPercent;
  String uid;
  Page2Obs(this.heightPercent, this.widthPercent, this.uid);

  @override
  _Page2ObsState createState() => _Page2ObsState();
}

String uid;
double heightPercent;
double widthPercent;
ScrollController _scrollController;

final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar



bool _firstLoad=false;

double _currentSliderValue = 0.0;

class _Page2ObsState extends State<Page2Obs> with AfterLayoutMixin{

  TextEditingController _psController = TextEditingController();
  TextEditingController _qntLancesEscadaController = TextEditingController();
  int ajudantesSelecionados=1;


  @override
  void initState() {
    _scrollController = ScrollController();

    void _loadPsInShared() async {

      await SharedPrefsUtils().getPsFromShared().then((value) {
        if(value!= null){
          _psController.text = value;
        }
      });
    }
    _loadPsInShared();

  }

  void _firstLoadData(MoveModel moveModel){
    _firstLoad==true;

    _qntLancesEscadaController.addListener(() {
      moveModel.moveClass.lancesEscada= int.parse(_qntLancesEscadaController.text);
    });

    void _loadAjudantesInShared() async {

      await SharedPrefsUtils().getAjudantesFromShared().then((value) {
        if(value!=1 && value!= null){
          setState(() {
            //atualiza se for diferente de 1 para o valor selecionado pelo user de outra vez
            ajudantesSelecionados=value;
            moveModel.updateAjudantes(value);
          });
        } else {
          moveModel.updateAjudantes(1);
        }
      });

    }

    _loadAjudantesInShared();

    void _loadLancesEscadaInShared() async {

      await SharedPrefsUtils().getLancesDeEscadaFromShared().then((value) {
        if(value!=0 && value!= null){
          setState(() {
            //atualiza se for diferente de 1 para o valor selecionado pelo user de outra vez
            _currentSliderValue=value.toDouble();
            moveModel.updateLancesEscada(value);
          });
        } else {
          moveModel.updateLancesEscada(0);
        }
      });
    }

    _loadLancesEscadaInShared();

    /*
    //verifica para lembrar a opção que o user deixou
    if(moveModel.moveClass.escada==true){
      if(moveModel.moveClass.lancesEscada.toString()!="null"){
        _qntLancesEscadaController.text = moveModel.moveClass.lancesEscada.toString();
      }
    }

    if(moveModel.moveClass.escada==null){
      moveModel.moveClass.escada=false;
    }

     */

  }

  @override
  Widget build(BuildContext context) {

    uid = widget.uid;
    heightPercent = widget.heightPercent;
    widthPercent = widget.widthPercent;

    return ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget child, MoveModel moveModel){

        if(_firstLoad==false){
          _firstLoad=true;
          _firstLoadData(moveModel);

          if(moveModel.needHelper()==true){

            moveModel.updateHelpersNeeded(2);
            if(moveModel.HelpersNeeded==2 && ajudantesSelecionados==1){
              ajudantesSelecionados = 2;
            }
          }
        }


        return _buildBody(moveModel);

      },
    );
  }

  Widget _buildBody(MoveModel moveModel){

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: widthPercent,
        height: heightPercent,
        color: Colors.white,
        child: Stack(
          children: [

            Positioned(
              top: heightPercent*0.29,
              left: 0.5,
              right: 0.5,
              bottom: heightPercent*0.10,
              child: ListView(
                controller: _scrollController,
                children: [

                  Container(

                    //titulo
                    child: WidgetsConstructor().makeResponsiveText(context,
                        'Características do local', CustomColors.blue, 3, 0.0, 0.0, 'center'),),
                  SizedBox(height: heightPercent*0.04,),

                  Padding(padding: EdgeInsets.all(10.0),
                    child: Container(
                      width: widthPercent*0.9,
                      child: ResponsiveTextCustomWithMargin('Lances de escada', context,
                          CustomColors.blue, 2.5, 10.0, 0.0, 0.0, 0.0, 'no'),

                    ),
                  ),


                  //slider dos lances de escada
                  Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                    child: Container(
                      width: widthPercent*0.90,
                      height: heightPercent*0.15,
                      decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 2.0, 0.0),
                      child: Column(
                        children: [

                          SizedBox(height: heightPercent*0.02,),
                          Slider(
                            value: _currentSliderValue,
                            min: 0,
                            max: 20,
                            divisions: 20,
                            label: _currentSliderValue.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                _currentSliderValue = value;
                                moveModel.updateLancesEscada(value.toInt());
                              });
                            },
                          ),
                          WidgetsConstructor().makeResponsiveText(context,
                              _currentSliderValue==0.0 ? 'Sem escada' : 'lances: '+_currentSliderValue.round().toString(),
                              Colors.grey[400], 2.0, 5.0, 0.0, 'center'),

                        ],
                      ),
                    ),
                  ),

                  //ajudantes titulo
                  Padding(padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                    child: Container(
                      width: widthPercent*0.9,
                      child: ResponsiveTextCustomWithMargin('Quantidade de ajudantes', context,
                          CustomColors.blue, 2.5, 30.0, 0.0, 0.0, 0.0, 'no'),

                    ),
                  ),

                  //ajudantes container
                  Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                    child: Container(
                      width: widthPercent*0.90,
                      decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 2.0, 0.0),
                      child: Padding(padding: EdgeInsets.all(10.0),
                        child: Column(
                          children: [

                            SizedBox(height: heightPercent*0.02,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                InkWell(
                                  onTap: (){
                                    if(moveModel.HelpersNeeded==2){
                                      _displaySnackBar(context, 'Você precisa de mais ajudantes');
                                    } else {
                                      setState(() {
                                        ajudantesSelecionados=1;
                                        moveModel.updateAjudantes(ajudantesSelecionados);
                                      });
                                      scrollToBottom();
                                    }

                                  },
                                  child: ajudantesSelecionados==1 ? const HelperContainer('+1', Colors.blue, Colors.white) : const HelperContainer('+1', Colors.white, Colors.blue),
                                ),

                                InkWell(
                                  onTap: (){

                                    setState(() {
                                      ajudantesSelecionados=2;
                                      moveModel.updateAjudantes(ajudantesSelecionados);
                                    });
                                    scrollToBottom();
                                  },
                                  child:
                                  ajudantesSelecionados==2 ? const HelperContainer('+2', Colors.blue, Colors.white) : const HelperContainer('+2', Colors.white, Colors.blue),
                                ),

                                InkWell(
                                  onTap: (){

                                    setState(() {
                                      ajudantesSelecionados=3;
                                      moveModel.updateAjudantes(ajudantesSelecionados);
                                    });
                                    scrollToBottom();
                                  },
                                  child:
                                  ajudantesSelecionados==3 ? const HelperContainer('+3', Colors.blue, Colors.white) : const HelperContainer('+3', Colors.white, Colors.blue),
                                ),

                                InkWell(
                                  onTap: (){

                                    setState(() {
                                      ajudantesSelecionados=4;
                                      moveModel.updateAjudantes(ajudantesSelecionados);
                                    });
                                    scrollToBottom();
                                  },
                                  child:
                                  ajudantesSelecionados==4 ? const HelperContainer('+4', Colors.blue, Colors.white) : const HelperContainer('+4', Colors.white, Colors.blue),
                                ),

                              ],
                            ),
                            WidgetsConstructor().makeResponsiveText(context,
                                moveModel.HelpersNeeded==2 ? 'Alguns itens escolhidos necessitam de dois ajudantes.' : '',
                                Colors.grey, 2.0, 5.0, 0.0, 'center'),

                          ],
                        ),),
                    ),
                  ),

                  //observacoes
                  Padding(padding: EdgeInsets.all(10.0),
                    child: Container(
                      width: widthPercent*0.9,
                      child: WidgetsConstructor().makeResponsiveText(context,
                          'Observações', CustomColors.blue, 2.5, 30.0, 10.0, 'no'),
                    ),
                  ),

                  Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                    child: Container(
                      width: widthPercent*0.90,
                      height: heightPercent*0.15,
                      decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 2.0, 0.0),
                      child: TextField(
                        controller: _psController,
                        decoration: new InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                            hintText: 'Suas observações aqui, se houver.'
                        ),
                      ),
                    ),
                  ),

                  //botao de salvar observações
                  Padding(
                    padding: EdgeInsets.fromLTRB(widthPercent*0.20, 15.0, widthPercent*0.20, 0.0),
                    child: Container(
                      height: heightPercent*0.10,
                      child: RaisedButton(onPressed: (){

                        moveModel.moveClass.ps = _psController.text;
                        SharedPrefsUtils().savePsInShared(_psController.text);
                        MyBottomSheet().settingModalBottomSheet(context, 'Salvo!', '', 'Esta observação foi salva.', Icons.save, heightPercent, widthPercent, 0, true);

                      },
                        child: ResponsiveTextCustom('Salvar observação', context, Colors.white, 2.5, 0.0, 0.0, 'center'),
                        color: CustomColors.blue,
                      ),
                    ),
                  ),

                  SizedBox(height: 40.0,),



                ],
              ),
            ),


            //float action button
            Positioned(
                bottom: 15.0,
                right: 10.0,
                child: FloatingActionButton(
                  onPressed: (){

                    if(moveModel.ActualPage!='final'){
                      moveModel.changePageForward('truck', 'obs', 'Veículo');
                    }


                  },
                  backgroundColor: CustomColors.yellow,
                  splashColor: Colors.yellow,
                  child: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 50.0,),
                )
            ),

          ],
        ),
      ),
    );
  }

  void scrollToBottom() {
    double bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      bottomOffset,
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {

    _qntLancesEscadaController.dispose();
    _scrollController.dispose();
    super.dispose();

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
  void afterFirstLayout(BuildContext context) {

    setState(() {
      //apenas para atualizar os ajudantes no botoes
    });

  }

}


class HelperContainer extends StatelessWidget {
  final String text;
  final Color bgcolor;
  final Color txtcolor;

  const HelperContainer(this.text, this.bgcolor, this.txtcolor);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgcolor,
        border: Border.all(
          color: Colors.blue,
          width: 2.0,
        ),
          borderRadius: BorderRadius.all(Radius.circular(3.0)),
      ),
      height: 45.0,
      width: widthPercent*0.12,
      child: ResponsiveTextCustom(text, context, txtcolor, 2.5, 0.0, 0.0, 'center'),
    );
  }
}

