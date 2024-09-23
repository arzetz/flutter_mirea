import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: MyWidget()));
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 132.0),
            child: Center(
              child: Text(
                "Авторизация",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 70.0, 16.0, 0.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Логин',
                      border: InputBorder.none,
                      fillColor: const Color.fromARGB(255, 243, 243, 243),
                      filled: true,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Пароль',
                        border: InputBorder.none,
                        fillColor: const Color.fromARGB(255, 235, 235, 235),
                        filled: true),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value!;
                        });
                      },
                    ),
                    Text(
                      'Запомнить меня',
                      style: TextStyle(fontSize: 16),
                    ), // Текст справа от чекбокса
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2771FF),
                      padding: EdgeInsets.all(10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: const BorderSide(color: Color(0xFF00A0E3)),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Войти",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: const BorderSide(color: Color(0xFF00A0E3)),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Регистрация",
                      style: TextStyle(
                        fontSize: 15,
                        color: const Color(0xFF2E7FA8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Восстановить пароль',
                  style: TextStyle(fontSize: 15),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

