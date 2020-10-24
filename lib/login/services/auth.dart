import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/services/firestore_services.dart';

/*
class AuthService {


  FirebaseAuth _auth;
  Map<String, dynamic> userData = Map();

  AuthService(this._auth);

  FirebaseUser signUp(@required Map<String, dynamic> userData, @required String password, UserModel userModel,  @required VoidCallback onSuccess, @required VoidCallback onFailure){

    _auth.createUserWithEmailAndPassword(email: userData["email"], password: password).then((user) async {
      FirebaseUser firebaseUser = user;

      await FirestoreServices().saveUserData(userData, firebaseUser);

      try {
        await firebaseUser.sendEmailVerification();
      } catch (e) {
        print("An error occured while trying to send email verification");
        print(e.message);
      }

      onSuccess();
      return firebaseUser;
    }).catchError((error){
      onFailure();
      return null;
    });
  }

  FirebaseUser signIn(@required String email, String password, UserModel userModel,  @required VoidCallback onSuccess, @required VoidCallback onFailure){

    _auth.signInWithEmailAndPassword(email: email, password: password).then((user) async {
      FirebaseUser firebaseUser = user;

      await FirestoreServices().loadCurrentUserData(firebaseUser, _auth, userModel);
      onSuccess();
      return firebaseUser;
    }).catchError((error){
      onFailure();
      return null;
    });
  }

  Future<FirebaseUser> isLoggedIn () async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    return firebaseUser;
  }

  void signOut(UserModel userModel) async{
    await _auth.signOut();

    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    firebaseUser = null;
    userModel.updateUid("");
    userModel.updateEmail("");
    userModel.updateFullName("");
  }

  void updateUserInfo(UserModel userModel) async {
    var _uid = userModel.Uid;
    if(_uid !=""){
      //ja foram carregados os dados.
      print("valor uid é "+userModel.Uid);
    } else {
      //precisamos carregar os dados do user. Inicialmente pegamos do firestore...depois talvez pegaremos do sharedprefs
      FirebaseUser firebaseUser = await _auth.currentUser();
      FirestoreServices().loadCurrentUserData(firebaseUser, _auth, userModel);
    }
  }

  Future<bool> checkEmailVerify(FirebaseUser firebaseUser) async {
    await firebaseUser.reload();
    if(firebaseUser.isEmailVerified == true){
      return true;
    } else {
      return false;
    }
  }

}


 */