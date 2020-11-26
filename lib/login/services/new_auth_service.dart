
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:scoped_model/scoped_model.dart';

class NewAuthService extends Model {

  FirebaseAuth auth = FirebaseAuth.instance;

  bool _isLoggedIn=false;

  User _user;

 void updateAuthStatus(bool status){
   _isLoggedIn = status;
   notifyListeners();
 }

  get AuthStatus=>_isLoggedIn;

 Future<void> SignInWithEmailAndPassword(String email, String password, @required VoidCallback onSuccess, @required VoidCallback onFailure()) async {

   try {
     UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
         email: email,
         password: password
     ).whenComplete(() {
       onSuccess();
       notifyListeners();
     });
   } on FirebaseAuthException catch (e) {
     String erro="Um erro ocorreu";
     if (e.code == 'user-not-found') {
       erro = "Não existe um usuário com este e-mail.";
     } else if (e.code == 'wrong-password') {
       erro = "Senha errada";
     }
     onFailure();
   }

 }

 Future<void> SignOut() async {
   await FirebaseAuth.instance.signOut();
   notifyListeners();
 }

 void loadUser(){
   _user = FirebaseAuth.instance.currentUser;
   _user.reload();
 }
 get getFirebaseUser => _user;

 bool isUserEmailVerified(){

   if(_user.emailVerified==true){
     return true;
   } else {
     return false;
   }

 }

 Future<void> sendUserVerifyMail() async {
   if(!_user.emailVerified){
     await _user.sendEmailVerification();
   }
  notifyListeners();
 }

 Future<void> SignUpNewUserWithEmailAndPassword(UserModel userModel, String name, String email, String password, @required VoidCallback onSuccess, @required VoidCallback onFailure()) async {
   try {
     UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
         email: email,
         password: password
     ).whenComplete(() {
        User user = FirebaseAuth.instance.currentUser;
        user.sendEmailVerification();
        //obs: Abaixo falta a parte do firestore que ainda n fiz
       //await FirestoreServices().saveUserData(userData, firebaseUser);
        FirestoreServices().createNewUser(name, email, user.uid);
        onSuccess();
     });
   } on FirebaseAuthException catch (e) {
     onFailure();
     notifyListeners();
     if (e.code == 'weak-password') {
       print('The password provided is too weak.');
     } else if (e.code == 'email-already-in-use') {
       print('The account already exists for that email.');
     }
   } catch (e) {
     print(e);
   }
 }

  void checkFBconnection() async {
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User user) {
      if (user == null) {

        updateAuthStatus(false);

      } else {

        updateAuthStatus(true);
        //userIsLoggedIn = true;


      }
    });
  }

  void loadUserBasicDataInSharedPrefs(UserModel userModel){
    _user = FirebaseAuth.instance.currentUser;
    _user.reload();
    userModel.updateUid(_user.uid);
    userModel.updateEmail(_user.email);
    SharedPrefsUtils().saveBasicInfo(userModel);
    notifyListeners();
  }

  String loadUserMail(){
    _user = FirebaseAuth.instance.currentUser;
    return _user.email;
  }

}