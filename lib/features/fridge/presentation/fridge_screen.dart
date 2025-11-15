import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/router/routes.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/nutrition_utils.dart';
import '../../../data/local/hive_streams.dart';
import '../../../data/models/consumed_entry.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/consumption_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../widgets/empty_state.dart';
import '../controllers/fridge_filters.dart';

class FridgeScreen extends ConsumerWidget {
  const FridgeScreen({super.key});

  static const _uuid = Uuid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);
    final sort = ref.watch(fridgeSortProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fridge'),
        actions: [
          PopupMenuButton<FridgeSort>(
            onSelected: (value) =>
                ref.read(fridgeSortProvider.notifier).state = value,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: FridgeSort.expiry,
                child: Text('Soonest expiry'),
              ),
              const PopupMenuItem(value: FridgeSort.name, child: Text('Name')),
              const PopupMenuItem(
                value: FridgeSort.calories,
                child: Text('Calories'),
              ),
            ],
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          final items = products.where((product) => product.isInStock).toList();
          _sort(items, sort);
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.kitchen,
              message: 'Your fridge is empty. Start scanning products!',
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];
              return Dismissible(
                key: ValueKey(product.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: Colors.redAccent,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) => _confirmDelete(context),
                onDismissed: (_) async {
                  await ref.read(productRepositoryProvider).delete(product.id);
                  await ref
                      .read(notificationServiceProvider)
                      .cancelProductNotifications(product.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product deleted')),
                    );
                  }
                },
                child: Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                          'Qty: ${product.quantity.toStringAsFixed(1)} ${product.unit.name}\nExpiry: ${DateUtilsHelper.format(product.expiryDate)}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.local_fire_department_outlined,
                              size: 16,
                            ),
                            Text('${product.calories.toStringAsFixed(0)} kcal'),
                          ],
                        ),
                        onTap: () => context.pushNamed(
                          AppRoutes.productDetail.name,
                          pathParameters: {'id': product.id},
                        ),
                        isThreeLine: true,
                        leading: Icon(
                          Icons.circle,
                          color: DateUtilsHelper.expiryColor(
                            product.expiryDate,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: OverflowBar(
                          alignment: MainAxisAlignment.spaceBetween,
                          spacing: 12,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  _markConsumed(context, ref, product),
                              child: const Text('Consume'),
                            ),
                            TextButton(
                              onPressed: () => context.pushNamed(
                                AppRoutes.productForm.name,
                                queryParameters: {'id': product.id},
                              ),
                              child: const Text('Edit'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final updated = product.copyWith(
                                  isInStock: false,
                                  updatedAt: DateTime.now(),
                                );
                                await ref
                                    .read(productRepositoryProvider)
                                    .upsert(updated);
                                await ref
                                    .read(notificationServiceProvider)
                                    .cancelProductNotifications(product.id);
                              },
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(AppRoutes.productForm.name),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _sort(List<Product> products, FridgeSort sort) {
    switch (sort) {
      case FridgeSort.expiry:
        products.sort((a, b) {
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return a.expiryDate!.compareTo(b.expiryDate!);
        });
        break;
      case FridgeSort.name:
        products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case FridgeSort.calories:
        products.sort((a, b) => a.calories.compareTo(b.calories));
        break;
    }
  }

  Future<void> _markConsumed(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final amount = await _showAmountDialog(context, product);
    if (amount == null) return;
    final macros = NutritionUtils.macrosForAmount(product, amount);
    final entry = ConsumedEntry(
      id: _uuid.v4(),
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
    final newQuantity = (product.quantity - amount).clamp(0, 999).toDouble();
    final updated = product.copyWith(
      quantity: newQuantity,
      isInStock: newQuantity > 0,
      updatedAt: DateTime.now(),
    );
    await ref.read(productRepositoryProvider).upsert(updated);
    if (!updated.isInStock) {
      await ref
          .read(notificationServiceProvider)
          .cancelProductNotifications(product.id);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry saved')));
    }
  }

  Future<double?> _showAmountDialog(
    BuildContext context,
    Product product,
  ) async {
    final controller = TextEditingController(
      text: product.quantity.toStringAsFixed(0),
    );
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('How much ${product.name}?'),
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

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product'),
        content: const Text('Remove this product from your fridge?'),
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
    return confirmed ?? false;
  }
}
