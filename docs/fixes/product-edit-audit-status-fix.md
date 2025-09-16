# 商品编辑后审核状态重置问题修复

## 问题描述

商品编辑后，审核状态（statusAudit）会被后端强制重置为 "WAIT"（待审核），即使该商品之前已经审核通过（"SUCCESS"）。这违反了业务逻辑：已上架的商品编辑后应该保持审核通过状态。

## 问题分析

### 后端行为（参考代码）
后端 `ProductApiController.java` 的 `/api/shop/product/update` 端点会强制设置所有更新商品的审核状态为 `WAIT`：

```java
@PostMapping("/update")
public AjaxResult updateProduct(@Validated @RequestBody Product product) {
    // ...
    product.setStatusAudit(ProductStatusAuditEnum.WAIT);  // 强制设置为待审核
    productService.updateProductById(product);
    // ...
}
```

### 原前端实现问题
前端原本使用 `/api/shop/product/update` 端点，即使在请求中设置 `statusAudit: 'SUCCESS'`，也会被后端覆盖。

## 解决方案

### 使用 `/api/shop/product/edit` 端点替代

经过分析发现，后端还提供了另一个端点 `/api/shop/product/edit`，该端点不会强制重置审核状态。我们修改前端代码，使用这个端点来更新商品。

### 修改内容

#### 文件：`lib/features/seller/data/datasources/seller_remote_data_source_impl.dart`

1. **修改 `updateProduct` 方法**（第 443 行）：
```dart
// 原代码：
final endpoint = '/api/shop/product/update';

// 修改为：
final endpoint = '/api/shop/product/edit';
```

2. **修改 `_mergeProductData` 方法**（第 1082 行）：
```dart
// 原代码：
'statusAudit': 'SUCCESS',  // 硬编码为 SUCCESS

// 修改为：
'statusAudit': existingData['statusAudit'] ?? 'SUCCESS',  // 保持原有审核状态
```

## 修复效果

- **已审核商品**：编辑后保持 `statusAudit: 'SUCCESS'`，无需重新审核
- **待审核商品**：编辑后保持 `statusAudit: 'WAIT'`
- **其他状态**：保持原有状态不变

## 测试验证

1. **测试已审核商品编辑**：
   - 选择一个已上架的商品（审核通过）
   - 编辑商品信息并保存
   - 验证商品仍显示在"已上架"列表中，而不是"审核中"

2. **测试待审核商品编辑**：
   - 选择一个审核中的商品
   - 编辑商品信息并保存
   - 验证商品仍在"审核中"列表

3. **测试新建商品**：
   - 创建新商品
   - 验证新商品进入正确的审核流程

## 注意事项

1. 此修复依赖于后端 `/api/shop/product/edit` 端点的行为
2. 如果后端修改了该端点的逻辑，可能需要重新评估此方案
3. 建议后端最终修复 `/update` 端点的逻辑，使其能够智能处理审核状态

## 相关文件

- `lib/features/seller/data/datasources/seller_remote_data_source_impl.dart`
- `lib/features/seller/presentation/bloc/product_edit/product_edit_bloc.dart`
- `lib/features/seller/presentation/pages/product_edit_page.dart`

## 修复时间

- 2025-09-17