import 'package:fretego/classes/item_class.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/models/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtils {


  Future<bool> thereIsBasicInfoSavedInShared() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = 'nao';
    uid = (prefs.getString('uid'));
    if(uid==null){
      return false;
    } else {
      return true;
    }

  }

  Future<void> saveBasicInfo(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('uid', userModel.Uid);
    await prefs.setString('email', userModel.Email);

  }

  Future<UserModel> loadBasicInfoFromSharedPrefs() async {
    //MoveClass moveClass = MoveClass.empty();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserModel userModel;

    String value = (prefs.getString('uid').toString());
    userModel.updateUid(value);
    value = (prefs.getString('email').toString());
    userModel.updateEmail(value);

    return userModel;

  }

  Future<bool> checkIfExistsMoreInfos() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = 'nao';
    name = (prefs.getString('name'));
    if(name==null){
      return false;
    } else {
      return true;
    }

  }

  Future<void> saveMoreInfos(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', userModel.FullName);
  }

  Future<String> loadMoreInfoInSharedPrefs() async {
    //MoveClass moveClass = MoveClass.empty();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    //UserModel userModel;

    String value = (prefs.getString('name').toString());
    //userModel.updateFullName(value);
    return value;

    //return userModel;

  }



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

  Future<MoveClass> loadMoveClassFromSharedPrefs(MoveClass moveClass) async {
    //MoveClass moveClass = MoveClass.empty();

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
  Future<void> saveListOfItemsInShared([List<ItemClass> itemsSelectedCart]) async {

    giveMeTheSizeOfTheListInShared().then((value) async {

      int _newValue=0;
      if(value!=null){
        _newValue=value;
      }
      //value é o tamanho da lista
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int _cont=0;

      while(_cont<itemsSelectedCart.length){  //o cont vai servir para contar quantas vezes precisa passar para salvar os novos dados.
        int internalCont=_cont+_newValue; //digamos que cont seja 0 e a lista seja de tamanho 1. Mas já existam 2 itens salvos anteriormente.
        // Então cont=0 < lista.lenght. Então ele entra. Mas o index para salvar será internalCont = 2(itens ja salvos)+cont

        await prefs.setString('item_name'+internalCont.toString(), itemsSelectedCart[_cont].name);
        //await prefs.setString('item_image'+cont.toString(), itemsSelectedCart[cont].image);
        await prefs.setBool('item_single_person'+internalCont.toString(), itemsSelectedCart[_cont].singlePerson);
        await prefs.setDouble('item_volume'+internalCont.toString(), itemsSelectedCart[_cont].volume);
        await prefs.setDouble('item_weight'+internalCont.toString(), itemsSelectedCart[_cont].weight);
        _cont++;
        internalCont = _newValue+_cont; //pega valor atualizado
        await prefs.setInt('item_list_size', internalCont);  //utilizar isto para saber o tamanho da lista


        /* codigo original
        await prefs.setString('item_name'+cont.toString(), itemsSelectedCart[cont].name);
        //await prefs.setString('item_image'+cont.toString(), itemsSelectedCart[cont].image);
        await prefs.setBool('item_single_person'+cont.toString(), itemsSelectedCart[cont].singlePerson);
        await prefs.setDouble('item_volume'+cont.toString(), itemsSelectedCart[cont].volume);
        await prefs.setDouble('item_weight'+cont.toString(), itemsSelectedCart[cont].weight);
        cont++;
        await prefs.setInt('item_list_size', cont);  //utilizar isto para saber o tamanho da lista

         */


        /*
        exemplo
        value (tamanho original da lista) = 3
        cont=0;
        listSize=2;
        enquanto cont(0)<listSize(2) faça
          //o que já existe na lista
          //item_name0
          //item_name1
          //item_name2
          //preciso salvar como 3 então
          internalCont=value(3)+cont(0);
          set item_name+internalCont;
          cont++;
          set item_list_size=value(3)+cont(1); (item_list_size agora é 4);

          //rodada 2
          //agora a lsita
          //item_name0
          //item_name1
          //item_name2
          //item_name3 (o ultimo salvo)
          internalCont=value(3)+cont(1);
          set item_name+internalCont; (item_name4)
          cont++;
          set item_list_size=value(3)+cont(1); (item_list_size agora é 5);

         */

      }
    });

  }

  //obs: Este método precisa ser chamado antes de apagar a lista
  Future<void> clearListInShared(int size) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int cont=0;
    while(cont<size){
      await prefs.remove('item_name'+cont.toString());
      await prefs.remove('item_image'+cont.toString());
      await prefs.remove('item_single_person'+cont.toString());
      await prefs.remove('item_volume'+cont.toString());
      await prefs.remove('item_weight'+cont.toString());
      await prefs.remove('item_list_size');
      cont++;
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

  Future<int> giveMeTheSizeOfTheListInShared() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('item_list_size'));
    return counter;

  }

  //esta funçao está ultrapassada e foi substituida pela abaixo. Agora busca as infos direto na classe.
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

  Future<MoveClass> loadListOfItemsInSharedToMoveClass(MoveClass moveClass) async {

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

    moveClass.itemsSelectedCart=itemsSelectedCart;
    //return itemsSelectedCart;
    return moveClass;

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

  Future<void> saveAjudantesInShared(int n) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ajudantes', n);
  }

  Future<int> getAjudantesFromShared() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int n = prefs.getInt('ajudantes');
    return n;
  }

  Future<void> saveLancesDeEscadasInShared(int n) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lancesEscada', n);
  }

  Future<int> getLancesDeEscadaFromShared() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int n = prefs.getInt('lancesEscada');
    return n;
  }

  Future<void> savePsInShared(String value) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ps', value);
  }

  Future<String> getPsFromShared() async {

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String n = prefs.getString('ps');
  return n;
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

  Future<void> clearScheduledMove() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('freteiroId');
    await prefs.remove('nomeFreteiro');
    await prefs.remove('dateSelected');
    await prefs.remove('timeSelected');
    await prefs.remove('freteiroImage');
    await prefs.remove('situacao');
  }

  Future<bool> checkIfThereIsScheduledMove() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String sit = (prefs.getString('situacao')) ?? 'nao';  //?? significa que vai assignar 2 se for null
    if(sit=='nao'){
      return false;
    } else {
      return true;
    }

  }

  Future<bool> checkMoveSituation() async {

  }

  Future<bool> checkIfThereIsNeedNewTrucker() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String sit = (prefs.getString('situacao')) ?? 'nao';  //?? significa que vai assignar 2 se for null
    if(sit=='sem motorista'){
      return true;
    } else {
      return false;
    }

  }

  Future<void> updateSituation(String str) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(str=="sem motorista"){
      await prefs.setString('situacao', str);
      await prefs.remove('freteiroId');
      await prefs.remove('nomeFreteiro');
      await prefs.remove('dateSelected');
      await prefs.remove('timeSelected');
      await prefs.remove('freteiroImage');
    }

  }

  Future<void> clearEntireList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }



}