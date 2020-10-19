import 'package:fretego/classes/item_class.dart';

class MoveClass {

  List<ItemClass> itemsSelectedCart =[];
  String ps;
  String enderecoOrigem;
  String enderecoDestino;
  //double latEnderecoOrigem;
  //double longEnderecoOrigem;
  //double latEnderecoDestino;
  //double longEnderecoDestino;
  int ajudantes;
  String carro;



  //MoveClass({this.itemsSelectedCart, this.ps, this.enderecoOrigem, this.enderecoDestino, this.latEnderecoOrigem, this.longEnderecoOrigem, this.latEnderecoDestino, this.longEnderecoDestino});
  MoveClass({this.itemsSelectedCart, this.ps, this.enderecoOrigem, this.enderecoDestino, this.ajudantes, this.carro});

  MoveClass.empty();

}