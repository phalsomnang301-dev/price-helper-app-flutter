// import 'dart:convert';

// import 'package:getdatabacken/services/auth_token.dart';
// import 'package:http/http.dart' as http;

// import '../models/product_model.dart';
// import 'base.dart';

// class CategoryService {
//   final _baseUrl = BaseURL.base;

//   Future<List<Category>> fetch() async {
//     final response = await http
//         .get(
//           Uri.parse("$_baseUrl/api/categories"),
//        headers: AuthToken.headers(),
//         )
//         .timeout(const Duration(seconds: 10));

//     if (response.statusCode == 200) {
//       final body = json.decode(utf8.decode(response.bodyBytes));
//       return List<Category>.from(
//         body['data'].map((x) => Category.fromJson(x)),
//       );
//     }
//     throw Exception('Server Error: ${response.statusCode}');
//   }
// }



import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import 'auth_token.dart';
import 'base.dart';

class CategoryService {
  final _baseUrl = BaseURL.base;

  Future<List<Category>> fetch() async {
    final response = await http
        .get(
          Uri.parse("$_baseUrl/api/categories"),
          headers: AuthToken.headers(),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = json.decode(utf8.decode(response.bodyBytes));
      return List<Category>.from(
        body['data'].map((x) => Category.fromJson(x)),
      );
    }
    throw Exception('Server Error: ${response.statusCode}');
  }
}