import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ui_kit/ui_kit.dart';

import '../domain/models/stock_item.dart';
import '../domain/stock_cubit.dart';

final _getIt = GetIt.instance;

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _getIt<StockCubit>(),
      child: const _StockView(),
    );
  }
}

class _StockView extends StatelessWidget {
  const _StockView();

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
              itemBuilder: (context, index) => _StockCard(
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

class _StockCard extends StatelessWidget {
  const _StockCard({
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
          ],
        ),
      ),
    );
  }

  String _shortId(String id) {
    if (id.length <= 8) return id;
    return '${id.substring(0, 8)}…';
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
