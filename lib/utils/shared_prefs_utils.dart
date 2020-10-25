import 'package:fretego/classes/item_class.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtils {

  Future<void> saveMoveClassToShared(MoveClass moveClass) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('enderecoOrigem', moveClass.enderecoOrigem);
    await prefs.setString('enderecoDestino', moveClass.enderecoDestino);
    await prefs.setDouble('latEnderecoOrigem', moveClass.latEnderecoOrigem);
    await prefs.setDouble('longEnderecoOrigem', moveClass.longEnderecoOrigem);
    await prefs.setDouble('latEnderecoDestino', moveClass.latEnderecoDestino);
    await prefs.setDouble('longEnderecoDestino', moveClass.longEnderecoDestino);
    await prefs.setInt('ajudantes', moveClass.ajudantes);
    await prefs.setString('carro', moveClass.carro);
    await prefs.setDouble('preco', moveClass.preco);
    await prefs.setString('ps', moveClass.ps);
    await prefs.setBool('escada', moveClass.escada);
    await prefs.setInt('lancesEscada', moveClass.lancesEscada);
    await prefs.setString('freteiroId', moveClass.freteiroId);
    await prefs.setString('nomeFreteiro', moveClass.nomeFreteiro);
    await prefs.setString('dateSelected', moveClass.dateSelected);
    await prefs.setString('timeSelected', moveClass.timeSelected);
    await prefs.setString('userImage', moveClass.userImage);
    await prefs.setString('freteiroImage', moveClass.freteiroImage);
    await prefs.setString('situacao', moveClass.situacao);
    await prefs.setString('userId', moveClass.userId);

  }

  Future<MoveClass> loadMoveClassFromSharedPrefs() async {

    MoveClass moveClass = MoveClass.empty();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String endereco = (prefs.getString('enderecoOrigem').toString());
    if(endereco!= null){ //se for diferente de null é pq tem coisa armazenada
      moveClass.enderecoOrigem = (prefs.getString('enderecoOrigem'));
      moveClass.enderecoDestino = (prefs.getString('enderecoDestino'));
      moveClass.latEnderecoOrigem = (prefs.getDouble('latEnderecoOrigem'));
      moveClass.longEnderecoOrigem = (prefs.getDouble('longEnderecoOrigem'));
      moveClass.latEnderecoDestino = (prefs.getDouble('latEnderecoDestino'));
      moveClass.longEnderecoDestino = (prefs.getDouble('longEnderecoDestino'));
      moveClass.ajudantes = (prefs.getInt('ajudantes'));
      moveClass.carro = (prefs.getString('carro'));
      moveClass.preco = (prefs.getDouble('preco'));
      moveClass.ps = (prefs.getString('ps'));
      moveClass.escada = (prefs.getBool('escada'));
      moveClass.lancesEscada = (prefs.getInt('lancesEscada'));
      moveClass.freteiroId = (prefs.getString('freteiroId'));
      moveClass.nomeFreteiro = (prefs.getString('nomeFreteiro'));
      moveClass.dateSelected = (prefs.getString('dateSelected'));
      moveClass.timeSelected = (prefs.getString('timeSelected'));
      moveClass.userImage = (prefs.getString('userImage'));
      moveClass.freteiroImage = (prefs.getString('freteiroImage'));
      moveClass.situacao = (prefs.getString('situacao'));
      moveClass.userId = (prefs.getString('userId'));
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
      ItemClass itemClass = ItemClass.empty();
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

  Future<void> saveDataFromCustomItemPage(MoveClass moveClass) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('ps', moveClass.ps);
    await prefs.setBool('escada', moveClass.escada);
    await prefs.setInt('lancesEscada', moveClass.lancesEscada);

  }

  Future<void> saveDataFromSelectTruckPage(MoveClass moveClass) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('ajudantes', moveClass.ajudantes);
    await prefs.setString('carro', moveClass.carro);

  }

  Future<void> saveDataFromSelectAddressPage(MoveClass moveClass) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

  }

  Future<void> saveDataFromSelectTruckERPage(MoveClass moveClass) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('freteiroId', moveClass.freteiroId);
    await prefs.setString('freteiroImage', moveClass.freteiroImage);
    await prefs.setString('nomeFreteiro', moveClass.nomeFreteiro);

  }

  Future<void> clearSharedPrefs(MoveClass moveClass) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('enderecoOrigem');
    await prefs.remove('enderecoDestino');
    await prefs.remove('latEnderecoOrigem');
    await prefs.remove('longEnderecoOrigem');
    await prefs.remove('latEnderecoDestino');
    await prefs.remove('longEnderecoDestino');
    await prefs.remove('ajudantes');
    await prefs.remove('carro');
    await prefs.remove('preco');
    await prefs.remove('ps');
    await prefs.remove('escada');
    await prefs.remove('lancesEscada');
    await prefs.remove('freteiroId');
    await prefs.remove('nomeFreteiro');
    await prefs.remove('dateSelected');
    await prefs.remove('timeSelected');
    await prefs.remove('userImage');
    await prefs.remove('freteiroImage');
    await prefs.remove('situacao');


  }

  Future<void> clearSelectedTrucker(MoveClass moveClass) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('freteiroId');
    await prefs.remove('nomeFreteiro');
    await prefs.remove('dateSelected');
    await prefs.remove('timeSelected');
    await prefs.remove('freteiroImage');
    await prefs.remove('situacao');
  }

}