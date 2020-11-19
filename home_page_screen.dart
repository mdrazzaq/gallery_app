import 'package:flutter/material.dart';
import 'package:wallpaper_app/screen/accounts_screen.dart';
import 'package:wallpaper_app/screen/explore_screen.dart';
import 'package:wallpaper_app/screen/favorites_screen.dart';

class HomePageScreen extends StatefulWidget {
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int _selectedPageIndex = 0;
  var _pages = [
    ExploreScreen(),
    FavoriteScreen(),
    AccountsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomePage'),
        backgroundColor: Colors.black,
      ),
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('Explore')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            title: Text('Favorites')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            title: Text('Accounts')
          ),
        ],
        currentIndex: _selectedPageIndex,
        onTap: (index){
          setState(() {
            _selectedPageIndex = index;
          });
        },
      ),
    );
  }
}
