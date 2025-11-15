import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../widgets/empty_state.dart';
import '../controllers/home_stats_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(homeStatsControllerProvider);
    return stats.when(
      data: (data) => RefreshIndicator(
        onRefresh: () async => ref.refresh(homeStatsControllerProvider.future),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _HeroHeader(stats: data),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummarySection(stats: data),
                  const SizedBox(height: 24),
                  _MacroSection(stats: data),
                  const SizedBox(height: 24),
                  const _SectionHeading(title: 'Today\'s consumption'),
                  const SizedBox(height: 8),
                  if (data.todayEntries.isEmpty)
                    const EmptyState(
                      icon: Icons.restaurant,
                      message:
                          'No entries yet. Scan a product or add from fridge.',
                    )
                  else
                    ...data.todayEntries.map(
                      (entry) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.check_circle_outline),
                          title: Text(
                            '${entry.calories.toStringAsFixed(0)} kcal',
                          ),
                          subtitle: Text(
                            '${entry.amount.toStringAsFixed(0)} ${entry.unit.name}',
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const _SectionHeading(title: 'Expiring soon'),
                  const SizedBox(height: 8),
                  if (data.expiringSoon.isEmpty)
                    const EmptyState(
                      icon: Icons.kitchen,
                      message: 'Nothing is expiring soon.',
                    )
                  else
                    ...data.expiringSoon.map(
                      (product) => Card(
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Text(
                            product.expiryDate == null
                                ? 'No expiry date'
                                : 'Expires on ${product.expiryDate!.toLocal().toString().split(' ').first}',
                          ),
                          trailing: Icon(
                            Icons.circle,
                            color: product.isExpired
                                ? Colors.red
                                : (product.daysUntilExpiry ?? 10) <= 2
                                ? Colors.red
                                : (product.daysUntilExpiry ?? 10) <= 5
                                ? Colors.orange
                                : Colors.green,
                          ),
                          onTap: () => context.pushNamed(
                            AppRoutes.productDetail.name,
                            pathParameters: {'id': product.id},
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error loading stats: $error')),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.stats});

  final HomeStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradientColors = [
      theme.colorScheme.primary,
      theme.colorScheme.primary.withAlpha((255 * 0.7).round()),
    ];
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.only(
          top: 32,
          left: 16,
          right: 16,
          bottom: 24,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'CATRA',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Smart calorie & stock tracker',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Today\'s energy',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${stats.totalCalories.toStringAsFixed(0)} kcal consumed',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _HeroStat(
                    label: 'Target',
                    value: '${stats.calorieTarget.toStringAsFixed(0)} kcal',
                    icon: Icons.flag_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HeroStat(
                    label: 'Estimated burn',
                    value: '${stats.estimatedBurn.toStringAsFixed(0)} kcal',
                    icon: Icons.local_fire_department,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((255 * 0.15).round()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.stats});

  final HomeStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final overviewCards = [
      _OverviewData(
        title: 'Calories',
        value: '${stats.totalCalories.toStringAsFixed(0)} kcal',
        subtitle: 'Target ${stats.calorieTarget.toStringAsFixed(0)}',
        progress: stats.calorieTarget == 0
            ? null
            : stats.totalCalories / stats.calorieTarget,
        color: scheme.primary,
      ),
      _OverviewData(
        title: 'Sugar',
        value: '${stats.totalSugar.toStringAsFixed(0)} g',
        subtitle: 'Limit ${stats.sugarTarget.toStringAsFixed(0)}',
        progress: stats.sugarTarget == 0
            ? null
            : stats.totalSugar / stats.sugarTarget,
        color: Colors.orangeAccent,
      ),
      _OverviewData(
        title: 'Net calories',
        value:
            '${stats.netCalories >= 0 ? '+' : ''}${stats.netCalories.toStringAsFixed(0)} kcal',
        subtitle: 'Consumed - Burned',
        progress: null,
        color: stats.netCalories >= 0 ? Colors.deepOrange : Colors.green,
      ),
      _OverviewData(
        title: 'Meals logged',
        value: stats.todayEntries.length.toString(),
        subtitle: 'Entries today',
        progress: null,
        color: scheme.secondary,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(title: 'Daily snapshot'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final spacing = 12.0;
            final cardWidth = constraints.maxWidth;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: overviewCards
                  .map(
                    (data) => SizedBox(
                      width: cardWidth,
                      child: _OverviewCard(data: data),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _OverviewData {
  const _OverviewData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    this.progress,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final double? progress;
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.data});

  final _OverviewData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.04).round()),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.color.withAlpha((255 * 0.12).round()),
            ),
            child: Center(
              child: data.progress != null
                  ? Text(
                      '${(data.progress!.clamp(0, 9.99) * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: data.color,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Icon(Icons.trending_up, size: 20, color: data.color),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(170),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(140),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroSection extends StatelessWidget {
  const _MacroSection({required this.stats});

  final HomeStats stats;

  @override
  Widget build(BuildContext context) {
    final macros = [
      _MacroData('Protein', stats.totalProtein),
      _MacroData('Carbs', stats.totalCarbs),
      _MacroData('Fat', stats.totalFat),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(title: 'Macro balance'),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < macros.length; i++) ...[
              Expanded(child: _MacroTile(data: macros[i])),
              if (i != macros.length - 1) const SizedBox(width: 12),
            ],
          ],
        ),
      ],
    );
  }
}

class _MacroData {
  const _MacroData(this.label, this.value);

  final String label;
  final double value;
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({required this.data});

  final _MacroData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(160),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${data.value.toStringAsFixed(0)} g',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
