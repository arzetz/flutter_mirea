import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchOrders() async {
    final token = await getToken();
    if (token == null) {
      print("Authorization token missing");
      return;
    }

    final response = await http.get(
      Uri.parse('http://localhost:8080/orders'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        orders = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    } else {
      print("Failed to fetch orders: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Мои Заказы")),
      body: orders.isEmpty
          ? const Center(
              child: Text(
                "Нет заказов для отображения",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text(order['cucumber_title']),
                  subtitle: Text("Дата заказа: ${order['created_at']}"),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                );
              },
            ),
    );
  }
}
