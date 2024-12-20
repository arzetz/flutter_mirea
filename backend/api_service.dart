import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080',
    headers: {'Content-Type': 'application/json'},
  ));

  // Добавить огурчик
  Future<void> addCucumber({
    required int id,
    required String title,
    required String description,
    required String price,
    required String photoPath,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'photo': await MultipartFile.fromFile(photoPath, filename: 'f1.jpg'),
      });

      final response = await _dio.post('/add', data: formData);
      if (response.statusCode == 201) {
        print('Cucumber added successfully!');
      } else {
        print('Failed to add cucumber: ${response.data}');
      }
    } catch (e) {
      print('Error adding cucumber: $e');
    }
  }

  // Получить список всех огурчиков
  Future<List<Map<String, dynamic>>> getCucumbers() async {
    try {
      final response = await _dio.get('/cucumbers');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to fetch cucumbers');
      }
    } catch (e) {
      print('Error fetching cucumbers: $e');
      return [];
    }
  }

  // Добавить огурчик в избранное
  Future<void> addToFavorites(int id) async {
    try {
      final response = await _dio.post('/addToFavorites', data: {'id': id});
      if (response.statusCode == 200) {
        print('Cucumber added to favorites!');
      } else {
        print('Failed to add to favorites: ${response.data}');
      }
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  // Удалить из избранного
  Future<void> removeFromFavorites(int id) async {
    try {
      final response =
          await _dio.post('/removeFromFavorites', data: {'id': id});
      if (response.statusCode == 200) {
        print('Cucumber removed from favorites!');
      } else {
        print('Failed to remove from favorites: ${response.data}');
      }
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }

  // Добавить в корзину
  Future<void> addToCart(int id) async {
    try {
      final response = await _dio.post('/addToCart', data: {'id': id});
      if (response.statusCode == 200) {
        print('Cucumber added to cart!');
      } else {
        print('Failed to add to cart: ${response.data}');
      }
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  // Получить корзину
  Future<List<Map<String, dynamic>>> getCart() async {
    try {
      final response = await _dio.get('/getCart');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to fetch cart');
      }
    } catch (e) {
      print('Error fetching cart: $e');
      return [];
    }
  }
}
