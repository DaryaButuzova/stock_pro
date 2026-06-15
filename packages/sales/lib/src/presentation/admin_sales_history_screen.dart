import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ui_kit/ui_kit.dart';

import '../domain/admin_sales_history_cubit.dart';
import '../domain/models/sale_history_entry.dart';
import '../domain/models/sales_dashboard_metrics.dart';
import '../domain/models/sales_history_filter.dart';
import '../domain/models/seller_option.dart';
import '../domain/sales_cubit.dart';
import '../domain/sales_report_file_exporter.dart';

final _getIt = GetIt.instance;

Future<void> _exportSalesReport(BuildContext context) async {
  final csv = context.read<AdminSalesHistoryCubit>().buildExportCsv();
  if (csv == null) return;

  final error = await saveSalesReportCsvAndOpen(csv);
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

/// Admin sales dashboard with drill-down to the sales list.
class AdminSalesHistoryScreen extends StatelessWidget {
  const AdminSalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _getIt<AdminSalesHistoryCubit>(),
      child: const _AdminSalesHistoryView(),
    );
  }
}

class _AdminSalesHistoryView extends StatelessWidget {
  const _AdminSalesHistoryView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminSalesHistoryCubit, AdminSalesHistoryState>(
      listener: (context, state) {
        if (state is AdminSalesHistoryFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        return switch (state) {
          AdminSalesHistoryDetailLoading(:final entry) ||
          AdminSalesHistoryDetailLoaded(:final entry) =>
            _SaleDetailView(entry: entry, state: state),
          AdminSalesHistoryEntriesLoaded loaded =>
            _SalesHistoryEntriesView(loaded: loaded),
          _ => _SalesDashboardView(state: state),
        };
      },
    );
  }
}

class _SalesDashboardView extends StatelessWidget {
  const _SalesDashboardView({required this.state});

  final AdminSalesHistoryState state;

  @override
  Widget build(BuildContext context) {
    final dashboardState = switch (state) {
      AdminSalesHistoryDashboardLoaded loaded => loaded,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Продажи'),
        actions: [
          IconButton(
            onPressed: dashboardState == null
                ? null
                : () => _showFilterSheet(context, dashboardState),
            icon: Badge(
              isLabelVisible: dashboardState?.filter.hasActiveFilters ?? false,
              smallSize: 8,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Фильтры',
          ),
          IconButton(
            onPressed: dashboardState == null || dashboardState.entries.isEmpty
                ? null
                : () => _exportSalesReport(context),
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Экспорт CSV',
          ),
          IconButton(
            onPressed: () => context.read<AdminSalesHistoryCubit>().loadHistory(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: switch (state) {
        AdminSalesHistoryInitial() || AdminSalesHistoryLoading() =>
          const Center(child: CircularProgressIndicator()),
        AdminSalesHistoryDashboardLoaded loaded => _SalesDashboardBody(
          metrics: loaded.metrics,
          filter: loaded.filter,
          onOpenEntries: loaded.entries.isEmpty
              ? null
              : () => context.read<AdminSalesHistoryCubit>().openEntriesList(),
        ),
        AdminSalesHistoryFailure() => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Не удалось загрузить продажи', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 16),
              AppButton(
                text: 'Повторить',
                onPressed: () =>
                    context.read<AdminSalesHistoryCubit>().loadHistory(),
              ),
            ],
          ),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Future<void> _showFilterSheet(
    BuildContext context,
    AdminSalesHistoryDashboardLoaded dashboardState,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _SalesHistoryFilterSheet(
        initialFilter: dashboardState.filter,
        sellers: dashboardState.sellers,
        onApply: (filter) {
          Navigator.of(sheetContext).pop();
          context.read<AdminSalesHistoryCubit>().applyFilter(filter);
        },
        onReset: () {
          Navigator.of(sheetContext).pop();
          context.read<AdminSalesHistoryCubit>().clearFilter();
        },
      ),
    );
  }
}

class _SalesDashboardBody extends StatelessWidget {
  const _SalesDashboardBody({
    required this.metrics,
    required this.filter,
    required this.onOpenEntries,
  });

  final SalesDashboardMetrics metrics;
  final SalesHistoryFilter filter;
  final VoidCallback? onOpenEntries;

  @override
  Widget build(BuildContext context) {
    if (metrics.saleCount == 0) {
      return Center(
        child: Text(
          filter.hasActiveFilters
              ? 'Нет продаж за выбранный период'
              : 'Завершённых продаж пока нет',
          style: AppTextStyles.bodyLarge,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (filter.hasActiveFilters) ...[
          _ActiveFiltersBanner(filter: filter),
          const SizedBox(height: 12),
        ],
        _SummaryHeroCard(
          metrics: metrics,
          onTap: onOpenEntries,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.today_outlined,
                iconColor: AppColors.info,
                backgroundColor: AppColors.infoSubtle,
                label: 'Сегодня',
                value: '${metrics.todayCount}',
                subtitle: '${metrics.todaySum.toStringAsFixed(0)} ₽',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricTile(
                icon: Icons.receipt_long_outlined,
                iconColor: AppColors.primary,
                backgroundColor: AppColors.primarySubtle,
                label: 'Средний чек',
                value: '${metrics.averageCheck.toStringAsFixed(0)} ₽',
                subtitle: '${metrics.saleCount} продаж',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.trending_up,
                iconColor: AppColors.success,
                backgroundColor: AppColors.successSubtle,
                label: 'Макс. чек',
                value: '${metrics.maxSaleAmount.toStringAsFixed(0)} ₽',
                subtitle: 'лучшая продажа',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricTile(
                icon: Icons.payments_outlined,
                iconColor: AppColors.secondaryDark,
                backgroundColor: AppColors.secondaryMuted,
                label: 'Выручка',
                value: '${metrics.totalSum.toStringAsFixed(0)} ₽',
                subtitle: 'за период',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Способы оплаты', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),
        _PaymentBreakdownCard(metrics: metrics),
        if (metrics.topSellerName != null) ...[
          const SizedBox(height: 20),
          Text('Сотрудники', style: AppTextStyles.headingSmall),
          const SizedBox(height: 12),
          _TopSellerCard(metrics: metrics),
        ],
      ],
    );
  }
}

class _ActiveFiltersBanner extends StatelessWidget {
  const _ActiveFiltersBanner({required this.filter});

  final SalesHistoryFilter filter;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (filter.fromDate != null) {
      parts.add('с ${_formatDate(filter.fromDate!)}');
    }
    if (filter.toDate != null) {
      parts.add('по ${_formatDate(filter.toDate!)}');
    }
    if (filter.userId != null) {
      parts.add('фильтр по сотруднику');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warningSubtle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_alt_outlined, size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              parts.join(' · '),
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryHeroCard extends StatelessWidget {
  const _SummaryHeroCard({
    required this.metrics,
    required this.onTap,
  });

  final SalesDashboardMetrics metrics;
  final VoidCallback? onTap;

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
                    'Сводка',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.onPrimary.withValues(alpha: 0.9),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${metrics.totalSum.toStringAsFixed(2)} ₽',
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${metrics.saleCount} продаж · '
                'средний чек ${metrics.averageCheck.toStringAsFixed(0)} ₽',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.85),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Нажмите, чтобы открыть список',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.75),
                  ),
                ),
              ],
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

class _PaymentBreakdownCard extends StatelessWidget {
  const _PaymentBreakdownCard({required this.metrics});

  final SalesDashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _PaymentBar(
              label: PaymentMethods.labels[PaymentMethods.cash]!,
              count: metrics.cashCount,
              sum: metrics.cashSum,
              share: metrics.cashShare,
              color: AppColors.success,
            ),
            const SizedBox(height: 16),
            _PaymentBar(
              label: PaymentMethods.labels[PaymentMethods.card]!,
              count: metrics.cardCount,
              sum: metrics.cardSum,
              share: metrics.cardShare,
              color: AppColors.info,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentBar extends StatelessWidget {
  const _PaymentBar({
    required this.label,
    required this.count,
    required this.sum,
    required this.share,
    required this.color,
  });

  final String label;
  final int count;
  final double sum;
  final double share;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
            Text(
              '${(share * 100).round()}%',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: share,
            minHeight: 8,
            backgroundColor: AppColors.border,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$count · ${sum.toStringAsFixed(0)} ₽',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

class _TopSellerCard extends StatelessWidget {
  const _TopSellerCard({required this.metrics});

  final SalesDashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primaryMuted,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Лидер продаж', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    metrics.topSellerName!,
                    style: AppTextStyles.headingSmall,
                  ),
                  Text(
                    '${metrics.topSellerCount} продаж',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesHistoryEntriesView extends StatelessWidget {
  const _SalesHistoryEntriesView({required this.loaded});

  final AdminSalesHistoryEntriesLoaded loaded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список продаж'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.read<AdminSalesHistoryCubit>().backToDashboard(),
        ),
        actions: [
          IconButton(
            onPressed: loaded.entries.isEmpty
                ? null
                : () => _exportSalesReport(context),
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Экспорт CSV',
          ),
        ],
      ),
      body: loaded.entries.isEmpty
          ? Center(
              child: Text(
                'Нет продаж за выбранный период',
                style: AppTextStyles.bodyLarge,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: loaded.entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _SaleHistoryCard(
                entry: loaded.entries[index],
                onTap: () => context
                    .read<AdminSalesHistoryCubit>()
                    .openSaleDetail(loaded.entries[index]),
              ),
            ),
    );
  }
}

class _SalesHistoryFilterSheet extends StatefulWidget {
  const _SalesHistoryFilterSheet({
    required this.initialFilter,
    required this.sellers,
    required this.onApply,
    required this.onReset,
  });

  final SalesHistoryFilter initialFilter;
  final List<SellerOption> sellers;
  final ValueChanged<SalesHistoryFilter> onApply;
  final VoidCallback onReset;

  @override
  State<_SalesHistoryFilterSheet> createState() =>
      _SalesHistoryFilterSheetState();
}

class _SalesHistoryFilterSheetState extends State<_SalesHistoryFilterSheet> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fromDate = widget.initialFilter.fromDate;
    _toDate = widget.initialFilter.toDate;
    _userId = widget.initialFilter.userId;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Фильтры', style: AppTextStyles.headingSmall),
          const SizedBox(height: 16),
          _DateFilterField(
            label: 'Дата с',
            value: _fromDate,
            onPick: (date) => setState(() => _fromDate = date),
            onClear: () => setState(() => _fromDate = null),
          ),
          const SizedBox(height: 12),
          _DateFilterField(
            label: 'Дата по',
            value: _toDate,
            onPick: (date) => setState(() => _toDate = date),
            onClear: () => setState(() => _toDate = null),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: _userId,
            decoration: const InputDecoration(
              labelText: 'Сотрудник',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Все'),
              ),
              ...widget.sellers.map(
                (seller) => DropdownMenuItem<String?>(
                  value: seller.id,
                  child: Text(seller.displayName),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _userId = value),
          ),
          const SizedBox(height: 20),
          AppButton(
            text: 'Применить',
            onPressed: () => widget.onApply(
              SalesHistoryFilter(
                fromDate: _fromDate,
                toDate: _toDate,
                userId: _userId,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onReset,
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }
}

class _DateFilterField extends StatelessWidget {
  const _DateFilterField({
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) onPick(picked);
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value == null ? label : _formatDate(value!),
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ),
        ),
        if (value != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close),
            tooltip: 'Очистить',
          ),
        ],
      ],
    );
  }
}

class _SaleHistoryCard extends StatelessWidget {
  const _SaleHistoryCard({
    required this.entry,
    required this.onTap,
  });

  final SaleHistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sale = entry.sale;
    final completedAt = sale.completedAt ?? sale.createdAt;
    final paymentLabel =
        PaymentMethods.labels[sale.paymentMethod] ?? sale.paymentMethod ?? '—';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDateTime(completedAt),
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: 8),
              Text(
                entry.sellerName.isNotEmpty
                    ? entry.sellerName
                    : 'Сотрудник ${sale.userId.substring(0, 8)}…',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      paymentLabel,
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  Text(
                    '${sale.sum?.toStringAsFixed(2) ?? '0.00'} ₽',
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaleDetailView extends StatelessWidget {
  const _SaleDetailView({
    required this.entry,
    required this.state,
  });

  final SaleHistoryEntry entry;
  final AdminSalesHistoryState state;

  @override
  Widget build(BuildContext context) {
    final sale = entry.sale;
    final completedAt = sale.completedAt ?? sale.createdAt;
    final paymentLabel =
        PaymentMethods.labels[sale.paymentMethod] ?? sale.paymentMethod ?? '—';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Продажа'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<AdminSalesHistoryCubit>().backToList(),
        ),
      ),
      body: switch (state) {
        AdminSalesHistoryDetailLoading() =>
          const Center(child: CircularProgressIndicator()),
        AdminSalesHistoryDetailLoaded(:final items, :final goodsById) =>
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(_formatDateTime(completedAt), style: AppTextStyles.headingSmall),
              const SizedBox(height: 8),
              Text(
                entry.sellerName.isNotEmpty
                    ? entry.sellerName
                    : 'Сотрудник',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text('Оплата: $paymentLabel', style: AppTextStyles.bodySmall),
              const SizedBox(height: 24),
              Text('Позиции', style: AppTextStyles.headingSmall),
              const SizedBox(height: 12),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          goodsById[item.goodsId]?.displayName ?? item.goodsId,
                          style: AppTextStyles.bodyLarge,
                        ),
                      ),
                      Text(
                        '${item.count} × ${item.cost.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Итого: ${sale.sum?.toStringAsFixed(2) ?? '0.00'} ₽',
                style: AppTextStyles.headingMedium,
              ),
            ],
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}.'
      '${local.month.toString().padLeft(2, '0')}.'
      '${local.year}';
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final time =
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
  return '${_formatDate(local)} $time';
}
