import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

Future<void> showStockAdjustDialog(
  BuildContext context, {
  required String title,
  required int? maxCount,
  required Future<String?> Function(int count, String? comment) onSubmit,
}) async {
  final result = await showDialog<({int count, String? comment})>(
    context: context,
    builder: (dialogContext) => _StockAdjustDialog(
      title: title,
      maxCount: maxCount,
    ),
  );

  if (result == null || !context.mounted) return;

  final error = await onSubmit(result.count, result.comment);
  if (error != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }
}

Future<void> showStockMetaDialog(
  BuildContext context, {
  required String goodsAddr,
  required int minCount,
  required Future<String?> Function(String goodsAddr, int minCount) onSubmit,
}) async {
  final result = await showDialog<({String goodsAddr, int minCount})>(
    context: context,
    builder: (dialogContext) => _StockMetaDialog(
      goodsAddr: goodsAddr,
      minCount: minCount,
    ),
  );

  if (result == null || !context.mounted) return;

  final error = await onSubmit(result.goodsAddr, result.minCount);
  if (error != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }
}

Future<void> confirmDeleteStockPosition(
  BuildContext context, {
  required String label,
  required Future<String?> Function() onConfirm,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Удалить позицию?'),
      content: Text(
        'Позиция «$label» будет удалена со склада. Товар в справочнике останется.',
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

  final error = await onConfirm();
  if (error != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }
}

class _StockMetaDialog extends StatefulWidget {
  const _StockMetaDialog({
    required this.goodsAddr,
    required this.minCount,
  });

  final String goodsAddr;
  final int minCount;

  @override
  State<_StockMetaDialog> createState() => _StockMetaDialogState();
}

class _StockMetaDialogState extends State<_StockMetaDialog> {
  late final TextEditingController _addrController;
  late final TextEditingController _minCountController;

  @override
  void initState() {
    super.initState();
    _addrController = TextEditingController(text: widget.goodsAddr);
    _minCountController =
        TextEditingController(text: widget.minCount.toString());
  }

  @override
  void dispose() {
    _addrController.dispose();
    _minCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Параметры позиции'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _addrController,
            decoration: const InputDecoration(
              labelText: 'Адрес / ячейка',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _minCountController,
            decoration: const InputDecoration(
              labelText: 'Минимальный остаток',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  void _submit() {
    final minCount = int.tryParse(_minCountController.text.trim());
    if (minCount == null || minCount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Минимальный остаток должен быть неотрицательным'),
        ),
      );
      return;
    }

    Navigator.of(context).pop((
      goodsAddr: _addrController.text.trim(),
      minCount: minCount,
    ));
  }
}

class _StockAdjustDialog extends StatefulWidget {
  const _StockAdjustDialog({
    required this.title,
    required this.maxCount,
  });

  final String title;
  final int? maxCount;

  @override
  State<_StockAdjustDialog> createState() => _StockAdjustDialogState();
}

class _StockAdjustDialogState extends State<_StockAdjustDialog> {
  int _quantity = 1;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxCount = widget.maxCount;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (maxCount != null)
            Text('Доступно: $maxCount', style: AppTextStyles.bodySmall),
          if (maxCount != null) const SizedBox(height: 16),
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
                onPressed: maxCount == null || _quantity < maxCount
                    ? () => setState(() => _quantity++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Комментарий',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            final comment = _commentController.text.trim();
            Navigator.of(context).pop((
              count: _quantity,
              comment: comment.isEmpty ? null : comment,
            ));
          },
          child: const Text('Применить'),
        ),
      ],
    );
  }
}
