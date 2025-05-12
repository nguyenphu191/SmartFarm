import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_farm/models/plant_model.dart';
import 'package:smart_farm/utils/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class PlantProvider with ChangeNotifier {
  String baseUrl = BaseUrl.baseUrl;
  bool _loading = false;
  bool get loading => _loading;
  List<PlantModel> _plants = [];
  PlantModel? _plant;
  List<PlantModel> get plants => _plants;
  PlantModel? get plant => _plant;

  Future<bool> fetchPlants(bool harvested) async {
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
        Uri.parse(
            '$baseUrl/api/plants/harvest-status?harvested=${harvested.toString()}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Plants fetched successfully');

        final body = json.decode(response.body);
        final List<dynamic> data = body['data']['plants'];
        print('Data: $data');
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

  Future<bool> fetchPlantById(
      String seasonId, String locationId, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      print('Token is null, cannot fetch seasons');

      return false;
    }
    _loading = true;
    notifyListeners();
    print('Fetching plants...');
    _plant = null;
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/seasons/${seasonId}/locations/${locationId}/plants/${id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Plants fetched successfully');
        final body = json.decode(response.body);
        final Map<String, dynamic> data = body['data'];
        print('Data: $data');
        _plant = PlantModel.fromJson(data);
        print('Plants fetched successfully: ${_plant?.name}');
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
      _loading = false;
      notifyListeners();
      print(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> createPlant(
      {String? seasonId,
      String? locationId,
      String? name,
      File? image,
      String? sysImage,
      String? status,
      String? note,
      String? startdate,
      String? enddate,
      String? address}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      print('Token is null, cannot fetch seasons');

      return false;
    }
    _loading = true;
    notifyListeners();
    print('Creating plant...');
    final dio = Dio();

    final formData = FormData();
    formData.fields.add(MapEntry('name', name!));
    formData.fields.add(MapEntry('status', status!));
    formData.fields.add(MapEntry('note', note!));
    formData.fields.add(MapEntry('startdate', startdate!));
    formData.fields.add(MapEntry('plantingDate', enddate!));
    formData.fields.add(MapEntry('address', address!));
    if (image != null) {
      final filename = image.path.split('/').last;
      if (!await image.exists()) {
        print('File không tồn tại: ${image.path}');
        _loading = false;
        notifyListeners();
        return false;
      }

      // Kiểm tra xem có phải là file ảnh hợp lệ không
      if (!_isImageFile(image.path)) {
        print('File không phải là ảnh hợp lệ: ${image.path}');
        _loading = false;
        notifyListeners();
        return false;
      }

      // Lấy thông tin về file
      final fileStats = await image.stat();
      print('File size: ${fileStats.size} bytes');

      // Tạo mimetype chính xác từ extension file
      final mimeType = _getMimeTypeFromExtension(image.path);
      print('MIME Type: ${mimeType.type}/${mimeType.subtype}');

      // Thêm file vào form với tên field là image và MIME type chính xác
      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            image.path,
            filename: filename,
            contentType: mimeType,
          ),
        ),
      );
    } else {
      formData.fields.add(MapEntry('defaultImage', sysImage!));
    }
    final uri = Uri.parse(
        '$baseUrl/api/seasons/${seasonId}/locations/${locationId}/plants');
    try {
      final response = await dio.post(
        uri.toString(),
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Plant created successfully');
        print('Response: ${response.data}');
        final Map<String, dynamic> body = response.data;
        final data = body['data'];

        print('Data: $data');
        PlantModel plant = PlantModel.fromJson(data);
        _plants.add(plant);
        _loading = false;
        notifyListeners();
        return true;
      } else {
        print('Failed to create plant: ${response.statusCode}');
        print('Response body: ${response.data}');
        _loading = false;
        notifyListeners();
        throw Exception('Failed to create plant');
      }
    } catch (e) {
      print(e);
      _loading = false;
      notifyListeners();
    } finally {
      _loading = false;
      notifyListeners();
    }
    return false;
  }

  // Hàm để lấy MIME type từ file extension
  MediaType _getMimeTypeFromExtension(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.gif':
        return MediaType('image', 'gif');
      case '.webp':
        return MediaType('image', 'webp');
      case '.bmp':
        return MediaType('image', 'bmp');
      default:
        return MediaType('image', 'jpeg'); // Mặc định là jpeg
    }
  }

  // Hàm để kiểm tra nếu file là ảnh hợp lệ
  bool _isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp']
        .contains(extension);
  }

  Future<bool> updatePlant(
      {String? seasonId,
      String? locationId,
      String? id,
      String? name,
      File? image,
      String? sysImage,
      String? status,
      String? note,
      String? startdate,
      String? enddate,
      String? address}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      print('Token is null, cannot update plant');
      return false;
    }

    // Kiểm tra xem ID có hợp lệ không
    if (id == null || id.isEmpty) {
      print('Plant ID is null or empty, cannot update plant');
      return false;
    }

    // Kiểm tra seasonId và locationId
    if (seasonId == null || locationId == null) {
      print('SeasonId or LocationId is null, cannot update plant');
      return false;
    }

    _loading = true;
    notifyListeners();
    print('Updating plant...');
    final dio = Dio();

    // Tạo FormData và kiểm tra các trường bắt buộc
    final formData = FormData();

    // Thêm các trường thông tin, kiểm tra null
    if (name != null) formData.fields.add(MapEntry('name', name));
    if (status != null) formData.fields.add(MapEntry('status', status));
    if (note != null) formData.fields.add(MapEntry('note', note));
    if (startdate != null)
      formData.fields.add(MapEntry('startdate', startdate));
    if (enddate != null) formData.fields.add(MapEntry('plantingDate', enddate));
    if (address != null) formData.fields.add(MapEntry('address', address));

    // Xử lý file ảnh
    if (image != null) {
      // Kiểm tra file có tồn tại không
      if (!await image.exists()) {
        print('File không tồn tại: ${image.path}');
        _loading = false;
        notifyListeners();
        return false;
      }

      // Kiểm tra xem có phải là file ảnh hợp lệ không
      if (!_isImageFile(image.path)) {
        print('File không phải là ảnh hợp lệ: ${image.path}');
        _loading = false;
        notifyListeners();
        return false;
      }

      // Lấy thông tin về file
      final fileStats = await image.stat();
      print('File size: ${fileStats.size} bytes');

      // Tạo mimetype chính xác từ extension file
      final mimeType = _getMimeTypeFromExtension(image.path);
      print('MIME Type: ${mimeType.type}/${mimeType.subtype}');

      // Thêm file vào form với tên field là image và MIME type chính xác
      final filename = image.path.split('/').last;
      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            image.path,
            filename: filename,
            contentType: mimeType,
          ),
        ),
      );
    } else if (sysImage != null && sysImage.isNotEmpty) {
      // Chỉ thêm defaultImage nếu image là null và sysImage không phải null/rỗng
      formData.fields.add(MapEntry('defaultImage', sysImage));
    }

    // In thông tin debug
    print('Form data fields: ${formData.fields}');
    if (formData.files.isNotEmpty) {
      print(
          'Form data files: ${formData.files.map((f) => '${f.key}: ${f.value.filename}').join(', ')}');
    }

    // Tạo URI
    final uri = Uri.parse(
        '$baseUrl/api/seasons/$seasonId/locations/$locationId/plants/$id');
    print('Request URI: $uri');

    try {
      final response = await dio.put(
        uri.toString(),
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Không cần set 'Content-Type' với FormData, Dio sẽ tự động thiết lập
          },
          validateStatus: (status) {
            // Cho phép tất cả status codes để xử lý lỗi một cách rõ ràng
            return true;
          },
        ),
      );

      // In response để debug
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Plant updated successfully');

        try {
          final Map<String, dynamic> body = response.data is String
              ? json.decode(response.data)
              : response.data;

          final data = body['data'];
          print('Data: $data');

          if (data != null) {
            // Cập nhật plant hiện tại
            PlantModel plant = PlantModel.fromJson(data);
            _plant = plant;

            // Cập nhật plant trong danh sách nếu có
            int index = _plants.indexWhere((element) => element.id == id);
            if (index != -1) {
              _plants[index] = plant;
            }

            _loading = false;
            notifyListeners();
            return true;
          } else {
            print('Response data format is invalid: no data field');
            _loading = false;
            notifyListeners();
            return false;
          }
        } catch (parseError) {
          print('Error parsing response data: $parseError');
          _loading = false;
          notifyListeners();
          return false;
        }
      } else {
        print('Failed to update plant: ${response.statusCode}');
        print('Response body: ${response.data}');
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error during plant update: $e');
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
