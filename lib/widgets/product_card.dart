
import 'package:flutter/material.dart';
import 'package:getdatabacken/widgets/product_image.dart';

import '../models/product_model.dart';
import '../utils/format.dart';

class ProductCard extends StatelessWidget {
  final ProductModel item;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final shown = item.prices.take(2).toList(); // បង្ហាញត្រឹម 2
    final extra = item.prices.length - shown.length; // នៅសល់ប៉ុន្មាន

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- រូប ----------
            Expanded(
              child: SizedBox.expand(child: ProductImage(item: item)),
            ),

            // ---------- ឈ្មោះ + តម្លៃ ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (shown.isEmpty)
                    Text('មិនទាន់មានតម្លៃ', style: text.bodySmall)
                  else ...[
                    for (final p in shown) _priceRow(p, scheme, text),
                    if (extra > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '+$extra តម្លៃទៀត',
                          style: text.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- ជួរតម្លៃ: ឯកតា ........ តម្លៃ ----------
  Widget _priceRow(Price p, ColorScheme scheme, TextTheme text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              p.unit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            formatMoney(p.price, p.currency),
            style: text.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }


}
