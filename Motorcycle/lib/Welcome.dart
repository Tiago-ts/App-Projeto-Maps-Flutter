import 'package:Motorcycle/telas/Cadastro.dart';
import 'package:Motorcycle/telas/Home.dart';
import 'package:Motorcycle/widget/SlideItem.dart';
import 'package:Motorcycle/widget/SlideMarcador.dart';
import 'package:flutter/material.dart';
import 'modal/Slide.dart';
import 'dart:async';


class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(

        body: Container(
            color: Colors.black,
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                Expanded(
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: <Widget>[
                PageView.builder(
                scrollDirection: Axis.horizontal,
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: slideList.length,
                  itemBuilder: (ctx, i) => SlideItem(i),
                ),
                Stack(
                    alignment: AlignmentDirectional.topStart,
                    children: <Widget>[
                Container(
                margin: const EdgeInsets.only(bottom: 35),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                for(int i = 0; i<slideList.length; i++)
                if( i == _currentPage )
            SlideMarcador(true)
        else
        SlideMarcador(false)
               ],
             ),
           )
          ],
         )
       ],
     ),
    ),

    Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget> [
    FlatButton(
        child: Text(
            "Cadastre-se",
            style: TextStyle(
            fontSize: 19,
        ),
    ),
     shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    padding: const EdgeInsets.all(15),
        color: Colors.yellow,
        textColor: Colors.black,
          onPressed: (){
           Navigator.push(
            context, MaterialPageRoute(
                      builder: (context) => Cadastro()
                              )
                            );
                          },

    ),

    Row(
      mainAxisAlignment: MainAxisAlignment.center,
        children: [
            Text(
            "Já possui conta?",
        style: TextStyle(
        fontSize: 18,
        color: Colors.white
      ),
    ),


    FlatButton(
      onPressed: (){
    Navigator.push(
    context, MaterialPageRoute(
    builder: (context) => Home()
    )
    );
    },
    child: Text(
        "Faça Login",
        style: TextStyle(
            fontSize: 18,
            color: Colors.white

                    ),
                   ),

                  ),
                 ],
                )
               ],
             ),
           ],
         ),
       ),
     ),
    );
  }
}
