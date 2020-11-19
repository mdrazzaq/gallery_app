import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class ViewWallpaperScreen extends StatefulWidget {
  final DocumentSnapshot data;
  ViewWallpaperScreen({this.data});
  @override
  _ViewWallpaperScreenState createState() => _ViewWallpaperScreenState();
}

class _ViewWallpaperScreenState extends State<ViewWallpaperScreen> {
  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    List<dynamic> tags = widget.data['tags'].toList();
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                child: Hero(
                  tag: widget.data['url'],
                  child: CachedNetworkImage(
                    placeholder: (ctx, index)=> Image(image: AssetImage('assets/placeholder.jpg')),
                    imageUrl: widget.data['url'],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  children: tags.map((tag){
                    return Chip(
                      label: Text(tag),
                    );
                  }).toList(),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  children: [
                    RaisedButton.icon(
                      onPressed: _launchUrl,
                      icon: Icon(Icons.image),
                      label: Text('Get Wallpaper'),
                    ),
                    RaisedButton.icon(
                      onPressed: (){},
                      icon: Icon(Icons.share),
                      label: Text('Share'),
                    ),
                    RaisedButton.icon(
                      onPressed: _addToFavorite,
                      icon: Icon(Icons.favorite_border),
                      label: Text('Favorites'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _launchUrl()async{
    try{
      await launch(
        widget.data['url'],
        option: CustomTabsOption(
          toolbarColor: Colors.greenAccent,
        ),
      );
    }catch(e){

    }
  }
  void _addToFavorite()async{
    FirebaseUser user = await _auth.currentUser();
    String uId = user.uid;
    _db.collection('users').document(uId).collection('favorites')
        .document(widget.data.documentID).setData(widget.data.data);
  }
}
