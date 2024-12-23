import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchCartItems() async {
    final token = await getToken();
    if (token == null) {
      print("Authorization token missing");
      return;
    }

    final response = await http.get(
      Uri.parse('http://localhost:8080/getCart'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        cartItems = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    } else {
      print("Failed to fetch cart items: ${response.body}");
    }
  }

  Future<void> placeOrder() async {
    final token = await getToken();
    if (token == null) {
      print("Authorization token missing");
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:8080/placeOrder'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully!")),
      );
      fetchCartItems(); // Обновляем корзину
    } else {
      print("Failed to place order: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Корзина")),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                "Ваша корзина пуста",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  leading: Image.asset(
                    'assets/${item['photo_link']}', // Динамически добавляем путь из базы данных
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error,
                          size: 50); // Обработчик ошибки
                    },
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item['title']),
                  subtitle: Text("Цена: ${item['price']} ₽"),
                );
              },
            ),
      bottomNavigationBar: cartItems.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: placeOrder,
                child: const Text("Оформить заказ"),
              ),
            )
          : null,
    );
  }
}
