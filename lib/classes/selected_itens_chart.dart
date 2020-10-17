import 'package:fretego/classes/item_class.dart';

class SelectedItensChart {

  int quantity;
  bool singlePerson;
  ItemClass itens;

  SelectedItensChart(this.quantity, this.singlePerson, this.itens);

  SelectedItensChart.empty();

}