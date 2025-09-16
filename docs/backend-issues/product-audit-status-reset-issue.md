# 商品编辑后审核状态被重置问题

## 问题描述

当前后端 `/api/shop/product/update` 接口存在一个逻辑问题：更新商品时会强制将审核状态（statusAudit）重置为 "WAIT"（待审核），即使该商品之前已经审核通过。

## 影响

- 已上架的商品（审核通过）编辑后变成"待审核"状态
- 商家需要重新等待审核，影响正常运营
- 违反业务逻辑：已审核通过的商品进行常规编辑不应该重新审核

## 问题代码位置

文件：`duoshaokk_api/xunman-shop/src/main/java/vip/xunman/shop/product/controller/ProductApiController.java`

当前代码（第125-144行）：
```java
@PostMapping("/update")
public AjaxResult updateProduct(@Validated @RequestBody Product product) {
    if (!(Objects.equals(product.getTenantId(), SecurityUtils.getId()))){
        throw new RuntimeException("你只能修改自己的商品!!!");
    }

    product.setStatusAudit(ProductStatusAuditEnum.WAIT);  // ← 问题在这里
    productService.updateProductById(product);
    return AjaxResult.success("更新成功");
}
```

## 建议的修复方案

### 方案1：智能判断审核状态（推荐）

```java
@PostMapping("/update")
public AjaxResult updateProduct(@Validated @RequestBody Product product) {
    if (!(Objects.equals(product.getTenantId(), SecurityUtils.getId()))){
        throw new RuntimeException("你只能修改自己的商品!!!");
    }

    // 获取当前商品的审核状态
    Product existingProduct = productService.getProductById(product.getId());

    // 如果商品已经审核通过，保持审核通过状态
    if (existingProduct != null &&
        ProductStatusAuditEnum.SUCCESS.equals(existingProduct.getStatusAudit())) {
        product.setStatusAudit(ProductStatusAuditEnum.SUCCESS);
    } else {
        // 只有未审核通过的商品才设置为待审核
        product.setStatusAudit(ProductStatusAuditEnum.WAIT);
    }

    productService.updateProductById(product);
    return AjaxResult.success("更新成功");
}
```

### 方案2：根据修改内容决定是否需要重新审核

```java
@PostMapping("/update")
public AjaxResult updateProduct(@Validated @RequestBody Product product) {
    if (!(Objects.equals(product.getTenantId(), SecurityUtils.getId()))){
        throw new RuntimeException("你只能修改自己的商品!!!");
    }

    Product existingProduct = productService.getProductById(product.getId());

    // 判断是否修改了需要重新审核的关键字段
    boolean needReAudit = isNeedReAudit(existingProduct, product);

    if (needReAudit) {
        product.setStatusAudit(ProductStatusAuditEnum.WAIT);
    } else {
        // 保持原有审核状态
        product.setStatusAudit(existingProduct.getStatusAudit());
    }

    productService.updateProductById(product);
    return AjaxResult.success("更新成功");
}

// 判断是否需要重新审核
private boolean isNeedReAudit(Product oldProduct, Product newProduct) {
    // 例如：只有修改了商品名称、描述、图片等关键信息才需要重新审核
    // 修改价格、库存等不需要重新审核
    return !Objects.equals(oldProduct.getName(), newProduct.getName()) ||
           !Objects.equals(oldProduct.getDescription(), newProduct.getDescription()) ||
           !Objects.equals(oldProduct.getImages(), newProduct.getImages());
}
```

## 临时解决方案

在后端修复之前，前端有以下临时方案：

1. **使用 `/api/shop/product/edit` 端点**（已测试）
   - 优点：不会重置审核状态
   - 缺点：没有权限验证，存在安全风险

2. **前端缓存审核状态**
   - 在更新后立即查询商品状态
   - 如果发现被重置，再调用状态更新接口恢复

## 测试场景

修复后需要测试以下场景：

1. **已审核商品编辑**
   - 编辑已审核通过的商品
   - 验证：保持审核通过状态

2. **待审核商品编辑**
   - 编辑待审核的商品
   - 验证：保持待审核状态

3. **审核失败商品编辑**
   - 编辑审核失败的商品
   - 验证：设置为待审核状态

4. **关键信息修改**（如果采用方案2）
   - 修改商品名称/描述/图片
   - 验证：触发重新审核

5. **非关键信息修改**（如果采用方案2）
   - 修改价格/库存
   - 验证：保持原审核状态

## 相关端点对比

| 端点 | 权限验证 | 审核状态处理 | 数据验证 | 适用场景 |
|-----|---------|-------------|---------|---------|
| `/update` | ✅ | 强制重置（需修复） | ✅ | 完整商品更新 |
| `/edit` | ❌ | 不处理 | ❌ | 简单字段更新 |

## 优先级

**高** - 此问题直接影响商家正常运营，建议尽快修复。

## 联系前端

修复后请通知前端团队，以便：
1. 移除临时解决方案代码
2. 更新相关文档
3. 进行集成测试