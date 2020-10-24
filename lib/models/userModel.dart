import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {

  String _uid="";
  String _fullName="";
  String _email="";
  String _userRole="";

  //UserModel({this.uid, this.fullName, this.email, this.userRole});
  //UserModel();

  void updateUid(String value) {
    _uid = value;
    notifyListeners();
  }

  get Uid=>_uid;

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
  }


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
