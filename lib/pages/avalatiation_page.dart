import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/avaliation_class.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/widgets/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';


final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

bool showLandPage=true;
bool showCompleteAvaliation=false;
bool showLastPageConfirmationPage=false;

bool showConfirmationPopup=false;

bool isLoading=true;

AvaliationClass _avaliationClass = AvaliationClass('', '', 0, 0);

String name='no123';

double heightPercent;
double widthPercent;

double avaliation=0;


class AvaliationPage extends StatefulWidget {
  MoveClass moveClass = MoveClass();

  AvaliationPage(this.moveClass);

  @override
  _AvaliationPageState createState() => _AvaliationPageState();
}

class _AvaliationPageState extends State<AvaliationPage> with AfterLayoutMixin<AvaliationPage> {


  @override
  Future<void> afterFirstLayout(BuildContext context) async {

    loadAvaliationClass();

  }


  @override
  Widget build(BuildContext context) {

    heightPercent = MediaQuery
        .of(context)
        .size
        .height;
    widthPercent = MediaQuery
        .of(context)
        .size
        .width;

    print(widget.moveClass.userId);
    //AvaliationClass _avaliationClass = AvaliationClass('', widget.moveClass.idPedido, 0, 0);
    _avaliationClass.avaliationTargetId = widget.moveClass.freteiroId;


    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel){

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(

            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              iconSize: 20.0,
              onPressed: () {
                _goBack(context);
              },
            ),

            title: Text('Avaliação'), centerTitle: true,
          ),

          body: Stack(
            children: [

              showLandPage==true
                  ? _landPage() : Container(),

              showCompleteAvaliation==true
                  ? _avaliationPage() : Container(),

              showLastPageConfirmationPage==true
                  ? _postAvaliationPage()
                  : Container(),

              isLoading==true
                  ? Center(child:  CircularProgressIndicator(),)
                  : Container(),

            ],

          ),

        );
      },
    );
  }

  //PAGES
  Widget _landPage(){

    void _onConfirmPopup(){
      _quickAvaliation(avaliation, widget.moveClass);
      setState(() {
        showConfirmationPopup=false;
      });
    }

    void _onCancelPopup(){
      setState(() {
        showConfirmationPopup=false;
      });
    }

    return ListView(
      children: [


        Stack(
          children: [

            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                name!='no123'
                    ? WidgetsConstructor().makeText('Sua avaliação de '+name, Colors.blue, 18.0, 25.0, 20.0, 'no')
                    : Container(),

                WidgetsConstructor().makeText('Avaliação rápida', Colors.blue, 18.0, 25.0, 20.0, 'center'),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: (){
                          setState(() {
                            showConfirmationPopup=true;
                            avaliation=1;
                          });

                        },
                        child: avaliation==0
                            ?Icon(Icons.star_border, color: Colors.yellow[600], size: 60.0,)
                            : Icon(Icons.star, color: Colors.yellow[600], size: 60.0,)
                    ),

                    GestureDetector(
                        onTap: (){
                          setState(() {
                            avaliation=2;
                            showConfirmationPopup=true;
                          });

                        },
                        child: avaliation<=1
                            ?Icon(Icons.star_border, color: Colors.yellow[600], size: 60.0,)
                            : Icon(Icons.star, color: Colors.yellow[600], size: 60.0,)
                    ),

                    GestureDetector(
                        onTap: (){
                          setState(() {
                            showConfirmationPopup=true;
                            avaliation=3;
                          });

                        },
                        child: avaliation<=2
                            ?Icon(Icons.star_border, color: Colors.yellow[600], size: 60.0,)
                            : Icon(Icons.star, color: Colors.yellow[600], size: 60.0,)
                    ),

                    GestureDetector(
                        onTap: (){
                          setState(() {
                            avaliation=4;
                            showConfirmationPopup=true;
                          });

                        },
                        child: avaliation<=3
                            ?Icon(Icons.star_border, color: Colors.yellow[600], size: 60.0,)
                            : Icon(Icons.star, color: Colors.yellow[600], size: 60.0,)
                    ),

                    GestureDetector(
                        onTap: (){
                          setState(() {
                            avaliation=5;
                            showConfirmationPopup=true;
                          });

                        },
                        child: avaliation<=4
                            ?Icon(Icons.star_border, color: Colors.yellow[600], size: 60.0,)
                            : Icon(Icons.star, color: Colors.yellow[600], size: 60.0,)
                    ),
                  ],
                ),

                SizedBox(height: heightPercent*0.75,),
                // WidgetsConstructor().makeText('Ou se preferir, faça uma avaliação detalhada', Colors.blue, 16.0, 25.0, 20.0, 'center'),
                // SizedBox(height: 25.0,),
                // WidgetsConstructor().makeButtonWithCallBack(Colors.blue, Colors.white, 200.0, 60.0, 2.0, 4.0, "Avaliação completa", Colors.white, 17.0, () {_completeAvaliation();}),


              ],
            ),

            showConfirmationPopup==true
                ? WidgetsConstructor().customPopUp('Confirmação', 'Confirmar avaliação.', 'Confirmar', 'Cancelar', widthPercent, heightPercent, () {_onConfirmPopup();}, (){_onCancelPopup();})
                : Container(),


          ],
        )

      ],
    );
  }

  Widget _avaliationPage(){


    void _finishVote(){
      print('finish him');
    }

    void _next(){
      print('next');
    }


    void starCallback(int number){
      print(number);
    }

    return ListView(
      children: [

        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            WidgetsConstructor().makeText('Avaliação completa', Colors.blue, 18.0, 25.0, 20.0, 'center'),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [

                  Container(color: Colors.white, width: widthPercent, height: heightPercent*0.3,
                    child: Stack(
                      children: [

                        Column(
                          children: [

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                WidgetsConstructor().makeText('Como você avalia a pontualidade: ', Colors.black, 17.0, 10.0, 20.0, 'center'),
                              ],
                            ),

                            SizedBox(height: 25.0,),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                GestureDetector(
                                  child: startsLine(),
                                  onTap: (){
                                    starCallback(1);
                                  },
                                ),


                              ],
                            )


                          ],
                        ),

                        Positioned(

                          child: IconButton(icon: Icon(Icons.arrow_forward_rounded, color: Colors.blue,), onPressed: () {_next();}),
                          bottom: 1.0,
                          right: 10.0,
                        ),

                      ],
                    ),
                  ),
                  Container(color: Colors.blue, width: widthPercent, height: heightPercent*0.25,),
                  Container(color: Colors.yellow, width: widthPercent, height: heightPercent*0.25,),

                ],
              ),
            ),

            SizedBox(height: 35.0,),

            WidgetsConstructor().makeButtonWithCallBack(Colors.blue, Colors.white, 100.0, 60.0, 2.0, 4.0, 'Finalizar', Colors.white, 16.0, () {_finishVote();}),





          ],
        ),

      ],
    );
  }

  Widget _postAvaliationPage(){

    void _onClickOkButton(){
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => HomePage()));
    }

    return ListView(
      children: [

        WidgetsConstructor().makeText('Obrigado por avaliar '+name, Colors.blue, 20.0, 40.0, 25.0, 'center'),
        WidgetsConstructor().makeButtonWithCallBack(Colors.blue, Colors.white, 150.0, 60.0, 2.0, 4.0, 'Finalizar', Colors.white, 18.0, () {_onClickOkButton();}),

      ],
    );
  }








  //WIDGETS
  Widget startsLine(){
    return Container(

      child: Row(
        children: [

          Icon(Icons.star_border, color: Colors.yellow[600], size: 40.0,),

        ],
      ),

    );
  }


  //Functions
  _completeAvaliation(){
    setState(() {
      showCompleteAvaliation=true;
      showLandPage=false;
    });
  }

  _goBack(BuildContext context) {

    if(showLandPage==true){
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => HomePage()));
    } else if(showCompleteAvaliation==true){
      avaliation=0;
      showConfirmationPopup=false;
      setState(() {
        showCompleteAvaliation=false;
        showLandPage=true;
      });
    }


  }

  void _quickAvaliation(double avaliation, MoveClass moveClass){
    _avaliationClass.newRate = AvaliationClass.Empty().calculateAvaliation(avaliation, _avaliationClass.avaliations, _avaliationClass.avaliationTargetRate);
    FirestoreServices().saveUserAvaliation(_avaliationClass);

    //se o freteiro já tiver finalizado, fechar ticket senao deixar um anuncio de que o user ja acabou
    if(moveClass.situacao=='trucker_finished'){
      FirestoreServices().FinishAmove(moveClass); //aqui apaga e cria um histórico
    } else {
      FirestoreServices().updateMoveSituation('user_finished', _avaliationClass.avaliationTargetId, moveClass);
    }


    showLandPage=false;
    showCompleteAvaliation=false;
    setState(() {
      showLastPageConfirmationPage=true;
    });
  }

  Future<void> loadAvaliationClass() async {


    void _onSucessLoadAvaliationClass(){

      setState(() {
        name = _avaliationClass.avaliationTargetName;
        isLoading=false;
      });

    }


    await FirestoreServices().loadAvaliationClass(_avaliationClass, () {_onSucessLoadAvaliationClass();});

  }

}





/*
import 'package:flutter/material.dart';
import 'package:fretego/classes/avaliation_class.dart';
import 'package:fretego/models/userModel.dart';
import 'package:scoped_model/scoped_model.dart';

AvaliationClass _avaliationClass = AvaliationClass();  //esta é a classe que será usada na activity

class AvaliationPage extends StatefulWidget {
  AvaliationClass avaliationClass = AvaliationClass();

  AvaliationPage(this.avaliationClass);

  @override
  _AvaliationPageState createState() => _AvaliationPageState();
}

class _AvaliationPageState extends State<AvaliationPage> {
  @override
  Widget build(BuildContext context) {

    _avaliationClass = widget.avaliationClass; //passando os dados que vieram da outra página para esta

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){

        return Scaffold(
          appBar: AppBar(
            title: Text('Avaliação do serviço'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Container(color: Colors.yellow,),
          ),
        );
      },
    );
  }
}


 */