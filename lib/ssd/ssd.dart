import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ml/ssd/BoundingBox.dart';
import 'package:ml/ssd/camera.dart';
import 'package:tflite/tflite.dart';

const String ssd = "SSD";

class SSD extends StatefulWidget {
  final List<CameraDescription> cameras;

  SSD(this.cameras);
  @override
  _SSDState createState() => _SSDState();
}

class _SSDState extends State<SSD> {
  List<dynamic> _recognition;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  loadMyModel() async {
    String result;

    switch (_model) {
      case ssd:
        result = await Tflite.loadModel(
          model: "assets/ssd.tflite",
          labels: "assets/ssd.txt",
        );
    }
    print(result);
  }

  onSelectModel(model) {
    setState(() {
      _model = model;
    });
    loadMyModel();
  }

  setRecoginitions(recognitions, imageHeight, imageWidth) {
    _recognition = recognitions;
    _imageHeight = imageHeight;
    _imageWidth = imageWidth;
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: _model == ""
          ? Container()
          : Stack(
              children: [
                Camera(widget.cameras, setRecoginitions, _model),
                BoundingBox(
                    _recognition == null ? [] : _recognition,
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    screen.width,
                    screen.height,
                    _model)
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onSelectModel(ssd);
        },
        child: Icon(Icons.camera),
      ),
    );
  }
}
