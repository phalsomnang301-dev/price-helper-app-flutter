import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product_model.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../utils/message.dart';

// ជួរតម្លៃមួយ: ឯកតា + តម្លៃ + រូបិយប័ណ្ណ
class _PriceRow {
  final unit = TextEditingController();
  final price = TextEditingController();
  String currency;

  _PriceRow({String? unit, String? price, this.currency = 'KHR'}) {
    this.unit.text = unit ?? '';
    this.price.text = price ?? '';
  }

  void dispose() {
    unit.dispose();
    price.dispose();
  }
}

class ProductFormScreen extends ConsumerStatefulWidget {
  final ProductModel? item; // null = បន្ថែម, មាន = កែ

  const ProductFormScreen({super.key, this.item});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scroll = ScrollController();
  late final TextEditingController _name;
  late final TextEditingController _note;
  final List<_PriceRow> _prices = [];
  int? _categoryId;
  XFile? _image;
  bool _saving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final it = widget.item;
    _name = TextEditingController(text: it?.name ?? '');
    _note = TextEditingController(text: it?.note ?? '');
    _categoryId = it?.categoryId;

    if (it != null && it.prices.isNotEmpty) {
      for (final p in it.prices) {
        _prices.add(_PriceRow(
          unit: p.unit,
          price: _plain(p.price),
          currency: p.currency,
        ));
      }
    } else {
      _prices.add(_PriceRow());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _name.dispose();
    _note.dispose();
    for (final r in _prices) {
      r.dispose();
    }
    super.dispose();
  }

  // "4000.00" → "4000"
  String _plain(String raw) {
    final v = double.tryParse(raw) ?? 0;
    return v % 1 == 0 ? v.toInt().toString() : v.toString();
  }

  // ---------- រូបភាព ----------
  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024, // បង្រួមរូប ឱ្យតិចជាង 2 MB (ដែនកំណត់ Backend)
      imageQuality: 80,
    );
    if (picked != null) setState(() => _image = picked);
  }

  void _showPickSheet() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('ថតរូប'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('ជ្រើសពី Gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------- សម្អាតទម្រង់ (រក្សាតែប្រភេទ) ----------
  void _resetForNext() {
    final old = List<_PriceRow>.of(_prices);

    setState(() {
      _name.clear();
      _note.clear();
      _image = null;
      _prices
        ..clear()
        ..add(_PriceRow());
    });

    // បោះចោល Controller ចាស់ ក្រោយ UI ប្តូររួច (ជៀសវាង "used after dispose")
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final r in old) {
        r.dispose();
      }
    });

    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ---------- រក្សាទុក ----------
  Future<void> _save({bool addAnother = false}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final note = _note.text.trim();
      final data = {
        'category_id': _categoryId,
        'name': _name.text.trim(),
        'note': note.isEmpty ? null : note,
        'prices': [
          for (final r in _prices)
            {
              'unit': r.unit.text.trim(),
              'price': double.parse(r.price.text.replaceAll(',', '').trim()),
              'currency': r.currency,
            },
        ],
      };

      await ref.read(productNotifierProvider.notifier).saveProduct(
            id: widget.item?.id,
            data: data,
            imagePath: _image?.path,
          );

      if (!mounted) return;
      showMessage(
        context,
        _isEdit ? 'កែទំនិញជោគជ័យ' : 'បន្ថែមទំនិញជោគជ័យ: ${data['name']}',
      );

      if (addAnother && !_isEdit) {
        _resetForNext();
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      showMessage(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final catsAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'កែទំនិញ' : 'បន្ថែមទំនិញ')),
      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _imagePicker(scheme),
            const SizedBox(height: 20),

            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'ឈ្មោះទំនិញ',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'សូមបញ្ចូលឈ្មោះ' : null,
            ),
            const SizedBox(height: 14),

            catsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => Text('ទាញប្រភេទមិនបាន: $e'),
              data: (cats) => DropdownButtonFormField<int>(
                value: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'ប្រភេទ',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: [
                  for (final c in cats)
                    DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
                validator: (v) => v == null ? 'សូមជ្រើសប្រភេទ' : null,
              ),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _note,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'កំណត់ចំណាំ (មិនបង្ខំ)',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'តម្លៃ',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            for (var i = 0; i < _prices.length; i++) _priceCard(i, scheme),

            TextButton.icon(
              onPressed: () => setState(() => _prices.add(_PriceRow())),
              icon: const Icon(Icons.add),
              label: const Text('បន្ថែមតម្លៃ'),
            ),
            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: _saving ? null : () => _save(),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_saving ? 'កំពុងរក្សាទុក...' : 'រក្សាទុក'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),

            // មានតែពេលបន្ថែមថ្មី
            if (!_isEdit) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _saving ? null : () => _save(addAnother: true),
                icon: const Icon(Icons.playlist_add),
                label: const Text('រក្សាទុក ហើយបន្ថែមទៀត'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _imagePicker(ColorScheme scheme) {
    Widget child;
    if (_image != null) {
      child = Image.file(File(_image!.path), fit: BoxFit.cover);
    } else if (widget.item?.imageUrl != null) {
      child = CachedNetworkImage(
        imageUrl: widget.item!.imageUrl!,
        fit: BoxFit.cover,
      );
    } else {
      child = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_a_photo_outlined, size: 40, color: scheme.outline),
            const SizedBox(height: 8),
            Text('ចុចដើម្បីបន្ថែមរូប',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _showPickSheet,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 200,
          width: double.infinity,
          color: scheme.surfaceContainerHighest,
          child: child,
        ),
      ),
    );
  }

  Widget _priceCard(int i, ColorScheme scheme) {
    final row = _prices[i];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: row.unit,
                  decoration: const InputDecoration(
                    labelText: 'ឯកតា (ឧ. 1 គីឡូ)',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'បញ្ចូលឯកតា' : null,
                ),
              ),
              if (_prices.length > 1)
                IconButton(
                  tooltip: 'លុបតម្លៃនេះ',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() {
                    _prices.removeAt(i).dispose();
                  }),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: row.price,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'តម្លៃ',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) {
                    final n = double.tryParse((v ?? '').replaceAll(',', ''));
                    if (n == null || n < 0) return 'តម្លៃមិនត្រឹមត្រូវ';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'KHR', label: Text('៛')),
                  ButtonSegment(value: 'USD', label: Text('\$')),
                ],
                selected: {row.currency},
                onSelectionChanged: (s) =>
                    setState(() => row.currency = s.first),
              ),
            ],
          ),
        ],
      ),
    );
  }
}