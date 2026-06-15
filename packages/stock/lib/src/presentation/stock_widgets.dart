import 'package:flutter/material.dart';
import 'package:local_reference_feature/local_reference_feature.dart';
import 'package:ui_kit/ui_kit.dart';

import '../domain/models/stock_positions_filter.dart';
import '../domain/models/stock_item.dart';
import '../domain/stock_list_utils.dart';

/// Compact warehouse position row for list screens.
class StockPositionRow extends StatelessWidget {
  const StockPositionRow({
    required this.item,
    required this.goodsById,
    required this.onTap,
    super.key,
  });

  final StockItem item;
  final Map<String, Goods> goodsById;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: item.isLowStock ? AppColors.warningSubtle : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stockItemTitle(item, goodsById),
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stockItemSubtitle(item, goodsById),
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.count}',
                    style: AppTextStyles.headingSmall,
                  ),
                  Text(
                    'мин ${item.minCount}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              if (item.isLowStock) ...[
                const SizedBox(width: 8),
                const StockLowBadge(),
              ],
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StockLowBadge extends StatelessWidget {
  const StockLowBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Мало',
        style: AppTextStyles.caption.copyWith(color: AppColors.textInverse),
      ),
    );
  }
}

class StockSearchField extends StatelessWidget {
  const StockSearchField({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: 'Поиск по товару или адресу',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

class StockFilterChips extends StatelessWidget {
  const StockFilterChips({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final StockPositionsFilter selected;
  final ValueChanged<StockPositionsFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: StockPositionsFilter.values.map((filter) {
          final isSelected = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (_) => onSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}
