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
    this.nestedInCategory = false,
    super.key,
  });

  final StockItem item;
  final Map<String, Goods> goodsById;
  final VoidCallback onTap;
  final bool nestedInCategory;

  Color? get _backgroundColor {
    if (item.isLowStock) return AppColors.warningSubtle;
    if (nestedInCategory) return AppColors.primarySubtle;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: nestedInCategory ? 0 : 1,
      color: _backgroundColor,
      shape: nestedInCategory
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: item.isLowStock
                    ? AppColors.warning.withValues(alpha: 0.35)
                    : AppColors.primary.withValues(alpha: 0.18),
              ),
            )
          : null,
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
        hintText: 'Поиск по товару, адресу или категории',
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

/// Warehouse positions grouped by goods category with collapsible sections.
class StockCategoryGroupedList extends StatefulWidget {
  const StockCategoryGroupedList({
    required this.items,
    required this.goodsById,
    required this.onItemTap,
    required this.searchQuery,
    required this.filter,
    super.key,
  });

  final List<StockItem> items;
  final Map<String, Goods> goodsById;
  final ValueChanged<StockItem> onItemTap;
  final String searchQuery;
  final StockPositionsFilter filter;

  @override
  State<StockCategoryGroupedList> createState() =>
      _StockCategoryGroupedListState();
}

class _StockCategoryGroupedListState extends State<StockCategoryGroupedList> {
  static const _expandDuration = Duration(milliseconds: 280);

  final Set<String> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _syncExpansion();
  }

  @override
  void didUpdateWidget(covariant StockCategoryGroupedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items ||
        oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.filter != widget.filter) {
      _syncExpansion();
    }
  }

  void _syncExpansion() {
    final groups = groupStockItemsByCategory(
      items: widget.items,
      goodsById: widget.goodsById,
    );
    final visibleLabels = groups.map((group) => group.categoryLabel).toSet();

    if (shouldExpandAllStockCategories(
      groups: groups,
      searchQuery: widget.searchQuery,
      filter: widget.filter,
    )) {
      _expandedCategories
        ..clear()
        ..addAll(visibleLabels);
      return;
    }

    final preserved =
        _expandedCategories.intersection(visibleLabels).toSet();
    final defaults = defaultExpandedStockCategories(groups);

    _expandedCategories
      ..clear()
      ..addAll(preserved)
      ..addAll(defaults);
  }

  void _toggleCategory(String categoryLabel) {
    setState(() {
      if (_expandedCategories.contains(categoryLabel)) {
        _expandedCategories.remove(categoryLabel);
      } else {
        _expandedCategories.add(categoryLabel);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = groupStockItemsByCategory(
      items: widget.items,
      goodsById: widget.goodsById,
    );

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final group = groups[index];
        final isExpanded = _expandedCategories.contains(group.categoryLabel);

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: AppColors.surfaceVariant,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.divider),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => _toggleCategory(group.categoryLabel),
                child: Container(
                  width: double.infinity,
                  color: AppColors.secondaryMuted,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0,
                        duration: _expandDuration,
                        curve: Curves.easeInOutCubic,
                        child: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          group.categoryLabel,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (group.hasLowStock) ...[
                        const StockLowBadge(),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '${group.items.length}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _StockCategoryExpandableBody(
                isExpanded: isExpanded,
                duration: _expandDuration,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(height: 1),
                    ColoredBox(
                      color: AppColors.primaryMuted,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                        child: Column(
                          children: [
                            for (var i = 0; i < group.items.length; i++) ...[
                              if (i > 0) const SizedBox(height: 8),
                              StockPositionRow(
                                item: group.items[i],
                                goodsById: widget.goodsById,
                                nestedInCategory: true,
                                onTap: () =>
                                    widget.onItemTap(group.items[i]),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animated expand/collapse with synchronized height and opacity.
class _StockCategoryExpandableBody extends StatelessWidget {
  const _StockCategoryExpandableBody({
    required this.isExpanded,
    required this.duration,
    required this.child,
  });

  final bool isExpanded;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeInOutCubic,
      tween: Tween<double>(end: isExpanded ? 1 : 0),
      builder: (context, progress, animatedChild) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: progress,
            child: Opacity(
              opacity: progress,
              child: animatedChild,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
