import 'package:scoped_model/scoped_model.dart';

class AdressAddModel extends Model {

  bool _searchCep=false;
  String _origemAddressVerified;
  String _destinyAddressVerified;
  bool _isLoading=false;

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

}