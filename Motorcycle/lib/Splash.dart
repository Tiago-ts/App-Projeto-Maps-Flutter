import 'dart:async';

import 'package:Motorcycle/telas/Home.dart';
import 'package:flutter/material.dart';

import 'Welcome.dart';

class Splash extends StatefulWidget {

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void didChangeDependencies() {

    super.didChangeDependencies();
    // tempo de abertura do splash
    Timer(Duration(seconds: 5),(){



      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Welcome() ));
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(

        /*
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/fundo2.jpg"),
                fit: BoxFit.cover
            )
        ),
        */

        color: Color(0xff000000),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Align(
                alignment: Alignment.center,
                child: Icon(Icons.motorcycle,
                  size: 120,
                  color: Colors.yellow,
                ),
              ),

              Align(
                child: Text(
                  "Motorcycle",
                  style: TextStyle(
                      fontSize: 40,
                      color:  Colors.yellow,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
