-- 添加待付款状态的测试订单
-- 用于验证订单详情页面显示问题是否与mock数据相关

-- 注意：使用前请确保已有测试用户数据
-- 买家ID: 10319 (纸蓝测试 - 已验证存在)
-- 卖家ID: 10320 (已验证存在的用户)

-- 插入新的待付款测试订单
INSERT INTO `xunshop_order` (
    `buyer_id`, `tenant_id`, `order_sn`, `total_price`, `pay_price`, 
    `coupon_price`, `freight_price`, `receiver_name`, `receiver_mobile`, 
    `receiver_address`, `receiver_info`, `remark`, `state`, `activity_type`,
    `create_time`, `update_time`, `is_del`, `is_show`, `seller_show_flag`
) VALUES
-- 新的待付款测试订单
(10319, 10320, 'TEST_AWAITING_PAY_001', 599.00, 599.00, 0.00, 19.00, 
 '测试用户', '13912345678', '江苏省南京市玄武区中山路100号', 
 '{"province":"江苏省","city":"南京市","district":"玄武区","detail":"中山路100号"}',
 '这是一个新的待付款测试订单，用于验证页面显示', 'awaitingPayment', 'product',
 NOW(), NOW(), 0, 1, 1);

-- 获取刚插入的订单ID
SET @order_id = LAST_INSERT_ID();

-- 插入订单商品明细
INSERT INTO `xunshop_order_item` (
    `buyer_id`, `tenant_id`, `order_id`, `product_id`, `variant_id`,
    `variant_name`, `product_name`, `product_image`, `product_info`,
    `quantity`, `unit_price`, `total_price`, `pay_price`, `freight_price`,
    `is_refund`, `delivery_day`, `edit_num`, `create_time`, `update_time`
) VALUES
(10319, 10320, @order_id, 2001, 3001,
 '旗舰版', '测试产品 - Logo设计服务', 
 'https://images.unsplash.com/photo-1611224923853-80b023f02d71?w=400&h=300',
 JSON_OBJECT(
    'category', '设计服务',
    'brand', '专业设计',
    'description', '专业的Logo设计服务，包含3次修改机会',
    'features', JSON_ARRAY('原创设计', '3次修改', '矢量格式', '商用授权')
 ),
 1,
 580.00,
 580.00,
 580.00,
 19.00,
 0,
 7,
 3,
 NOW(),
 NOW());

-- 为订单添加自动处理时间（30分钟后自动取消）
UPDATE `xunshop_order` 
SET feature = JSON_OBJECT(
    'autoCancelTime', UNIX_TIMESTAMP(DATE_ADD(create_time, INTERVAL 30 MINUTE)) * 1000,
    'orderReminder', '请在30分钟内完成支付，否则订单将自动取消'
)
WHERE id = @order_id;

-- 查询验证新创建的订单
SELECT 
    o.id,
    o.order_sn,
    o.state,
    o.pay_price,
    o.receiver_name,
    o.create_time,
    oi.product_name,
    oi.variant_name,
    oi.quantity,
    oi.unit_price
FROM xunshop_order o
LEFT JOIN xunshop_order_item oi ON o.id = oi.order_id
WHERE o.order_sn = 'TEST_AWAITING_PAY_001';