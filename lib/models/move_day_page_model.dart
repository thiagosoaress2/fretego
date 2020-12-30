import 'package:fretego/classes/trucker_movement_class.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

class MoveDayPageModel extends Model {

  LatLng _origemPos;
  LatLng _destinyPos;
  LatLng _truckerLocationLatLng;
  bool _showAlertFinishMove=false;
  bool _showMessageThatTruckerFinishedTheMove=false;
  bool _showProblemInformPage=false;
  String _problem;
  String _phone;
  bool _showWhatsappBtn=false;
  bool _isLoadingInitialData=true;
  bool _initialDataIsLoaded=false;
  LatLng _userLocationLatLng;
  bool _showCompleteInfo=false;
  String _truckerImage;
  String _truckerCarImage;
  bool _showMoveIsFinished=false;

  void updateShowMoveIsFinished(bool value){
    _showMoveIsFinished = value;
    notifyListeners();
  }
  get ShowMoveIsFinished=>_showMoveIsFinished;

  void updateTruckerImage(String value){
    _truckerImage = value;
    notifyListeners();
  }
  get TruckerImage => _truckerImage;

  void updateTruckerCarImage(String value){
    _truckerCarImage = value;
    notifyListeners();
  }
  get TruckerCarImage => _truckerCarImage;

  void updateShowCompleteInfo(){
    _showCompleteInfo=!_showCompleteInfo;
    notifyListeners();
  }

  get ShowCompleteInfo=>_showCompleteInfo;

  void updateUserLocationLatLng(LatLng value){
    _userLocationLatLng = value;
    notifyListeners();
  }
  get UserLocationLatLng => _userLocationLatLng;

  void updateInitialDataIsLoaded(bool value){
    _initialDataIsLoaded=value;
    notifyListeners();
  }

  get InitialDataIsLoaded=>_initialDataIsLoaded;

  TruckerMovementClass truckerMovementClass = TruckerMovementClass();

  LatLng initialcameraposition;

  void updateOrigemPos(LatLng value){
    _origemPos = value;
    notifyListeners();
  }
  get OrigemPos=>_origemPos;


  void updateDestinyPos(LatLng value){
    _destinyPos = value;
    notifyListeners();
  }

  get DestinyPos=>_destinyPos;

  void updateTruckerLocationLatLng(LatLng value){
    _truckerLocationLatLng = value;
    notifyListeners();
  }

  get TruckerLocationLatLng=>_truckerLocationLatLng;


  void updateShowAlertFinishMove(bool value){
    _showAlertFinishMove = value;
    notifyListeners();
  }

  get ShowAlertFinishMove=>_showAlertFinishMove;

  void updateShowMessageThatTruckerFinishedTheMove(bool value){
    _showMessageThatTruckerFinishedTheMove = value;
    notifyListeners();
  }

  get ShowMessageThatTruckerFinishedTheMove=>_showMessageThatTruckerFinishedTheMove;

  bool _showMessageThatTruckerIsCommingBack=false;
  void updateShowMessageThatTruckerIsCommingBack(bool value){
    _showMessageThatTruckerIsCommingBack = value;
    notifyListeners();
  }

  get ShowMessageThatTruckerIsCommingBack=>_showMessageThatTruckerIsCommingBack;


  void updateShowProblemInformPage(bool value){
    _showProblemInformPage = value;
    notifyListeners();
  }

  get ShowProblemInformPage=>_showProblemInformPage;

  void updateShowWhatsappBtn(bool value){
    _showWhatsappBtn = value;
    notifyListeners();
  }

  get ShowWhatsappBtn=>_showWhatsappBtn;


  void updatePhone(String value){
    _phone = value;
    notifyListeners();
  }
  get Phone=>_phone;

  void updateProblem(String value){
    _problem = value;
    notifyListeners();
  }
  get Problem=>_problem;


  void updateIsLoadingInitialData(bool value){
    _isLoadingInitialData=value;
    notifyListeners();
  }
  get IsLoadingInitialData=>_isLoadingInitialData;


  void manuallyNotifyListeners(){
    notifyListeners();
  }

}