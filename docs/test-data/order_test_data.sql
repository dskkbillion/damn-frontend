-- 测试订单数据脚本
-- 用于在数据库中创建各种状态的测试订单

-- 注意：使用前请确保已有测试用户数据
-- 买家ID: 10319 (纸蓝测试 - 已验证存在)
-- 卖家ID: 10320 (已验证存在的用户)

-- 清理已有的测试数据（可选）
-- DELETE FROM xunshop_order_item WHERE order_id IN (SELECT id FROM xunshop_order WHERE order_sn LIKE 'TEST%');
-- DELETE FROM xunshop_order WHERE order_sn LIKE 'TEST%';

-- 插入测试订单主表数据
INSERT INTO `xunshop_order` (
    `buyer_id`, `tenant_id`, `order_sn`, `total_price`, `pay_price`, 
    `coupon_price`, `freight_price`, `receiver_name`, `receiver_mobile`, 
    `receiver_address`, `receiver_info`, `remark`, `state`, `activity_type`,
    `create_time`, `update_time`, `is_del`, `is_show`, `seller_show_flag`
) VALUES
-- 1. 待付款订单
(10319, 10320, 'TEST20250127001', 299.00, 299.00, 0.00, 0.00, 
 '张三', '13800138001', '上海市浦东新区张江高科技园区', 
 '{"province":"上海市","city":"上海市","district":"浦东新区","detail":"张江高科技园区"}',
 '测试订单-待付款', 'awaitingPayment', 'product',
 NOW(), NOW(), 0, 1, 1),

-- 2. 等待提交要求订单
(10319, 10320, 'TEST20250127002', 199.00, 199.00, 0.00, 0.00,
 '李四', '13800138002', '北京市朝阳区建国门外大街', 
 '{"province":"北京市","city":"北京市","district":"朝阳区","detail":"建国门外大街"}',
 '测试订单-等待提交要求', 'awaitingSubmission', 'product',
 DATE_SUB(NOW(), INTERVAL 1 DAY), NOW(), 0, 1, 1),

-- 3. 等待开始订单（已付款已提交材料）
(10319, 10320, 'TEST20250127003', 399.00, 399.00, 0.00, 10.00,
 '王五', '13800138003', '广州市天河区珠江新城', 
 '{"province":"广东省","city":"广州市","district":"天河区","detail":"珠江新城"}',
 '测试订单-等待开始', 'awaitingStart', 'product',
 DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), 0, 1, 1),

-- 4. 等待卖家交付订单
(10319, 10320, 'TEST20250127004', 599.00, 579.00, 20.00, 0.00,
 '赵六', '13800138004', '深圳市南山区科技园', 
 '{"province":"广东省","city":"深圳市","district":"南山区","detail":"科技园"}',
 '测试订单-等待卖家交付', 'awaitingDelivery', 'product',
 DATE_SUB(NOW(), INTERVAL 3 DAY), NOW(), 0, 1, 1),

-- 5. 交付待确认订单
(10319, 10320, 'TEST20250127005', 799.00, 759.00, 40.00, 0.00,
 '孙七', '13800138005', '杭州市西湖区文三路', 
 '{"province":"浙江省","city":"杭州市","district":"西湖区","detail":"文三路"}',
 '测试订单-交付待确认', 'awaitingConfirmation', 'product',
 DATE_SUB(NOW(), INTERVAL 4 DAY), NOW(), 0, 1, 1),

-- 6. 等待评价订单
(10319, 10320, 'TEST20250127006', 999.00, 949.00, 50.00, 0.00,
 '周八', '13800138006', '成都市高新区天府大道', 
 '{"province":"四川省","city":"成都市","district":"高新区","detail":"天府大道"}',
 '测试订单-等待评价', 'awaitingEvaluation', 'product',
 DATE_SUB(NOW(), INTERVAL 5 DAY), NOW(), 0, 1, 1),

-- 7. 订单成功结束
(10319, 10320, 'TEST20250127007', 1299.00, 1199.00, 100.00, 0.00,
 '吴九', '13800138007', '武汉市洪山区光谷广场', 
 '{"province":"湖北省","city":"武汉市","district":"洪山区","detail":"光谷广场"}',
 '测试订单-订单成功结束', 'orderCompleted', 'product',
 DATE_SUB(NOW(), INTERVAL 10 DAY), NOW(), 0, 1, 1),

-- 8. 已取消订单
(10319, 10320, 'TEST20250127008', 99.00, 99.00, 0.00, 0.00,
 '郑十', '13800138008', '南京市鼓楼区新街口', 
 '{"province":"江苏省","city":"南京市","district":"鼓楼区","detail":"新街口"}',
 '测试订单-已取消', 'canceled', 'product',
 DATE_SUB(NOW(), INTERVAL 7 DAY), NOW(), 0, 1, 1),

-- 9. 售后中订单
(10319, 10320, 'TEST20250127009', 499.00, 449.00, 50.00, 0.00,
 '钱十一', '13800138009', '西安市雁塔区高新技术产业开发区', 
 '{"province":"陕西省","city":"西安市","district":"雁塔区","detail":"高新技术产业开发区"}',
 '测试订单-售后中', 'afterSale', 'product',
 DATE_SUB(NOW(), INTERVAL 6 DAY), NOW(), 0, 1, 1),

-- 10. 平台介入订单
(10319, 10320, 'TEST20250127010', 899.00, 849.00, 50.00, 0.00,
 '冯十二', '13800138010', '重庆市渝中区解放碑', 
 '{"province":"重庆市","city":"重庆市","district":"渝中区","detail":"解放碑"}',
 '测试订单-平台介入', 'applyingForMediation', 'product',
 DATE_SUB(NOW(), INTERVAL 8 DAY), NOW(), 0, 1, 1);

-- 更新已付款订单的支付信息
UPDATE `xunshop_order` 
SET `pay_type` = 'weapp', 
    `pay_trade_no` = CONCAT('PAY', order_sn),
    `pay_time` = DATE_ADD(create_time, INTERVAL 30 MINUTE)
WHERE order_sn IN (
    'TEST20250127002', 'TEST20250127003', 'TEST20250127004', 
    'TEST20250127005', 'TEST20250127006', 'TEST20250127007', 
    'TEST20250127009', 'TEST20250127010'
);

-- 更新已完成订单的完成时间
UPDATE `xunshop_order` 
SET `complete_time` = DATE_ADD(create_time, INTERVAL 7 DAY)
WHERE order_sn = 'TEST20250127007';

-- 更新已取消订单的取消时间
UPDATE `xunshop_order` 
SET `cancel_time` = DATE_ADD(create_time, INTERVAL 2 HOUR)
WHERE order_sn = 'TEST20250127008';

-- 插入订单商品明细（每个订单一个商品）
INSERT INTO `xunshop_order_item` (
    `buyer_id`, `tenant_id`, `order_id`, `product_id`, `variant_id`,
    `variant_name`, `product_name`, `product_image`, `product_info`,
    `quantity`, `unit_price`, `total_price`, `pay_price`, `freight_price`,
    `is_refund`, `delivery_day`, `edit_num`, `create_time`, `update_time`
)
SELECT 
    o.buyer_id,
    o.tenant_id,
    o.id,
    1001 + (o.id % 10), -- 模拟不同的商品ID
    2001 + (o.id % 10), -- 模拟不同的规格ID
    CASE (o.id % 3)
        WHEN 0 THEN '标准版'
        WHEN 1 THEN '专业版'
        ELSE '企业版'
    END,
    CONCAT('测试商品', (o.id % 10 + 1)),
    'https://img.duoshaokankan.com/test/product.jpg',
    JSON_OBJECT(
        'category', '测试分类',
        'brand', '测试品牌',
        'description', '这是一个测试商品'
    ),
    1,
    o.pay_price,
    o.pay_price,
    o.pay_price,
    o.freight_price,
    0,
    7,
    3,
    o.create_time,
    o.update_time
FROM `xunshop_order` o
WHERE o.order_sn LIKE 'TEST%';

-- 为部分订单添加自动处理时间（用于前端倒计时显示）
UPDATE `xunshop_order` o
SET o.feature = JSON_OBJECT(
    'autoCancelTime', UNIX_TIMESTAMP(DATE_ADD(o.create_time, INTERVAL 30 MINUTE)) * 1000,
    'autoMaterialTime', UNIX_TIMESTAMP(DATE_ADD(o.pay_time, INTERVAL 24 HOUR)) * 1000,
    'autoCompleteTime', UNIX_TIMESTAMP(DATE_ADD(o.create_time, INTERVAL 7 DAY)) * 1000
)
WHERE o.order_sn LIKE 'TEST%' AND o.state IN ('awaitingPayment', 'awaitingSubmission', 'awaitingConfirmation');

-- 提交事务
-- COMMIT;

-- 查询验证
SELECT 
    o.id,
    o.order_sn,
    o.state,
    o.pay_price,
    o.create_time,
    o.pay_time,
    oi.product_name,
    oi.quantity
FROM xunshop_order o
LEFT JOIN xunshop_order_item oi ON o.id = oi.order_id
WHERE o.order_sn LIKE 'TEST%'
ORDER BY o.id;