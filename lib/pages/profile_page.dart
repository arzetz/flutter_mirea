import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _token;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final email = prefs.getString('email');

    if (token != null && email != null) {
      setState(() {
        _token = token;
        _email = email;
      });
    }
  }

  Future<void> _saveSession(String token, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('email', email);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
  }

  Future<void> _register() async {
    final url = 'http://localhost:8080/register';
    final body = jsonEncode({
      'email': _emailController.text,
      'password': _passwordController.text,
    });
    print('Requesting: $url');
    print('Body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('Response: ${response.statusCode}, ${response.body}');
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Регистрация успешна. Проверьте почту.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${response.body}')),
      );
    }
  }

  Future<void> _login() async {
    final url = 'http://localhost:8080/login';
    final body = jsonEncode({
      'email': _emailController.text,
      'password': _passwordController.text,
    });
    print('Requesting: $url');
    print('Body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('Response: ${response.statusCode}, ${response.body}');
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        setState(() {
          _token = token;
          _email = _emailController.text;
        });
        await _saveSession(token, _emailController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вход успешен')),
        );
      } catch (e) {
        print('Error decoding JSON: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Ошибка: некорректный ответ от сервера')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${response.body}')),
      );
    }
  }

  Future<void> _logout() async {
    final url = 'http://localhost:8080/logout';
    try {
      print('Requesting: $url');
      print('Token: $_token');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      print('Response: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Logout message: ${data['message']}');
        await _clearSession();
        setState(() {
          _token = null;
          _email = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выход успешен')),
        );
      } else {
        final errorBody = response.body.isNotEmpty
            ? jsonDecode(response.body)['error']
            : 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $errorBody')),
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: не удалось завершить выход')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Личный кабинет'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _token == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Пароль',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _login,
                        child: const Text('Вход'),
                      ),
                      ElevatedButton(
                        onPressed: _register,
                        child: const Text('Регистрация'),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Вы вошли как:',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Email: $_email',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _logout,
                    child: const Text('Выйти'),
                  ),
                ],
              ),
      ),
    );
  }
}
