import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallpaper_app/screen/view_wallpaper_screen.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  /*var _images = [
    'https://images.unsplash.com/photo-1602188798833-e9250c62b450?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
    'https://images.unsplash.com/photo-1602228819971-2ae00d3e642d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
    'https://images.unsplash.com/photo-1602186123314-fff17bd65f2f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
    'https://images.unsplash.com/photo-1602233601086-b1e73e767ba1?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
    'https://images.unsplash.com/photo-1601931032130-dd03662aeef3?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
    'https://images.unsplash.com/photo-1602064172250-43f8909056c7?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
  ];*/
  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  
  @override
  void initState() {
    _getUser();
    super.initState();
  }
  void _getUser()async{
    FirebaseUser u = await _auth.currentUser();
    setState(() {
      user = u;
    });
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(top: 5, left: 20, bottom: 20),
        child: Column(
          children: [
            Container(
              child: Text(
                'Favorites',
                style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.grey),
              ),
            ),
            SizedBox(height: 20),

            if(user !=null)...[
              StreamBuilder(
                stream: _db.collection('users').document(user.uid).collection('favorites')
                    .orderBy('date',descending: true).snapshots(),
                builder: (ctx, AsyncSnapshot<QuerySnapshot>snapshot){
                  if(snapshot.hasData){
                    return StaggeredGridView.countBuilder(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      staggeredTileBuilder: (int index)=> StaggeredTile.fit(1),
                      itemCount: snapshot.data.documents.length,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      itemBuilder: (context, index){
                        return InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context)=>ViewWallpaperScreen(
                                data:snapshot.data.documents[index],
                              ),
                            ));
                          },
                          child: Hero(
                            tag: snapshot.data.documents[index].data['url'],
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              /*child: Image(
                        image: NetworkImage(_images[index]),
                      ),*/
                              child: CachedNetworkImage(
                                placeholder: (ctx, index)=> Image(image: AssetImage('assets/placeholder.jpg')),
                                imageUrl: snapshot.data.documents[index].data['url'],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return SpinKitChasingDots(
                    color: Colors.greenAccent,
                    size: 50,
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}
