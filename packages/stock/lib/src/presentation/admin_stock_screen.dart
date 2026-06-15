import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:local_reference_feature/local_reference_feature.dart';
import 'package:ui_kit/ui_kit.dart';

import '../domain/admin_stock_cubit.dart';
import '../domain/models/stock_dashboard_metrics.dart';
import '../domain/models/stock_positions_filter.dart';
import '../domain/stock_list_utils.dart';
import 'stock_action_dialogs.dart';
import 'stock_movement_history_screen.dart';
import 'stock_widgets.dart';

final _getIt = GetIt.instance;

/// Admin warehouse dashboard with drill-down to positions and actions.
class AdminStockScreen extends StatelessWidget {
  const AdminStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _getIt<AdminStockCubit>(),
      child: const _AdminStockView(),
    );
  }
}

class _AdminStockView extends StatelessWidget {
  const _AdminStockView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminStockCubit, AdminStockState>(
      listener: (context, state) {
        if (state is AdminStockFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        return switch (state) {
          AdminStockPositionDetailLoaded loaded =>
            _StockPositionDetailView(loaded: loaded),
          AdminStockPositionsLoaded loaded =>
            _StockPositionsListView(loaded: loaded),
          _ => _StockDashboardView(state: state),
        };
      },
    );
  }
}

class _StockDashboardView extends StatelessWidget {
  const _StockDashboardView({required this.state});

  final AdminStockState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Склад'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const StockMovementHistoryScreen(),
              ),
            ),
            icon: const Icon(Icons.history),
            tooltip: 'Журнал движений',
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AdminGoodsScreen(),
              ),
            ),
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Справочник товаров',
          ),
          IconButton(
            onPressed: () => context.read<AdminStockCubit>().loadStock(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: switch (state) {
        AdminStockInitial() || AdminStockLoading() =>
          const Center(child: CircularProgressIndicator()),
        AdminStockDashboardLoaded loaded when loaded.items.isEmpty =>
          Center(
            child: Text('Нет записей на складе', style: AppTextStyles.bodyLarge),
          ),
        AdminStockDashboardLoaded loaded => _StockDashboardBody(
          metrics: loaded.metrics,
          goodsById: loaded.goodsById,
        ),
        AdminStockFailure() => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Не удалось загрузить склад', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 16),
              AppButton(
                text: 'Повторить',
                onPressed: () => context.read<AdminStockCubit>().loadStock(),
              ),
            ],
          ),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _StockDashboardBody extends StatelessWidget {
  const _StockDashboardBody({
    required this.metrics,
    required this.goodsById,
  });

  final StockDashboardMetrics metrics;
  final Map<String, Goods> goodsById;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminStockCubit>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryHeroCard(
          metrics: metrics,
          onTap: () => cubit.openPositionsList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.primary,
                backgroundColor: AppColors.primarySubtle,
                label: 'Позиций',
                value: '${metrics.totalPositions}',
                subtitle: '${metrics.totalUnits} ед.',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricTile(
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.warning,
                backgroundColor: AppColors.warningSubtle,
                label: 'Мало',
                value: '${metrics.lowStockCount}',
                subtitle: 'требует внимания',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.remove_circle_outline,
                iconColor: AppColors.error,
                backgroundColor: AppColors.errorSubtle,
                label: 'Нулевой',
                value: '${metrics.zeroStockCount}',
                subtitle: 'остаток 0',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricTile(
                icon: Icons.place_outlined,
                iconColor: AppColors.secondaryDark,
                backgroundColor: AppColors.secondaryMuted,
                label: 'Без адреса',
                value: '${metrics.noAddressCount}',
                subtitle: 'позиций',
              ),
            ),
          ],
        ),
        if (metrics.attentionItems.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Text('Требует внимания', style: AppTextStyles.headingSmall),
              const Spacer(),
              TextButton(
                onPressed: () => cubit.openPositionsList(
                  filter: StockPositionsFilter.lowStock,
                ),
                child: const Text('Все'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...metrics.attentionItems.take(5).map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: StockPositionRow(
                item: item,
                goodsById: goodsById,
                onTap: () => cubit.openPositionDetail(item),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SummaryHeroCard extends StatelessWidget {
  const _SummaryHeroCard({
    required this.metrics,
    required this.onTap,
  });

  final StockDashboardMetrics metrics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Все позиции',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.onPrimary.withValues(alpha: 0.9),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${metrics.totalUnits} ед.',
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${metrics.totalPositions} позиций на складе',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(label, style: AppTextStyles.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.headingSmall),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _StockPositionsListView extends StatefulWidget {
  const _StockPositionsListView({required this.loaded});

  final AdminStockPositionsLoaded loaded;

  @override
  State<_StockPositionsListView> createState() =>
      _StockPositionsListViewState();
}

class _StockPositionsListViewState extends State<_StockPositionsListView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.loaded.searchQuery);
  }

  @override
  void didUpdateWidget(covariant _StockPositionsListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loaded.searchQuery != widget.loaded.searchQuery &&
        _searchController.text != widget.loaded.searchQuery) {
      _searchController.text = widget.loaded.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loaded = widget.loaded;
    final cubit = context.read<AdminStockCubit>();
    final visibleItems = loaded.visibleItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Позиции'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: cubit.backToDashboard,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: StockSearchField(
              controller: _searchController,
              onChanged: cubit.applySearchQuery,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StockFilterChips(
              selected: loaded.filter,
              onSelected: cubit.applyListFilter,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: visibleItems.isEmpty
                ? Center(
                    child: Text(
                      'Позиции не найдены',
                      style: AppTextStyles.bodyLarge,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: visibleItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => StockPositionRow(
                      item: visibleItems[index],
                      goodsById: loaded.goodsById,
                      onTap: () =>
                          cubit.openPositionDetail(visibleItems[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StockPositionDetailView extends StatelessWidget {
  const _StockPositionDetailView({required this.loaded});

  final AdminStockPositionDetailLoaded loaded;

  @override
  Widget build(BuildContext context) {
    final item = loaded.item;
    final goodsName = loaded.goodsById[item.goodsId]?.displayName;
    final title = stockItemTitle(item, loaded.goodsById);
    final cubit = context.read<AdminStockCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: cubit.backToList,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: item.isLowStock ? AppColors.warningSubtle : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.goodsAddr.isNotEmpty) ...[
                    Text('Адрес', style: AppTextStyles.bodySmall),
                    Text(item.goodsAddr, style: AppTextStyles.headingSmall),
                    const SizedBox(height: 12),
                  ],
                  Text('Товар', style: AppTextStyles.bodySmall),
                  Text(
                    goodsName ?? shortId(item.goodsId),
                    style: AppTextStyles.headingSmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DetailMetric(
                          label: 'Остаток',
                          value: '${item.count}',
                        ),
                      ),
                      Expanded(
                        child: _DetailMetric(
                          label: 'Минимум',
                          value: '${item.minCount}',
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
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Пополнить',
            onPressed: () => showStockAdjustDialog(
              context,
              title: 'Пополнение',
              maxCount: null,
              onSubmit: (count, comment) => cubit.replenishStock(
                goodsId: item.goodsId,
                count: count,
                comment: comment,
              ),
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            text: item.count > 0 ? 'Списать' : 'Удалить',
            variant: item.count > 0
                ? AppButtonVariant.outlined
                : AppButtonVariant.outlined,
            onPressed: item.count > 0
                ? () => showStockAdjustDialog(
                    context,
                    title: 'Списание',
                    maxCount: item.count,
                    onSubmit: (count, comment) => cubit.writeOffStock(
                      goodsId: item.goodsId,
                      count: count,
                      comment: comment,
                    ),
                  )
                : () => confirmDeleteStockPosition(
                    context,
                    label: goodsName ?? title,
                    onConfirm: () => cubit.deleteStockPosition(item.goodsId),
                  ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => showStockMetaDialog(
              context,
              goodsAddr: item.goodsAddr,
              minCount: item.minCount,
              onSubmit: (goodsAddr, minCount) => cubit.updateStockMeta(
                goodsId: item.goodsId,
                goodsAddr: goodsAddr,
                minCount: minCount,
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Параметры позиции'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => StockMovementHistoryScreen(
                  goodsId: item.goodsId,
                  goodsName: goodsName ?? title,
                ),
              ),
            ),
            icon: const Icon(Icons.history),
            label: const Text('История движений'),
          ),
        ],
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text(value, style: AppTextStyles.headingMedium),
      ],
    );
  }
}
