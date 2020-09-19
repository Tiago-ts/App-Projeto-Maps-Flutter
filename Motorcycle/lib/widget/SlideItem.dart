import 'package:Motorcycle/modal/Slide.dart';
import 'package:flutter/material.dart';

import 'dart:async';



class SlideItem extends StatelessWidget {

  final int index;
  SlideItem(this.index);

  @override
  Widget build(BuildContext context) {
    return Column(

      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: AssetImage(slideList[index].imageUrl),
                  fit: BoxFit.cover
              )
          ),
        ),
        SizedBox(
          height: 40,
        ),

        Text(
            slideList[index].titulo,
            style: TextStyle(
              fontSize: 23,

              color: Colors.yellow
            ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          slideList[index].descricao,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
