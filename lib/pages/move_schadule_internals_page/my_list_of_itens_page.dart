import 'package:flutter/material.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/pages/move_schadule_internals_page/page1_select_itens.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/widgets/responsive_text_custom.dart';
import 'package:scoped_model/scoped_model.dart';

class MyListOfItensPage extends StatefulWidget {
  double heightPercent;
  double widthPercent;
  MyListOfItensPage(this.heightPercent, this.widthPercent);

  @override
  _MyListOfItensPageState createState() => _MyListOfItensPageState();
}

class _MyListOfItensPageState extends State<MyListOfItensPage> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MoveModel>(
      builder: (BuildContext context, Widget child, MoveModel moveModel){

        print(itensMap.length);

        return Container(
          width: widget.widthPercent,
          color: Colors.white,
          height: widget.heightPercent,
          child: Stack(
            children: [

              //botao de fechar
              Positioned(

                right: 10.0,
                  height: widget.heightPercent*0.20,
                  child: CloseButton(
                    onPressed: (){
                      moveModel.updateShowListAnywhere(false);
                    },
                  )
              ),

              //titulo
              Positioned(
                left: 10.0,
                  right: 10.0,
                  top: widget.heightPercent*0.20,
                  child: ResponsiveTextCustom('Itens da mudança', context, CustomColors.blue, 2.5, 0.0, 0.0, 'center')
              ),

              //legenda da lista
              Positioned(
                left: 10.0,
                  right: 10.0,
                  top: widget.heightPercent*0.25,
                  child:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ResponsiveTextCustom('Item', context, CustomColors.blue, 2, 5.0, 0.0, 'no'),
                  ResponsiveTextCustom('Quantidade', context, Colors.black, 2, 5.0, 0.0, 'no'),
                ],
              )),

              //lista
              Positioned(
                top: widget.heightPercent*0.28,
                  right: 10.0,
                  left: 15.0,
                  child: Container(
                    height: widget.heightPercent*0.70,
                    width: widget.widthPercent*0.85,
                    child: ListView.builder(
                        itemCount: itensMap.length,
                        itemBuilder: (BuildContext context, int index){


                          String key = itensMap.keys.elementAt(index);
                          int value = itensMap.values.elementAt(index);
                          return _listLine(key, value);



                        }
                    ),
                  ),
              ),

              Positioned(
                  bottom: 50.0,
                  left: 10.0,
                  right: 10.0,
                  child: Container(
                    width: widget.widthPercent*0.50,
                    height: widget.heightPercent*0.08,
                    child: RaisedButton(onPressed: (){
                      moveModel.changePageBackward('itens', 'Início', 'Itens grandes');
                      moveModel.updateShowListAnywhere(false);

                    },
                      color: CustomColors.blue,
                      //child: ResponsiveTextCustom(txt, context, color, size, marginTop, marginBottom, aligment),
                      child: ResponsiveTextCustom('Editar lista', context, Colors.white, 2.0,  0.0, 0.0, 'center'),
                    ),
                  ))

            ],
          ),
        );

      },
    );
  }

  Widget _listLine(String key, int value){
    return Container(
      width: widget.widthPercent*0.80,
      height: widget.heightPercent*0.10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(key),
              Text(value.toString()),
            ],
          ),
          const Divider(),
        ],
      )
    );
  }
}
