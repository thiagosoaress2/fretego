import 'package:fretego/classes/move_class.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePageModel extends Model {

  bool _shouldShowGoToMoveBtn=false;
  void updateShouldShowGoToMoveBtn (bool value){
    _shouldShowGoToMoveBtn=value;
    notifyListeners();
  }
  get ShouldShowGoToMoveBtn=>_shouldShowGoToMoveBtn;

  bool _showClassicPage=true;
  void updateShowClassicPage(bool value){
    _showClassicPage = value;
    notifyListeners();
  }

  get ShowClassicPage=>_showClassicPage;

  double _offset = 1.0;
  void updateOffset(double value){
    _offset = value;
    notifyListeners();
  }
  get Offset=>_offset;

  bool _showPayBtn=false;
  void updateShowPayBtn(bool value){
    _showPayBtn=value;
    notifyListeners();
  }
  get ShowPayBtn=>_showPayBtn;

  bool _isLoading=false;
  void setIsLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }
  get IsLoading=>_isLoading;

  String _btnTxt='';
  void updateBtnTxt(String value){
    _btnTxt = value;
    notifyListeners();
  }
  get BtnTxt=>_btnTxt;

  MoveClass moveClass = MoveClass();

  void updateSituationInMoveClass(String value){
    moveClass.situacao = value;
    notifyListeners();
  }

  void updateMoveClass(MoveClass moveClassNew){
    moveClass= moveClassNew;
    notifyListeners();
  }



  //variaveis exclusivas de myMoves
  bool _showResume=false;
  void updateShowResume(bool value){
    _showResume=value;
    notifyListeners();
  }
  get ShowResume=>_showResume;

  bool _showDarkerBackground=false;
  void showDarkBackground (bool value){
    _showDarkerBackground = value;
        notifyListeners();
  }
  get DarkBackground=>_showDarkerBackground;

  bool _showLoadingInitials=false;
  void updateShowLoadingInitial(bool value){
    _showLoadingInitials = value;
    notifyListeners();
  }
  get ShowLoadingInitials=>_showLoadingInitials;

  bool _userIsLoggedIn=false;
  void updateUserIsLoggedIn(bool value){
    _userIsLoggedIn=value;
    notifyListeners();
  }
  get UserIsLoggedIn=>_userIsLoggedIn;

  bool _firstLoad=true;
  void updateFirstLoad(bool value){
    _firstLoad = value;
    notifyListeners();
  }
  get FirstLoad=>_firstLoad;

  bool _firstLoadInHomeMyMove=true;
  void updateFirstLoadInHomeMyMove(bool value){
    _firstLoad = value;
    notifyListeners();
  }
  get FirstLoadInHomeMyMove=>_firstLoadInHomeMyMove;

  bool _showOptions=true;
  void updateShowOptions(bool value){
    _showOptions = value;
    notifyListeners();
  }
  get ShowOptions=>_showOptions;

  bool _shouldForceVerify=false;
  void updateShouldForceVerify(bool value){
    _shouldForceVerify=value;
    notifyListeners();
  }
  get ShouldForceVeriry=>_shouldForceVerify;

}