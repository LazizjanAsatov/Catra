import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/nutrition_utils.dart';
import '../../../data/local/hive_streams.dart';
import '../../../data/models/consumed_entry.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/consumption_repository.dart';
import '../../../data/repositories/product_repository.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsStreamProvider);
    return products.when(
      data: (items) {
        final product = items.firstWhereOrNull(
          (element) => element.id == productId,
        );
        if (product == null) {
          return const Scaffold(body: Center(child: Text('Product not found')));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(product.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.pushNamed(
                  AppRoutes.productForm.name,
                  queryParameters: {'id': product.id},
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Brand: ${product.brand ?? 'Unknown'}'),
              Text('Barcode: ${product.barcode ?? 'n/a'}'),
              Text('Expiry: ${DateUtilsHelper.format(product.expiryDate)}'),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nutrition per 100g',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _nutrientRow('Calories', product.calories, 'kcal'),
                      _nutrientRow('Protein', product.protein, 'g'),
                      _nutrientRow('Carbs', product.carbs, 'g'),
                      _nutrientRow('Fat', product.fat, 'g'),
                      _nutrientRow('Sugar', product.sugar, 'g'),
                      _nutrientRow('Salt', product.salt, 'g'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _markConsumed(context, ref, product),
                icon: const Icon(Icons.restaurant),
                label: const Text('Mark consumed'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final updated = product.copyWith(
                    isInStock: !product.isInStock,
                    updatedAt: DateTime.now(),
                  );
                  await ref.read(productRepositoryProvider).upsert(updated);
                  if (updated.isInStock && updated.expiryDate != null) {
                    await ref
                        .read(notificationServiceProvider)
                        .scheduleExpiryNotifications(updated);
                  } else {
                    await ref
                        .read(notificationServiceProvider)
                        .cancelProductNotifications(product.id);
                  }
                },
                icon: const Icon(Icons.kitchen),
                label: Text(
                  product.isInStock ? 'Remove from fridge' : 'Add to fridge',
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete product'),
                      content: const Text('This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref
                        .read(productRepositoryProvider)
                        .delete(product.id);
                    await ref
                        .read(notificationServiceProvider)
                        .cancelProductNotifications(product.id);
                    if (context.mounted) context.pop();
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete product'),
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  Future<void> _markConsumed(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final controller = TextEditingController(text: '100');
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Consumed amount'),
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
    if (amount == null) return;
    final macros = NutritionUtils.macrosForAmount(product, amount);
    final entry = ConsumedEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry saved')));
    }
  }

  Widget _nutrientRow(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text('${value.toStringAsFixed(1)} $unit')],
      ),
    );
  }
}
