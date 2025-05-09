import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_farm/models/location_model.dart';
import 'package:smart_farm/utils/base_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationProvider with ChangeNotifier {
  String baseUrl = BaseUrl.baseUrl;
  bool _loading = false;
  bool get loading => _loading;
  List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;
  void reset() {
    _locations = [];
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchLocations(String seasonId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      print('Token is null, cannot fetch locations');

      return;
    }
    _loading = true;
    notifyListeners();

    print('Fetching locations...');
    _locations = [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/seasons/${seasonId}/locations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        final List<dynamic> data = body['data']['locations'];
        _locations =
            data.map((location) => LocationModel.fromJson(location)).toList();
      } else {
        throw Exception('Failed to load locations');
      }
    } catch (e) {
      print(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addLocation(
      String seasonId, String name, String description, int area) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      print('Token is null, cannot add location');
      return false;
    }
    _loading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/seasons/${seasonId}/locations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'description': description,
          'area': '${area} m2',
        }),
      );
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchLocations(seasonId);
        return true;
      } else {
        throw Exception('Failed to add location');
      }
    } catch (e) {
      print(e);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateLocation(
      String id, String name, String description, int area) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      print('Token is null, cannot update location');
      return false;
    }
    _loading = true;
    notifyListeners();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/locations/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'description': description,
          'area': '${area} m2',
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchLocations(id);
        return true;
      } else {
        throw Exception('Failed to update location');
      }
    } catch (e) {
      print(e);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteLocation(String seasonId, String locationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      print('Token is null, cannot delete location');
      return false;
    }
    _loading = true;
    notifyListeners();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/seasons/${seasonId}/locations/$locationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchLocations(seasonId);
        return true;
      } else {
        throw Exception('Failed to delete location');
      }
    } catch (e) {
      print(e);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
