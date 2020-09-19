import 'package:flutter/material.dart';

class Slide {
  final String imageUrl;
  final String titulo;
  final String descricao;

  Slide({
    @required this.imageUrl,
    @required this.titulo,
    @required this.descricao,
  });
}

final slideList = [
  Slide(
    imageUrl: 'imagens/01.png',
    titulo: 'Bem vindo ao Motorcycle!',
    descricao: ' Somos uma empresa que liga moto táxi ao passageiro',
  ),
  Slide(
    imageUrl: 'imagens/02.jpg',
    titulo: 'Como funciona?',
    descricao: 'Basta apenas fazer um rápido cadastro no botão abaixo!',
  ),
  Slide(
    imageUrl: 'imagens/03.png',
    titulo: 'Vamos dar inicio a essa parceira perfeita?',
    descricao: 'Desfrute da facilidade de mobilidade e encontre um piloto próximo a você! Clique em Cadastre-se!',
  ),
];
