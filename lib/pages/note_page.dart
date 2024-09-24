import 'package:flutter/material.dart';

import '../models/note.dart';

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
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                note.innerKnopaDescription,
                style: const TextStyle(fontSize: 24),
              ),),
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(                
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color.fromARGB(153, 0, 119, 30)),
                      padding: MaterialStateProperty.all(const EdgeInsets.fromLTRB(15,20,15,20)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                          content: Text(
                            'Спасибо за покупку огурчика!',
                            style: TextStyle(fontSize: 24, color: Color.fromARGB(255, 39, 214, 83)),
                          ),
                          backgroundColor: Color.fromARGB(255, 2, 95, 25),
                           behavior: SnackBarBehavior.floating, 
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0), 
                          side: BorderSide(
                          color: const Color.fromARGB(255, 51, 51, 51), 
                          width: 2.0, 
                            ),
                          ),                
                        ),
                      );
                    },
                    child: Text(
                      'Потратить ${note.price} на огурчик',
                      style: TextStyle(fontSize: 24, color: const Color.fromARGB(255, 3, 26, 9)),
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