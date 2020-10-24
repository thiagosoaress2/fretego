import 'package:fretego/classes/item_class.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtils {

  Future<void> saveMoveClassToShared(MoveClass moveClass) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('enderecoOrigem', moveClass.enderecoOrigem);
    await prefs.setString('enderecoDestino', moveClass.enderecoDestino);
    await prefs.setInt('ajudantes', moveClass.ajudantes);
    await prefs.setString('carro', moveClass.carro);
    await prefs.setDouble('preco', moveClass.preco);
    await prefs.setBool('escada', moveClass.escada);
    await prefs.setInt('lancesEscada', moveClass.lancesEscada);
    await prefs.setString('freteiroId', moveClass.freteiroId);
    await prefs.setString('nomeFreteiro', moveClass.nomeFreteiro);
    await prefs.setString('dateSelected', moveClass.dateSelected);
    await prefs.setString('timeSelected', moveClass.timeSelected);

  }

  Future<MoveClass> loadMoveClassFromSharedPrefs() async {

    MoveClass moveClass;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String endereco = (prefs.getString('enderecoOrigem'));
    if(endereco!= null){ //se for diferente de null é pq tem coisa armazenada
      moveClass.enderecoOrigem = endereco;
      moveClass.enderecoDestino = (prefs.getString('enderecoDestino'));
      moveClass.ajudantes = (prefs.getInt('ajudantes'));
      moveClass.carro = (prefs.getString('carro'));
      moveClass.preco = (prefs.getDouble('preco'));
      moveClass.escada = (prefs.getBool('escada'));
      moveClass.lancesEscada = (prefs.getInt('lancesEscada'));
      moveClass.freteiroId = (prefs.getString('freteiroId'));
      moveClass.nomeFreteiro = (prefs.getString('nomeFreteiro'));
      moveClass.dateSelected = (prefs.getString('dateSelected'));
      moveClass.timeSelected = (prefs.getString('timeSelected'));
    }

    return moveClass;


  }



  //Aqui estes métodos são somente para a primeira página, onde salva a lista de itens do usuário
  Future<void> saveListOfItemsInShared(List<ItemClass> itemsSelectedCart) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int cont=0;

    while(cont<itemsSelectedCart.length){
      await prefs.setString('item_name'+cont.toString(), itemsSelectedCart[cont].name);
      await prefs.setString('item_image'+cont.toString(), itemsSelectedCart[cont].image);
      await prefs.setBool('item_single_person'+cont.toString(), itemsSelectedCart[cont].singlePerson);
      await prefs.setDouble('item_volume'+cont.toString(), itemsSelectedCart[cont].volume);
      await prefs.setDouble('item_weight'+cont.toString(), itemsSelectedCart[cont].weight);
      cont++;
      await prefs.setInt('item_list_size', cont);  //utilizar isto para saber o tamanho da lista
    }
  }

  Future<bool> thereIsItemsSavedInShared() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('item_list_size'));
    if(counter==0 || counter==null){
      return false;
    } else {
      return true;
    }

  }

  Future<List<ItemClass>> loadListOfItemsInShared() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int size = (prefs.getInt('item_list_size'));
    List<ItemClass> itemsSelectedCart =[];

    int cont=0;
    while(cont<size){
      ItemClass itemClass;
      itemClass.name = prefs.getString('item_name'+cont.toString());
      itemClass.image = prefs.getString('item_image'+cont.toString());
      itemClass.singlePerson = prefs.getBool('item_single_person'+cont.toString());
      itemClass.volume = prefs.getDouble('item_volume'+cont.toString());
      itemClass.weight = prefs.getDouble('item_weigth'+cont.toString());
      itemsSelectedCart.add(itemClass);
      cont++;

    }

    return itemsSelectedCart;

  }
}