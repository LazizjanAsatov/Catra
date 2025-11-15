import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/notification_service.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.existingProductId, this.barcode});

  final String? existingProductId;
  final String? barcode;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _caloriesController = TextEditingController(text: '100');
  final _proteinController = TextEditingController(text: '5');
  final _carbsController = TextEditingController(text: '10');
  final _fatController = TextEditingController(text: '4');
  final _sugarController = TextEditingController(text: '5');
  final _saltController = TextEditingController(text: '0.4');
  final _quantityController = TextEditingController(text: '1');

  UnitType _unit = UnitType.gram;
  DateTime? _expiryDate;
  bool _inStock = true;
  String? _frontImagePath;
  String? _backImagePath;

  @override
  void initState() {
    super.initState();
    if (widget.barcode != null) {
      _barcodeController.text = widget.barcode!;
    }
    if (widget.existingProductId != null) {
      final product = ref
          .read(productRepositoryProvider)
          .getById(widget.existingProductId!);
      if (product != null) {
        _nameController.text = product.name;
        _brandController.text = product.brand ?? '';
        _barcodeController.text = product.barcode ?? '';
        _caloriesController.text = product.calories.toString();
        _proteinController.text = product.protein.toString();
        _carbsController.text = product.carbs.toString();
        _fatController.text = product.fat.toString();
        _sugarController.text = product.sugar.toString();
        _saltController.text = product.salt.toString();
        _quantityController.text = product.quantity.toString();
        _unit = product.unit;
        _expiryDate = product.expiryDate;
        _inStock = product.isInStock;
        _frontImagePath = product.imageFrontPath;
        _backImagePath = product.imageBackPath;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _barcodeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _sugarController.dispose();
    _saltController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingProductId == null ? 'Create product' : 'Edit product',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Brand'),
            ),
            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(labelText: 'Barcode'),
            ),
            const SizedBox(height: 16),
            Text(
              'Nutrition per 100g',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            _numberField('Calories', _caloriesController),
            _numberField('Protein', _proteinController),
            _numberField('Carbs', _carbsController),
            _numberField('Fat', _fatController),
            _numberField('Sugar', _sugarController),
            _numberField('Salt', _saltController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _numberField('Quantity', _quantityController)),
                const SizedBox(width: 12),
                DropdownButton<UnitType>(
                  value: _unit,
                  onChanged: (value) => setState(() => _unit = value ?? _unit),
                  items: UnitType.values
                      .map(
                        (unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit.name),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            ListTile(
              title: const Text('Expiry date'),
              subtitle: Text(
                _expiryDate == null
                    ? 'No expiry'
                    : _expiryDate!.toLocal().toString().split(' ').first,
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _expiryDate ?? now,
                  firstDate: now.subtract(const Duration(days: 1)),
                  lastDate: now.add(const Duration(days: 365 * 2)),
                );
                if (picked != null) {
                  setState(() => _expiryDate = picked);
                }
              },
            ),
            SwitchListTile(
              value: _inStock,
              title: const Text('Add to fridge'),
              onChanged: (value) => setState(() => _inStock = value),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(true),
                    icon: const Icon(Icons.photo_camera),
                    label: Text(
                      _frontImagePath == null ? 'Front photo' : 'Front added',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(false),
                    icon: const Icon(Icons.photo_camera_back),
                    label: Text(
                      _backImagePath == null ? 'Back photo' : 'Back added',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save product')),
          ],
        ),
      ),
    );
  }

  Widget _numberField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
    );
  }

  Future<void> _pickImage(bool front) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        if (front) {
          _frontImagePath = file.path;
        } else {
          _backImagePath = file.path;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final existing = widget.existingProductId == null
        ? null
        : ref
              .read(productRepositoryProvider)
              .getById(widget.existingProductId!);
    final product = Product(
      id: widget.existingProductId ?? const Uuid().v4(),
      name: _nameController.text,
      brand: _brandController.text.isEmpty ? null : _brandController.text,
      barcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
      imageFrontPath: _frontImagePath,
      imageBackPath: _backImagePath,
      calories: double.tryParse(_caloriesController.text) ?? 0,
      protein: double.tryParse(_proteinController.text) ?? 0,
      carbs: double.tryParse(_carbsController.text) ?? 0,
      fat: double.tryParse(_fatController.text) ?? 0,
      sugar: double.tryParse(_sugarController.text) ?? 0,
      salt: double.tryParse(_saltController.text) ?? 0,
      expiryDate: _expiryDate,
      quantity: double.tryParse(_quantityController.text) ?? 0,
      unit: _unit,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      isInStock: _inStock,
    );
    await ref.read(productRepositoryProvider).upsert(product);
    if (_inStock && product.expiryDate != null) {
      await ref
          .read(notificationServiceProvider)
          .scheduleExpiryNotifications(product);
    }
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product saved')));
    }
  }
}
