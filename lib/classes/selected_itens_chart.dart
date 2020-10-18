import 'package:fretego/classes/item_class.dart';

class SelectedItensChart {

  //int quantity;
  //bool singlePerson;
  ItemClass itemAdded;

  List<ItemClass> itemsSelectedCart =[];

  SelectedItensChart(this.itemAdded);
  //SelectedItensChart(this.quantity, this.singlePerson, this.itemAdded);

  SelectedItensChart.empty();

  void addItemToChart (ItemClass itemClass){
    itemsSelectedCart.add(itemClass);
  }

}