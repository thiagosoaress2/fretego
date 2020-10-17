import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fretego/models/userModel.dart';

class FirestoreServices {

  UserModel userModel;

  final CollectionReference _usersCollectionReference = Firestore.instance.collection("users");

  Future<Null> saveUserData(Map<String, dynamic> userData, FirebaseUser firebaseUser) async {
    await Firestore.instance.collection("users").document(firebaseUser.uid).setData(userData);
  }

  Future loadCurrentUserData(FirebaseUser firebaseUser, FirebaseAuth _auth, UserModel userModel) async {

    if(firebaseUser == null){  //verifica se tem acesso a informação do user
      firebaseUser = await _auth.currentUser(); //se for nulo, vai tentaar pegar
      if (firebaseUser != null){ //verifica novamente
        if(userModel.Uid == ""){
          DocumentSnapshot docUser = await Firestore.instance.collection("users").document(firebaseUser.uid).get();
          //userData = docUser.data;
          userModel.updateUid(firebaseUser.uid);
          userModel.updateEmail(firebaseUser.email);
          userModel.updateFullName(docUser.data['name'].toString());

          print("printing userclass info "+userModel.Uid);

        }
      }
    } else {
      if(userModel.Uid == ""){
        DocumentSnapshot docUser = await Firestore.instance.collection("users").document(firebaseUser.uid).get().then((docUser) {

          userModel.updateUid(firebaseUser.uid);
          userModel.updateEmail(firebaseUser.email);
          userModel.updateFullName(docUser.data['name'].toString());

          print("printing userclass info "+userModel.Uid);
          print("nome do user é "+userModel.FullName);
        });
      }
    }

  }


}
