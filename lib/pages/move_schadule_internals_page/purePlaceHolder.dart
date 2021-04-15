import 'package:flutter/material.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/pages/move_schadule_internals_page/page6_data.dart';
import 'package:fretego/utils/colors.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

import '../home_page.dart';

//obs
//Essa classe vai suportar a pagina6  para o user atualizar a data sem precisar carregar todas as informações das páginas seguintes

class PurePlaceHolder extends StatelessWidget {
  String userId;
  double heightPercent;
  double widthPercent;
  PurePlaceHolder(this.userId, this.heightPercent, this.widthPercent);

  @override
  Widget build(BuildContext context) {

    return ScopedModel<MoveModel>(
      model: MoveModel(),
      child: ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget child, MoveModel moveModel){
        return Scaffold(
          body: Container(
            height: heightPercent,
            width: widthPercent,
            child: Stack(
              children: [

                //este ultimo argumento true significa que estamos chamando esta página por aqui e que portanto é uma atualização
                Page6Data(heightPercent, widthPercent, userId, true),

                //botao de fechar
                Positioned(
                    top: heightPercent*0.05,
                    left: 0.0,
                    right: 0.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CloseButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => HomePage()));
                          },
                        )
                      ],
                    )
                ),

                //textos
                Positioned(
                  top: heightPercent*0.15,
                  left: widthPercent*0.10,
                  right: widthPercent*0.10,
                  child: Column(
                    children: [
                      Text('Você está editando a data e hora de sua mudança', textAlign: TextAlign.center ,style: TextStyle(
                          color: CustomColors.blue,
                          fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),

                      SizedBox(height: heightPercent*0.005,),

                      Text('O profissional pode não concordar com a mudança. Neste caso você poderá escolher outro.', style: TextStyle(
                          color: Colors.black,
                          fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),

                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      ),
    );

  }
}
