import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallpaper_app/screen/add_wallpaper_screen.dart';
import 'package:wallpaper_app/screen/view_wallpaper_screen.dart';

class AccountsScreen extends StatefulWidget {
  @override
  _AccountsScreenState createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
 /* var _images = [
    'https://images.unsplash.com/photo-1602188798833-e9250c62b450?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
    'https://images.unsplash.com/photo-1602228819971-2ae00d3e642d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
    'https://images.unsplash.com/photo-1602186123314-fff17bd65f2f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
    'https://images.unsplash.com/photo-1602233601086-b1e73e767ba1?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
    'https://images.unsplash.com/photo-1601931032130-dd03662aeef3?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
    'https://images.unsplash.com/photo-1602064172250-43f8909056c7?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
  ];*/
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;
  FirebaseUser _user;

  @override
  void initState() {
    fetchUserData();
    super.initState();
  }
  void fetchUserData()async{
    FirebaseUser u = await _auth.currentUser();
    setState(() {
      _user = u;
    });
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: _user !=null ?Column(
          children: [
            SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: FadeInImage(
                width: 200,
                height: 200,
                image: NetworkImage('${_user.photoUrl}'),
                placeholder: AssetImage('assets/placeholder.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20.0),
            Text('${_user.displayName}'),
            SizedBox(height: 20),
            RaisedButton(
              onPressed: (){
                _auth.signOut();
              },
              child: Text('Logout'),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Wallpaper'),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context)=>AddWallpaperScreen(),
                        fullscreenDialog: true,
                      ));
                    },
                  ),
                ],
              ),
            ),
            StreamBuilder(
              stream: _db
                  .collection('wallpapers')
                  .where('uploaded_by', isEqualTo: _user.uid)
                  .orderBy('date',descending: true)
                  .snapshots(),
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
                        child: Stack(
                          children: [
                            Hero(
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
                            IconButton(
                              onPressed:(){
                                showDialog(
                                  context: context,
                                  builder: (ctx){
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: Text('Confrimation'),
                                      content: Text('Are You Sure To Delete Wallpaper'),
                                      actions: [
                                        RaisedButton(
                                          child: Text('Cancel'),
                                          onPressed: (){
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        RaisedButton(
                                          child: Text('Delete'),
                                          onPressed: (){
                                           _db.collection('wallpapers')
                                               .document(snapshot.data.documents[index].documentID)
                                               .delete();
                                           Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  }
                                );
                              },
                              icon:Icon(Icons.delete,color: Colors.red),
                            ),
                          ],
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
          ],
        ):LinearProgressIndicator(),
      ),
    );
  }
}
