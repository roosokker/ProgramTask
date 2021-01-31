import 'dart:io';

import 'package:ProgramTest/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ssh/ssh.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File _pickedImage;
  void _pickImage(File img) {
    setState(() {
      _pickedImage = img;
    });
  }

  void _uploadToFirebase(BuildContext context) async {
    try {
      final ref =
          FirebaseStorage.instance.ref().child('Photos').child("Photo.jpg");
      await ref.putFile(_pickedImage);
      // await ref.getDownloadURL();

    } catch (e) {}
  }

  String _result = '';
  List _array;
  Future<void> _uploadToFtpServer() async {
    var client = new SSHClient(
      host: " william-blount.dreamhost.com",
      port: 22,
      username: "flutter_ftp",
      passwordOrKey: "67IbyHP3PVF0",
    );

    try {
      String result = await client.connect();
      if (result == "session_connected") {
        result = await client.connectSFTP();
        if (result == "sftp_connected") {
          var array = await client.sftpLs();
          setState(() {
            _result = result;
            print(_result);
            _array = array;
            print(_array);
          });

          print(await client.sftpMkdir("Photos"));
          print(await client.sftpRm("testupload"));
          print(await client.sftpUpload(
            path: _pickedImage.path,
            toPath: "Photos",
            callback: (progress) async {
              print(progress);
              // if (progress == 30) await client.sftpCancelUpload();
            },
          ));

          print(await client.disconnectSFTP());

          client.disconnect();
        }
      }
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pick Image"),
      ),
      body: Center(
          child: Column(
        children: [
          PickImage(
            imagePickFn: _pickImage,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlatButton(
                child: Text("Upload to Firebase"),
                onPressed: _pickedImage == null
                    ? null
                    : () => _uploadToFirebase(context),
              ),
              FlatButton(
                child: Text("Upload to Ftp Server"),
                onPressed: _pickedImage == null ? null : _uploadToFtpServer,
              ),
            ],
          ),
        ],
      )),
    );
  }
}
