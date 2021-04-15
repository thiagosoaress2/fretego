
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/services/firestore_services.dart';
import 'package:fretego/utils/shared_prefs_utils.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';


class NewAuthService extends Model {

  FirebaseAuth auth = FirebaseAuth.instance;

  bool _isLoggedIn=false;

  User _user;

  static final FacebookLogin _facebookSignIn = new FacebookLogin();

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
     ).then((_) {
       onSuccess();
       notifyListeners();
     });
   } on FirebaseAuthException catch (e) {
     String erro="Um erro ocorreu";
     if (e.code == 'user-not-found') {
       erro = "Não existe um usuário com este e-mail.";
       _updateErroLoginCode(erro);
     } else if (e.code == 'wrong-password') {
       erro = "Senha incorreta";
       _updateErroLoginCode(erro);
     }
     onFailure();
   }

 }

 String _erroLogin;
 void _updateErroLoginCode(String value){
   _erroLogin=value;
 }
 get ErroLoginCode=>_erroLogin;

 Future<void> SignOut() async {
   await FirebaseAuth.instance.signOut();
   _facebookSignIn.logOut();
   notifyListeners();
 }

 Future<void> recoverPassword(String email, @required VoidCallback onSuccess, @required VoidCallback onFailure()) async {

   await FirebaseAuth.instance.sendPasswordResetEmail(email: email).whenComplete(() {
     onSuccess();
   }).catchError((){
     onFailure();
   });
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
     ).then((_) {
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

  Future<void> SignInWithFacebook(UserModel userModel, @required VoidCallback onSuccess,@required VoidCallback onFailureUserCancel, @required VoidCallback onFailureUnknwon, @required VoidCallback newUser(), @required VoidCallback onFailureInFireBase) async {

    final FacebookLoginResult result = await _facebookSignIn.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;

        print('''
                     Logged in!
                     
                     Token: ${accessToken.token}
                     User id: ${accessToken.userId}
                     Expires: ${accessToken.expires}
                     Permissions: ${accessToken.permissions}
                     Declined permissions: ${accessToken.declinedPermissions}
                     ''');

        //final facebookCred = accessToken.token;
        //final facebookId = accessToken.userId;
        //print('facebookcred ${facebookCred}');
        //print('facebookId ${facebookId}');


        // Create a credential from the access token
        final FacebookAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(result.accessToken.token);

        // Once signed in, return the UserCredential
        await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential).then((_) {

          User user = FirebaseAuth.instance.currentUser;
          FirestoreServices().checkIfTheUserIsCommingBack(user.uid, user.email); //verifica se precisa recriar o bd caso o user tenha apagado
          UserModel().updateUid(user.uid);
          userModel.updateUid(user.uid);
          userModel.updateEmail(user.email);
          onSuccess();
        });

        //codigo para verificar se é user de facebook
        /* este código é pra ser usado em homePage para nao verificar e-mail se for do facebook
                if(newAuthService.isFacebookUser()==true){
                  print('nao precisa checar e-mail');
                } else {
                  print('checar email');
                }

                 */

        /*
                /// we use FacebookAuthProvider class to get a credential from accessToken
                /// this will return an AuthCredential object that we will use to auth in firebase
                AuthCredential credential= FacebookAuthProvider.credential(accessToken.token);
                // this line do auth in firebase with your facebook credential.
                FirebaseAuth.instance.signInWithCredential(credential).then((_) async {
                  FirebaseUser firebaseUser = (await FirebaseAuth.instance.signInWithCredential(credential)).user;
                  print('fez login');
                }).catchError((error) {
                  print('erro');
                });

                 */

        //depois que conseguir o login, usar user.metadata.createtime e lastlogin pra comparar se é um novo user.

        break;
      case FacebookLoginStatus.cancelledByUser:
        onFailureUserCancel();
        break;
      case FacebookLoginStatus.error:
        onFailureUnknwon();
        break;
    }

  }

  //caso o user não exista vai criar a entrada no bd com este método.
  Future<void> CreateNewFacebookUser(UserModel userModel,@required VoidCallback onSuccess, {VoidCallback onFailure}){

    User user = FirebaseAuth.instance.currentUser;
    FirestoreServices().createNewUser(user.displayName, user.email, user.uid);
    UserModel().updateUid(user.uid);
    userModel.updateUid(user.uid);
    userModel.updateEmail(user.email);
    SharedPrefsUtils().saveBasicInfo(userModel);
    onSuccess();
  }

  //depois de chamar o SignInWithFacebook, caso o user já exista vai chamar este método
  Future<void> CompleteFacebookUserSignIn(UserModel userModel, @required VoidCallback onSuccess){

    User user = FirebaseAuth.instance.currentUser;
    UserModel().updateUid(user.uid);
    userModel.updateUid(user.uid);
    userModel.updateEmail(user.email);
    //SharedPrefsUtils().saveBasicInfo(userModel);
    onSuccess();

  }

  bool isFacebookUser(){

    User user = FirebaseAuth.instance.currentUser;
    if(user.providerData[0].providerId.contains('facebook')){
      print('contem');
      return true;
    } else {
      return false;
      print('nao contem');
    }
  }

}