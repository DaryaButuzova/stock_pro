import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_reference_feature/local_reference_feature.dart';
import 'package:ui_kit/ui_kit.dart';

import 'sales_catalog_utils.dart';

typedef SalesAddItemCallback = Future<String?> Function({
  required String goodsId,
  required int quantity,
});

/// Bottom sheet for searching and adding goods to the sales cart.
///
/// Designed as a standalone surface so barcode scan, favorites, and other
/// entry points can be added later without changing the cart screen.
class SalesAddItemSheet extends StatefulWidget {
  const SalesAddItemSheet({
    required this.catalogGoods,
    required this.stockByGoodsId,
    required this.cartCountByGoodsId,
    required this.onAdd,
    super.key,
  });

  final List<Goods> catalogGoods;
  final Map<String, int> stockByGoodsId;
  final Map<String, int> cartCountByGoodsId;
  final SalesAddItemCallback onAdd;

  @override
  State<SalesAddItemSheet> createState() => _SalesAddItemSheetState();
}

class _SalesAddItemSheetState extends State<SalesAddItemSheet> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  String _searchQuery = '';
  String? _selectedCategory;
  String? _pendingGoodsId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<Goods> get _filteredGoods => filterAvailableCatalogGoods(
    catalogGoods: widget.catalogGoods,
    stockByGoodsId: widget.stockByGoodsId,
    searchQuery: _searchQuery,
    category: _selectedCategory,
  );

  List<String> get _categories =>
      extractCatalogCategories(widget.catalogGoods);

  Future<void> _quickAdd(Goods goods) async {
    if (_pendingGoodsId != null) return;

    setState(() => _pendingGoodsId = goods.id);
    final error = await widget.onAdd(goodsId: goods.id, quantity: 1);
    if (!mounted) return;
    setState(() => _pendingGoodsId = null);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _addWithQuantity(Goods goods) async {
    final stockCount = widget.stockByGoodsId[goods.id] ?? 0;
    final inCart = widget.cartCountByGoodsId[goods.id] ?? 0;
    final maxCount = stockCount - inCart;
    if (maxCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Недостаточно на складе')),
      );
      return;
    }

    final quantity = await showDialog<int>(
      context: context,
      builder: (dialogContext) => _QuantityDialog(
        title: goods.displayName,
        maxCount: maxCount,
        initialQuantity: 1,
      ),
    );
    if (quantity == null || !mounted) return;

    setState(() => _pendingGoodsId = goods.id);
    final error = await widget.onAdd(goodsId: goods.id, quantity: quantity);
    if (!mounted) return;
    setState(() => _pendingGoodsId = null);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredGoods = _filteredGoods;
    final categories = _categories;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Добавить товар',
                        style: AppTextStyles.headingSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: const InputDecoration(
                    hintText: 'Поиск по названию или категории',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              if (categories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('Все'),
                            selected: _selectedCategory == null,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = null),
                          ),
                        ),
                        for (final category in categories)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (_) => setState(
                                () => _selectedCategory = category,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: filteredGoods.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty && _selectedCategory == null
                              ? 'Нет товаров на складе'
                              : 'Ничего не найдено',
                          style: AppTextStyles.bodyLarge,
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: filteredGoods.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final goods = filteredGoods[index];
                          final stock = widget.stockByGoodsId[goods.id] ?? 0;
                          final inCart =
                              widget.cartCountByGoodsId[goods.id] ?? 0;
                          final isPending = _pendingGoodsId == goods.id;

                          return _CatalogPickRow(
                            goods: goods,
                            stockCount: stock,
                            inCartCount: inCart,
                            isPending: isPending,
                            onTap: () => _addWithQuantity(goods),
                            onQuickAdd: () => _quickAdd(goods),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CatalogPickRow extends StatelessWidget {
  const _CatalogPickRow({
    required this.goods,
    required this.stockCount,
    required this.inCartCount,
    required this.isPending,
    required this.onTap,
    required this.onQuickAdd,
  });

  final Goods goods;
  final int stockCount;
  final int inCartCount;
  final bool isPending;
  final VoidCallback onTap;
  final VoidCallback onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final price = (goods.cost ?? 0).toStringAsFixed(2);
    final subtitle = inCartCount > 0
        ? 'На складе: $stockCount · $price · в корзине: $inCartCount'
        : 'На складе: $stockCount · $price';

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: isPending ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goods.displayName, style: AppTextStyles.bodyLarge),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              if (isPending)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  tooltip: 'Добавить 1',
                  onPressed: onQuickAdd,
                  icon: const Icon(Icons.add_circle_outline),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityDialog extends StatefulWidget {
  const _QuantityDialog({
    required this.title,
    required this.maxCount,
    this.initialQuantity = 1,
  });

  final String title;
  final int maxCount;
  final int initialQuantity;

  @override
  State<_QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<_QuantityDialog> {
  late final TextEditingController _controller;
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity.clamp(1, widget.maxCount);
    _controller = TextEditingController(text: '$_quantity');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _adjustQuantity(int delta) {
    final parsed = int.tryParse(_controller.text.trim()) ?? _quantity;
    final next = parsed + delta;
    if (next < 1) return;

    setState(() {
      _quantity = next;
      _controller.value = TextEditingValue(
        text: '$next',
        selection: TextSelection.collapsed(offset: '$next'.length),
      );
    });
  }

  void _onQuantityTextChanged(String value) {
    if (value.isEmpty) {
      setState(() => _quantity = 0);
      return;
    }

    final parsed = int.tryParse(value);
    if (parsed == null) return;

    setState(() => _quantity = parsed);
  }

  int? _resolveQuantity() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null || parsed < 1 || parsed > widget.maxCount) return null;
    return parsed;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedQuantity = _resolveQuantity();
    final parsedQuantity = int.tryParse(_controller.text.trim());
    final showMaxWarning =
        parsedQuantity != null && parsedQuantity > widget.maxCount;
    final canDecrement = (parsedQuantity ?? 0) > 1;
    final canIncrement = (parsedQuantity ?? 0) < widget.maxCount;

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
                onPressed: canDecrement ? () => _adjustQuantity(-1) : null,
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 72,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingSmall,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onQuantityTextChanged,
                ),
              ),
              IconButton(
                onPressed: canIncrement ? () => _adjustQuantity(1) : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          if (showMaxWarning)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Максимум: ${widget.maxCount}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: resolvedQuantity == null
              ? null
              : () => Navigator.of(context).pop(resolvedQuantity),
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}
