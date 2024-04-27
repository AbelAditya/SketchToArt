import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:sketch/components/colorPaletteElem.dart';
import 'package:sketch/model/drawingPainter.dart';
import 'package:sketch/model/drawingPoints.dart';
import 'package:rxdart/rxdart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';
import 'package:sketch/services/api.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<DrawingPoints?> pointsList = [];
  final BehaviorSubject<List<DrawingPoints?>?> pointsStream =
      BehaviorSubject<List<DrawingPoints?>?>();

  double strokeWidthPen = 5.0;
  double strokeWidthEraser = 5.0;
  Color strokeColor = Colors.black;
  Color prevStrokeColor = Colors.black;
  bool _isPen = true;
  int selectedColor = 0;
  bool _showPanel = true;
  bool _loader = false;

  FocusNode focus = FocusNode();

  GlobalKey _key = GlobalKey();
  GlobalKey _repaintKey = GlobalKey();

  final _prompt = TextEditingController();

  Future<dynamic> _callingAPI(path) async {
    return await API().processImage(img_path: path, prompt: _prompt.text);
  }

  _showDialog(path) {
    return showDialog(
      context: context,
      builder: (cntxt) => FutureBuilder(
        future: _callingAPI(path),
        builder: (context, snapshot) => AlertDialog(
          content: snapshot.hasData
              ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(),
                      SizedBox(height: 25,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(onPressed: (){}, child: Center(child: Text("asdf"),),),
                          ElevatedButton(onPressed: (){}, child: Center(child: Text("asdf"),),),
                        ],
                      )
                    ],
                  ),
              )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
        ),
      ),
    );
  }

  void initState() {
    super.initState();
    focus.addListener(() => {});
  }

  void setFocus() {
    FocusScope.of(context).requestFocus(focus);
  }

  @override
  void dispose() {
    pointsStream.close();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (details) {
              RenderBox? renderBox =
                  _key.currentContext?.findRenderObject() as RenderBox;

              Paint paint = Paint();
              paint.color = strokeColor;
              paint.strokeWidth = _isPen ? strokeWidthPen : strokeWidthEraser;
              paint.strokeCap = StrokeCap.round;

              pointsList.add(
                DrawingPoints(
                  points: renderBox.globalToLocal(details.globalPosition),
                  paint: paint,
                ),
              );

              pointsStream.add(pointsList);
            },
            onPanUpdate: (details) {
              RenderBox? renderBox =
                  _key.currentContext?.findRenderObject() as RenderBox;

              Paint paint = Paint();
              paint.color = strokeColor;
              paint.strokeWidth = _isPen ? strokeWidthPen : strokeWidthEraser;
              paint.strokeCap = StrokeCap.round;

              pointsList.add(
                DrawingPoints(
                  points: renderBox.globalToLocal(details.globalPosition),
                  paint: paint,
                ),
              );

              pointsStream.add(pointsList);
            },
            onPanEnd: (details) {
              pointsList.add(null);

              pointsStream.add(pointsList);
            },
            child: StreamBuilder(
              stream: pointsStream.stream,
              builder: (context, snapshot) => Container(
                color: Color(0xfff2f3f7),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: CustomPaint(
                    painter: DrawingPainter(pointList: snapshot.data ?? []),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 40,
            right: 40,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showPanel = !_showPanel;
                    });
                  },
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.grey[300],
                    child: Icon(_showPanel
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                AnimatedCrossFade(
                  duration: Duration(milliseconds: 500),
                  firstChild: Container(),
                  secondChild: Container(
                    alignment: Alignment.center,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.lightBlueAccent,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() {
                                    _isPen = true;
                                    strokeColor = prevStrokeColor;
                                  }),
                                  child: Icon(
                                    FontAwesomeIcons.pen,
                                    color: !_isPen
                                        ? Colors.grey[600]
                                        : strokeColor,
                                  ),
                                ),
                                Slider(
                                  value: strokeWidthPen,
                                  onChanged: _isPen
                                      ? (value) {
                                          setState(() {
                                            strokeWidthPen = value;
                                          });
                                        }
                                      : null,
                                  min: 2.0,
                                  max: 20.0,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                    onTap: () => setState(() {
                                          _isPen = false;
                                          prevStrokeColor = strokeColor;
                                          strokeColor = Color(0xfff2f3f7);
                                        }),
                                    child: Icon(
                                      FontAwesomeIcons.eraser,
                                      color: _isPen
                                          ? Colors.grey[600]
                                          : Colors.black,
                                    )),
                                Slider(
                                  value: strokeWidthEraser,
                                  onChanged: !_isPen
                                      ? (value) {
                                          setState(() {
                                            strokeWidthEraser = value;
                                          });
                                        }
                                      : null,
                                  min: 2.0,
                                  max: 50.0,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() {
                                strokeColor = Colors.amber;
                                _isPen = true;
                              }),
                              child: ColorPalleteElem(
                                color: Colors.amber,
                                isSelected: strokeColor == Colors.amber,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () => setState(() {
                                strokeColor = Colors.green;
                                _isPen = true;
                              }),
                              child: ColorPalleteElem(
                                color: Colors.green,
                                isSelected: strokeColor == Colors.green,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() {
                                strokeColor = Colors.red;
                                _isPen = true;
                              }),
                              child: ColorPalleteElem(
                                color: Colors.red,
                                isSelected: strokeColor == Colors.red,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () => setState(() {
                                strokeColor = Colors.blue;
                                _isPen = true;
                              }),
                              child: ColorPalleteElem(
                                color: Colors.blue,
                                isSelected: strokeColor == Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  strokeColor = Colors.black;
                                  _isPen = true;
                                });
                              },
                              child: ColorPalleteElem(
                                color: Colors.black,
                                isSelected: strokeColor == Colors.black,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  strokeColor = Colors.white;
                                  _isPen = true;
                                });
                              },
                              child: ColorPalleteElem(
                                color: Colors.white,
                                isSelected: strokeColor == Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        SizedBox(
                          height: 80,
                          width: 450,
                          child: Center(
                            child: TextFormField(
                              controller: _prompt,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    _prompt.clear();
                                  },
                                  child: Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.black,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        !_loader
                            ? GestureDetector(
                                onTap: () async {
                                  await fetchImage();

                                  setState(() {
                                    _loader = true;
                                  });

                                  dynamic res = await API().processImage(
                                      img_path:
                                          "/storage/emulated/0/Download/sketch.jpg",
                                      prompt: _prompt.text);

                                  setState(() {
                                    _loader = false;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: res[0] == 0
                                          ? Colors.green
                                          : Colors.red,
                                      content: Center(
                                        child: Text(res[1]),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    child: Text(
                                      "GENERATE",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ),
                              )
                            : CircularProgressIndicator(
                                color: Colors.white,
                              ),
                        SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          onTap: () {
                            pointsStream.add(null);
                            pointsList.clear();
                          },
                          child: Icon(
                            Icons.delete,
                          ),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: _showPanel
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
// Import for Uint8List

  Future fetchImage() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary;
      final img = await boundary.toImage();
      final ByteData? bd = await img.toByteData(format: ImageByteFormat.png);
      if (bd != null) {
        Directory generalDownloadDir =
            Directory('/storage/emulated/0/Download');

        File imageFile =
            await File('${generalDownloadDir.path}/sketch.jpg').create();

        await imageFile.writeAsBytes(bd.buffer.asUint8List());
      }
      return null;
    } catch (e) {
      print('Error fetching image: $e');
      return null; // Handle the error gracefully by returning null
    }
  }

  Stream<List<int>> createByteStream(Uint8List bytes) {
    final controller = StreamController<List<int>>();
    controller.add(bytes.toList());
    controller.close();
    return controller.stream;
  }

//   Future<ByteData?> fetchImage()async{
//     final boundary = _key.currentContext?.findRenderObject()as RenderRepaintBoundary;

//     final img = await boundary.toImage();

//     final bd = await img.toByteData(format: ImageByteFormat.png);

//     return bd;
//   }
}
