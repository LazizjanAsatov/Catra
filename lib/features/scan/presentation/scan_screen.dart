import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/router/routes.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/nutrition_utils.dart';
import '../../../data/models/consumed_entry.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/consumption_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../widgets/empty_state.dart';
import '../controllers/scan_controller.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _previewBytes;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Analyze Product')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CaptureCard(
            previewBytes: _previewBytes,
            onCapture: () => _pickImage(ImageSource.camera),
            onUpload: () => _pickImage(ImageSource.gallery),
            onClear: _selectedImage == null
                ? null
                : () {
                    setState(() {
                      _selectedImage = null;
                      _previewBytes = null;
                    });
                    ref.read(scanControllerProvider.notifier).reset();
                  },
            isCameraAvailable: !kIsWeb,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _selectedImage == null || _isUploading
                ? null
                : () => _analyze(ref),
            child: _isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Analyze product'),
          ),
          const SizedBox(height: 24),
          scanState.when(
            data: (product) {
              if (product == null) {
                return const EmptyState(
                  icon: Icons.info_outline,
                  message:
                      'Capture or upload a product photo to see nutrition details.',
                );
              }
              return _ProductResult(
                product: product,
                onAddToFridge: () async {
                  final updated = product.copyWith(
                    isInStock: true,
                    updatedAt: DateTime.now(),
                  );
                  await ref.read(productRepositoryProvider).upsert(updated);
                  if (product.expiryDate != null) {
                    await ref
                        .read(notificationServiceProvider)
                        .scheduleExpiryNotifications(updated);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to fridge')),
                    );
                  }
                },
                onMarkEaten: () async {
                  final amount = await _askAmount(context, product);
                  if (amount == null) return;
                  final macros = NutritionUtils.macrosForAmount(
                    product,
                    amount,
                  );
                  final entry = ConsumedEntry(
                    id: product.id + DateTime.now().toIso8601String(),
                    productId: product.id,
                    dateTime: DateTime.now(),
                    amount: amount,
                    unit: product.unit,
                    calories: macros['calories']!,
                    carbs: macros['carbs']!,
                    protein: macros['protein']!,
                    fat: macros['fat']!,
                    sugar: macros['sugar']!,
                  );
                  await ref.read(consumptionRepositoryProvider).add(entry);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Entry saved')),
                    );
                  }
                },
                onEdit: () => context.pushNamed(
                  AppRoutes.productForm.name,
                  queryParameters: {'id': product.id},
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImage = picked;
        _previewBytes = bytes;
      });
      ref.read(scanControllerProvider.notifier).reset();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to access camera/gallery: $error')),
      );
    }
  }

  Future<void> _analyze(WidgetRef ref) async {
    final image = _selectedImage;
    if (image == null) return;
    setState(() => _isUploading = true);
    await ref.read(scanControllerProvider.notifier).analyzeImage(image);
    if (mounted) {
      setState(() => _isUploading = false);
    }
  }

  Future<double?> _askAmount(BuildContext context, Product product) {
    final controller = TextEditingController(text: '100');
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Amount for ${product.name}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(suffixText: product.unit.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _CaptureCard extends StatelessWidget {
  const _CaptureCard({
    required this.previewBytes,
    required this.onCapture,
    required this.onUpload,
    required this.onClear,
    required this.isCameraAvailable,
  });

  final Uint8List? previewBytes;
  final VoidCallback onCapture;
  final VoidCallback onUpload;
  final VoidCallback? onClear;
  final bool isCameraAvailable;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Product image',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onClear != null)
                  TextButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: previewBytes == null
                      ? const Center(child: Text('No image selected'))
                      : Image.memory(previewBytes!, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (isCameraAvailable)
                  FilledButton.icon(
                    onPressed: onCapture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take photo'),
                  ),
                OutlinedButton.icon(
                  onPressed: onUpload,
                  icon: const Icon(Icons.upload),
                  label: Text(
                    isCameraAvailable ? 'Upload photo' : 'Choose file',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Use good lighting and capture the front of the package so CATRA can read nutrition data accurately.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductResult extends StatelessWidget {
  const _ProductResult({
    required this.product,
    required this.onAddToFridge,
    required this.onMarkEaten,
    required this.onEdit,
  });

  final Product product;
  final VoidCallback onAddToFridge;
  final VoidCallback onMarkEaten;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Brand: ${product.brand ?? 'Unknown'}'),
            Text('Barcode: ${product.barcode ?? 'n/a'}'),
            Text('Calories/100g: ${product.calories}'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: onAddToFridge,
                  icon: const Icon(Icons.kitchen),
                  label: const Text('Add to fridge'),
                ),
                OutlinedButton.icon(
                  onPressed: onMarkEaten,
                  icon: const Icon(Icons.restaurant),
                  label: const Text('Mark eaten'),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
