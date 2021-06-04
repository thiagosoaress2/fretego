import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fretego/classes/avaliation_class.dart';
import 'package:fretego/classes/bank_data_class.dart';
import 'package:fretego/classes/move_class.dart';
import 'package:fretego/classes/trucker_class.dart';
import 'package:fretego/classes/trucker_movement_class.dart';
import 'package:fretego/models/home_page_model.dart';
import 'package:fretego/models/move_model.dart';
import 'package:fretego/models/selected_items_chart_model.dart';
import 'package:fretego/models/userModel.dart';
import 'package:fretego/pages/move_schadule_internals_page/page2_obs.dart';
import 'package:fretego/utils/date_utils.dart';
import 'package:fretego/utils/globals_strings.dart';


class FirestoreServices {

  UserModel userModel;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final String agendamentosPath = "agendamentos_aguardando";
  static final String userPath = 'users';
  static final String truckerCancelmentNotify = 'notificacoes_cancelamento';
  static final String ordersPath = 'orders';
  static final String truckerAdvice = 'truckers_advice';
  static final String avaliationPath = 'truckers';
  static final String userMoveHistory = 'historico';
  static final String reembolsoPath = 'reembolso';
  static final String punishmentPath = 'freteiros_em_punicao';
  static final String historicPathUsers = 'historico_mudancas_users';
  static final String historicPathTrucker = 'historico_mudancas_truckers';
  static final String reembolsoPathUsers = 'reembolso_usuarios';
  static final String reembolsoPathTrucker = 'reembolso_freteiros';
  static final String locationPath = 'location';
  static final String truckersPath = 'truckers';
  static final String agendamentosSemMotorista = 'agendamentos_sem_motorista';

  Future<void> createNewUser(String name, String email, String uid) {
    // Call the user's CollectionReference to add a new user
    CollectionReference users = FirebaseFirestore.instance.collection('users');

      return users
          .doc(uid)
          .set({
        'name': name,
        'email': email,
        'aval' : 0,
        'rate' : 0.0,
      })
          .then((value) {
            userModel.updateFullName(name);
            print('user added');
      })
          .catchError((error) => print("Failed to add user: $error"));

  }

  void getUserInfoFromCloudFirestore(UserModel userModel, @required VoidCallback userExists(), @required VoidCallback userNotReg()){

    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel.Uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {

              if (documentSnapshot.exists) {
                userModel.updateFullName(documentSnapshot['name']);
                userExists();
              } else {
                userNotReg();
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


  //funções de mudanças
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
      'placa' : moveClass.placa,
      'pago' : moveClass.pago,
      'situacao_backup' : 'nao',
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

  Future<void> scheduleAmoveInBdWithoutTrucker(MoveModel moveModel, MoveClass moveClass, @required VoidCallback onSuccess, @required VoidCallback onFailure, double Latlong, double distance){

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
      'id_freteiro' : moveClass.freteiroId == null ? 'nao' : moveClass.freteiroId,
      'valor' : moveClass.preco,
      'id_contratante' : moveClass.userId,
      'selectedDate' : moveClass.dateSelected,
      'selectedTime' : moveClass.timeSelected,
      'nome_freteiro' : moveClass.apelido == null  ? 'nao' : moveClass.apelido,  //se estiver vindo de um agendamento com motorista especifico este dado já vai ser preenchido
      'situacao' : moveClass.freteiroId == null  ? 'aguardando' : GlobalsStrings.sitAguardandoEspecifico,//se estiver vindo de um agendamento com motorista especifico este dado já vai ser preenchido
      'alert' : 'trucker',
      'alert_saw' : false,
      'placa' : moveClass.placa == null  ? 'nao' : moveClass.placa,//se estiver vindo de um agendamento com motorista especifico este dado já vai ser preenchido
      'pago' : moveClass.pago,
      'situacao_backup' : 'nao',
      'latlong' : Latlong,
      'distancia' : moveModel.Distance,
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

  Future<MoveClass> loadScheduledMoveInFbWithCallBack(MoveClass moveClass, UserModel userModel, [VoidCallback onSucess]) async {

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
      moveClass.placa = querySnapshot['placa'];
      moveClass.pago = querySnapshot['pago'];
      moveClass.situacaoBackup = querySnapshot['situacao_backup']??'nao';

      if(moveClass.situacao==GlobalsStrings.sitReschedule){
        moveClass.situacao = moveClass.situacaoBackup; //usar a situação antiga.
      }
      moveClassUpdated = moveClass;
      onSucess();
    });

    return moveClassUpdated;
  }



  Future<MoveClass> copyOfloadScheduledMoveInFbWithCallBack(MoveClass moveClass, String id, [VoidCallback onSucess]) async {

    MoveClass moveClassUpdated;

    await FirebaseFirestore.instance.collection(agendamentosPath).doc(id).get().then((querySnapshot) {

      moveClass.enderecoOrigem = querySnapshot['endereco_origem'];
      moveClass.enderecoDestino = querySnapshot['endereco_destino'];
      moveClass.ajudantes = querySnapshot['ajudantes'];
      moveClass.carro = querySnapshot['carro'];
      moveClass.escada = querySnapshot['escada'] ?? false;
      moveClass.lancesEscada = querySnapshot['lances_escada'] ?? 0;
      moveClass.userId = uid;
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
      moveClass.placa = querySnapshot['placa'];
      moveClass.situacaoBackup = querySnapshot['situacao_backup']??'nao';
      moveClassUpdated = moveClass;
      onSucess();
    });

    return moveClassUpdated;
  }

  Future<MoveClass> loadAdditionalTruckerInfosToScheduledMoveInFbWithCallBack(MoveClass moveClass, UserModel userModel, [VoidCallback onSucess]) async {

    MoveClass moveClassUpdated;

    print(moveClass.freteiroId);

    //obs. quando o user terminou adicionou not ao final do id do user para não ficar achando este serviço como se ainda fosse aberto. Vamos remover agora
    if(moveClass.situacao == GlobalsStrings.sitTruckerFinished){
      moveClass.freteiroId = moveClass.freteiroId.replaceAll('not', '').trim();
    }
    print(moveClass.freteiroId);
    await FirebaseFirestore.instance.collection(truckersPath).doc(moveClass.freteiroId).get().then((querySnapshot) {

      moveClassUpdated = moveClass; //atualiza com os dados ja baixados
      moveClass.freteiroImage = querySnapshot['image'] ?? 'no';
      moveClassUpdated = moveClass;
      onSucess();
    });

    return moveClassUpdated;
  }

  Future<void> loadScheduledMoveInMoveMovelToChangeTrucker(MoveModel moveModel, String id, [VoidCallback onSucess]) async {

    await FirebaseFirestore.instance.collection(agendamentosPath).doc(id).get().then((querySnapshot) {

      bool pago = moveModel.moveClass.pago;
      
      moveModel.moveClass.enderecoOrigem = querySnapshot['endereco_origem'];
      moveModel.moveClass.enderecoDestino = querySnapshot['endereco_destino'];
      moveModel.moveClass.ajudantes = querySnapshot['ajudantes'];
      moveModel.moveClass.carro = querySnapshot['carro'];
      moveModel.moveClass.escada = querySnapshot['escada'] ?? false;
      moveModel.moveClass.lancesEscada = querySnapshot['lances_escada'] ?? 0;
      moveModel.moveClass.userId = id;
      //moveModel.moveClass.freteiroId = querySnapshot['id_freteiro'];
      //moveModel.moveClass.nomeFreteiro = querySnapshot['nome_freteiro'];
      moveModel.moveClass.situacao = querySnapshot['situacao'];
      moveModel.moveClass.ps = querySnapshot['ps'];
      moveModel.moveClass.dateSelected = querySnapshot['selectedDate'];
      moveModel.moveClass.timeSelected = querySnapshot['selectedTime'];
      moveModel.moveClass.preco = querySnapshot['valor'];
      moveModel.moveClass.moveId = querySnapshot['moveId'];
      moveModel.moveClass.alert = querySnapshot['alert'];
      moveModel.moveClass.alertSaw = querySnapshot['alert_saw'];
      moveModel.moveClass.pago = pago;
      moveModel.updateMoveClass(moveModel.moveClass);
      //moveModel.moveClass.placa = querySnapshot['placa'];
      //moveClassUpdated = moveClass;

      onSucess();
    });

  }

  Future<MoveClass> loadScheduledMoveInFbReturnMoveClass(MoveClass moveClass, UserModel userModel) async {

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
      moveClass.placa = querySnapshot['placa'];
      moveClass.situacaoBackup = querySnapshot['situacao_backup']??'nao';
      moveClassUpdated = moveClass;
    });

    return moveClassUpdated;
  }

  Future<void> loadScheduledMoveSituationAndDateTime(MoveClass moveClass, UserModel userModel,  [VoidCallback onSucess, VoidCallback onFailure]) async {

    //MoveClass moveClassUpdated;
    //String situacao;
    await FirebaseFirestore.instance.collection(agendamentosPath).doc(userModel.Uid).get().then((querySnapshot) {

      if(querySnapshot.exists){
        //moveClass.freteiroId = querySnapshot['id_freteiro']??null;
        moveClass.freteiroId = null;
        moveClass.moveId = querySnapshot['moveId'];
        moveClass.situacao = querySnapshot['situacao'];
        moveClass.dateSelected = querySnapshot['selectedDate'];
        moveClass.timeSelected = querySnapshot['selectedTime'];
        //moveClass.pago = querySnapshot['pago'];
        onSucess();
      } else {
        onFailure();
      }

    }).catchError((error) => onFailure());

    //return moveClassUpdated;
  }

  Future<void> loadScheduledMoveSituationAndDateTimeInModel(HomePageModel homePageModel, UserModel userModel,  [VoidCallback onSucess, VoidCallback onFailure]) async {

    //MoveClass moveClassUpdated;
    //String situacao;
    await FirebaseFirestore.instance.collection(agendamentosPath).doc(userModel.Uid).get().then((querySnapshot) {

      homePageModel.moveClass.freteiroId = querySnapshot['id_freteiro'];
      homePageModel.moveClass.moveId = querySnapshot['moveId'];
      homePageModel.moveClass.situacao = querySnapshot['situacao'];
      homePageModel.moveClass.dateSelected = querySnapshot['selectedDate'];
      homePageModel.moveClass.timeSelected = querySnapshot['selectedTime'];
      homePageModel.updateMoveClass(homePageModel.moveClass);
      onSucess();
    }).catchError((error) => onFailure());

    //return moveClassUpdated;
  }

  Future<void> deleteAscheduledMove(MoveClass moveClass, [@required VoidCallback onSuccess, @required VoidCallback onFailure]){
    CollectionReference move = FirebaseFirestore.instance.collection(agendamentosPath);
    move.doc(moveClass.moveId)
    .delete()
    .then((value) => onSuccess()).catchError((onError)=> onFailure());
  }

  Future<void> FinishAmove(MoveClass moveClass, [@required VoidCallback onSuccess, @required VoidCallback onFailure]){
    CollectionReference move = FirebaseFirestore.instance.collection(agendamentosPath);
    move.doc(moveClass.moveId)
        .delete()
        .then((value) => createHistoricOfMoves(moveClass)).catchError((onError)=> onFailure());
  }

  Future<void> createHistoricOfMoves(MoveClass moveClass){

    CollectionReference history = FirebaseFirestore.instance.collection(historicPathUsers);

    history.doc(moveClass.moveId).set({
      'user' : moveClass.moveId,
      'freteiro' : moveClass.freteiroId,
      'preco' : moveClass.preco,
      'origem' : moveClass.enderecoOrigem,
      'destino' : moveClass.enderecoDestino,
      'data' : DateServices().giveMeTheDateToday(),
      'hora' : DateServices().giveMeTheTimeNow(),

    }).then((value) => createHistoricOfMovesToTrucker(moveClass));

  }

  Future<void> createHistoricOfMovesToTrucker(MoveClass moveClass){

    /*
    CollectionReference history = FirebaseFirestore.instance.collection(historicPathTrucker);
    //cria historico do trucker
    history.doc(moveClass.freteiroId).set({
      'user' : moveClass.userId,
      'freteiro' : moveClass.freteiroId,
      'preco' : moveClass.preco,
      'origem' : moveClass.enderecoOrigem,
      'destino' : moveClass.enderecoDestino,
      'data' : DateUtils().giveMeTheDateToday(),
      'hora' : DateUtils().giveMeTheTimeNow(),

    });
     */


    FirebaseFirestore.instance.collection(historicPathTrucker).doc(moveClass.freteiroId).collection('historico').add({
      'user' : moveClass.userId,
      'freteiro' : moveClass.freteiroId,
      'preco' : moveClass.preco,
      'origem' : moveClass.enderecoOrigem,
      'destino' : moveClass.enderecoDestino,
      'data' : DateServices().giveMeTheDateToday(),
      'hora' : DateServices().giveMeTheTimeNow(),
    });

  }

  Future<void> createTruckerAlertToInformMoveDeleted(MoveClass moveClass, String motivo) {
    // Call the user's CollectionReference to add a new user
    CollectionReference users = FirebaseFirestore.instance.collection(truckerAdvice);

    return users
        .doc(moveClass.moveId)
        .set({
      'hora': moveClass.timeSelected,
      'data': moveClass.dateSelected,
      'motivo' : motivo,
      'trucker' : moveClass.freteiroId,
    });

  }

  Future<bool>  loadPagoSituation(String id) async {

    bool pago;
    await FirebaseFirestore.instance.collection(agendamentosPath).doc(id).get().then((querySnapshot) {

      pago = querySnapshot['pago'];

    });
    return pago;

  }

  Future<void> updateMoveSituation(String newSituationString, truckerId, MoveClass moveClass, [VoidCallback onSucess(), VoidCallback onFail()]){


    CollectionReference update = FirebaseFirestore.instance.collection(agendamentosPath);
    return update
        .doc(moveClass.moveId)
        .update({
      'situacao' : newSituationString,

    }).then((value) {
      onSucess();
    }).catchError((e) => onFail());

  }

  Future<void> updateMoveBackupSituation(String newSituationString, truckerId, MoveClass moveClass, [VoidCallback onSucess(), VoidCallback onFail()]){


    CollectionReference update = FirebaseFirestore.instance.collection(agendamentosPath);
    return update
        .doc(moveClass.moveId)
        .update({
      'situacao_backup' : newSituationString,

    }).then((value) {
      onSucess();
    }).catchError((e) => onFail());

  }

  Future<void> checkIfExistsAmoveScheduled(String id, @required VoidCallback onSuccess, @required VoidCallback onFailure) async {

    await FirebaseFirestore.instance.collection(agendamentosPath).doc(id).get().then((querySnapshot) {

      if(querySnapshot.data() != null) {

        onSuccess();

      } else {
        onFailure();
      }
    });
  }

  Future<void> checkIfExistsAmoveScheduledForItensPage(String id, @required VoidCallback onSuccess, @required VoidCallback onFailure) async {

    await FirebaseFirestore.instance.collection(agendamentosPath).doc(id).get().then((querySnapshot) {

      if(querySnapshot.data() != null) {

        if(querySnapshot['situacao']=='trucker_quit_after_payment'){
          onFailure();
        } else {
          onSuccess();
        }

      } else {
        onFailure();
      }
    });
  }

  Future<String> situationListener(MoveClass moveClass){

    final docRef = FirebaseFirestore.instance.collection(agendamentosPath).doc(moveClass.moveId);

    docRef.snapshots().listen((DocumentSnapshot event) async {

      print(event.data()['situacao']);
      if(event.data()['situacao'] !=  'trucker_quited_after_payment'){   //trocar para pago
        return event.data()['situacao'];
      }
    });

  }





  Future<void> checkIfThereIsAlert(String id, @required VoidCallback onSuccess) async {

    await FirebaseFirestore.instance.collection(agendamentosPath).doc(id).get().then((querySnapshot) {

      if(querySnapshot.exists){
        if(querySnapshot['alert'].toString().contains("user") && querySnapshot['alert_saw'] == false){
          onSuccess();
        }
      }

    });
  }

  Future<void> changeTrucker(String id, @required VoidCallback onSucess, @required VoidCallback onFailure) async {

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

  Future<void> changeSchedule(
      {String id,
      String data,
      String hora,
      String oldSituation,
      @required VoidCallback onSucess,
      @required VoidCallback onFailure}) async {

    CollectionReference move = FirebaseFirestore.instance.collection(agendamentosPath);
    return move.doc(id)
        .update({

      //abaixo:
      //se situação for aguardando ou aguardando especifico (quando escolheu um freteiro especifico)
      //entao nao precisa mudar a situacao, pq n teve alteração
      'situacao': oldSituation==GlobalsStrings.sitAguardando || oldSituation==GlobalsStrings.sitAguardandoEspecifico ? oldSituation : GlobalsStrings.sitReschedule,
      'selectedDate' : data,
      'selectedTime' : hora,
      'situacao_backup' : oldSituation,

    })
        .then((_) {
      onSucess();
    })
        .catchError((error) {
      onFailure();
    });

  }

  Future<void> notifyTruckerThatHeWasChanged(String idFreteiro, String idUser) async {

    CollectionReference move = FirebaseFirestore.instance.collection(truckerCancelmentNotify);
    return move.doc(idFreteiro)
        .set({

      'moveId': idUser,

    });

  }

  Future<void> updateAlertView(String id){

    bool test = true;
    CollectionReference alert = FirebaseFirestore.instance.collection(agendamentosPath);
    return alert
        .doc(id)
        .update({
      'alert_saw' : test,
    });

  }

  Future<void> alertSetTruckerAlert(String moveId){

    bool test = false;
    CollectionReference alert = FirebaseFirestore.instance.collection(agendamentosPath);
    return alert
        .doc(moveId)
        .update({
      'alert_saw' : test,
      'alert' : 'trucker',
    });
  }

  Future<String> getTruckerPhone(String truckerId, [@required VoidCallback onSucess, @required VoidCallback onFailure]) async {

    String phone;
    await FirebaseFirestore.instance.collection('truckers').doc(truckerId).get().then((querySnapshot) {
      phone = querySnapshot['phone'];
      phone = phone.replaceAll("(", "");
      phone = phone.replaceAll(")", "");
      phone = phone.replaceAll("-", "");
      phone = phone.replaceAll(" ", "");
      phone = phone.trim();

    });

    return phone;
  }

  Future<String> getTruckerImage(String truckerId, [@required VoidCallback onSucess, @required VoidCallback onFailure]) async {

    String image;
    await FirebaseFirestore.instance.collection('truckers').doc(truckerId).get().then((querySnapshot) {
      //moveClass.carroImagem = querySnapshot['vehicle_image'];
      image = querySnapshot['image'];
    });

    return image;
  }

  Future<String> getTruckerCarImage(String truckerId, [@required VoidCallback onSucess, @required VoidCallback onFailure]) async {

    String image;
    await FirebaseFirestore.instance.collection('truckers').doc(truckerId).get().then((querySnapshot) {
      image = querySnapshot['vehicle_image'];
    });

    return image;
  }

  Future<void> saveLastKnownTruckerPosition(String id, TruckerMovementClass truckerMovementClass) async {

    CollectionReference userLocation = FirebaseFirestore.instance.collection(locationPath);
    return userLocation
        .doc(id)
        .update({
      'lastTrucker_lat' : truckerMovementClass.latitude,
      'lastTrucker_long' : truckerMovementClass.longitude,
    });

  }

  Future<void> loadLastKnownTruckerPosition(String truckerId, TruckerMovementClass truckerMovementClass, [@required VoidCallback onSucess]) async {
    await FirebaseFirestore.instance.collection(locationPath).doc(truckerId)
        .get()
        .then((querySnapshot) {
      if(querySnapshot.data().containsKey('lastTrucker_lat')){
        truckerMovementClass.latitude = querySnapshot['lastTrucker_lat'];
        truckerMovementClass.longitude = querySnapshot['lastTrucker_long'];
      } else {
        truckerMovementClass.latitude = 0.0;
        truckerMovementClass.longitude = 0.0;
      }

      /*
          if(querySnapshot['lastTrucker_lat'].toString() != null){
            truckerMovementClass.latitude = querySnapshot['lastTrucker_lat'];
            truckerMovementClass.longitude = querySnapshot['lastTrucker_long'];
          } else {
            truckerMovementClass.latitude = 0.0;
            truckerMovementClass.longitude = 0.0;
          }

           */


      onSucess();
    });
  }
  /*
  Future<void> loadLastKnownTruckerPosition(String id, TruckerMovementClass truckerMovementClass, [@required VoidCallback onSucess]) async {
    await FirebaseFirestore.instance.collection(agendamentosPath).doc(id)
        .get()
        .then((querySnapshot) {
          if(querySnapshot.data().containsKey('lastTrucker_lat')){
            truckerMovementClass.latitude = querySnapshot['lastTrucker_lat'];
            truckerMovementClass.longitude = querySnapshot['lastTrucker_long'];
          } else {
            truckerMovementClass.latitude = 0.0;
            truckerMovementClass.longitude = 0.0;
          }

          /*
          if(querySnapshot['lastTrucker_lat'].toString() != null){
            truckerMovementClass.latitude = querySnapshot['lastTrucker_lat'];
            truckerMovementClass.longitude = querySnapshot['lastTrucker_long'];
          } else {
            truckerMovementClass.latitude = 0.0;
            truckerMovementClass.longitude = 0.0;
          }

           */


      onSucess();
    });
  }
   */

  Future<void> loadDataToTruckerClass(String truckerId, HomePageModel homePageModel, @required VoidCallback onSucess, @required VoidCallback onFail) async {

    TruckerClass _trucker = TruckerClass();

    await FirebaseFirestore.instance.collection(truckersPath).doc(truckerId)
        .get()
        .then((querySnapshot) {

        _trucker.name = querySnapshot['name'];
        _trucker.image = querySnapshot['image'];
        _trucker.aval2 = querySnapshot['aval'];
        _trucker.rate = querySnapshot['rate'];
        _trucker.placa = querySnapshot['placa'];
        _trucker.apelido = querySnapshot['apelido'];
        _trucker.phone = querySnapshot['phone'];
        _trucker.vehicle = querySnapshot['vehicle'];
        _trucker.vehicle_image = querySnapshot['vehicle_image'];

        homePageModel.truckerClass = _trucker;
        onSucess();

    }).catchError((e) => onFail());
  }

  //punishiments functions
  Future<void> createPunishmentEntryToTrucker(String truckerId, String motivo){

    CollectionReference path = FirebaseFirestore.instance.collection(punishmentPath);

    path.doc(truckerId).set({
      'trucker' : truckerId,
      'motivo' : motivo,
      'data' : DateServices().giveMeTheDateToday(),
      'hora' : DateServices().giveMeTheTimeNow(),

    });

  }

  //payments functions
  Future<void> deleteCode(String id){

    CollectionReference alert = FirebaseFirestore.instance.collection(ordersPath);
    return alert
        .doc(id)
        .update({
      'code_global' : null,
    });

  }

  Future<void> deleteOrder(String id){

    CollectionReference alert = FirebaseFirestore.instance.collection(ordersPath);
    return alert
        .doc(id)
        .delete();

  }

  Future<void> updateOrderafterPayment(String id, String formaPgto, String tipoPgto, String freteiroId){

    CollectionReference alert = FirebaseFirestore.instance.collection(ordersPath);
    return alert
        .doc(id)
        .update({
      'situacao' : 'pago',
      'bandeira' : formaPgto,
      'tipo_pgto' : tipoPgto,
      'freteiro' : freteiroId,
    });

  }

  Future<void> updatescheduldMoveAfterPayment(String id){

    CollectionReference alert = FirebaseFirestore.instance.collection(agendamentosPath);
    return alert
        .doc(id)
        .update({
      'situacao' : 'pago',
      'data_pgto' : DateTime.now().toString(),
    });

  }



  //user avalation funcions
  Future<void> loadAvaliationClass(AvaliationClass avaliationClass, @required VoidCallback onSucess()){

    //AvaliationClass avaliationClassHere = avaliationClass;

    FirebaseFirestore.instance
        .collection(avaliationPath)
        .doc(avaliationClass.avaliationTargetId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {

        avaliationClass.avaliationTargetName = documentSnapshot['apelido'];
        avaliationClass.avaliations = documentSnapshot['aval'].toInt();
        avaliationClass.avaliationTargetRate = documentSnapshot['rate'].toDouble();

        onSucess();

      } else {

        return avaliationClass;
      }
    });



  }

  Future<void> saveUserAvaliation(AvaliationClass avaliationClass){ 

    CollectionReference userLocation = FirebaseFirestore.instance.collection(avaliationPath);
    return userLocation
        .doc(avaliationClass.avaliationTargetId)
        .update({
      'rate' : avaliationClass.newRate,
      'aval' : avaliationClass.avaliations+1,
    });

  }

  Future<double> loadOwnAvaliation(String userId, double rate, VoidCallback onSucess(double rateback)){

    FirebaseFirestore.instance
        .collection(userPath)
        .doc(userId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {

        rate = documentSnapshot['rate'];
        onSucess(rate);

        //onSucess();

      } else {
        //erro
      }
    });
  }

  Future<double> saveOwnAvaliation(String userId, double rate, VoidCallback onSucess()){

    CollectionReference userLocation = FirebaseFirestore.instance.collection(userPath);
    return userLocation
        .doc(userId)
        .update({
      'rate' : rate,
    }).then((value) {
      onSucess();
    });

  }





  //bank save to
  Future<void> saveBankDataToDevolution(BankData _bankData, double _valorReembolso, double _valorTotal, String _idFreteiro, VoidCallback onSucess(), VoidCallback onFail()){

    CollectionReference path = FirebaseFirestore.instance.collection(reembolsoPath);
    return path
        .add({
      'userId' : _bankData.userId,
      'userName' : _bankData.userName??'noName',
      'userMail' : _bankData.userMail,
      'accountName' : _bankData.nameOfAccountOwner,
      'agency' : _bankData.agency,
      'account' : _bankData.account,
      'digit' : _bankData.accountDigit,
      'bank' : _bankData.bank,
      'cpf' : _bankData.cpfOfAccountOwner,
      'problema' : _bankData.problem,
      'tipoConta' : _bankData.accountType,
      'data_requisicao' : DateServices().giveMeTheDateToday(),
      'valor_reembolso' : _valorReembolso,
      'contato' : _bankData.phoneContact,
      'freteiro' : _idFreteiro,
      'valorTotal' : _valorTotal,
    }).then((value) {

      onSucess();

    })

        .catchError((e) => onFail())

    ;

  }


  //salvar dados para reembolso
//punishiments functions
  Future<void> createReembolsoEntryUser(String data, userId, String truckerId, double valor, VoidCallback onSucess(), VoidCallback onFail()){

    CollectionReference path = FirebaseFirestore.instance.collection(reembolsoPathUsers);

    path.add({
      'data' : data,
      'valor' : valor.toStringAsFixed(2),
      'userUid' : userId,
      'truckerId' : truckerId,
    }).then((value) => onSucess()).catchError(onFail());

  }




  //procedimentos de login de facebook

  Future<void> checkIfTheUserIsCommingBack(String uid, String email){

    FirebaseFirestore.instance
        .collection(userPath)
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {

      if (documentSnapshot.exists) {

        //do nothing

      } else {
        createNewUser(null, email, uid); //recria os campos
      }

    });
  }


}

