import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_farm/models/location_model.dart';
import 'package:smart_farm/models/plant_model.dart';
import 'package:smart_farm/utils/base_url.dart';
import 'package:http/http.dart' as http;

class PlantProvider with ChangeNotifier {
  String baseUrl = BaseUrl.baseUrl;
  bool _loading = false;
  bool get loading => _loading;
  List<PlantModel> _plants = [];
  PlantModel? _plant;
  List<PlantModel> get plants => _plants;
  PlantModel? get plant => _plant;
  List<LocationModel> _locations = [];

  Future<bool> fetchPlants(String seasons) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      print('Token is null, cannot fetch seasons');

      return false;
    }
    _loading = true;
    notifyListeners();
    print('Fetching plants...');
    _plants = [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/plants'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        final List<dynamic> data = body['data']['plants'];
        _plants = data.map((plant) => PlantModel.fromJson(plant)).toList();
        _plants.sort((a, b) {
          if (a.status == "active" && b.status != "active") return -1;
          if (a.status != "active" && b.status == "active") return 1;
          return 0;
        });
        print('Plants fetched successfully: ${_plants.length}');
        print('Plants: $_plants');
        _loading = false;
        notifyListeners();
        return true;
      } else {
        print('Failed to load plants: ${response.statusCode}');
        print('Response body: ${response.body}');
        _loading = false;
        notifyListeners();

        throw Exception('Failed to load plants');
      }
    } catch (e) {
      print(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
    return false;
  }
}
