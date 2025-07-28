# 订单测试数据说明

## 概述
本目录包含用于测试订单功能的SQL脚本，可以创建各种状态的测试订单数据。

## 测试数据详情

### 订单状态覆盖
脚本创建了10个不同状态的测试订单：

1. **TEST20250127001** - `awaitingPayment` (待付款)
2. **TEST20250127002** - `awaitingSubmission` (等待提交要求)
3. **TEST20250127003** - `awaitingStart` (等待开始)
4. **TEST20250127004** - `awaitingDelivery` (等待卖家交付)
5. **TEST20250127005** - `awaitingConfirmation` (交付待确认)
6. **TEST20250127006** - `awaitingEvaluation` (等待评价)
7. **TEST20250127007** - `orderCompleted` (订单成功结束)
8. **TEST20250127008** - `canceled` (已取消)
9. **TEST20250127009** - `afterSale` (售后中)
10. **TEST20250127010** - `applyingForMediation` (平台介入)

### 测试数据特点
- 所有订单使用 `TEST` 前缀，便于识别和清理
- 买家ID固定为 `10319`（纸蓝测试 - 已验证存在）
- 卖家ID固定为 `10320`（已验证存在的用户）
- 包含完整的收货地址信息
- 模拟了不同的价格、优惠和运费组合
- 自动生成订单商品明细

## 使用方法

### 方式一：直接在数据库执行
```bash
mysql -u username -p database_name < order_test_data.sql
```

### 方式二：使用MCP MySQL工具
通过Claude的MCP MySQL工具执行SQL语句：
```sql
-- 执行整个脚本或分段执行
```

### 方式三：通过数据库管理工具
1. 打开phpMyAdmin、Navicat等工具
2. 选择目标数据库
3. 执行SQL脚本

## 注意事项

1. **用户数据依赖**
   - 确保数据库中存在买家ID `10319`（已验证）
   - 确保数据库中存在卖家ID `10320`（已验证）

2. **清理旧数据**
   - 脚本开头包含清理语句（已注释）
   - 执行前可根据需要取消注释

3. **数据库表结构**
   - `xunshop_order` - 订单主表
   - `xunshop_order_item` - 订单商品表

4. **时间处理**
   - 使用MySQL的日期函数自动生成时间
   - 订单创建时间分散在过去10天内

## 验证数据
执行后可运行以下查询验证：
```sql
SELECT 
    o.id,
    o.order_sn,
    o.state,
    o.pay_price,
    o.create_time,
    oi.product_name
FROM xunshop_order o
LEFT JOIN xunshop_order_item oi ON o.id = oi.order_id
WHERE o.order_sn LIKE 'TEST%'
ORDER BY o.state;
```

## 在Flutter中使用
1. 确保 `AppConfig.useMockData` 设置为 `false`
2. 登录用户ID应为 `10319`
3. 访问订单列表即可看到测试订单
4. 各个状态的订单都可以正常显示和操作

## 清理测试数据
```sql
-- 清理所有测试订单
DELETE FROM xunshop_order_item WHERE order_id IN (
    SELECT id FROM xunshop_order WHERE order_sn LIKE 'TEST%'
);
DELETE FROM xunshop_order WHERE order_sn LIKE 'TEST%';
```