import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/product_edit_models.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

/// 买家需要提供信息的 section。
///
/// 通过回调将操作传回父级，父级维护 [items] 列表：
/// - [onAdd]：添加信息项
/// - [onUpdate]：更新信息项
/// - [onRemove]：删除信息项（by index）
class ProductBuyerInfoSection extends StatefulWidget {
  const ProductBuyerInfoSection({
    super.key,
    required this.items,
    required this.isPreviewMode,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
  });

  final List<BuyerInfoItem> items;
  final bool isPreviewMode;
  final void Function(BuyerInfoType type, String label, String description, bool isRequired) onAdd;
  final void Function(int index, String label, String description, bool isRequired) onUpdate;
  final void Function(int index) onRemove;

  @override
  State<ProductBuyerInfoSection> createState() => _ProductBuyerInfoSectionState();
}

class _ProductBuyerInfoSectionState extends State<ProductBuyerInfoSection> {
  bool _isExpanded = false;

  InputDecoration get _lightBorderDecoration => InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.borderInput, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.borderInput, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd, vertical: AppDimensions.spacingMd),
        filled: true,
        fillColor: AppColors.backgroundCard,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundCard,
      margin: const EdgeInsets.only(top: AppDimensions.spacingMd),
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏（可点击展开/折叠）
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spacingSm, horizontal: AppDimensions.spacingXs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '需要买家提供',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
                    children: [
                      if (widget.items.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingSm,
                              vertical: AppDimensions.spacingXs),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          ),
                          child: Text(
                            '${widget.items.length}项信息',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                      const SizedBox(width: AppDimensions.spacingSm),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 折叠状态下显示说明
          if (!_isExpanded)
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              margin: const EdgeInsets.only(top: AppDimensions.spacingSm),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderInput),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Text(
                '选择你需要买家提供的信息类型（该信息将展示在订单详情页）',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
            ),

          // 展开内容
          if (_isExpanded) ...[
            const SizedBox(height: AppDimensions.spacingLg),
            _BuyerInfoTypeGrid(
              isPreviewMode: widget.isPreviewMode,
              onTypeTapped: (type) => _showAddDialog(context, type),
            ),
            if (widget.items.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              Text(
                '已选择的信息项：',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              ...widget.items.asMap().entries.map(
                    (entry) => _BuyerInfoItemTile(
                      index: entry.key,
                      item: entry.value,
                      isPreviewMode: widget.isPreviewMode,
                      onEdit: () => _showEditDialog(context, entry.key, entry.value),
                      onRemove: () => widget.onRemove(entry.key),
                    ),
                  ),
            ],
          ],
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, BuyerInfoType type) {
    if (widget.isPreviewMode) return;
    final labelController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isRequired = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('添加${type.displayName}信息'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
              maxWidth: double.maxFinite,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: labelController,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '信息标签',
                      hintText: '例如：公司Logo设计需求',
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '详细说明',
                      hintText: '请详细说明需要买家提供的信息内容',
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  CheckboxListTile(
                    title: const Text('必填项'),
                    value: isRequired,
                    onChanged: (value) => setState(() => isRequired = value ?? false),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (labelController.text.isNotEmpty) {
                  widget.onAdd(type, labelController.text, descriptionController.text, isRequired);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).product_edit_please_enter_label ??
                            'Please enter information label',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, int index, BuyerInfoItem item) {
    if (widget.isPreviewMode) return;
    final labelController = TextEditingController(text: item.label);
    final descriptionController = TextEditingController(text: item.description);
    bool isRequired = item.isRequired;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('编辑${item.type.displayName}信息'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
              maxWidth: double.maxFinite,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: labelController,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '信息标签',
                      hintText: '例如：公司Logo设计需求',
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '详细说明',
                      hintText: '请详细说明需要买家提供的信息内容',
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  CheckboxListTile(
                    title: const Text('必填项'),
                    value: isRequired,
                    onChanged: (value) => setState(() => isRequired = value ?? false),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (labelController.text.isNotEmpty) {
                  widget.onUpdate(
                      index, labelController.text, descriptionController.text, isRequired);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).product_edit_please_enter_label ??
                            'Please enter information label',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 信息类型选择网格
// ---------------------------------------------------------------------------

class _BuyerInfoTypeGrid extends StatelessWidget {
  const _BuyerInfoTypeGrid({required this.isPreviewMode, required this.onTypeTapped});

  final bool isPreviewMode;
  final void Function(BuyerInfoType type) onTypeTapped;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: BuyerInfoType.values.length,
      itemBuilder: (context, index) {
        final type = BuyerInfoType.values[index];
        return InkWell(
          onTap: isPreviewMode ? null : () => onTypeTapped(type),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              color: AppColors.backgroundCard,
            ),
            child: Row(
              children: [
                Icon(_iconFor(type), color: AppColors.primary),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Text(type.displayName,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _iconFor(BuyerInfoType type) {
    switch (type) {
      case BuyerInfoType.text:
        return Icons.text_fields;
      case BuyerInfoType.image:
        return Icons.image;
      case BuyerInfoType.file:
        return Icons.attach_file;
      case BuyerInfoType.contact:
        return Icons.contact_phone;
      case BuyerInfoType.requirement:
        return Icons.description;
      case BuyerInfoType.reference:
        return Icons.link;
    }
  }
}

// ---------------------------------------------------------------------------
// 单个信息项 tile
// ---------------------------------------------------------------------------

class _BuyerInfoItemTile extends StatelessWidget {
  const _BuyerInfoItemTile({
    required this.index,
    required this.item,
    required this.isPreviewMode,
    required this.onEdit,
    required this.onRemove,
  });

  final int index;
  final BuyerInfoItem item;
  final bool isPreviewMode;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderInput),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        children: [
          Icon(_iconFor(item.type), size: 20, color: AppColors.primary),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item.label,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500)),
                    if (item.isRequired)
                      Container(
                        margin: const EdgeInsets.only(left: AppDimensions.spacingSm),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingXs + 2,
                            vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Text(
                          '必填',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                color: AppColors.error,
                              ),
                        ),
                      ),
                  ],
                ),
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
              ],
            ),
          ),
          if (!isPreviewMode)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  onPressed: onEdit,
                  tooltip: '编辑',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: onRemove,
                  tooltip: '删除',
                ),
              ],
            ),
        ],
      ),
    );
  }

  IconData _iconFor(BuyerInfoType type) {
    switch (type) {
      case BuyerInfoType.text:
        return Icons.text_fields;
      case BuyerInfoType.image:
        return Icons.image;
      case BuyerInfoType.file:
        return Icons.attach_file;
      case BuyerInfoType.contact:
        return Icons.contact_phone;
      case BuyerInfoType.requirement:
        return Icons.description;
      case BuyerInfoType.reference:
        return Icons.link;
    }
  }
}
