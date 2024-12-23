import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

// Функция для получения токена из SharedPreferences
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

// Функция для добавления товара в корзину
Future<void> addToCartOnServer(int id) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('Пользователь не авторизован. Токен отсутствует.');
  }

  final response = await http.post(
    Uri.parse('http://localhost:8080/addToCart'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'id': id}),
  );

  if (response.statusCode != 200) {
    throw Exception('Ошибка при добавлении в корзину: ${response.body}');
  }
}

// Страница с информацией о товаре
class NotePage extends StatelessWidget {
  final Knopa note;

  const NotePage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 24,
        ),
        title: Text(note.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Фото товара
              Center(
                child: Image.asset(
                  'assets/${note.photoLink}', // Замените на ваш путь к изображению
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error,
                        size: 50); // Обработка ошибки
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Название товара
              Text(
                note.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Описание товара
              Text(
                note.innerKnopaDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              // Кнопка "Добавить в корзину"
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(153, 0, 119, 30)),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.fromLTRB(15, 20, 15, 20)),
                    ),
                    onPressed: () async {
                      try {
                        await addToCartOnServer(note.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${note.title} добавлен в корзину!',
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 39, 214, 83)),
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 2, 95, 25),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              side: const BorderSide(
                                color: Color.fromARGB(255, 51, 51, 51),
                                width: 2.0,
                              ),
                            ),
                          ),
                        );
                        Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Ошибка: ${e.toString()}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Потратить ${double.parse(note.price).toStringAsFixed(2)} ₽ на огурчик',
                      style: const TextStyle(
                          fontSize: 20, color: Color.fromARGB(255, 3, 26, 9)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
