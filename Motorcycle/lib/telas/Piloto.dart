import 'dart:async';

import 'package:Motorcycle/util/StatusRequisicao.dart';
import 'package:Motorcycle/util/UsuarioFirebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Home.dart';

class Piloto extends StatefulWidget {
  @override
  _PilotoState createState() => _PilotoState();
}

class _PilotoState extends State<Piloto> {

  List<String> itensMenu = [
    "Configurações", "Deslogar"
  ];
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore db = Firestore.instance;

  _deslogarUsuario() async {

    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.signOut();
    Navigator.push(
        context, MaterialPageRoute(
        builder: (context) => Home()
    )
    );

  }

  _escolhaMenuItem( String escolha ){

    switch( escolha ){
      case "Deslogar" :
        _deslogarUsuario();
        break;
      case "Configurações" :

        break;
    }

  }

  Stream<QuerySnapshot> _adicionarListenerRequisicoes(){

    final stream = db.collection("requisicoes")
        .where("status", isEqualTo: StatusRequisicao.AGUARDANDO )
        .snapshots();

    stream.listen((dados){
      _controller.add( dados );
    });

  }

  _recuperaRequisicaoAtivaPiloto() async {

    //Recupera dados do usuario logado
    FirebaseUser firebaseUser = await UsuarioFirebase.getUsuarioAtual();

    //Recupera requisicao ativa
    DocumentSnapshot documentSnapshot = await db
        .collection("requisicao_ativa_piloto")
        .document( firebaseUser.uid ).get();

    var dadosRequisicao = documentSnapshot.data;

    if( dadosRequisicao == null ){
      _adicionarListenerRequisicoes();
    }else{

      String idRequisicao = dadosRequisicao["id_requisicao"];
      Navigator.pushReplacementNamed(
          context,
          "/corrida",
          arguments: idRequisicao
      );

    }

  }

  @override
  void initState() {
    super.initState();

    /*
    Recupera requisicao ativa para verificar se piloto está
    atendendo alguma requisição e envia ele para tela de corrida
    */
    _recuperaRequisicaoAtivaPiloto();

  }

  @override
  Widget build(BuildContext context) {

    var mensagemCarregando = Center(
      child: Column(
        children: <Widget>[
          Text("Carregando requisições"),
          CircularProgressIndicator()
        ],
      ),
    );

    var mensagemNaoTemDados = Center(
      child: Text(
        "Você não tem nenhuma requisição :( ",
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Painel Moto táxi"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context){

              return itensMenu.map((String item){

                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );

              }).toList();

            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _controller.stream,
          builder: (context, snapshot){
            switch( snapshot.connectionState ){
              case ConnectionState.none:
              case ConnectionState.waiting:
                return mensagemCarregando;
                break;
              case ConnectionState.active:
              case ConnectionState.done:

                if( snapshot.hasError ){
                  return Text("Erro ao carregar os dados!");
                }else {

                  QuerySnapshot querySnapshot = snapshot.data;
                  if( querySnapshot.documents.length == 0 ){
                    return mensagemNaoTemDados;
                  }else{

                    return ListView.separated(
                        itemCount: querySnapshot.documents.length,
                        separatorBuilder: (context, indice) => Divider(
                          height: 2,
                          color: Colors.grey,
                        ),
                        itemBuilder: (context, indice){

                          List<DocumentSnapshot> requisicoes = querySnapshot.documents.toList();
                          DocumentSnapshot item = requisicoes[ indice ];

                          String idRequisicao = item["id"];
                          String nomePassageiro = item["passageiro"]["nome"];
                          String rua = item["destino"]["rua"];
                          String numero = item["destino"]["numero"];

                          return ListTile(
                            title: Text( nomePassageiro ),
                            subtitle: Text("destino: $rua, $numero"),
                            onTap: (){
                              Navigator.pushNamed(
                                  context,
                                  "/corrida",
                                  arguments: idRequisicao
                              );
                            },
                          );

                        },
                    );
                  }
                }
                break;
            }
          },

      ),
    );
  }
}
