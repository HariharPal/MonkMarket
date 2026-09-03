import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ProductFormMode { create, edit }

class ProductFormScreen extends ConsumerStatefulWidget {
  final ProductFormMode mode;
  final String? productId;

  const ProductFormScreen({required this.mode, this.productId, super.key});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();

  final _descriptionController = TextEditingController();

  final _priceController = TextEditingController();

  final _stockController = TextEditingController();

  final _imageController = TextEditingController();

  String? _category;

  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  bool get isEdit => widget.mode == ProductFormMode.edit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Product' : 'Add Product',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Product name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a product name';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: _descriptionController,
              minLines: 4,
              maxLines: 7,
              decoration: const InputDecoration(labelText: 'Description'),
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Price (₹)'),
              validator: (value) {
                final amount = double.tryParse(value ?? '');

                if (amount == null || amount <= 0) {
                  return 'Enter a valid price';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock quantity'),
              validator: (value) {
                final stock = int.tryParse(value ?? '');

                if (stock == null || stock < 0) {
                  return 'Enter valid stock';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              value: _category,
              items: const [],
              onChanged: (value) {
                setState(() {
                  _category = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),

            const SizedBox(height: 28),

            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Save Changes' : 'Create Product'),
            ),

            const SizedBox(height: 12),

            Text(
              'Product changes are sent to the merchant/catalog backend.',
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product write API is not connected yet.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
}
