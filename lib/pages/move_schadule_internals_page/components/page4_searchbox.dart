import 'package:flutter/material.dart';
import 'package:fretego/models/move_model.dart';

class Page4Searchbox extends StatelessWidget {
  double heightPercent;
  double widthPercent;
  TextEditingController controller;
  MoveModel moveModel;
  String label;
  String tip;
  Page4Searchbox({this.heightPercent, this.widthPercent, this.controller, this.moveModel, this.label, this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: heightPercent * 0.08,
      width: widthPercent * 0.6,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.all(
            Radius.circular(4.0)),),
      child: TextField(controller: controller,
        //enabled: _permissionGranted==true ? true : false,
        keyboardType: moveModel.SearchCep == true ? TextInputType.number : TextInputType.streetAddress,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.home),
            labelText: label,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding:
            EdgeInsets.only(left: 5,
                bottom: 5,
                top: 5,
                right: 5),
            hintText: tip),

      ),
    );
  }
}
