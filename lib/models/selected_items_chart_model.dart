import 'package:fretego/classes/item_class.dart';
import 'package:scoped_model/scoped_model.dart';

class SelectedItemsChartModel extends Model {

  ItemClass itemAdded;

  List<ItemClass> itemsSelectedCart =[];

  void addItemToChart (ItemClass itemClass){
    itemsSelectedCart.add(itemClass);
  }

  int getItemsChartSize(){
    return itemsSelectedCart.length;
  }

  void clearChart(){
    itemsSelectedCart = [];
  }

  double getTotalVolumeOfChart(){
    int cont =0;
    double volumeTotal=0.0;
    while(cont<itemsSelectedCart.length){
      volumeTotal = itemsSelectedCart[cont].volume+volumeTotal;
      cont++;
    }
    return volumeTotal;
  }

  bool needHelper(){
    int cont=0;
    bool needIt=false;
    while(cont<itemsSelectedCart.length){
      if(itemsSelectedCart[cont].singlePerson==false){
        //se for false é pq precisa de mais de uma pessoa
        needIt=true;
      }
      return needIt;
    }
  }

}