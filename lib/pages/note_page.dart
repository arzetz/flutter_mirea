import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/note.dart';

Future<void> addToCartOnServer(int id) async {
  final response = await http.post(
    Uri.parse('http://localhost:8080/addToCart'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'id': id}),
  );

  if (response.statusCode != 200) {
    throw Exception('Ошибка при добавлении в корзину');
  }
}

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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style:
                    const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  note.innerKnopaDescription,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 20),
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
                                  fontSize: 24,
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
                          const SnackBar(
                            content: Text('Ошибка при добавлении в корзину'),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Потратить ${note.price} на огурчик',
                      style: const TextStyle(
                          fontSize: 24, color: Color.fromARGB(255, 3, 26, 9)),
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
