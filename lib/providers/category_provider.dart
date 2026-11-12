import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_model.dart';
import '../services/category_service.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return CategoryService().fetch();
});