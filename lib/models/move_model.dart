import 'package:flutter/material.dart';
import 'package:fretego/classes/item_class.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/utils/date_utils.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:scoped_model/scoped_model.dart';

class MoveModel extends Model {

  //variaveis que vieram da classe selected_items_chart_model.dart
  ItemClass itemAdded;

  List<ItemClass> itemsSelectedCart =[];
  //fim das variaveis que vieram da classe selected_items_chart_model.dart


  double _offset=0.0;
  bool _canScroll=false;
  int _step = 0;

  int _helpersContracted = 1;

  int _helpersNeeded = 1;

  String _actualPage = 'itens';

  bool _showListAnywhere = false;

  int _qntItens=0;

  String _truckSuggested;

  bool _loadInitialData=true;
  void updateLoadInitialData(bool value){
    _loadInitialData=value;
   // notifyListeners();
  }
  get LoadInitialData=>_loadInitialData;

  bool _isLoadingDatA=false;
  void updateIsLoadingData(bool value){
    _isLoadingDatA = value;
    notifyListeners();
  }
  get IsLoadingData=>_isLoadingDatA;

  void updateQntItens(int value){
    _qntItens = value;
    notifyListeners();
  }
  get QntItens=>_qntItens;

  bool _needFirstLoad=true;
  void updateNeedFirstLoad(bool value){
    _needFirstLoad = value;
    notifyListeners();
  }
  get NeedFirstLoad=>_needFirstLoad;

  String _appBarTextBack='Início';
  String _appBarTitleText='Itens Grandes';

  MoveClass moveClass = MoveClass();

  void updateCarInMoveClass(String value){
    moveClass.carro = value;
    updateTruckSuggested(value);
    notifyListeners();
  }

  void updateMoveClass(MoveClass _moveClass){
    moveClass=_moveClass;
    notifyListeners();
  }

  get carInMoveClass => moveClass.carro;

  void updateAjudantes(int value){
    moveClass.ajudantes = value;
    SharedPrefsUtils().saveAjudantesInShared(value); //para ler isto do shared pegar direto no sharedprefsutils método etAjudantesFromShared
    notifyListeners();
  }

  get ajudantesInMoveclass => moveClass.ajudantes;

  void updateLancesEscada(int value){
    moveClass.lancesEscada = value;
    SharedPrefsUtils().saveLancesDeEscadasInShared(value);
    notifyListeners();
  }

  get lancesDeEscadasInMoveclass => moveClass.lancesEscada;


  void updateHelpersNeeded(int value){
    _helpersNeeded = value;
    notifyListeners();
  }

  get HelpersNeeded => _helpersNeeded;



  void updateHelpers(int value) {
    _helpersContracted = value;
    notifyListeners();
  }



  void updateOffset(double value) {
    _offset = value;
    notifyListeners();
  }

  get Offset=>_offset;

  void updateCanScroll(bool value) {
    _canScroll = value;
    notifyListeners();
  }

  get CanScroll=>_canScroll;

  void updateActualPage(String value) {
    _actualPage = value;
    notifyListeners();
  }

  get ActualPage=>_actualPage;

  void updateShowListAnywhere(bool value) {
    _showListAnywhere = value;
    notifyListeners();
  }

  get ShowListAnywhere=>_showListAnywhere;


  void updateAppBarText(String backtext, String title) {
    _appBarTextBack = backtext;
    _appBarTitleText = title;
    notifyListeners();
  }

  get AppBarTextBack=>_appBarTextBack;
  get AppBarTextTitle=>_appBarTitleText;

  void changePageForward(String newPage, String backText, String titleText){

    _actualPage = newPage;
    _appBarTitleText = titleText;
    _appBarTextBack = backText;
    notifyListeners();

  }

  void changePageBackward(String newPage, String backText, String titleText){

      _actualPage = newPage;
      _appBarTitleText = titleText;
      _appBarTextBack = backText;
      notifyListeners();

  }

  void prepareAnim(bool isForward, double widthPercent){

    if(isForward==true) {
      double offsetAcrescim = widthPercent * 0.20;
      _canScroll = true;
      _offset = _offset + offsetAcrescim;
      notifyListeners();
    } else {
      double offsetAcrescim=widthPercent*0.19; //n é igual para corrigir
      _canScroll = true;
      _offset<0.1 ? 0.0 : _offset=_offset-offsetAcrescim;
      notifyListeners();
    }

  }

  void finishAnim(bool isForward){
    if(isForward==true){
      _canScroll=false;
      _step=_step+1;
      notifyListeners();
    } else{
      _canScroll=false;
      if(_step!=0){
        _step=_step-1;
      }
      notifyListeners();
    }

  }

  get Step=> _step;


  bool _page1IsOk=false;
  void updatePage1IsOk(bool value){
    _page1IsOk = value;
    notifyListeners();
  }
  get Page1isOk => _page1IsOk;












//funções que vieram da classe selected_items_chart_model.dart

  void updateItemsSelectedCartList(List<ItemClass> newList){
    itemsSelectedCart = newList;
    notifyListeners();
  }

  void addItemToChart (ItemClass itemClass){
    itemsSelectedCart.add(itemClass);
  }

  void removeItemFromChart(ItemClass itemClass){
    int cont=0;
    while(cont<itemsSelectedCart.length){
      if(itemsSelectedCart[cont].name==itemClass.name){
        itemsSelectedCart.removeAt(cont);
        cont = itemsSelectedCart.length;
      } else {
        cont++;
      }

    }
  }

  get getList => itemsSelectedCart;

  int getItemsChartSize(){
    return itemsSelectedCart.length;
  }

  void clearChart(){
    itemsSelectedCart = [];
    notifyListeners();
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
//fim das funções que vieram da classe selected_items_chart_model.dart





    //parte da página de add endereço
  bool _searchCep=false;
  String _origemAddressVerified='';
  String _destinyAddressVerified='';
  bool _isLoading=false;
  bool _addressIsAllOk=false;
  double _distance=0.0;
  double _finalGasCosts=0.0;
  double _custoAjudantes=0.0;
  double _totalExtraProducts=0.0;
  double _precoMudanca=0.0;
  bool _showResume=false;

  void updateShowResume(bool value){
    _showResume = value;
    notifyListeners();
  }
  get ShowResume => _showResume;

  void updatePrecoMudanca(double value){
    _precoMudanca = value;
    moveClass.preco = value;
    notifyListeners();
  }
  get PrecoMudanca => _precoMudanca;

  void updateTotalExtraProducts(double value){
    _totalExtraProducts = value;
    notifyListeners();
  }
  get TotalExtraProducts => _totalExtraProducts;

  void updateCustoAjudantes(double value){
    _custoAjudantes = value;
    notifyListeners();
  }
  get CustoAjudantes => _custoAjudantes;

  void updateGasCosts(double value){
    _finalGasCosts=value;
    notifyListeners();
  }
  get GasCosts => _finalGasCosts;

  void updateDistance(double value){
    _distance = value;
    notifyListeners();
  }

  get Distance => _distance;

  void updateAdressIsAllOk(){
    _addressIsAllOk = true;
    notifyListeners();
  }

  get AddressIsAllOk => _addressIsAllOk;

  void updateSearchCep(bool value){
    _searchCep = value;
    notifyListeners();
  }

  get SearchCep => _searchCep;

  void updateOrigemAddressVerified(String value){
    _origemAddressVerified = value;
    notifyListeners();
  }

  get OrigemAddress => _origemAddressVerified;

  void updateDestinyAddressVerified(String value){
    _destinyAddressVerified = value;
    notifyListeners();
  }

  get DestinyAddress => _destinyAddressVerified;

  void setIsLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }

  get isLoading => _isLoading;



  //variaveis de pagina de escolher motorista
  bool _showPopup=false;
  Map<String, dynamic> _map;

  void updateShowPopup(bool value){
    _showPopup = value;
    notifyListeners();
  }
  get ShowPopup=>_showPopup;




  //variaveis da pagina horario e data
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedtime = TimeOfDay.now();

  bool dataIsOk=false;
  bool horaIsOk=false;

  void updateDataIsOk(bool value){
    dataIsOk=value;
    notifyListeners();
  }

  void updateHoraIsOk(bool value){
    horaIsOk=value;
    notifyListeners();
  }

  void updateselectedDate(DateTime value){
    _selectedDate = value;
    notifyListeners();
    checkIfDataIsOk(); //verifica se a data é aceitavel
  }
  get SelectedDate=>_selectedDate;

  void updateSelectedTime(TimeOfDay value){
    _selectedtime = value;
    notifyListeners();
    checkIfDataIsOk(); //verifica se a data é aceitavel
  }
  get SelectedTime=>_selectedtime;

  bool _specialConditionChangingTrucker=false;
  void updateSpecialCondition(bool value){
    _specialConditionChangingTrucker=value;
    notifyListeners();
  }
  get SpecialCondition=>_specialConditionChangingTrucker;

  bool _theDataIsOk=false;
  void checkIfDataIsOk(){
    String time = _selectedtime.hour.toString()+':'+_selectedtime.minute.toString();
    DateTime choosenDate = DateServices().addMinutesAndHoursFromStringToAdate(_selectedDate, time);
    final difference = choosenDate.difference(DateTime.now()).inMinutes;
    if(difference<=0){
      //menor
      //choosen date é menor e nao pode fazer mudança
      _theDataIsOk=false;
      notifyListeners();
    } else {
      _theDataIsOk=true;
      notifyListeners();
    }
  }
  get TheDataIsOk=>_theDataIsOk;

  bool _showAdditionalInfoToCEP=false; //controla se vai exibir a popup para pegar número e complemento pro endereço vindo do CEP
  void updateShowAddiotionalInfoToCEP(bool value){
    _showAdditionalInfoToCEP = value;
    notifyListeners();
  }
  get showAdditionalInfoToCEP=>_showAdditionalInfoToCEP;

  bool _helpIsOnScreen=false;
  void updateHelpIsOnScreen(bool value){
    _helpIsOnScreen = value;
    notifyListeners();
  }
  get HelpIsOnScreen=>_helpIsOnScreen;

  void updateTruckSuggested(String value){
    _truckSuggested = value;
  }

  get TruckSuggested=>_truckSuggested;


  bool _itsCalculating=false;
  void updateItsCalculating(bool value){

    _itsCalculating = value;
    notifyListeners();
  }

  get ItsCalculating=>_itsCalculating;



}