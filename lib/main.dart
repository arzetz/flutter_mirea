import 'package:flutter/material.dart';

void main() {
  runApp(const MyForm());
}

class MyForm extends StatelessWidget {
  const MyForm({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Форма',
      home: const MyWidget(),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          // Текст "Авторизация" вверху
          Padding(
            padding: const EdgeInsets.only(top: 152.0), // Отступ сверху
            child: Center(
              child: Text(
                "Авторизация",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Отступ для разделения
          SizedBox(height: 22),

          // Форма в центре
          Padding(
            padding: const EdgeInsets.only(top: 152.0),
          ), // Отступ сверху
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Логин',
                  border: OutlineInputBorder(),
                  fillColor: Colors.black12,
                  filled: true,
                ),
              ),
            ),
          ),
          CheckboxListTile(
            title: Text("title text"),
            value: null,
            onChanged: (newValue) {},
            controlAffinity:
                ListTileControlAffinity.leading, //  <-- leading Checkbox
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  hintText: 'Пароль',
                  border: OutlineInputBorder(),
                  fillColor: Colors.black12,
                  filled: true),
            ),
          ),
          ElevatedButton(onPressed: () {}, child: Text('Войти')),
          ElevatedButton(onPressed: () {}, child: Text('Регистрация')),
        ],
      ),
    );
  }
}
