import 'package:Motorcycle/telas/Cadastro.dart';
import 'package:Motorcycle/telas/Corrida.dart';
import 'package:Motorcycle/telas/Home.dart';
import 'package:Motorcycle/telas/Passageiro.dart';
import 'package:Motorcycle/telas/Piloto.dart';
import 'package:flutter/material.dart';


class Rotas {

  static Route<dynamic> gerarRotas(RouteSettings settings){

    final args = settings.arguments;

    switch( settings.name ){

      case "/" :
        return MaterialPageRoute(
            builder: (_) => Home()
        );

      case "/cadastro" :
        return MaterialPageRoute(
            builder: (_) => Cadastro()
        );

      case "/painel-passageiro" :
        return MaterialPageRoute(
            builder: (_) => Passageiro()
        );

      case "/painel-piloto" :
        return MaterialPageRoute(
            builder: (_) => Piloto()
        );

      case "/corrida" :
        return MaterialPageRoute(
            builder: (_) => Corrida(
                args
            )
        );

      default:
        _erroRota();
    }

  }

  static Route<dynamic> _erroRota(){

    return MaterialPageRoute(
        builder: (_){
          return Scaffold(
            appBar: AppBar(title: Text("Tela não encontrada!"),),
            body: Center(
              child: Text("Tela não encontrada!"),
            ),
          );
        }
    );

  }

}