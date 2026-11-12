import 'dart:async';
import 'package:getdatabacken/screens/product_detail_screen.dart';
import 'package:getdatabacken/screens/product_form_screen.dart';

import '../providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getdatabacken/models/product_model.dart';
import 'package:getdatabacken/providers/product_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../widgets/product_card.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  final bool _showButton = false;

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _scroller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchProvider.notifier).set(text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text("Price Helper"),
  actions: [
    IconButton.filledTonal(
      tooltip: 'បន្ថែមទំនិញ',
      icon: const Icon(Icons.add),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => const ProductFormScreen()),
        );
      },
    ),
    const SizedBox(width: 12),
  ],
),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: _showButton ? _buildFloating() : null,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        onChanged: _onSearchChanged,
        decoration: const InputDecoration(
          hintText: 'ស្វែងរកទំនិញ...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final catsAsync = ref.watch(categoriesProvider);
    final selected = ref.watch(selectedCategoryProvider);

    return catsAsync.when(
      loading: () => const SizedBox(height: 48),
      error: (e, s) => const SizedBox.shrink(),
      data: (cats) => SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: const Text("ទាំងអស់"),
                labelStyle: TextStyle(
                  color: selected == null
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                  fontWeight: FontWeight.w600,
                ),
                selected: selected == null,
                onSelected: (_) =>
                    ref.read(selectedCategoryProvider.notifier).set(null),
              ),
            ),
            for (final c in cats)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c.name),
                  labelStyle: TextStyle(
                    color: selected == c.id
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                    fontWeight: FontWeight.w600,
                  ),
                  selected: selected == c.id,
                  onSelected: (_) =>
                      ref.read(selectedCategoryProvider.notifier).set(c.id),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final productAsync = ref.watch(productNotifierProvider);

    return Center(
      child: RefreshIndicator(
        onRefresh: () => ref.read(productNotifierProvider.notifier).refresh(),
    
        child: productAsync.when(

          data: (items) {
            return _buildGridView(items);
          },
          error: (e, s) {
            debugPrint("Error: ${e.toString()}");
            debugPrint("TrackTrace: ${s.toString()}");
            return Text("Error: ${e.toString()}");
          },
          loading: () {
            return _buildSkeleton();
          },
        ),
      ),
    );
  }

  Widget _buildFloating() {
    return FloatingActionButton(
      shape: CircleBorder(),
      onPressed: () {
        _scroller.animateTo(
          0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      child: Icon(Icons.arrow_upward),
    );
  }

  Widget _buildSkeleton() {
    return Skeletonizer(
      child: GridView.builder(
        itemCount: 40,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
        ),
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(color: Colors.grey.shade400),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "asdsadasd sadassa",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  final _scroller = ScrollController();

  Widget _buildGridView(List<ProductModel> items) {
    if (items.isEmpty) {
      return Text("No Items");
    }

    return GridView.builder(
      controller: _scroller,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
  final item = items[index];
  return ProductCard(
    item: item,
    onTap: () {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(item: item),
        ),
      );
    },
  );
},
    );
  }
}
