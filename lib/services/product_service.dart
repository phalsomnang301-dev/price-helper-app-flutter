import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:getdatabacken/models/product_model.dart';
import 'package:getdatabacken/services/base.dart';
import 'package:http/http.dart' as http;

class ProductService {
  final _baseUrl = BaseURL.base;

  Future<List<ProductModel>> fetch({
    String search = '',
    int? categoryId,
  }) async {
    final params = <String, String>{
      if (search.isNotEmpty) 'search': search,
      if (categoryId != null) 'category_id': categoryId.toString(),
    };

    final uri = Uri.parse(
      "$_baseUrl/api/products",
    ).replace(queryParameters: params.isEmpty ? null : params);

    try {
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
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

  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

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

  Future<void> uploadImage(int id, String path) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("$_baseUrl/api/products/$id/image"),
    );
    request.headers['Accept'] = 'application/json';
    request.files.add(await http.MultipartFile.fromPath('image', path));

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 200) {
      throw Exception(_extractError(res));
    }
  }

    Future<void> delete(int id) async {
    final res = await http
        .delete(
          Uri.parse("$_baseUrl/api/products/$id"),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) throw Exception(_extractError(res));
  }

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

  // Future<List<ProductModel>> fetch() async {
  //   final url = "$_baseUrl/api/products";

  //   try {
  //     final response = await http
  //         .get(Uri.parse(url))
  //         .timeout(const Duration(seconds: 10));
  //     if (response.statusCode == 200) {
  //       // ប្រើ utf8.decode ការពារដាច់អក្សរខ្មែរ
  //       final responseBody = utf8.decode(response.bodyBytes);
  //       final list = await compute(productModelFromJson, responseBody);
  //       return list;
  //     }
  //     throw Exception('Server Error: ${response.statusCode}');
  //   } catch (e) {
  //     throw Exception('Failed to load products: $e');
  //   }
  // }

  // Future<bool> create(Product item) async {
  //   final url = "$_baseUrl/api/products";

  //   try {
  //     final response = await http
  //         .post(
  //           Uri.parse(url),
  //           headers: {
  //             'Content-Type': 'application/json',
  //             "Accept": "application/json",
  //           },
  //           body: jsonEncode(item.toJson()),
  //         )
  //         .timeout(const Duration(seconds: 10));
  //     if (response.statusCode == 201) {
  //       debugPrint("response body: ${response.body}");
  //       return true;
  //     }
  //     throw Exception('Server Error: ${response.statusCode}');
  //   } catch (e) {
  //     throw Exception('Failed to posting students: $e');
  //   }
  // }

  // Future<bool> update(StudentModel item) async {
  //   final url = "$_baseUrl/api/students/${item.id}";

  //   final body = {"full_name": item.fullName};

  //   try {
  //     final response = await http
  //         .put(
  //           Uri.parse(url),
  //           headers: {'Content-Type': 'application/json'},
  //           body: jsonEncode(body),
  //         )
  //         .timeout(const Duration(seconds: 10));
  //     if (response.statusCode == 200) {
  //       debugPrint("response body: ${response.body}");
  //       return true;
  //     }
  //     throw Exception('Server Error: ${response.statusCode}');
  //   } catch (e) {
  //     throw Exception('Failed to updating students: $e');
  //   }
  // }

  // Future<bool> delete(int id) async {
  //   final url = "$_baseUrl/api/students/$id";

  //   try {
  //     final response = await http
  //         .delete(Uri.parse(url))
  //         .timeout(const Duration(seconds: 10));
  //     if (response.statusCode == 200) {
  //       debugPrint("response body: ${response.body}");
  //       return true;
  //     }
  //     throw Exception('Server Error: ${response.statusCode}');
  //   } catch (e) {
  //     throw Exception('Failed to deleting students: $e');
  //   }
  // }
}
