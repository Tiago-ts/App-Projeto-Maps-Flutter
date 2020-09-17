import 'package:Motorcycle/telas/Home.dart';
import 'package:flutter/material.dart';


import 'Rotas.dart';
import 'Splash.dart';

final ThemeData temaPadrao = ThemeData(
    primaryColor: Color(0xff000000),
    accentColor: Color(0xff546e7a)
);

void main() => runApp(MaterialApp(
  title: "Motorcycle",
  home: Splash(),
  theme: temaPadrao,
  initialRoute: "/",
  onGenerateRoute: Rotas.gerarRotas,
  debugShowCheckedModeBanner: false,
));
