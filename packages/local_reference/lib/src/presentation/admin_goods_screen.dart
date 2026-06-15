import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ui_kit/ui_kit.dart';

import '../domain/admin_goods_cubit.dart';
import '../domain/models/goods.dart';

final _getIt = GetIt.instance;

/// Admin catalog screen for creating and editing goods.
class AdminGoodsScreen extends StatelessWidget {
  const AdminGoodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _getIt<AdminGoodsCubit>(),
      child: const _AdminGoodsView(),
    );
  }
}

class _AdminGoodsView extends StatelessWidget {
  const _AdminGoodsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Справочник товаров'),
        actions: [
          IconButton(
            onPressed: () => context.read<AdminGoodsCubit>().loadGoods(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGoodsForm(context),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<AdminGoodsCubit, AdminGoodsState>(
        listener: (context, state) {
          if (state is AdminGoodsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            AdminGoodsInitial() || AdminGoodsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            AdminGoodsLoaded(:final items) when items.isEmpty => Center(
              child: Text(
                'Товаров пока нет',
                style: AppTextStyles.bodyLarge,
              ),
            ),
            AdminGoodsLoaded(:final items) => ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _GoodsCard(
                goods: items[index],
                onEdit: () => _showGoodsForm(context, goods: items[index]),
                onDelete: () => _confirmDelete(context, items[index]),
              ),
            ),
            AdminGoodsFailure() => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Не удалось загрузить справочник',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Повторить',
                    onPressed: () =>
                        context.read<AdminGoodsCubit>().loadGoods(),
                  ),
                ],
              ),
            ),
          };
        },
      ),
    );
  }

  Future<void> _showGoodsForm(BuildContext context, {Goods? goods}) async {
    final result = await showDialog<_GoodsFormResult>(
      context: context,
      builder: (dialogContext) => _GoodsFormDialog(goods: goods),
    );

    if (result == null || !context.mounted) return;

    final cubit = context.read<AdminGoodsCubit>();
    final String? error;
    if (goods == null) {
      error = await cubit.createGoods(
        name: result.name,
        description: result.description,
        cost: result.cost,
        category: result.category,
      );
    } else {
      error = await cubit.updateGoods(
        id: goods.id,
        name: result.name,
        description: result.description,
        cost: result.cost,
        category: result.category,
      );
    }

    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, Goods goods) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить товар?'),
        content: Text(
          '«${goods.displayName}» будет удалён из справочника.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final error = await context.read<AdminGoodsCubit>().deleteGoods(goods.id);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }
}

class _GoodsCard extends StatelessWidget {
  const _GoodsCard({
    required this.goods,
    required this.onEdit,
    required this.onDelete,
  });

  final Goods goods;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goods.displayName,
                    style: AppTextStyles.headingSmall,
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Редактировать',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Удалить',
                ),
              ],
            ),
            if (goods.category != null && goods.category!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Категория: ${goods.category}',
                style: AppTextStyles.bodySmall,
              ),
            ],
            if (goods.cost != null) ...[
              const SizedBox(height: 4),
              Text(
                'Цена: ${goods.cost!.toStringAsFixed(2)} ₽',
                style: AppTextStyles.bodyMedium,
              ),
            ],
            if (goods.description != null && goods.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                goods.description!,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

typedef _GoodsFormResult = ({
  String name,
  String? description,
  double? cost,
  String? category,
});

class _GoodsFormDialog extends StatefulWidget {
  const _GoodsFormDialog({this.goods});

  final Goods? goods;

  @override
  State<_GoodsFormDialog> createState() => _GoodsFormDialogState();
}

class _GoodsFormDialogState extends State<_GoodsFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _costController;
  late final TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    final goods = widget.goods;
    _nameController = TextEditingController(text: goods?.name ?? '');
    _descriptionController =
        TextEditingController(text: goods?.description ?? '');
    _costController = TextEditingController(
      text: goods?.cost?.toStringAsFixed(2) ?? '',
    );
    _categoryController = TextEditingController(text: goods?.category ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.goods != null;

    return AlertDialog(
      title: Text(isEdit ? 'Редактировать товар' : 'Новый товар'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название *',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Категория',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Цена',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(isEdit ? 'Сохранить' : 'Создать'),
        ),
      ],
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите название товара')),
      );
      return;
    }

    final costText = _costController.text.trim().replaceAll(',', '.');
    double? cost;
    if (costText.isNotEmpty) {
      cost = double.tryParse(costText);
      if (cost == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Некорректная цена')),
        );
        return;
      }
      if (cost < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Цена не может быть отрицательной')),
        );
        return;
      }
    }

    Navigator.of(context).pop((
      name: name,
      description: _optionalText(_descriptionController.text),
      cost: cost,
      category: _optionalText(_categoryController.text),
    ));
  }

  String? _optionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
