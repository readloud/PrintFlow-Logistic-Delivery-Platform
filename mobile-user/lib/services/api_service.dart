import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000/api');
  
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    
    return _handleResponse(response);
  }
  
  Future<dynamic> post(String endpoint, dynamic data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    
    return _handleResponse(response);
  }
  
  Future<dynamic> put(String endpoint, dynamic data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    
    return _handleResponse(response);
  }
  
  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    
    return _handleResponse(response);
  }
  
  dynamic _handleResponse(http.Response response) {
    final data = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else if (response.statusCode == 401) {
      _handleUnauthorized();
      throw Exception('Unauthorized');
    } else {
      throw Exception(data['error'] ?? 'Request failed');
    }
  }
  
  Future<void> _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refreshToken');
    // Navigate to login screen
  }
  
  // Auth endpoints
  Future<dynamic> login(String email, String password) async {
    return post('/auth/login', {'email': email, 'password': password});
  }
  
  Future<dynamic> register(Map<String, dynamic> userData) async {
    return post('/auth/register', userData);
  }
  
  // Order endpoints
  Future<dynamic> getOrders() async {
    return get('/orders');
  }
  
  Future<dynamic> createOrder(Map<String, dynamic> orderData) async {
    return post('/orders', orderData);
  }
  
  Future<dynamic> trackOrder(String orderId) async {
    return get('/orders/$orderId/track');
  }
  
  // Payment endpoints
  Future<dynamic> createPayment(String orderId, String method) async {
    return post('/payments', {'orderId': orderId, 'method': method});
  }
}