import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_farm/models/user_model.dart';
import 'package:smart_farm/utils/base_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String _baseUrl = BaseUrl.baseUrl;
  bool _loading = false;
  String? _token;
  UserModel? _user;

  bool get loading => _loading;
  String? get token => _token;
  UserModel? get user => _user;

  Future<bool> register(String username, String email, String password) async {
    _loading = true;
    notifyListeners();
    print('Registering user...');
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'address': '',
          'phone': '',
        }),
      );
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Response data: $data');
        _token = data['data']['token'];
        _user = UserModel.fromJson(data['data']['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        _loading = false;
        notifyListeners();
        return true;
      } else {
        print('Failed to register user: ${response.body}');
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error during registration: $e');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['data']['token'];
        _user = UserModel.fromJson(data['data']['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}
