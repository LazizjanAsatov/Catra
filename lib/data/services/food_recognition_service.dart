import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../models/enums.dart';
import '../models/product.dart';

class FoodRecognitionService {
  FoodRecognitionService({http.Client? client})
    : _client = client ?? http.Client();

  static const String _endpoint =
      'https://food-ai-check.jprq.live/analyze-food';

  final http.Client _client;

  Future<Product?> analyze(XFile file) async {
    final uri = Uri.parse(_endpoint);
    final bytes = await file.readAsBytes();
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
          contentType: _contentType(file.path),
        ),
      );

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200) {
      throw HttpException(
        'Food recognition failed: ${response.statusCode}',
        uri: uri,
      );
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data.isEmpty) return null;
    return _mapResponseToProduct(data);
  }

  Product _mapResponseToProduct(Map<String, dynamic> json) {
    final now = DateTime.now();
    final nutrition = (json['nutrition'] as Map?)?.cast<String, dynamic>();
    final expiry = (json['expiry'] as Map?)?.cast<String, dynamic>();
    final id = json['id']?.toString() ?? now.millisecondsSinceEpoch.toString();
    return Product(
      id: id,
      name:
          (json['product_name'] ?? json['name'])?.toString() ?? 'Unknown item',
      brand: json['brand']?.toString(),
      barcode: json['barcode']?.toString(),
      imageFrontPath: json['image_url']?.toString(),
      imageBackPath: null,
      calories:
          _extractDouble(nutrition, 'calories') ??
          _toDouble(json['calories']) ??
          0,
      protein: _extractDouble(nutrition, 'protein') ?? 0,
      carbs: _extractDouble(nutrition, 'carbs') ?? 0,
      fat: _extractDouble(nutrition, 'fat') ?? 0,
      sugar: _extractDouble(nutrition, 'sugar') ?? 0,
      salt: _extractDouble(nutrition, 'salt') ?? 0,
      expiryDate: _parseDate(expiry?['expiry_date']),
      quantity: 1,
      unit: UnitType.gram,
      createdAt: now,
      updatedAt: now,
      isInStock: false,
    );
  }

  double? _extractDouble(Map<String, dynamic>? map, String key) {
    if (map == null) return null;
    return _toDouble(map[key]);
  }

  double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final sanitized = value.replaceAll(RegExp('[^0-9\\.-]'), '');
      return double.tryParse(sanitized);
    }
    return null;
  }

  DateTime? _parseDate(Object? value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  MediaType _contentType(String path) {
    final lowered = path.toLowerCase();
    if (lowered.endsWith('.png')) return MediaType('image', 'png');
    if (lowered.endsWith('.jpg') || lowered.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    return MediaType('image', 'jpeg');
  }
}

final foodRecognitionServiceProvider = Provider<FoodRecognitionService>((ref) {
  return FoodRecognitionService();
});
