import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/truck_class.dart';
import 'package:fretego/classes/trucker_class.dart';
import 'package:fretego/models/home_page_model.dart';
import 'package:fretego/pages/avalatiation_page.dart';
import 'package:fretego/pages/home_page.dart';
import 'package:fretego/pages/home_page_internals/widget_loading_screen.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/colors.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

class TruckerProfile extends StatefulWidget {
  double heightPercent;
  double widthPercent;
  String truckerId;
  String truckerName;
  TruckerProfile({this.heightPercent, this.widthPercent, this.truckerId, this.truckerName});

  @override
  _TruckerProfileState createState() => _TruckerProfileState();
}

//is loading é true de inicio, então a page já começa com a janela de loading ativada
bool _isLoading = true;

//controla o zoom na imagem do perfil
bool _profilePicZoom=false;

//se der erro ao carregar infos do user, chama essa variavel
bool _showErrorPage=false;

class _TruckerProfileState extends State<TruckerProfile> {



  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<HomePageModel>(
      builder: (BuildContext context, Widget widgets, HomePageModel homePageModel){


        //se nao for null, já está lido
        print(homePageModel.truckerClass.placa.toString());
        if(homePageModel.truckerClass.placa==null){
          if(_isLoading==true){
            _loadInfos(homePageModel);
          }
        }


        return WillPopScope(
            child: Scaffold(
              body: _showErrorPage==false ? _profilePage(homePageModel) : _errorPage(),
            ),
            onWillPop: (){

              _isLoading=true;

              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => HomePage()));

            }
            );

      },
    );
  }

  void _loadInfos(HomePageModel homePageModel) async {

    void _onSucess(){

      setState(() {
        _isLoading=false;
      });
      print(homePageModel.truckerClass.placa);

    }

    void _onFail(){
      print('erro');
      setState(() {
        _isLoading=false;
        _showErrorPage=true;
      });
    }

    homePageModel.truckerClass.id = widget.truckerId;
    FirestoreServices().loadDataToTruckerClass(widget.truckerId, homePageModel, (){_onSucess();}, () {_onFail();});

  }

  Widget _profilePage(HomePageModel homePageModel){

    print(homePageModel.truckerClass.vehicle);

    return Container(
      width: widget.widthPercent,
      height: widget.heightPercent,
      color: Colors.white,
      child: Stack(
        children: [

          _closeBtn(),

          if(homePageModel.truckerClass.placa!=null)

          if(homePageModel.truckerClass.placa!=null) _apelido(apelido: homePageModel.truckerClass.apelido, nome: homePageModel.truckerClass.name),

          if(homePageModel.truckerClass.placa!=null) _barraAmarela(homePageModel.truckerClass.aval2.toString(), homePageModel.truckerClass.rate.toStringAsFixed(2)),

          if(homePageModel.truckerClass.placa!=null) _tipoVeiculo(TruckClass.empty().formatCodeToHumanName(homePageModel.truckerClass.vehicle)),

          if(homePageModel.truckerClass.placa!=null) _imagemVeiculo(homePageModel.truckerClass.vehicle_image),

          if(homePageModel.truckerClass.placa!=null) _picture(homePageModel),



          //usar _dataIsLoaded para ver se exibe ou n as coisas

          if(_isLoading==true && homePageModel.truckerClass.placa==null) WidgetLoadingScreeen('Aguarde', 'Carregando dados\nde ${widget.truckerName}'),

        ],
      ),
    );
  }

  Widget _closeBtn(){
    return Positioned(
      top: widget.heightPercent*0.10,
      right: widget.widthPercent*0.05,
      child: _closeBtnBtn(),
    );
  }

  Widget _name(){

  }

  Widget _apelido({String apelido, String nome}){

    return Positioned(
        top: widget.heightPercent*0.40,
        left: 0.0,
        right: 0.0,
        child: Column(
          children: [
            Text(apelido, textAlign: TextAlign.center,
              style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(4.0), color: CustomColors.blue),
            ),
            Padding(padding: EdgeInsets.only(top: 5.0),
            child: Text('nome: ${nome}', textAlign: TextAlign.center,
              style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2.5), color: Colors.black),
            ),
            ),
          ],
        )
    );
  }

  Widget _closeBtnBtn(){
    return CloseButton(
      onPressed: (){

        _isLoading=true;

        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomePage()));
      },
    );
  }

  Widget _picture(HomePageModel homePageModel){

    return AnimatedPositioned(
      //ajustar posicao quando der zoom na foto
      top: _profilePicZoom==false ? widget.heightPercent*0.20 : widget.heightPercent*0.05,
      left: _profilePicZoom==false ? widget.widthPercent*0.0 : 10.0,
      right: _profilePicZoom==false ? widget.widthPercent*0.0 : 10.0,
      bottom: _profilePicZoom==false ? widget.heightPercent*0.60 : widget.heightPercent*0.35,
      child: GestureDetector(
        onTap: (){
          setState(() {
            _profilePicZoom=!_profilePicZoom;
          });
        },
        child: Container(
          //ajustar formato do container quando der zoom na foto
          color: Colors.transparent,
          constraints: BoxConstraints.expand(),
          width: widget.widthPercent*0.35,
          height: widget.heightPercent*0.175,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  homePageModel.truckerClass.image,
                  width: _profilePicZoom==false ? widget.widthPercent*0.32 : widget.widthPercent*0.90,
                  height: _profilePicZoom==false ? widget.heightPercent*0.18 : widget.heightPercent*0.50,
                  fit: BoxFit.fill,
                ),
              ),
              radius: 50,
              ),
          ),
        ),
      ),
      duration: Duration(milliseconds: 100),
    );

  }

  Widget _barraAmarela(String aval, String rate){
    return Positioned(
      top: widget.heightPercent*0.55,
      left: widget.widthPercent*0.05,
      right: widget.widthPercent*0.05,

      child: Container(
        height: widget.heightPercent*0.10,
        child: Column(
          children: [

            SizedBox(height: 5.0,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                Container(
                  alignment: Alignment.center,
                  width: widget.widthPercent*0.40,
                  child: Text('Viagens', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2.5), color: Colors.white),
                  ),
                ),

                Container(
                  alignment: Alignment.center,
                  width: widget.widthPercent*0.40,
                  child: Text('Nota', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2.5), color: Colors.white),
                  ),
                ),
              ],
            ),

            SizedBox(height: 5.0,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                Container(
                  alignment: Alignment.center,
                  width: widget.widthPercent*0.40,
                  child: Text(aval, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(4.0), color: Colors.white),
                  ),
                ),

                Container(
                  alignment: Alignment.center,
                  width: widget.widthPercent*0.40,
                  child: Text(rate, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(4.0), color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
        decoration: new BoxDecoration(
            color: CustomColors.yellow,
            borderRadius: new BorderRadius.all(const Radius.circular(5.0)),),
      ),
    );
  }

  Widget _tipoVeiculo(String veiculo){

    return Positioned(
      top: widget.heightPercent*0.70,
      left: 20.0,
      right: 20.0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Text('Tipo de veículo: ', textAlign: TextAlign.center,
              style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2.5), color: Colors.black),
            ),
            SizedBox(width: 20.0,),
            Container(
              child:
              veiculo=='pickup pequena' ? Image.asset('images/itensselect/trucks/truck_pickupp.png', fit: BoxFit.fill,)
                  : veiculo=='carroça' ? Image.asset('images/itensselect/trucks/truck_carroca.png', fit: BoxFit.fill,)
                  : veiculo=='pickup grande' ? Image.asset('images/itensselect/trucks/truck_pickupg.png', fit: BoxFit.fill,)
                  : veiculo=='kombi aberta' ? Image.asset('images/itensselect/trucks/truck_kombia.png', fit: BoxFit.fill,)
                  : veiculo=='kombi fechada' ? Image.asset('images/itensselect/trucks/truck_kombi.png', fit: BoxFit.fill,)
                  : veiculo=='caminhao aberto' ? Image.asset('images/itensselect/trucks/truck_aberto.png', fit: BoxFit.fill,)
                  : veiculo=='caminhao baú pequeno' ? Image.asset('images/itensselect/trucks/truck_baup.png', fit: BoxFit.fill,)
                  :  Image.asset('images/itensselect/trucks/truck_baug.png', fit: BoxFit.fill,),

              width: widget.widthPercent*0.30,
              height: widget.heightPercent*0.10,
              alignment: Alignment.center,
            ),
          ],
        ),
      ),

    );
  }

  Widget _imagemVeiculo(String imagemUrl){

    return Positioned(
      top: widget.heightPercent*0.82,
      left: 20.0,
      right: 20.0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Text('Imagem: ', textAlign: TextAlign.center,
              style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2.5), color: Colors.black),
            ),
            SizedBox(width: 20.0,),
            Container(
              width: widget.widthPercent*0.25,
              height: widget.heightPercent*0.10,
              child: Image.network(
                imagemUrl,
                width: widget.widthPercent*0.25,
                height: widget.heightPercent*0.10,
                fit: BoxFit.fill,
              ),

            ),
          ],
        ),
      ),

    );
  }









  Widget _errorPage(){
    return Container(
      width: widget.widthPercent,
      height: widget.heightPercent,
      color: Colors.white,
      child: Column(
        children: [

          //close btn
          Padding(padding: EdgeInsets.fromLTRB(widget.widthPercent*0.95, widget.heightPercent*0.10, 0.0, widget.heightPercent*0.20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _closeBtnBtn(),
              ],
            ),),

          Text('Ocorreu um erro. Você pode estar sem internet.', textAlign: TextAlign.center,
            style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(3.0), color: Colors.black),
          ),

        ],
      ),
    );
  }


}


