
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import 'auth_token.dart';
import 'base.dart';

class ProductService {
  final _baseUrl = BaseURL.base;

  Map<String, String> get _jsonHeaders => AuthToken.headers(json: true);

  // ---------- អាន ----------
  Future<List<ProductModel>> fetch({
    String search = '',
    int? categoryId,
  }) async {
    final params = <String, String>{
      if (search.isNotEmpty) 'search': search,
      if (categoryId != null) 'category_id': categoryId.toString(),
    };

    final uri = Uri.parse("$_baseUrl/api/products").replace(
      queryParameters: params.isEmpty ? null : params,
    );

    try {
      final response = await http
          .get(uri, headers: AuthToken.headers())
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        return await compute(productModelFromJson, responseBody);
      }
      throw Exception('Server Error: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  // ---------- បន្ថែម ----------
  Future<ProductModel> create(Map<String, dynamic> data) async {
    final res = await http
        .post(
          Uri.parse("$_baseUrl/api/products"),
          headers: _jsonHeaders,
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 10));
    return _parseSingle(res, 201);
  }

  // ---------- កែ ----------
  Future<ProductModel> update(int id, Map<String, dynamic> data) async {
    final res = await http
        .put(
          Uri.parse("$_baseUrl/api/products/$id"),
          headers: _jsonHeaders,
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 10));
    return _parseSingle(res, 200);
  }

  // ---------- Upload រូប ----------
  Future<void> uploadImage(int id, String path) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("$_baseUrl/api/products/$id/image"),
    );
    request.headers.addAll(AuthToken.headers());
    request.files.add(await http.MultipartFile.fromPath('image', path));

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 200) {
      throw Exception(_extractError(res));
    }
  }

  // ---------- លុប ----------
  Future<void> delete(int id) async {
    final res = await http
        .delete(
          Uri.parse("$_baseUrl/api/products/$id"),
          headers: AuthToken.headers(),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) throw Exception(_extractError(res));
  }

  // ---------- ជំនួយ ----------
  ProductModel _parseSingle(http.Response res, int expected) {
    if (res.statusCode != expected) throw Exception(_extractError(res));
    final body = json.decode(utf8.decode(res.bodyBytes));
    return ProductModel.fromJson(body['data']);
  }

  // ទាញសារ Error ពី Laravel (422 មាន "errors")
  String _extractError(http.Response res) {
    try {
      final body = json.decode(utf8.decode(res.bodyBytes));
      if (body['errors'] is Map && (body['errors'] as Map).isNotEmpty) {
        final first = (body['errors'] as Map).values.first;
        return first is List ? first.first.toString() : first.toString();
      }
      if (body['message'] != null) return body['message'].toString();
    } catch (_) {}
    return 'Server Error: ${res.statusCode}';
  }
}