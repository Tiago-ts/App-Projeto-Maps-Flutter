import 'package:Motorcycle/modal/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UsuarioFirebase {

  static Future<FirebaseUser> getUsuarioAtual() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    return await auth.currentUser();

  }

  static Future<Usuario> getDadosUsuarioLogado() async {

    FirebaseUser firebaseUser = await getUsuarioAtual();
    String idUsuario = firebaseUser.uid;

    Firestore db = Firestore.instance;

    DocumentSnapshot snapshot = await db.collection("usuarios")
        .document( idUsuario )
        .get();

    Map<String, dynamic> dados = snapshot.data;
    String tipoUsuario = dados["tipoUsuario"];
    String email = dados["email"];
    String nome = dados["nome"];

    Usuario usuario = Usuario();
    usuario.idUsuario = idUsuario;
    usuario.tipoUsuario = tipoUsuario;
    usuario.email = email;
    usuario.nome = nome;

    return usuario;

  }

  static atualizarDadosLocalizacao(String idRequisicao, double lat, double lon) async {

    Firestore db = Firestore.instance;

    Usuario piloto = await getDadosUsuarioLogado();
    piloto.latitude = lat;
    piloto.longitude = lon;

    db.collection("requisicoes")
        .document( idRequisicao )
        .updateData({
      "piloto" : piloto.toMap()
    });

  }

}