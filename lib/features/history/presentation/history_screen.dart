import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../data/local/hive_streams.dart';
import '../../../data/models/consumed_entry.dart';
import '../../../data/models/product.dart';
import '../../../widgets/empty_state.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final consumed = ref.watch(consumedStreamProvider);
    final products = ref.watch(productsStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Eaten'),
            Tab(text: 'Scanned'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search products',
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                consumed.when(
                  data: (entries) => _EatenTab(
                    entries: entries,
                    products: products.value ?? const [],
                    query: _query,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('$error')),
                ),
                products.when(
                  data: (items) => _ScannedTab(products: items, query: _query),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('$error')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EatenTab extends StatelessWidget {
  const _EatenTab({
    required this.entries,
    required this.products,
    required this.query,
  });

  final List<ConsumedEntry> entries;
  final List<Product> products;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const EmptyState(
        icon: Icons.restaurant,
        message: 'No consumption yet.',
      );
    }
    final nameMap = {for (final p in products) p.id: p.name};
    final filtered = entries
        .where(
          (e) =>
              query.isEmpty ||
              (nameMap[e.productId] ?? '').toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
    final grouped = <String, List<ConsumedEntry>>{};
    for (final entry in filtered) {
      final key = DateTime(
        entry.dateTime.year,
        entry.dateTime.month,
        entry.dateTime.day,
      ).toIso8601String();
      grouped.putIfAbsent(key, () => []).add(entry);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return ListView(
      children: [
        for (final key in sortedKeys)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  DateTime.parse(key).toLocal().toString().split(' ').first,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...grouped[key]!.map(
                (entry) => ListTile(
                  title: Text(nameMap[entry.productId] ?? 'Unknown product'),
                  subtitle: Text(
                    '${entry.calories.toStringAsFixed(0)} kcal · ${entry.amount.toStringAsFixed(1)} ${entry.unit.name} · ${entry.dateTime.hour.toString().padLeft(2, '0')}:${entry.dateTime.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ScannedTab extends StatelessWidget {
  const _ScannedTab({required this.products, required this.query});

  final List<Product> products;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const EmptyState(
        icon: Icons.qr_code_scanner,
        message: 'No products scanned yet.',
      );
    }
    final filtered =
        products
            .where(
              (p) =>
                  query.isEmpty ||
                  p.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];
        return ListTile(
          title: Text(product.name),
          subtitle: Text(
            '${product.brand ?? 'Unknown brand'} · ${product.createdAt.toLocal().toString().split(' ').first}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.pushNamed(
            AppRoutes.productDetail.name,
            pathParameters: {'id': product.id},
          ),
        );
      },
    );
  }
}
