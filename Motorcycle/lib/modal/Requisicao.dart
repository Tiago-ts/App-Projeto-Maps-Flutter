import 'package:Motorcycle/modal/Usuario.dart';
import 'package:Motorcycle/modal/Destino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Requisicao {

  String _id;
  String _status;
  Usuario _passageiro;
  Usuario _piloto;
  Destino _destino;

  Requisicao(){

    Firestore db = Firestore.instance;

    DocumentReference ref = db.collection("requisicoes").document();
    this.id = ref.documentID;

  }

  Map<String, dynamic> toMap(){

    Map<String, dynamic> dadosPassageiro = {
      "nome" : this.passageiro.nome,
      "email" : this.passageiro.email,
      "tipoUsuario" : this.passageiro.tipoUsuario,
      "idUsuario" : this.passageiro.idUsuario,
      "latitude" : this.passageiro.latitude,
      "longitude" : this.passageiro.longitude,
    };

    Map<String, dynamic> dadosDestino = {
      "rua" : this.destino.rua,
      "numero" : this.destino.numero,
      "bairro" : this.destino.bairro,
      "cep" : this.destino.cep,
      "latitude" : this.destino.latitude,
      "longitude" : this.destino.longitude,
    };

    Map<String, dynamic> dadosRequisicao = {
      "id" : this.id,
      "status" : this.status,
      "passageiro" : dadosPassageiro,
      "piloto" : null,
      "destino" : dadosDestino,
    };

    return dadosRequisicao;

  }

  Destino get destino => _destino;

  set destino(Destino value) {
    _destino = value;
  }

  Usuario get piloto => _piloto;

  set piloto(Usuario value) {
    _piloto = value;
  }

  Usuario get passageiro => _passageiro;

  set passageiro(Usuario value) {
    _passageiro = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }


}