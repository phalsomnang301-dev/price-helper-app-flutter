import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:getdatabacken/providers/product_provider.dart';
import 'package:getdatabacken/screens/product_form_screen.dart';

import '../models/product_model.dart';
import '../utils/format.dart';
import '../utils/message.dart';
import '../widgets/product_image.dart';

class ProductDetailScreen extends ConsumerWidget {
  final ProductModel item;

  const ProductDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final hasNote = item.note != null && item.note!.trim().isNotEmpty;
  

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ---------- រូបធំ ----------
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: scheme.surface.withValues(alpha: 0.85),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: ProductImage(item: item, letterSize: 120),
            ),
          ),

          // ---------- ព័ត៌មាន ----------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    avatar: const Icon(Icons.category_outlined, size: 18),
                    label: Text(item.category.name),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.name,
                    style: text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (hasNote) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.note!,
                      style: text.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'តម្លៃ',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (item.prices.isEmpty)
                    Text('មិនទាន់មានតម្លៃ', style: text.bodyMedium)
                  else
                    for (final p in item.prices) _priceTile(p, scheme, text),

                  const SizedBox(height: 24),

                  // ---------- ប៊ូតុង (មេរៀន 4.6 និង 4.7) ----------
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final ok = await showDeleteDialog(context, itemName: item.name);   // ← បន្ទាត់ថ្មី
                            if (ok != true) return;

                            try {
                              await ref
                                  .read(productNotifierProvider.notifier)
                                  .deleteProduct(item.id);
                              if (context.mounted) Navigator.of(context).pop();
                            } catch (e) {
                              if (context.mounted) {
                                showMessage(
                                  context,
                                  e.toString().replaceFirst('Exception: ', ''),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('លុប'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            final saved =
                                await Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductFormScreen(item: item),
                                  ),
                                );
                            // កែរួច → ត្រឡប់ទៅបញ្ជី (ព្រោះ Detail នេះរក្សាទិន្នន័យចាស់)
                            if (saved == true && context.mounted)
                              Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('កែ'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- ជួរតម្លៃធំៗ ----------
  Widget _priceTile(Price p, ColorScheme scheme, TextTheme text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              p.unit,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            formatMoney(p.price, p.currency),
            style: text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
