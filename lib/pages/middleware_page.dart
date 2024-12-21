import 'package:flutter/material.dart';
import 'package:flutter_practice_10/pages/home_page.dart';
import 'package:flutter_practice_10/pages/favourite_page.dart';
import 'package:flutter_practice_10/pages/profile_page.dart';
import 'package:flutter_practice_10/models/note.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  ScreenState createState() => ScreenState();
}

class ScreenState extends State<Screen> {
  int _selectedIndex = 0;
  List<Knopa> favoriteNotes = [];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void addToFavorites(Knopa note) {
    setState(() {
      if (!favoriteNotes.contains(note)) {
        favoriteNotes.add(note);
      }
    });
  }

  void removeFromFavorites(Knopa note) {
    setState(() {
      favoriteNotes.remove(note);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? HomePage(
              favoriteNotes: favoriteNotes,
              addToFavorites: addToFavorites,
            )
          : _selectedIndex == 1
              ? FavoritesPage(
                  favoriteNotes: favoriteNotes,
                  removeFromFavorites: removeFromFavorites,
                )
              : const ProfilePage(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Избранное',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 32, 100, 156),
        onTap: _onItemTapped,
      ),
    );
  }
}
