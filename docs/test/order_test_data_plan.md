# 订单测试数据模拟计划

## 一、背景和目标

为了方便前端开发和测试，需要创建各种状态的订单模拟数据，以便：
1. 测试订单详情页在不同状态下的展示效果
2. 验证状态转换逻辑的正确性
3. 无需依赖后端即可进行完整的功能测试

## 二、订单数据结构分析

### 核心字段
- **基础信息**: id, orderSn, buyerId, tenantId
- **金额信息**: totalPrice, payPrice, couponPrice, freightPrice
- **时间信息**: createTime, payTime, shipTime, completeTime, cancelTime
- **状态信息**: state (OrderStatusEnum)
- **商品信息**: items (OrderItem列表)
- **材料信息**: orderMaterials (买家提交的材料)
- **交付信息**: orderDeliveries (卖家交付的内容)

## 三、测试数据设计方案

### 1. 待付款订单 (awaitingPayment)
```dart
{
  "id": 1001,
  "orderSn": "ORD20240120001",
  "state": "awaitingPayment",
  "totalPrice": 299.00,
  "payPrice": 299.00,
  "createdAt": "2024-01-20 10:00:00",
  "autoCancelTime": "2024-01-20 10:30:00", // 30分钟后自动取消
  "items": [{
    "productName": "Logo设计服务",
    "productImage": "assets/images/test/logo_design.jpg",
    "unitPrice": 299.00,
    "quantity": 1
  }]
}
```

### 2. 等待提交材料 (awaitingSubmission)
```dart
{
  "id": 1002,
  "orderSn": "ORD20240120002",
  "state": "awaitingSubmission",
  "payTime": "2024-01-20 10:05:00",
  "autoMaterialTime": "2024-01-21 10:05:00", // 24小时内需提交
  "items": [{
    "productName": "品牌VI设计",
    "productImage": "assets/images/test/vi_design.jpg",
    "unitPrice": 1999.00,
    "quantity": 1,
    "productMaterials": [
      {"name": "品牌名称", "type": "text", "required": true},
      {"name": "品牌理念", "type": "text", "required": true},
      {"name": "参考案例", "type": "attachment", "required": false}
    ]
  }]
}
```

### 3. 等待卖家接单 (awaitingStart)
```dart
{
  "id": 1003,
  "orderSn": "ORD20240120003",
  "state": "awaitingStart",
  "submitMaterialsTime": "2024-01-20 11:00:00",
  "autoOrderReceivinTime": "2024-01-21 11:00:00",
  "orderMaterials": [
    {"name": "品牌名称", "value": "多少看看", "type": "text"},
    {"name": "品牌理念", "value": "让每个人都能享受优质服务", "type": "text"}
  ]
}
```

### 4. 制作中/等待交付 (awaitingDelivery)
```dart
{
  "id": 1004,
  "orderSn": "ORD20240120004", 
  "state": "awaitingDelivery",
  "deliveryTime": "2024-01-25 18:00:00", // 预计交付时间
  "overdueFlag": false,
  "items": [{
    "productName": "海报设计",
    "deliveryDay": 5 // 5天交付
  }]
}
```

### 5. 等待确认收货 (awaitingConfirmation)
```dart
{
  "id": 1005,
  "orderSn": "ORD20240120005",
  "state": "awaitingConfirmation",
  "autoCompleteTime": "2024-01-27 15:00:00", // 7天后自动确认
  "orderDeliveries": [{
    "content": "设计稿已完成，请查收",
    "files": ["design_v1.psd", "design_v1.jpg"],
    "deliveryTime": "2024-01-20 15:00:00"
  }]
}
```

### 6. 待评价 (awaitingEvaluation)
```dart
{
  "id": 1006,
  "orderSn": "ORD20240120006",
  "state": "awaitingEvaluation",
  "completeTime": "2024-01-20 16:00:00"
}
```

### 7. 已完成 (orderCompleted)
```dart
{
  "id": 1007,
  "orderSn": "ORD20240120007",
  "state": "orderCompleted",
  "completeTime": "2024-01-19 10:00:00",
  "evaluate": true
}
```

### 8. 已取消 (canceled)
```dart
{
  "id": 1008,
  "orderSn": "ORD20240120008",
  "state": "canceled",
  "cancelTime": "2024-01-20 10:35:00",
  "cancelReason": "买家取消"
}
```

### 9. 平台介入 (applyingForMediation)
```dart
{
  "id": 1009,
  "orderSn": "ORD20240120009",
  "state": "applyingForMediation",
  "buyerPlatformFlag": true,
  "platformReason": "卖家交付质量不满意"
}
```

### 10. 售后中 (afterSale)
```dart
{
  "id": 1010,
  "orderSn": "ORD20240120010",
  "state": "afterSale",
  "buyerRefundFlag": true,
  "refundReason": "服务不符合描述"
}
```

## 四、实现方案

### 1. 创建模拟数据仓库
```dart
// lib/features/orders/data/datasources/mock_order_data_source.dart
class MockOrderDataSource {
  static final List<Order> mockOrders = [
    // 所有状态的测试订单
  ];
  
  static Order getOrderByStatus(OrderStatus status) {
    return mockOrders.firstWhere((order) => order.state == status);
  }
}
```

### 2. 创建测试页面
```dart
// lib/features/orders/presentation/pages/order_test_page.dart
class OrderTestPage extends StatelessWidget {
  // 展示所有状态的订单列表
  // 支持切换状态查看详情
  // 支持模拟状态转换
}
```

### 3. 状态转换模拟器
```dart
// lib/features/orders/presentation/widgets/order_state_simulator.dart
class OrderStateSimulator extends StatefulWidget {
  // 模拟订单状态转换
  // 显示状态流转路径
  // 支持时间快进功能
}
```

## 五、测试场景设计

### 场景1: 正常购买流程
1. 创建订单 → awaitingPayment
2. 支付成功 → awaitingSubmission  
3. 提交材料 → awaitingStart
4. 卖家接单 → awaitingDelivery
5. 卖家发货 → awaitingConfirmation
6. 确认收货 → awaitingEvaluation
7. 完成评价 → orderCompleted

### 场景2: 取消流程
1. 待付款状态 → 买家取消 → canceled
2. 待付款状态 → 超时自动取消 → canceled

### 场景3: 争议流程
1. 制作中状态 → 申请平台介入 → applyingForMediation
2. 已完成状态 → 申请售后 → afterSale

### 场景4: 补充材料流程
1. 等待开始 → 卖家要求补充 → buyAwaitingSubmission
2. 买家补充材料 → awaitingStart

## 六、开发计划

1. **第一阶段**: 创建基础模拟数据结构
   - 定义完整的测试数据模型
   - 实现数据生成工具类

2. **第二阶段**: 实现测试页面
   - 订单列表展示页
   - 状态切换功能
   - 详情页测试入口

3. **第三阶段**: 增强功能
   - 状态转换动画演示
   - 时间模拟器（快进功能）
   - 导出测试报告

## 七、使用说明

1. **开发阶段**: 使用模拟数据源替代真实API
2. **测试阶段**: 通过测试页面验证各状态展示
3. **演示阶段**: 使用状态模拟器展示完整流程

## 八、注意事项

1. 模拟数据应覆盖所有边界情况
2. 时间相关字段需要合理设置
3. 图片资源使用本地占位图
4. 保持与后端数据结构一致性