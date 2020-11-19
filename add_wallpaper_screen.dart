import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
class AddWallpaperScreen extends StatefulWidget {
  @override
  _AddWallpaperScreenState createState() => _AddWallpaperScreenState();
}

class _AddWallpaperScreenState extends State<AddWallpaperScreen> {
  File _image;
  final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
  //List<ImageLabel> detectLabels;
  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isUploading = false;
  bool _isCompltedUploading  = false;
  List<String> labelsInString = [];

  @override
  void dispose() {
    labeler.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Wallpaper'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              InkWell(
                onTap: _loadImage,
                child: _image !=null ? Image.file(_image) :Image(
                  image: AssetImage('assets/placeholder.jpg'),
                ),
              ),
              Text('Click on Image To Upload Your Wallpaper'),
              labelsInString !=null ? Padding(
                padding: EdgeInsets.all(10.0),
                child: Wrap(
                  spacing: 20,
                  children: labelsInString.map((label){
                    return Chip(
                      label: Text(label),
                    );
                  }).toList(),
                ),
              ):Container(),
              SizedBox(height: 40),
              if(_isUploading)...[
                Text('Wallpaper Uploading'),
              ],
              if(_isCompltedUploading)...[
                Text('Uploading Successful'),
              ],
              SizedBox(height: 40),
              RaisedButton(
                onPressed: _uploadWallpaper,
                child: Text('Wallpaper upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _loadImage() async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    final FirebaseVisionImage visionImage =  FirebaseVisionImage.fromFile(image);
    List<ImageLabel> labels = await labeler.processImage(visionImage);
    labelsInString = [];
    for(var l in labels){
      labelsInString.add(l.text);
    }
    setState(() {
      _image = image;
    });
  }
  void _uploadWallpaper()async{
    if(_image !=null){
      String fileName = path.basename(_image.path);
      FirebaseUser user = await _auth.currentUser();
      String uId = user.uid;
      StorageUploadTask task =
      _storage.ref().child('wallpapers').child(uId).child(fileName).putFile(_image);

      task.events.listen((e){
        if(e.type == StorageTaskEventType.progress){
          setState(() {
            _isUploading = true;
          });
        }
        if(e.type == StorageTaskEventType.success){
          setState(() {
            _isCompltedUploading = true;
            _isUploading = false;
          });
          e.snapshot.ref.getDownloadURL().then((url){
            _db.collection('wallpapers').add({
              'url': url,
              'date': DateTime.now(),
              'uploaded_by': uId,
              'tags' : labelsInString,
            });
            Navigator.of(context).pop();
          });
        }
      });
    }else{
      showDialog(
        context: context,
        builder: (ctx){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('Error'),
            content: Text('Select Image to Upload'),
            actions: [
              RaisedButton(
                onPressed:(){
                  Navigator.of(context).pop();
                },
                child: Text('Ok'),
              ),
            ],
          );
        }
      );
    }
  }
}
