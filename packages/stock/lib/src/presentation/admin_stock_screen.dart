import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ui_kit/ui_kit.dart';

import '../domain/models/stock_item.dart';
import '../domain/stock_cubit.dart';

final _getIt = GetIt.instance;

/// Admin warehouse screen with replenish and write-off actions.
class AdminStockScreen extends StatelessWidget {
  const AdminStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _getIt<StockCubit>(),
      child: const _AdminStockView(),
    );
  }
}

class _AdminStockView extends StatelessWidget {
  const _AdminStockView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Склад'),
        actions: [
          IconButton(
            onPressed: () => context.read<StockCubit>().loadStock(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<StockCubit, StockState>(
        listener: (context, state) {
          if (state is StockFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            StockInitial() || StockLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            StockLoaded(:final items) when items.isEmpty => Center(
              child: Text(
                'Нет записей на складе',
                style: AppTextStyles.bodyLarge,
              ),
            ),
            StockLoaded(:final items, :final goodsById) => ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _AdminStockCard(
                key: ValueKey(items[index].goodsId),
                item: items[index],
                goodsName: goodsById[items[index].goodsId]?.displayName,
              ),
            ),
            StockFailure() => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Не удалось загрузить склад', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Повторить',
                    onPressed: () => context.read<StockCubit>().loadStock(),
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

class _AdminStockCard extends StatelessWidget {
  const _AdminStockCard({
    required this.item,
    this.goodsName,
    super.key,
  });

  final StockItem item;
  final String? goodsName;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: item.isLowStock ? AppColors.warningSubtle : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.goodsAddr.isNotEmpty
                        ? item.goodsAddr
                        : 'Без адреса',
                    style: AppTextStyles.headingSmall,
                  ),
                ),
                if (item.isLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Мало',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Товар: ${goodsName ?? _shortId(item.goodsId)}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _Metric(label: 'Кол-во', value: '${item.count}'),
                const SizedBox(width: 24),
                _Metric(label: 'Мин.', value: '${item.minCount}'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Пополнить',
                    onPressed: () => _showAdjustDialog(
                      context,
                      title: 'Пополнение',
                      maxCount: null,
                      onSubmit: (count, comment) =>
                          context.read<StockCubit>().replenishStock(
                            goodsId: item.goodsId,
                            count: count,
                            comment: comment,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Списать',
                    onPressed: item.count <= 0
                        ? null
                        : () => _showAdjustDialog(
                            context,
                            title: 'Списание',
                            maxCount: item.count,
                            onSubmit: (count, comment) =>
                                context.read<StockCubit>().writeOffStock(
                                  goodsId: item.goodsId,
                                  count: count,
                                  comment: comment,
                                ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _shortId(String id) {
    if (id.length <= 8) return id;
    return '${id.substring(0, 8)}…';
  }

  Future<void> _showAdjustDialog(
    BuildContext context, {
    required String title,
    required int? maxCount,
    required Future<String?> Function(int count, String? comment) onSubmit,
  }) async {
    final result = await showDialog<({int count, String? comment})>(
      context: context,
      builder: (dialogContext) => _StockAdjustDialog(
        title: title,
        maxCount: maxCount,
      ),
    );

    if (result == null || !context.mounted) return;

    final error = await onSubmit(result.count, result.comment);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text(value, style: AppTextStyles.bodyLarge),
      ],
    );
  }
}

class _StockAdjustDialog extends StatefulWidget {
  const _StockAdjustDialog({
    required this.title,
    required this.maxCount,
  });

  final String title;
  final int? maxCount;

  @override
  State<_StockAdjustDialog> createState() => _StockAdjustDialogState();
}

class _StockAdjustDialogState extends State<_StockAdjustDialog> {
  int _quantity = 1;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxCount = widget.maxCount;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (maxCount != null)
            Text('Доступно: $maxCount', style: AppTextStyles.bodySmall),
          if (maxCount != null) const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$_quantity', style: AppTextStyles.headingSmall),
              IconButton(
                onPressed: maxCount == null || _quantity < maxCount
                    ? () => setState(() => _quantity++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Комментарий',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            final comment = _commentController.text.trim();
            Navigator.of(context).pop((
              count: _quantity,
              comment: comment.isEmpty ? null : comment,
            ));
          },
          child: const Text('Применить'),
        ),
      ],
    );
  }
}
