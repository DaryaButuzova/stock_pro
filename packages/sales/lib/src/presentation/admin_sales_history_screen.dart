import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ui_kit/ui_kit.dart';

import '../domain/admin_sales_history_cubit.dart';
import '../domain/models/sale_history_entry.dart';
import '../domain/sales_cubit.dart';

final _getIt = GetIt.instance;

/// Admin view listing completed sales.
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
          _ => _SalesHistoryListView(state: state),
        };
      },
    );
  }
}

class _SalesHistoryListView extends StatelessWidget {
  const _SalesHistoryListView({required this.state});

  final AdminSalesHistoryState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Продажи'),
        actions: [
          IconButton(
            onPressed: () =>
                context.read<AdminSalesHistoryCubit>().loadHistory(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: switch (state) {
        AdminSalesHistoryInitial() || AdminSalesHistoryLoading() =>
          const Center(child: CircularProgressIndicator()),
        AdminSalesHistoryListLoaded(:final entries) when entries.isEmpty =>
          Center(
            child: Text(
              'Завершённых продаж пока нет',
              style: AppTextStyles.bodyLarge,
            ),
          ),
        AdminSalesHistoryListLoaded(:final entries) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _SaleHistoryCard(
            entry: entries[index],
            onTap: () => context
                .read<AdminSalesHistoryCubit>()
                .openSaleDetail(entries[index]),
          ),
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
        AdminSalesHistoryDetailLoading() ||
        AdminSalesHistoryDetailLoaded() =>
          const SizedBox.shrink(),
      },
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
                    '${sale.sum?.toStringAsFixed(2) ?? '0.00'}',
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
                'Итого: ${sale.sum?.toStringAsFixed(2) ?? '0.00'}',
                style: AppTextStyles.headingMedium,
              ),
            ],
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
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
