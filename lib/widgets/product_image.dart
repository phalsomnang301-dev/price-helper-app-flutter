import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/product_model.dart';

class ProductImage extends StatelessWidget {
  final ProductModel item;
  final double letterSize;

  const ProductImage({super.key, required this.item, this.letterSize = 44});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final placeholder = Container(
      color: scheme.primaryContainer.withValues(alpha: 0.55),
      alignment: Alignment.center,
      child: Text(
        item.name.isEmpty ? '?' : String.fromCharCode(item.name.runes.first),
        style: TextStyle(
          fontSize: letterSize,
          fontWeight: FontWeight.w700,
          color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
        ),
      ),
    );

    return Hero(
      tag: 'product-image-${item.id}', // tag ត្រូវតែមិនដូចគ្នារវាងទំនិញ
      child: item.imageUrl == null
          ? placeholder
          : CachedNetworkImage(
              imageUrl: item.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (_, __) => placeholder,
              errorWidget: (_, __, ___) => placeholder,
            ),
    );
  }
}