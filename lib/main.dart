import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File _image;

  final picker = ImagePicker();

  Future _getImage() async {
    var pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker test'),
      ),
      body: Column(
        children: [
          RaisedButton(
            onPressed: () {
              _getImage();
            },
            child: Text('Pick Logo'),
          ),
          Container(
            height: 200,
            width: 200,
            child: _image != null
                ? Image(
              image: FileImage(_image),
            )
                : Text('No image selected!'),
          ),
        ],
      ),
    );
  }
}
