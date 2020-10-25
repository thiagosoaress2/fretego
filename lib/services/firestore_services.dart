import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/models/selected_items_chart_model.dart';
import 'package:fretego/models/userModel.dart';

/*
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


 */

class FirestoreServices {

  UserModel userModel;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createNewUser(String name, String email, String uid) {
    // Call the user's CollectionReference to add a new user
    CollectionReference users = FirebaseFirestore.instance.collection('users');

      return users
          .doc(uid)
          .set({
        'name': name,
        'email': email
      })
          .then((value) {
            userModel.updateFullName(name);
            print('user added');
      })
          .catchError((error) => print("Failed to add user: $error"));

  }

    /*
        .add({
      'name' : name,
      'email' : email
    })
        .then((value) {
          UserModel().updateFullName(name);
          print("user Added");
    })
        .catchError((error) => print("Failed to add user: $error"));
  }

     */


  void getUserInfoFromCloudFirestore(UserModel userModel){

    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel.Uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        userModel.updateFullName(documentSnapshot['name']);
      }
    });

  }

  Future<double> loadCommoditiesAjudanteFromDb()async{

    double value=0.0;

    FirebaseFirestore.instance
        .collection('infos')
        .doc('ajudantes')
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        value = documentSnapshot['preco'].toDouble();
        return value.toDouble();
      }
    });


    /*
    final String _collection = 'infos';
    final FirebaseFirestore _fireStore = Firestore.instance;
    _fireStore.collection(_collection).getDocuments().then((value) {

      if(value.documents.length > 0){
        precoCadaAjudante =  value.documents[0].data['preco'].toDouble();
        print(precoCadaAjudante);
        precoBaseFreteiro = value.documents[1].data['preco'].toDouble();
        print(precoBaseFreteiro);
        precoGasolina = value.documents[2].data['preco'].toDouble();
        print(precoGasolina);



      } else {
        print("dados não encontrados");
      }

    });
     */

  }

  Future<double> loadCommoditiesFreteiroFromDb() async {

    double value=0.0;

    FirebaseFirestore.instance
        .collection('infos')
        .doc('freteiro')
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        value = documentSnapshot['preco'].toDouble();
        return value;
      }
    });


  }

  Future<double> loadCommoditiesGasolinaFromDb() async {

    double value=0.0;

    FirebaseFirestore.instance
        .collection('infos')
        .doc('gasolina')
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        value = documentSnapshot['preco'].toDouble();
        return value;
      }
    });


  }

  Future<void> scheduleAmoveInBd(MoveClass moveClass, @required VoidCallback onSuccess, @required VoidCallback onFailure){

    CollectionReference schedule = FirebaseFirestore.instance.collection('agendamentos_aguardando');

    String escadaFinal = "nao";
    int lancesEscadaFinal = 0;
    if(moveClass.escada!=null){
      escadaFinal = "sim";
      lancesEscadaFinal = moveClass.lancesEscada;
    }

    //obs: O id do pedido é o mesmo do user já que cada user só pode ter um ativo por vez
    return schedule.doc(moveClass.userId)
        .set({

      'endereco_origem': moveClass.enderecoOrigem,
      'endereco_destino' : moveClass.enderecoDestino,
      'ps' : moveClass.ps,
      'carro' : moveClass.carro,
      'ajudantes' : moveClass.ajudantes,
      'escada' : escadaFinal,
      'lances_escada' : lancesEscadaFinal,
      'id_freteiro' : moveClass.freteiroId,
      'valor' : moveClass.preco,
      'id_contratante' : moveClass.userId,
      'selectedDate' : moveClass.dateSelected,
      'selectedTime' : moveClass.timeSelected,
      'nome_freteiro' : moveClass.nomeFreteiro,
      'moveId' : schedule.id.toString(),
    })
        .then((value) => onSuccess())
        .whenComplete(() {
          //schedule.id
        })
        .catchError((error) => onFailure());

    /*
    return schedule
        .add({

          'endereco_origem': moveClass.enderecoOrigem,
          'endereco_destino' : moveClass.enderecoDestino,
          'ps' : moveClass.ps,
          'carro' : moveClass.carro,
          'ajudantes' : moveClass.ajudantes,
          'escada' : escadaFinal,
          'lances_escada' : lancesEscadaFinal,
          'id_freteiro' : moveClass.freteiroId,
          'valor' : moveClass.preco,
          'id_contratante' : moveClass.userId,
          'selectedDate' : moveClass.dateSelected,
          'selectedTime' : moveClass.timeSelected,
            'nome_freteiro' : moveClass.nomeFreteiro,
    })
        .then((value) => onSuccess())
        .catchError((error) => onFailure());

     */
  }

  Future<void> deleteAscheduledMove(MoveClass moveClass, @required VoidCallback onSuccess, @required VoidCallback onFailure){
    CollectionReference move = FirebaseFirestore.instance.collection('agendamentos_aguardando');
    move.doc(moveClass.userId)
    .delete()
    .then((value) => onSuccess()).catchError((onError)=> onFailure());
  }

}

