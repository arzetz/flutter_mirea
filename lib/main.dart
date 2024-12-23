import 'package:flutter/material.dart';
import 'package:flutter_practice_10/pages/middleware_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://xzibhythexmxaquxyrrf.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6aWJoeXRoZXhteGFxdXh5cnJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ3MjkwMzUsImV4cCI6MjA1MDMwNTAzNX0.3G1ugfU2rHDco8_e6cjtkn5imz955Z5qR_2MaBDbpGY';

Future<void> main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white, // Основной цвет — белый
        scaffoldBackgroundColor: Colors.white, // Фон приложения — белый
        appBarTheme: const AppBarTheme(
          color: Colors.white, // Цвет AppBar — белый
          iconTheme: IconThemeData(color: Colors.black), // Иконки чёрного цвета
          titleTextStyle: TextStyle(
            color: Colors.black, // Чёрный текст заголовка
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.black, // Кнопка действия — чёрная
          foregroundColor: Colors.white, // Иконка — белая
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white, // Белый фон нижней панели
          selectedItemColor: Colors.black, // Чёрный цвет выбранного элемента
          unselectedItemColor: Colors.grey, // Серый цвет невыбранных элементов
          selectedLabelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const Screen(),
    );
  }
}
