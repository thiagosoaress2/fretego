import 'package:fretego/login/services/new_auth_service.dart';
import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {

  String _uid="";
  String _fullName="";
  String _email="";
  String _userRole="";

  bool _alert=false;

  bool _thisUserHasAMove;

  //UserModel({this.uid, this.fullName, this.email, this.userRole});
  //UserModel();

  void updateUid(String value) {
    _uid = value;
    notifyListeners();
  }

  get Uid=>_uid;

  Future<void> getEmailFromFb() async {
    String mail = await NewAuthService().loadUserMail();
    updateEmail(mail);
  }

  void updateEmail(String value) {
    _email = value;
    notifyListeners();
  }

  get Email=>_email;

  void updateFullName(String value) {
    _fullName = value;
    notifyListeners();
  }

  get FullName=>_fullName;

  void signOutFromClass(){
    _uid="";
    _fullName="";
    _email="";
    _userRole="";
    _thisUserHasAMove=false;
  }

  void updateAlert(bool value) {
    _alert = value;
    notifyListeners();
  }

  get Alert=>_alert;

  void updateThisUserHasAmove(bool value) {
    _thisUserHasAMove = value;
    notifyListeners();
  }

  get ThisUserHasAmove=>_thisUserHasAMove;


  //esta função é para fazer o upload pro firestore em formato json
  Map<String, dynamic> toJson(){
    return {
      'uid': _uid,
      'fullName': _fullName,
      'email' : _email,
      'userRole' : _userRole,
    };

  }

}
