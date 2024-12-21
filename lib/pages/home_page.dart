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
  List<Knopa> filteredNotes = [];
  String searchQuery = "";
  double priceMin = 500;
  double priceMax = 2000;

  @override
  void initState() {
    super.initState();
    fetchCucumbers(); // Загружаем данные при инициализации
  }

  Future<void> fetchCucumbers() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8080/cucumbers'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          notes = data
              .map((e) => Knopa(
                    id: e['id'],
                    title: e['title'] ?? '',
                    knopaDescription: e['description'] ?? '',
                    innerKnopaDescription: '',
                    price: e['price'] ?? '0',
                    photoLink: e['photo_link'] ?? '',
                  ))
              .toList();
          filteredNotes = notes; // Сначала отображаем все данные
        });
      } else {
        print('Ошибка загрузки данных: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при загрузке данных: $e');
    }
  }

  void applyFilters() {
    setState(() {
      filteredNotes = notes
          .where((note) =>
              note.title.toLowerCase().contains(searchQuery.toLowerCase()) &&
              _isWithinPriceRange(note.price))
          .toList();
    });
  }

  bool _isWithinPriceRange(String price) {
    final priceValue =
        double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    return priceValue >= priceMin && priceValue <= priceMax;
  }

  void filterNotes(String query) {
    setState(() {
      searchQuery = query;
      applyFilters();
    });
  }

  void addNewItem(Knopa newKnopa) {
    setState(() {
      notes.add(newKnopa);
      applyFilters(); // Применяем фильтры к новому элементу
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(150.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: filterNotes,
                  decoration: InputDecoration(
                    hintText: 'Поиск по названию...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Цена от: ${priceMin.round()} ₽'),
                    Text('до: ${priceMax.round()} ₽'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: RangeSlider(
                  values: RangeValues(priceMin, priceMax),
                  min: 500,
                  max: 2000,
                  divisions: 15,
                  labels: RangeLabels(
                    '${priceMin.round()} ₽',
                    '${priceMax.round()} ₽',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      priceMin = values.start;
                      priceMax = values.end;
                      applyFilters();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: filteredNotes.isEmpty
          ? const Center(
              child: Text(
                'Нет данных для отображения',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (BuildContext context, int index) {
                return ItemNode(
                  knops: filteredNotes[index],
                  favoriteToggle: widget.addToFavorites,
                  isFavorite:
                      widget.favoriteNotes.contains(filteredNotes[index]),
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
