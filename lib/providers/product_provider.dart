

// import 'dart:async';

// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../models/product_model.dart';
// import '../services/product_service.dart';

// final _productServiceProvider = Provider<ProductService>((ref) {
//   return ProductService();
// });

// // អក្សរស្វែងរក
// class SearchNotifier extends Notifier<String> {
//   @override
//   String build() => '';

//   void set(String value) => state = value;
// }

// final searchProvider =
//     NotifierProvider<SearchNotifier, String>(SearchNotifier.new);

// // ប្រភេទដែលបានជ្រើស (null = ទាំងអស់)
// class SelectedCategoryNotifier extends Notifier<int?> {
//   @override
//   int? build() => null;

//   void set(int? value) => state = value;
// }

// final selectedCategoryProvider =
//     NotifierProvider<SelectedCategoryNotifier, int?>(
//         SelectedCategoryNotifier.new);

// // បញ្ជីទំនិញ: ស្តាប់ search + category
// class _ProductProvider extends AsyncNotifier<List<ProductModel>> {
//   @override
//   FutureOr<List<ProductModel>> build() {
//     final service = ref.watch(_productServiceProvider);
//     final search = ref.watch(searchProvider);
//     final categoryId = ref.watch(selectedCategoryProvider);
//     return service.fetch(search: search, categoryId: categoryId);
//   }

//   Future<void> refresh() async {
//     final service = ref.read(_productServiceProvider);
//     final search = ref.read(searchProvider);
//     final categoryId = ref.read(selectedCategoryProvider);
//     state = await AsyncValue.guard(
//       () => service.fetch(search: search, categoryId: categoryId),
//     );
//   }
// }

// final productNotifierProvider =
//     AsyncNotifierProvider<_ProductProvider, List<ProductModel>>(
//         _ProductProvider.new);




import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// អក្សរស្វែងរក
class SearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final searchProvider =
    NotifierProvider<SearchNotifier, String>(SearchNotifier.new);

// ប្រភេទដែលបានជ្រើស (null = ទាំងអស់)
class SelectedCategoryNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? value) => state = value;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, int?>(
        SelectedCategoryNotifier.new);

// បញ្ជីទំនិញ
class ProductNotifier extends AsyncNotifier<List<ProductModel>> {
  @override
  FutureOr<List<ProductModel>> build() {
    final service = ref.watch(productServiceProvider);
    final search = ref.watch(searchProvider);
    final categoryId = ref.watch(selectedCategoryProvider);
    return service.fetch(search: search, categoryId: categoryId);
  }

  Future<void> refresh() async {
    final service = ref.read(productServiceProvider);
    final search = ref.read(searchProvider);
    final categoryId = ref.read(selectedCategoryProvider);
    state = await AsyncValue.guard(
      () => service.fetch(search: search, categoryId: categoryId),
    );
  }

  /// បន្ថែម (id == null) ឬ កែ (id != null) ហើយ Upload រូបបើមាន
  Future<void> saveProduct({
    int? id,
    required Map<String, dynamic> data,
    String? imagePath,
  }) async {
    final service = ref.read(productServiceProvider);

    final saved = id == null
        ? await service.create(data)
        : await service.update(id, data);

    if (imagePath != null) {
      await service.uploadImage(saved.id, imagePath);
    }

    ref.invalidateSelf();
    await future;
  }
    Future<void> deleteProduct(int id) async {
    await ref.read(productServiceProvider).delete(id);
    ref.invalidateSelf();
    await future;
  }
}

final productNotifierProvider =
    AsyncNotifierProvider<ProductNotifier, List<ProductModel>>(
        ProductNotifier.new);