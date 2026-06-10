import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:local_reference_feature/local_reference_feature.dart';
import 'package:ui_kit/ui_kit.dart';

import '../domain/models/goods_in_sale.dart';
import '../domain/sales_cubit.dart';

final _getIt = GetIt.instance;

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _getIt<SalesCubit>(),
      child: const _SalesView(),
    );
  }
}

class _SalesView extends StatelessWidget {
  const _SalesView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SalesCubit, SalesState>(
      listener: (context, state) {
        if (state is SalesFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        return switch (state) {
          SalesCheckout() => _CheckoutView(state: state),
          SalesInitial() || SalesLoading() => Scaffold(
            appBar: AppBar(title: const Text('Продажи')),
            body: const Center(child: CircularProgressIndicator()),
          ),
          SalesCartBuilding() => _CartBuildingView(state: state),
          SalesFailure() => Scaffold(
            appBar: AppBar(title: const Text('Продажи')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Не удалось загрузить корзину', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Повторить',
                    onPressed: () => context.read<SalesCubit>().loadCart(),
                  ),
                ],
              ),
            ),
          ),
        };
      },
    );
  }
}

class _CartBuildingView extends StatelessWidget {
  const _CartBuildingView({required this.state});

  final SalesCartBuilding state;

  @override
  Widget build(BuildContext context) {
    final availableGoods = state.catalogGoods
        .where((goods) => (state.stockByGoodsId[goods.id] ?? 0) > 0)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Продажи'),
        actions: [
          IconButton(
            onPressed: () => context.read<SalesCubit>().loadCart(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Корзина', style: AppTextStyles.headingSmall),
          ),
          if (state.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Добавьте товары из каталога ниже',
                style: AppTextStyles.bodyMedium,
              ),
            )
          else
            Expanded(
              flex: 2,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _CartItemCard(
                  item: state.items[index],
                  goodsName: state.goodsById[state.items[index].goodsId]?.displayName,
                  onIncrement: () => _updateCount(
                    context,
                    itemId: state.items[index].id,
                    count: state.items[index].count + 1,
                  ),
                  onDecrement: () => _updateCount(
                    context,
                    itemId: state.items[index].id,
                    count: state.items[index].count - 1,
                  ),
                  onRemove: () => context.read<SalesCubit>().removeItem(
                    state.items[index].id,
                  ),
                ),
              ),
            ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('Каталог', style: AppTextStyles.headingSmall),
          ),
          Expanded(
            flex: 3,
            child: availableGoods.isEmpty
                ? Center(
                    child: Text(
                      'Нет товаров на складе',
                      style: AppTextStyles.bodyLarge,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: availableGoods.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final goods = availableGoods[index];
                      final stock = state.stockByGoodsId[goods.id] ?? 0;
                      return _CatalogItemCard(
                        goods: goods,
                        stockCount: stock,
                        onAdd: () => _showAddDialog(context, goods, stock),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Итого: ${state.total.toStringAsFixed(2)}',
                  style: AppTextStyles.headingSmall,
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 140,
                child: AppButton(
                  text: 'Оформить',
                  onPressed: state.items.isEmpty
                      ? null
                      : () => context.read<SalesCubit>().goToCheckout(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddDialog(
    BuildContext context,
    Goods goods,
    int stockCount,
  ) async {
    final quantity = await showDialog<int>(
      context: context,
      builder: (dialogContext) => _QuantityDialog(
        title: goods.displayName,
        maxCount: stockCount,
      ),
    );

    if (quantity == null || !context.mounted) return;

    final error = await context.read<SalesCubit>().addToCart(
      goodsId: goods.id,
      quantity: quantity,
    );
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _updateCount(
    BuildContext context, {
    required String itemId,
    required int count,
  }) async {
    final error = await context.read<SalesCubit>().updateItemCount(
      itemId: itemId,
      count: count,
    );
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }
}

class _CheckoutView extends StatefulWidget {
  const _CheckoutView({required this.state});

  final SalesCheckout state;

  @override
  State<_CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<_CheckoutView> {
  bool _isSubmitting = false;

  SalesCheckout get state => widget.state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Оформление'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<SalesCubit>().backToCart(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Позиции', style: AppTextStyles.headingSmall),
          const SizedBox(height: 12),
          ...state.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      state.goodsById[item.goodsId]?.displayName ?? item.goodsId,
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
          const SizedBox(height: 24),
          Text('Способ оплаты', style: AppTextStyles.headingSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: state.paymentMethod,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: PaymentMethods.labels.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<SalesCubit>().selectPaymentMethod(value);
              }
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Итого: ${state.total.toStringAsFixed(2)}',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Подтвердить продажу',
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : () => _confirmSale(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSale(BuildContext context) async {
    setState(() => _isSubmitting = true);
    final result = await context.read<SalesCubit>().confirmSale();
    if (!context.mounted) return;
    setState(() => _isSubmitting = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }

    if (result.sale != null) {
      final total = result.sale!.sum?.toStringAsFixed(2) ?? '0';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Продажа оформлена. Сумма: $total')),
      );
    }
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.goodsName,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final GoodsInSale item;
  final String? goodsName;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goodsName ?? item.goodsId, style: AppTextStyles.bodyLarge),
                  Text(
                    '${item.cost.toStringAsFixed(2)} × ${item.count} = ${item.lineTotal.toStringAsFixed(2)}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDecrement,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('${item.count}', style: AppTextStyles.bodyLarge),
            IconButton(
              onPressed: onIncrement,
              icon: const Icon(Icons.add_circle_outline),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogItemCard extends StatelessWidget {
  const _CatalogItemCard({
    required this.goods,
    required this.stockCount,
    required this.onAdd,
  });

  final Goods goods;
  final int stockCount;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(goods.displayName, style: AppTextStyles.bodyLarge),
        subtitle: Text(
          'На складе: $stockCount · ${(goods.cost ?? 0).toStringAsFixed(2)}',
          style: AppTextStyles.bodySmall,
        ),
        trailing: IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_shopping_cart),
        ),
      ),
    );
  }
}

class _QuantityDialog extends StatefulWidget {
  const _QuantityDialog({
    required this.title,
    required this.maxCount,
  });

  final String title;
  final int maxCount;

  @override
  State<_QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<_QuantityDialog> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Доступно: ${widget.maxCount}', style: AppTextStyles.bodySmall),
          const SizedBox(height: 16),
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
                onPressed: _quantity < widget.maxCount
                    ? () => setState(() => _quantity++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_quantity),
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}
