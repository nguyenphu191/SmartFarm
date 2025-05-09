import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_farm/models/season_model.dart';
import 'package:smart_farm/utils/base_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SeasonProvider with ChangeNotifier {
  String baseUrl = BaseUrl().baseUrl;
  bool _loading = false;
  bool get loading => _loading;
  List<SeasonModel> _seasons = [];
  List<SeasonModel> get seasons => _seasons;

  Future<void> fetchSeasons() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      print('Token is null, cannot fetch seasons');

      return;
    }
    _loading = true;
    notifyListeners();

    print('Fetching seasons...');
    _seasons = [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/seasons'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        final List<dynamic> data = body['data']['seasons'];
        _seasons = data.map((season) => SeasonModel.fromJson(season)).toList();

        _seasons.sort((a, b) {
          if (a.isActive && !b.isActive) return -1;
          if (!a.isActive && b.isActive) return 1;
          return 0;
        });
      } else {
        throw Exception('Failed to load seasons');
      }
    } catch (e) {
      print(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addSeason(
      String name, DateTime startDate, DateTime endDate) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      print('Token is null, cannot add season');
      return false;
    }
    _loading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/seasons'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        }),
      );
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchSeasons();
        return true;
      } else {
        throw Exception('Failed to add season');
      }
    } catch (e) {
      print(e);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSeason(
      {required String id,
      String? name,
      DateTime? startDate,
      DateTime? endDate}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      print('Token is null, cannot update season');
      return false;
    }
    _loading = true;
    notifyListeners();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/seasons/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'start_date': startDate?.toIso8601String(),
          'end_date': endDate?.toIso8601String(),
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchSeasons();
        return true;
      } else {
        throw Exception('Failed to update season');
      }
    } catch (e) {
      print(e);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSeason(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      print('Token is null, cannot delete season');
      return false;
    }
    _loading = true;
    notifyListeners();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/seasons/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchSeasons();
        return true;
      } else {
        throw Exception('Failed to delete season');
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
