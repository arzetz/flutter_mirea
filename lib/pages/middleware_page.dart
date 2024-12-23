import 'package:flutter/material.dart';
import 'package:flutter_practice_10/pages/chat_page.dart';
import 'package:flutter_practice_10/pages/home_page.dart';
import 'package:flutter_practice_10/pages/favourite_page.dart';
import 'package:flutter_practice_10/pages/profile_page.dart';
import 'package:flutter_practice_10/pages/cart.dart';
import 'package:flutter_practice_10/pages/order_page.dart';
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
              : _selectedIndex == 2
                  ? const CartPage()
                  : _selectedIndex == 3
                      ? const OrderPage()
                      : _selectedIndex == 4
                          ? const ProfilePage()
                          : ChatPage(
                              userId: '0a957f00-de12-43f5-9b55-3e6183192db0'),
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
            icon: Icon(Icons.shopping_cart),
            label: 'Корзина',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Мои Заказы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Чат',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 32, 100, 156),
        onTap: _onItemTapped,
      ),
    );
  }
}
