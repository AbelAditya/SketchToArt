import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sketch/model/drawingPoints.dart';

class DrawingPainter extends CustomPainter{
  final List<DrawingPoints?> pointList;

  DrawingPainter({required this.pointList});



  @override
  void paint(Canvas canvas, Size size) {
    for(int i=0;i<pointList.length-1;i++){
      if(pointList[i]!=null && pointList[i+1]!=null){
        canvas.drawLine(pointList[i]!.points, pointList[i+1]!.points, pointList[i]!.paint);
      }else if(pointList[i]!=null && pointList[i+1]==null){
        List<Offset> offsetList = [];
        offsetList.clear();
        offsetList.add(pointList[i]!.points);
        offsetList.add(Offset(
            pointList[i]!.points.dx + 0.1, pointList[i]!.points.dy + 0.1));

        canvas.drawPoints(PointMode.points, offsetList, pointList[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
  
}