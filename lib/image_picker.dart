import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PickImage extends StatefulWidget {
  PickImage({this.imagePickFn});
  final void Function(File image) imagePickFn;

  @override
  _PickImageState createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  File img;
  final picker = ImagePicker();
  void _pickImage() async {
    final resultImage = await picker.getImage(
      source: ImageSource.camera,
    );
    setState(() {
      img = File(resultImage.path);
    });
    widget.imagePickFn(img);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RaisedButton.icon(
          icon: Icon(
            Icons.camera_alt,
          ),
          label: Text("Pick Image"),
          onPressed: _pickImage,
        ),
        img == null
            ? Text("No images taken yet...")
            : Image.file(
                img,
                width: 400,
                height: 400,
              ),
      ],
    );
  }
}
