import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File pickedImage;
  bool isImageLoaded = false;

  List _results;
  String _confidence = "";
  String _names = "";

  getFromGallery() async {
    var tempStore = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = File(tempStore.path);
      isImageLoaded = true;
      applyMyModel(pickedImage);
    });
  }

  loadMyModel() async {
    var resultant = await Tflite.loadModel(
      labels: "assets/labels.txt",
      model: "assets/model_unquant.tflite",
    );
  }

  applyMyModel(File file) async {
    var res = await Tflite.runModelOnImage(
      path: file.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _results = res;
      print(res);
      String str = _results[0]["label"];
      _names = str.substring(2);
      _confidence = _results != null
          ? (_results[0]['confidence'] * 100.0).toString().substring(0, 4) + "%"
          : "";
    });
  }

  @override
  void initState() {
    super.initState();
    loadMyModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            isImageLoaded
                ? Center(
                    child: Container(
                      height: 350,
                      width: 350,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: FileImage(File(pickedImage.path)),
                        fit: BoxFit.cover,
                      )),
                    ),
                  )
                : Container(),
            Text("Name : $_names \nConfidence : $_confidence"),
            SizedBox(
              height: 50,
            ),
            FlatButton(
              color: Colors.indigo,
              onPressed: () {
                setState(() {
                  pickedImage = File("");
                  _confidence = "";
                  _names = "";
                });
              },
              child: Text(
                "Clear",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getFromGallery();
        },
        child: Icon(Icons.image),
      ),
    );
  }
}
