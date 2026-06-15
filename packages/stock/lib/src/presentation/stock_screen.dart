import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:local_reference_feature/local_reference_feature.dart';
import 'package:ui_kit/ui_kit.dart';

import '../domain/models/stock_item.dart';
import '../domain/models/stock_positions_filter.dart';
import '../domain/stock_cubit.dart';
import '../domain/stock_list_utils.dart';
import 'stock_widgets.dart';

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

class _StockView extends StatefulWidget {
  const _StockView();

  @override
  State<_StockView> createState() => _StockViewState();
}

class _StockViewState extends State<_StockView> {
  final _searchController = TextEditingController();
  StockPositionsFilter _filter = StockPositionsFilter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            StockLoaded(:final items, :final goodsById) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: StockSearchField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StockFilterChips(
                    selected: _filter,
                    onSelected: (filter) => setState(() => _filter = filter),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final visible = filterStockItems(
                        items: items,
                        goodsById: goodsById,
                        filter: _filter,
                        searchQuery: _searchQuery,
                      );

                      if (visible.isEmpty) {
                        return Center(
                          child: Text(
                            'Позиции не найдены',
                            style: AppTextStyles.bodyLarge,
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) => StockPositionRow(
                          item: visible[index],
                          goodsById: goodsById,
                          onTap: () => _showReadOnlyDetail(
                            context,
                            item: visible[index],
                            goodsById: goodsById,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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

  void _showReadOnlyDetail(
    BuildContext context, {
    required StockItem item,
    required Map<String, Goods> goodsById,
  }) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stockItemTitle(item, goodsById),
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: 8),
            Text(
              stockItemSubtitle(item, goodsById),
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Остаток', style: AppTextStyles.bodySmall),
                      Text('${item.count}', style: AppTextStyles.headingMedium),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Минимум', style: AppTextStyles.bodySmall),
                      Text(
                        '${item.minCount}',
                        style: AppTextStyles.headingMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.isLowStock) ...[
              const SizedBox(height: 12),
              const StockLowBadge(),
            ],
          ],
        ),
      ),
    );
  }
}
