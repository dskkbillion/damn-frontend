import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/product_edit_models.dart';

/// 常见问题编辑 section。
///
/// 内部管理 QA 列表和 TextEditingController，
/// 通过 [onChanged] 将最新列表传回父级（父级用于脏检测和 BLoC 同步）。
class ProductQASection extends StatefulWidget {
  const ProductQASection({
    super.key,
    required this.initialItems,
    required this.isPreviewMode,
    required this.onChanged,
  });

  final List<QAPair> initialItems;
  final bool isPreviewMode;
  /// 每次列表变化时回调，传入当前完整列表的快照
  final void Function(List<QAPair> items) onChanged;

  @override
  State<ProductQASection> createState() => _ProductQASectionState();
}

class _ProductQASectionState extends State<ProductQASection> {
  late final List<QAPair> _qaList;
  final Map<String, TextEditingController> _qaControllers = {};
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
  void initState() {
    super.initState();
    _qaList = List.from(widget.initialItems);
  }

  @override
  void dispose() {
    for (final c in _qaControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // 外部数据同步（父级重建时更新列表，不影响正在编辑的项）
  @override
  void didUpdateWidget(ProductQASection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 仅当父级传入的列表长度与内部不同时才同步（保持编辑中状态）
    if (widget.initialItems.length != _qaList.length) {
      _qaList
        ..clear()
        ..addAll(widget.initialItems);
      _cleanupUnusedControllers();
    }
  }

  TextEditingController _getController(int index, String type, String initialValue) {
    final key = '${index}_$type';
    if (!_qaControllers.containsKey(key)) {
      _qaControllers[key] = TextEditingController(text: initialValue);
    }
    final controller = _qaControllers[key]!;
    if (controller.text != initialValue) {
      final selection = controller.selection;
      controller.text = initialValue;
      if (selection.isValid && selection.end <= initialValue.length) {
        controller.selection = selection;
      }
    }
    return controller;
  }

  void _cleanupUnusedControllers() {
    final currentKeys = <String>{};
    for (int i = 0; i < _qaList.length; i++) {
      currentKeys.add('${i}_question');
      currentKeys.add('${i}_answer');
    }
    final toRemove =
        _qaControllers.keys.where((k) => !currentKeys.contains(k)).toList();
    for (final key in toRemove) {
      _qaControllers[key]?.dispose();
      _qaControllers.remove(key);
    }
  }

  void _addQAPair() {
    setState(() {
      _qaList.add(QAPair(question: '', answer: ''));
    });
    widget.onChanged(List.unmodifiable(_qaList));
  }

  void _removeQAPair(int index) {
    setState(() {
      _qaList.removeAt(index);
      _cleanupUnusedControllers();
    });
    widget.onChanged(List.unmodifiable(_qaList));
  }

  void _updateQAPair(int index, String question, String answer) {
    _qaList[index].question = question;
    _qaList[index].answer = answer;
    widget.onChanged(List.unmodifiable(_qaList));
  }

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
                    '常见问题编辑',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      if (_qaList.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBF7D2A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_qaList.length}个问题',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFBF7D2A),
                            ),
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

          // 展开内容
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            if (_qaList.isNotEmpty)
              ...List.generate(_qaList.length, (index) => _buildQAItem(index)),
            if (!widget.isPreviewMode)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16),
                child: OutlinedButton.icon(
                  onPressed: _addQAPair,
                  icon: const Icon(Icons.add),
                  label: const Text('添加问题'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFBF7D2A),
                    side: const BorderSide(color: Color(0xFFBF7D2A)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildQAItem(int index) {
    final qa = _qaList[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: widget.isPreviewMode,
                  decoration: _lightBorderDecoration.copyWith(
                    labelText: '问题',
                    hintText: '输入买家可能问的问题',
                  ),
                  controller: _getController(index, 'question', qa.question),
                  onChanged: widget.isPreviewMode
                      ? null
                      : (value) => _updateQAPair(index, value, qa.answer),
                  enableIMEPersonalizedLearning: true,
                  keyboardType: TextInputType.text,
                ),
              ),
              const SizedBox(width: 8),
              if (!widget.isPreviewMode)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeQAPair(index),
                  tooltip: '删除问题',
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            readOnly: widget.isPreviewMode,
            decoration: _lightBorderDecoration.copyWith(
              labelText: '答案',
              hintText: '输入对应的答案',
            ),
            controller: _getController(index, 'answer', qa.answer),
            maxLines: 3,
            onChanged: widget.isPreviewMode
                ? null
                : (value) => _updateQAPair(index, qa.question, value),
            enableIMEPersonalizedLearning: true,
            keyboardType: TextInputType.text,
          ),
        ],
      ),
    );
  }
}
