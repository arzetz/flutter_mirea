import 'package:flutter/material.dart';
import 'package:flutter_practice_4/components/item_node.dart';
import 'package:flutter_practice_4/models/note.dart';

class FavoritesPage extends StatelessWidget {
  final List<Knopa> favoriteNotes;
  final Function(Knopa) removeFromFavorites;
  const FavoritesPage({
    super.key,
    required this.favoriteNotes,
    required this.removeFromFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
         centerTitle: true,
      ),
      body: favoriteNotes.isEmpty
          ? const Center(
              child: Text(
                'Нет избранных товаров',
                style: TextStyle(fontSize: 20),
              ),
            )
          :  Center( child:GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.45,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: favoriteNotes.length,
              itemBuilder: (BuildContext context, int index) {
                return ItemNode(
                  knops: favoriteNotes[index],
                  favoriteToggle: (note) {
                    removeFromFavorites(note);
                  },
                  isFavorite: true,
                );
              },
            ),
          ),
    );
  }
}