# 修复商品编辑页面 productMaterials 数据保存问题

## 问题描述 (GitHub Issue #67)

商品编辑页面保存数据时，"需要卖家提供"板块的数据（buyerInfoItems）没有正确保存到后端。经调查发现，这些数据应该被转换为 `productMaterials` 字段发送到后端，但在页面的 `_buildFormData()` 方法中被硬编码为空数组。

## 问题根因

在文件 `lib/features/seller/presentation/pages/product_edit_page.dart` 的第3631行（修复前），`productMaterials` 被硬编码为空数组：

```dart
productMaterials: [],  // 错误：应该包含转换后的数据
```

## 影响范围

1. **buyerInfoItems**（买家需要提供的信息）完全丢失
2. **qaList**（常见问题）数据虽然单独保存，但也应该通过 productMaterials 传递
3. 所有通过页面保存的商品数据都受影响

## 数据结构说明

### ProductMaterial 类型映射

- **PROBLEM**: 常见问题 (QA)
- **TEXT**: 文本类型的买家需求信息
- **ATTACHMENT**: 文件/图片类型的买家需求信息
- **FILE**: 文件类型（已废弃，使用 ATTACHMENT）

### BuyerInfoType 到 ProductMaterial.type 的映射

- `BuyerInfoType.text` → `"TEXT"`
- `BuyerInfoType.image` → `"ATTACHMENT"`
- `BuyerInfoType.file` → `"ATTACHMENT"`
- `BuyerInfoType.contact` → `"TEXT"`
- `BuyerInfoType.requirement` → `"TEXT"`
- `BuyerInfoType.reference` → `"TEXT"`

## 修复方案

### 修改文件
`lib/features/seller/presentation/pages/product_edit_page.dart`

### 修复代码
在 `_buildFormData()` 方法中，添加了 qaList 和 buyerInfoItems 到 productMaterials 的转换逻辑：

```dart
// 转换qaList和buyerInfoItems为productMaterials
final List<ProductMaterial> materials = [];

// 转换qaList为PROBLEM类型的materials
int materialId = 1;
for (final qa in _qaList) {
  materials.add(ProductMaterial(
    id: materialId++,
    question: qa.question,
    answer: qa.answer,
    type: 'PROBLEM',
  ));
}

// 转换buyerInfoItems为ATTACHMENT或TEXT类型的materials
int buyerInfoMaterialId = 1000; // 从1000开始，避免与QA的ID冲突
for (final item in _buyerInfoItems) {
  String materialType = 'TEXT';
  // 根据类型判断是TEXT还是ATTACHMENT
  if (item.type == BuyerInfoType.file || item.type == BuyerInfoType.image) {
    materialType = 'ATTACHMENT';
  }
  
  materials.add(ProductMaterial(
    id: buyerInfoMaterialId++,
    question: item.label,
    answer: item.description,
    type: materialType,
  ));
}

// 使用转换后的materials
productMaterials: materials,
```

## 数据流验证

### 1. 保存流程
- 页面 → `_buildFormData()` → 转换 buyerInfoItems 和 qaList → productMaterials
- BLoC → `ProductEditBloc._onSubmitForm()` → 同样的转换逻辑（作为双重保障）
- Repository → 序列化 productMaterials → 发送到后端 API

### 2. 加载流程
- 后端 API → productMaterials 数组
- `ProductFormData.fromProduct()` → 反向转换为 qaList 和 buyerInfoItems
- 页面显示正确的数据

## 测试验证

创建了单元测试文件 `test/features/seller/presentation/pages/product_edit_page_test.dart` 来验证转换逻辑：

1. QA items 正确转换为 PROBLEM 类型
2. BuyerInfoItems 正确转换为 TEXT/ATTACHMENT 类型
3. 组合转换正确处理
4. 空列表正确处理

所有测试通过 ✓

## 相关文件

- **主要修复**: `lib/features/seller/presentation/pages/product_edit_page.dart`
- **BLoC逻辑**: `lib/features/seller/presentation/bloc/product_edit/product_edit_bloc.dart`
- **状态管理**: `lib/features/seller/presentation/bloc/product_edit/product_edit_state.dart`
- **数据源**: `lib/features/seller/data/datasources/seller_remote_data_source_impl.dart`
- **实体定义**: `lib/features/seller/domain/entities/seller_managed_product.dart`
- **测试文件**: `test/features/seller/presentation/pages/product_edit_page_test.dart`

## 注意事项

1. **ID分配策略**: QA items 从 ID 1 开始，BuyerInfoItems 从 ID 1000 开始，避免冲突
2. **类型映射**: 确保 BuyerInfoType 正确映射到 ProductMaterial 的 type 字段
3. **双重保障**: BLoC 层也有相同的转换逻辑，确保数据完整性

## 验证步骤

1. 创建/编辑商品时添加"常见问题"
2. 添加"需要买家提供"的信息项
3. 保存商品
4. 重新打开编辑页面，验证数据正确加载显示
5. 检查后端数据库，确认 productMaterials 字段包含正确数据

## 修复日期
2025-08-10