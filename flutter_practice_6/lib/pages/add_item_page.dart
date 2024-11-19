import 'package:flutter/material.dart';
import 'package:flutter_practice_4/models/note.dart';
class AddItemPage extends StatefulWidget {
  final Function(Knopa) onItemAdded;

  const AddItemPage({super.key, required this.onItemAdded});

  @override
  AddItemPageState createState() => AddItemPageState();
}

class AddItemPageState extends State<AddItemPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController innerDescriptionController = TextEditingController();
  final TextEditingController photoLinkController = TextEditingController();

  double price = 500.0;

  @override
  void dispose() {
    idController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    innerDescriptionController.dispose();
    photoLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить огурчик'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'ID'),
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Краткое описание'),
            ),
            TextField(
              controller: innerDescriptionController,
              decoration: const InputDecoration(labelText: 'Подробное описание'),
            ),
            Slider(
              value: price,
              min: 500,
              max: 2000,
              divisions: 20,
              label: price.round().toString(),
              onChanged: (double newValue) {
                setState(() {
                  price = newValue;
                });
              },
            ),
            TextField(
              controller: photoLinkController,
              decoration: const InputDecoration(labelText: 'Ссылка на фото'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newKnopa = Knopa(
                  id: int.parse(idController.text),
                  title: titleController.text,
                  knopaDescription: descriptionController.text,
                  innerKnopaDescription: innerDescriptionController.text,
                  price: '${price.toStringAsFixed(2)} ₽',
                  photoLink: photoLinkController.text,
                );
                widget.onItemAdded(newKnopa);
                Navigator.pop(context);
              },
              child: const Text('Добавить огурчик'),
            ),
          ],
        ),
      ),
    );
  }
}