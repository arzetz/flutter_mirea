import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Функция для получения токена авторизации
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

// Функция для отправки данных на сервер
// Функция для отправки данных на сервер
Future<void> addCucumberToServer({
  required String title,
  required String description,
  required String photoLink,
  required double price,
  required BuildContext context,
  required Function onItemAdded,
}) async {
  final token = await getToken(); // Получаем токен из SharedPreferences
  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ошибка: Токен отсутствует. Авторизуйтесь.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final response = await http.post(
    Uri.parse('http://localhost:8080/addCucumber'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Передаём токен в заголовке
    },
    body: jsonEncode({
      'title': title,
      'description': description,
      'price': price.toStringAsFixed(2), // Преобразуем цену в строку
      'photo_link': photoLink,
    }),
  );

  if (response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Огурчик успешно добавлен!'),
        backgroundColor: Colors.green,
      ),
    );
    onItemAdded(); // Вызываем callback для обновления данных
    Navigator.pop(context); // Возвращаемся на HomePage
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ошибка добавления огурчика: ${response.body}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Виджет страницы добавления нового огурца
class AddItemPage extends StatefulWidget {
  final Function onItemAdded;

  const AddItemPage({Key? key, required this.onItemAdded}) : super(key: key);

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController photoLinkController = TextEditingController();

  double price = 500.0;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
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
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Описание'),
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
                final String title = titleController.text;
                final String description = descriptionController.text;
                final String photoLink = photoLinkController.text;

                if (title.isEmpty || description.isEmpty || photoLink.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Заполните все поля корректно'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                addCucumberToServer(
                  title: title,
                  description: description,
                  photoLink: photoLink,
                  price: price,
                  context: context,
                  onItemAdded: widget.onItemAdded,
                );
              },
              child: const Text('Добавить огурчик'),
            ),
          ],
        ),
      ),
    );
  }
}
