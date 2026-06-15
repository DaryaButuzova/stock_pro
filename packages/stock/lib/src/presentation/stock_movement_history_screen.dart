import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ui_kit/ui_kit.dart';

import '../domain/models/stock_movement.dart';
import '../domain/models/stock_movement_filter.dart';
import '../domain/models/stock_movement_summary.dart';
import '../domain/stock_list_utils.dart';
import '../domain/stock_movement_file_exporter.dart';
import '../domain/stock_movement_history_cubit.dart';

final _getIt = GetIt.instance;

Future<void> _exportStockMovements(BuildContext context) async {
  final csv = context.read<StockMovementHistoryCubit>().buildExportCsv();
  if (csv == null) return;

  final error = await saveStockMovementCsvAndOpen(csv);
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        error ??
            'Отчёт сохранён и открыт. Файлы → На iPhone → Stock Pro → reports',
      ),
    ),
  );
}

/// Admin view of warehouse stock movements with summary and timeline.
class StockMovementHistoryScreen extends StatelessWidget {
  const StockMovementHistoryScreen({
    this.goodsId,
    this.goodsName,
    super.key,
  });

  final String? goodsId;
  final String? goodsName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _getIt<StockMovementHistoryCubit>()
        ..loadMovements(goodsId: goodsId),
      child: _StockMovementHistoryView(
        goodsId: goodsId,
        goodsName: goodsName,
      ),
    );
  }
}

class _StockMovementHistoryView extends StatelessWidget {
  const _StockMovementHistoryView({
    this.goodsId,
    this.goodsName,
  });

  final String? goodsId;
  final String? goodsName;

  @override
  Widget build(BuildContext context) {
    final title = goodsName != null && goodsName!.isNotEmpty
        ? 'Движения: $goodsName'
        : 'Журнал движений';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          BlocBuilder<StockMovementHistoryCubit, StockMovementHistoryState>(
            builder: (context, state) {
              final canExport = state is StockMovementHistoryLoaded &&
                  state.visibleMovements.isNotEmpty;
              return IconButton(
                onPressed: canExport ? () => _exportStockMovements(context) : null,
                icon: const Icon(Icons.download_outlined),
                tooltip: 'Экспорт CSV',
              );
            },
          ),
          IconButton(
            onPressed: () => context
                .read<StockMovementHistoryCubit>()
                .loadMovements(goodsId: goodsId),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<StockMovementHistoryCubit, StockMovementHistoryState>(
        listener: (context, state) {
          if (state is StockMovementHistoryFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            StockMovementHistoryInitial() ||
            StockMovementHistoryLoading() =>
              const Center(child: CircularProgressIndicator()),
            StockMovementHistoryLoaded loaded
                when loaded.visibleMovements.isEmpty =>
              Column(
                children: [
                  if (goodsId == null) _MovementSummaryCard(summary: loaded.summary),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: StockMovementFilterChips(
                      selected: loaded.typeFilter,
                      onSelected: context
                          .read<StockMovementHistoryCubit>()
                          .applyTypeFilter,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Движений пока нет',
                        style: AppTextStyles.bodyLarge,
                      ),
                    ),
                  ),
                ],
              ),
            StockMovementHistoryLoaded loaded => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (goodsId == null)
                  _MovementSummaryCard(summary: loaded.summary),
                if (goodsId == null) const SizedBox(height: 12),
                StockMovementFilterChips(
                  selected: loaded.typeFilter,
                  onSelected: context
                      .read<StockMovementHistoryCubit>()
                      .applyTypeFilter,
                ),
                const SizedBox(height: 16),
                ...loaded.dayGroups.expand((group) sync* {
                  yield Text(group.label, style: AppTextStyles.headingSmall);
                  yield const SizedBox(height: 8);
                  for (final movement in group.movements) {
                    yield Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _MovementTimelineTile(
                        movement: movement,
                        goodsName: loaded.goodsById[movement.goodsId]
                            ?.displayName,
                        showGoodsName: goodsId == null,
                      ),
                    );
                  }
                  yield const SizedBox(height: 8);
                }),
              ],
            ),
            StockMovementHistoryFailure() => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Не удалось загрузить журнал',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Повторить',
                    onPressed: () => context
                        .read<StockMovementHistoryCubit>()
                        .loadMovements(goodsId: goodsId),
                  ),
                ],
              ),
            ),
          };
        },
      ),
    );
  }
}

class _MovementSummaryCard extends StatelessWidget {
  const _MovementSummaryCard({required this.summary});

  final StockMovementSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primarySubtle,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Сегодня', style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    label: 'Пополнено',
                    value: '+${summary.todayReplenishment}',
                    color: AppColors.success,
                  ),
                ),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Списано',
                    value: '−${summary.todayWriteOff}',
                    color: AppColors.error,
                  ),
                ),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Продажи',
                    value: '−${summary.todaySales}',
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Изменение за день: '
              '${summary.todayNetChange >= 0 ? '+' : ''}'
              '${summary.todayNetChange}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class StockMovementFilterChips extends StatelessWidget {
  const StockMovementFilterChips({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final StockMovementTypeFilter selected;
  final ValueChanged<StockMovementTypeFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: StockMovementTypeFilter.values.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.label),
              selected: filter == selected,
              onSelected: (_) => onSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MovementTimelineTile extends StatelessWidget {
  const _MovementTimelineTile({
    required this.movement,
    this.goodsName,
    required this.showGoodsName,
  });

  final StockMovement movement;
  final String? goodsName;
  final bool showGoodsName;

  @override
  Widget build(BuildContext context) {
    final count = movement.signedCount;
    final countLabel = count > 0 ? '+$count' : '$count';
    final countColor = count > 0 ? AppColors.success : AppColors.error;
    final icon = switch (movement.movementType) {
      'replenishment_in' => Icons.add_circle_outline,
      'write_off' => Icons.remove_circle_outline,
      'sale_out' => Icons.shopping_cart_outlined,
      _ => Icons.swap_horiz,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: count > 0
                    ? AppColors.successSubtle
                    : AppColors.errorSubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: countColor),
            ),
            Container(
              width: 2,
              height: 48,
              color: AppColors.border,
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          movement.typeLabel,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        countLabel,
                        style: AppTextStyles.headingSmall.copyWith(
                          color: countColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(movement.createdAt),
                    style: AppTextStyles.bodySmall,
                  ),
                  if (showGoodsName) ...[
                    const SizedBox(height: 4),
                    Text(
                      goodsName ?? shortId(movement.goodsId),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                  if (movement.actorName != null &&
                      movement.actorName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      movement.actorName!,
                      style: AppTextStyles.caption,
                    ),
                  ],
                  if (movement.comment != null &&
                      movement.comment!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(movement.comment!, style: AppTextStyles.bodySmall),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
