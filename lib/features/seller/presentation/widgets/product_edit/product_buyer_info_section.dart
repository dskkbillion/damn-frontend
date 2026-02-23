import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/product_edit_models.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

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
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBF7D2A), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Colors.white,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏（可点击展开/折叠）
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '需要买家提供',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      if (widget.items.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBF7D2A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.items.length}项信息',
                            style: const TextStyle(fontSize: 12, color: Color(0xFFBF7D2A)),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
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
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '选择你需要买家提供的信息类型（该信息将展示在订单详情页）',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),

          // 展开内容
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            _BuyerInfoTypeGrid(
              isPreviewMode: widget.isPreviewMode,
              onTypeTapped: (type) => _showAddDialog(context, type),
            ),
            if (widget.items.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                '已选择的信息项：',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '详细说明',
                      hintText: '请详细说明需要买家提供的信息内容',
                    ),
                  ),
                  const SizedBox(height: 12),
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
                        AppLocalizations.of(context)!?.product_edit_please_enter_label ??
                            'Please enter information label',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBF7D2A),
                foregroundColor: Colors.white,
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '详细说明',
                      hintText: '请详细说明需要买家提供的信息内容',
                    ),
                  ),
                  const SizedBox(height: 12),
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
                        AppLocalizations.of(context)!?.product_edit_please_enter_label ??
                            'Please enter information label',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBF7D2A),
                foregroundColor: Colors.white,
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFBF7D2A)),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(_iconFor(type), color: const Color(0xFFBF7D2A)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(type.displayName, style: const TextStyle(fontSize: 14)),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(_iconFor(item.type), size: 20, color: const Color(0xFFBF7D2A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item.label, style: const TextStyle(fontWeight: FontWeight.w500)),
                    if (item.isRequired)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '必填',
                          style: TextStyle(fontSize: 10, color: Colors.red),
                        ),
                      ),
                  ],
                ),
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          if (!isPreviewMode)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFFBF7D2A)),
                  onPressed: onEdit,
                  tooltip: '编辑',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
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
