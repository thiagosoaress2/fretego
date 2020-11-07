import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  final String agendamentosPath = "agendamentos_aguardando";

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

    CollectionReference schedule = FirebaseFirestore.instance.collection(agendamentosPath);

    String escadaFinal = "nao";
    int lancesEscadaFinal = 0;
    if(moveClass.escada!=null){
      escadaFinal = "sim";
      lancesEscadaFinal = moveClass.lancesEscada;
    }

    bool escada;
    if(escadaFinal=='sim'){
      escada=true;
    } else {
      escada = false;
    }

    //obs: O id do pedido é o mesmo do user já que cada user só pode ter um ativo por vez
    return schedule.doc(moveClass.userId)
        .set({

      'endereco_origem': moveClass.enderecoOrigem,
      'endereco_destino' : moveClass.enderecoDestino,
      'ps' : moveClass.ps,
      'carro' : moveClass.carro,
      'ajudantes' : moveClass.ajudantes,
      'escada' : escada,
      'moveId' : moveClass.userId,
      'lances_escada' : lancesEscadaFinal,
      'id_freteiro' : moveClass.freteiroId,
      'valor' : moveClass.preco,
      'id_contratante' : moveClass.userId,
      'selectedDate' : moveClass.dateSelected,
      'selectedTime' : moveClass.timeSelected,
      'nome_freteiro' : moveClass.nomeFreteiro,
      'situacao' : "aguardando",
      'alert' : 'trucker',
      'alert_saw' : false,
    })
        .then((value) => onSuccess())
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

  Future<MoveClass> loadScheduledMoveInFb(MoveClass moveClass, UserModel userModel, [VoidCallback onSucess]) async {

    MoveClass moveClassUpdated;

    await FirebaseFirestore.instance.collection(agendamentosPath).doc(userModel.Uid).get().then((querySnapshot) {

      moveClass.enderecoOrigem = querySnapshot['endereco_origem'];
      moveClass.enderecoDestino = querySnapshot['endereco_destino'];
      moveClass.ajudantes = querySnapshot['ajudantes'];
      moveClass.carro = querySnapshot['carro'];
      moveClass.escada = querySnapshot['escada'] ?? false;
      moveClass.lancesEscada = querySnapshot['lances_escada'] ?? 0;
      moveClass.userId = userModel.Uid;
      moveClass.freteiroId = querySnapshot['id_freteiro'];
      moveClass.nomeFreteiro = querySnapshot['nome_freteiro'];
      moveClass.situacao = querySnapshot['situacao'];
      moveClass.ps = querySnapshot['ps'];
      moveClass.dateSelected = querySnapshot['selectedDate'];
      moveClass.timeSelected = querySnapshot['selectedTime'];
      moveClass.preco = querySnapshot['valor'];
      moveClass.moveId = querySnapshot['moveId'];
      moveClass.alert = querySnapshot['alert'];
      moveClass.alertSaw = querySnapshot['alert_saw'];
      moveClassUpdated = moveClass;
      onSucess();
    });

    return moveClassUpdated;
  }

  Future<void> deleteAscheduledMove(MoveClass moveClass, [@required VoidCallback onSuccess, @required VoidCallback onFailure]){
    CollectionReference move = FirebaseFirestore.instance.collection(agendamentosPath);
    move.doc(moveClass.userId)
    .delete()
    .then((value) => onSuccess()).catchError((onError)=> onFailure());
  }

  Future<void> checkIfExistsAmoveScheduled(id, @required VoidCallback onSuccess, @required VoidCallback onFailure) async {

    await FirebaseFirestore.instance.collection(agendamentosPath).doc(id).get().then((querySnapshot) {

      if(querySnapshot.data().isNotEmpty) {
        onSuccess();
      } else {
        onFailure();
      }
    });
  }

  Future<void> checkIfThereIsAlert(id, @required VoidCallback onSuccess) async {

    await FirebaseFirestore.instance.collection(agendamentosPath).doc(id).get().then((querySnapshot) {

      if(querySnapshot['alert'].toString().contains("user") && querySnapshot['alert_saw'] == false){
          onSuccess();
      }

    });
  }

  Future<void> changeTrucker(id, @required VoidCallback onSucess, @required VoidCallback onFailure) async {

    CollectionReference move = FirebaseFirestore.instance.collection(agendamentosPath);
    return move.doc(id)
        .update({

      'situacao': 'sem motorista',
      'nome_freteiro' : null,
      'id_freteiro': null,

    })
        .then((value) => onSucess())
        .catchError((error) => onFailure());

  }

  Future<void> updateAlertView(id){

    CollectionReference alert = FirebaseFirestore.instance.collection(agendamentosPath);
    return alert
        .doc(id)
        .update({
      'alert_saw' : "true",
    });

  }

  Future<void> alertSetTruckerAlert(id){
    CollectionReference alert = FirebaseFirestore.instance.collection(agendamentosPath);
    return alert
        .doc(id)
        .update({
      'alert_saw' : "false",
      'alert' : 'trucker',
    });
  }


}

