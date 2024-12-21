import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_practice_10/models/note.dart';
import 'package:flutter_practice_10/components/item_node.dart';
import 'package:http/http.dart' as http;
import 'add_item_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.favoriteNotes,
    required this.addToFavorites,
  });

  final List<Knopa> favoriteNotes;
  final Function(Knopa) addToFavorites;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Knopa> notes = [];

  Future<void> addToFavoritesOnServer(int id) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/addToFavorites'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add to favorites');
    }
  }

  Future<void> addToCartOnServer(int id) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/addToCart'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add to cart');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCucumbers(); // Запрос на сервер при инициализации
  }

  void fetchCucumbers() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8080/cucumbers'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          notes = data
              .map((e) => Knopa(
                    id: e['id'],
                    title: e['title'],
                    knopaDescription: e['description'],
                    innerKnopaDescription: '',
                    price: e['price'],
                    photoLink: e['photo_link'],
                  ))
              .toList();
        });
      } else {
        print('Failed to fetch cucumbers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cucumbers: $e');
    }
  }

  void addNewItem(Knopa newKnopa) {
    setState(() {
      notes.add(newKnopa);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Разные огурчики F1')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchCucumbers,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (BuildContext context, int index) {
          return ItemNode(
            knops: notes[index],
            favoriteToggle: widget.addToFavorites,
            isFavorite: widget.favoriteNotes.contains(notes[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddItemPage(onItemAdded: addNewItem),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
