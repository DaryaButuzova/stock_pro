import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ui_kit/ui_kit.dart';

import '../domain/models/stock_movement.dart';
import '../domain/stock_movement_history_cubit.dart';

final _getIt = GetIt.instance;

/// Admin view of warehouse stock movements.
class StockMovementHistoryScreen extends StatelessWidget {
  const StockMovementHistoryScreen({
    this.goodsId,
    this.goodsName,
    super.key,
  });

  /// When set, only movements for this goods item are shown.
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
            StockMovementHistoryLoaded(:final movements) when movements.isEmpty =>
              Center(
                child: Text(
                  'Движений пока нет',
                  style: AppTextStyles.bodyLarge,
                ),
              ),
            StockMovementHistoryLoaded(:final movements, :final goodsById) =>
              ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: movements.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _MovementCard(
                  movement: movements[index],
                  goodsName:
                      goodsById[movements[index].goodsId]?.displayName,
                  showGoodsName: goodsId == null,
                ),
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

class _MovementCard extends StatelessWidget {
  const _MovementCard({
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    movement.typeLabel,
                    style: AppTextStyles.headingSmall,
                  ),
                ),
                Text(
                  countLabel,
                  style: AppTextStyles.headingSmall.copyWith(color: countColor),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(movement.createdAt),
              style: AppTextStyles.bodySmall,
            ),
            if (showGoodsName) ...[
              const SizedBox(height: 4),
              Text(
                'Товар: ${goodsName ?? _shortId(movement.goodsId)}',
                style: AppTextStyles.bodyMedium,
              ),
            ],
            if (movement.actorName != null &&
                movement.actorName!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Сотрудник: ${movement.actorName}',
                style: AppTextStyles.bodySmall,
              ),
            ],
            if (movement.comment != null && movement.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                movement.comment!,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _shortId(String id) {
    if (id.length <= 8) return id;
    return '${id.substring(0, 8)}…';
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final date =
        '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.'
        '${local.year}';
    final time =
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}
