import 'package:flutter/material.dart';

class ColorPalleteElem extends StatelessWidget {
  const ColorPalleteElem({super.key,required this.color,required this.isSelected});

  final color;

  final isSelected;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: isSelected? Colors.white:Colors.lightBlueAccent,
      radius: 18,
      child: CircleAvatar(
        backgroundColor: Colors.lightBlueAccent,
        radius: 16,
        child: CircleAvatar(backgroundColor: color,radius: 15,),
      ),
    );
  }
}