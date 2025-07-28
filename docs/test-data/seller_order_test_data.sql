-- 卖家视角测试订单数据
-- 10319 作为卖家接收订单

-- 清理已有的卖家测试数据（可选）
-- DELETE FROM xunshop_order_item WHERE order_id IN (SELECT id FROM xunshop_order WHERE order_sn LIKE 'SELLER_TEST%');
-- DELETE FROM xunshop_order WHERE order_sn LIKE 'SELLER_TEST%';

-- 插入卖家视角的测试订单
INSERT INTO `xunshop_order` (
    `buyer_id`, `tenant_id`, `order_sn`, `total_price`, `pay_price`, 
    `coupon_price`, `freight_price`, `receiver_name`, `receiver_mobile`, 
    `receiver_address`, `receiver_info`, `remark`, `state`, `activity_type`,
    `create_time`, `update_time`, `is_del`, `is_show`, `seller_show_flag`
) VALUES
-- 1. 待付款 - Logo设计服务
(10320, 10319, 'SELLER_TEST001', 899.00, 899.00, 0.00, 0.00, 
 '王经理', '13866725004', '北京市朝阳区CBD国贸中心', 
 '{"province":"北京市","city":"北京市","district":"朝阳区","detail":"CBD国贸中心"}',
 '急需公司Logo设计，要求简洁大气', 'awaitingPayment', 'product',
 NOW(), NOW(), 0, 1, 1),

-- 2. 等待提交要求 - 小程序开发
(10318, 10319, 'SELLER_TEST002', 4999.00, 4799.00, 200.00, 0.00,
 '李总', '13275699985', '上海市浦东新区陆家嘴金融中心', 
 '{"province":"上海市","city":"上海市","district":"浦东新区","detail":"陆家嘴金融中心"}',
 '电商小程序开发，需要商城功能', 'awaitingSubmission', 'product',
 DATE_SUB(NOW(), INTERVAL 2 HOUR), NOW(), 0, 1, 1),

-- 3. 等待开始 - UI设计服务
(10317, 10319, 'SELLER_TEST003', 2999.00, 2899.00, 100.00, 0.00,
 '张总监', '18888888881', '深圳市南山区科技园南区', 
 '{"province":"广东省","city":"深圳市","district":"南山区","detail":"科技园南区"}',
 'APP界面设计，20个页面', 'awaitingStart', 'product',
 DATE_SUB(NOW(), INTERVAL 1 DAY), NOW(), 0, 1, 1),

-- 4. 等待卖家交付 - 网站开发
(10316, 10319, 'SELLER_TEST004', 6999.00, 6499.00, 500.00, 0.00,
 '陈女士', '13305672893', '杭州市西湖区阿里巴巴园区', 
 '{"province":"浙江省","city":"杭州市","district":"西湖区","detail":"阿里巴巴园区"}',
 '企业官网开发，响应式设计', 'awaitingDelivery', 'product',
 DATE_SUB(NOW(), INTERVAL 3 DAY), NOW(), 0, 1, 1),

-- 5. 交付待确认 - 海报设计
(10314, 10319, 'SELLER_TEST005', 599.00, 599.00, 0.00, 0.00,
 '刘经理', '17723217781', '成都市高新区天府软件园', 
 '{"province":"四川省","city":"成都市","district":"高新区","detail":"天府软件园"}',
 '活动海报设计，5张', 'awaitingConfirmation', 'product',
 DATE_SUB(NOW(), INTERVAL 4 DAY), NOW(), 0, 1, 1),

-- 6. 等待评价 - 营销策划
(10313, 10319, 'SELLER_TEST006', 3999.00, 3999.00, 0.00, 0.00,
 '赵总', '17723277781', '广州市天河区珠江新城', 
 '{"province":"广东省","city":"广州市","district":"天河区","detail":"珠江新城"}',
 '年度营销方案策划', 'awaitingEvaluation', 'product',
 DATE_SUB(NOW(), INTERVAL 7 DAY), NOW(), 0, 1, 1),

-- 7. 订单完成 - PPT模板
(10312, 10319, 'SELLER_TEST007', 199.00, 199.00, 0.00, 0.00,
 '周先生', '17302321473', '武汉市洪山区光谷软件园', 
 '{"province":"湖北省","city":"武汉市","district":"洪山区","detail":"光谷软件园"}',
 '商务PPT模板购买', 'orderCompleted', 'product',
 DATE_SUB(NOW(), INTERVAL 10 DAY), NOW(), 0, 1, 1),

-- 8. 已取消 - 技术咨询
(10311, 10319, 'SELLER_TEST008', 1999.00, 1999.00, 0.00, 0.00,
 '吴工', '13387185433', '西安市雁塔区高新技术开发区', 
 '{"province":"陕西省","city":"西安市","district":"雁塔区","detail":"高新技术开发区"}',
 '区块链技术咨询服务', 'canceled', 'product',
 DATE_SUB(NOW(), INTERVAL 5 DAY), NOW(), 0, 1, 1);

-- 更新支付信息
UPDATE `xunshop_order` 
SET `pay_type` = 'weapp', 
    `pay_trade_no` = CONCAT('SELLER_PAY_', order_sn),
    `pay_time` = DATE_ADD(create_time, INTERVAL 15 MINUTE)
WHERE order_sn IN (
    'SELLER_TEST002', 'SELLER_TEST003', 'SELLER_TEST004', 
    'SELLER_TEST005', 'SELLER_TEST006', 'SELLER_TEST007'
);

-- 更新完成和取消时间
UPDATE `xunshop_order` SET `complete_time` = DATE_ADD(create_time, INTERVAL 5 DAY) WHERE order_sn = 'SELLER_TEST007';
UPDATE `xunshop_order` SET `cancel_time` = DATE_ADD(create_time, INTERVAL 1 HOUR) WHERE order_sn = 'SELLER_TEST008';

-- 插入订单商品（使用真实的网络图片）
INSERT INTO `xunshop_order_item` (
    `buyer_id`, `tenant_id`, `order_id`, `product_id`, `variant_id`,
    `variant_name`, `product_name`, `product_image`, `product_info`,
    `quantity`, `unit_price`, `total_price`, `pay_price`, `freight_price`,
    `is_refund`, `delivery_day`, `edit_num`, `create_time`, `update_time`
) VALUES
-- Logo设计
((SELECT buyer_id FROM xunshop_order WHERE order_sn = 'SELLER_TEST001'),
 10319,
 (SELECT id FROM xunshop_order WHERE order_sn = 'SELLER_TEST001'),
 2001, 3001, '标准套餐', 'Logo设计服务 - 3个方案',
 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=400&h=400&fit=crop',
 '{"category":"设计服务","type":"Logo设计","deliverables":"3个设计方案+源文件"}',
 1, 899.00, 899.00, 899.00, 0.00, 0, 7, 3, NOW(), NOW()),

-- 小程序开发
((SELECT buyer_id FROM xunshop_order WHERE order_sn = 'SELLER_TEST002'),
 10319,
 (SELECT id FROM xunshop_order WHERE order_sn = 'SELLER_TEST002'),
 2002, 3002, '商城版', '电商小程序开发 - 全功能版',
 'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=400&h=400&fit=crop',
 '{"category":"开发服务","type":"小程序开发","features":"商城+支付+会员系统"}',
 1, 4999.00, 4999.00, 4799.00, 0.00, 0, 30, 5, NOW(), NOW()),

-- UI设计
((SELECT buyer_id FROM xunshop_order WHERE order_sn = 'SELLER_TEST003'),
 10319,
 (SELECT id FROM xunshop_order WHERE order_sn = 'SELLER_TEST003'),
 2003, 3003, '20页套餐', 'APP界面UI设计',
 'https://images.unsplash.com/photo-1609921212029-bb5a28e60960?w=400&h=400&fit=crop',
 '{"category":"设计服务","type":"UI设计","pages":"20个核心页面"}',
 1, 2999.00, 2999.00, 2899.00, 0.00, 0, 15, 3, NOW(), NOW()),

-- 网站开发
((SELECT buyer_id FROM xunshop_order WHERE order_sn = 'SELLER_TEST004'),
 10319,
 (SELECT id FROM xunshop_order WHERE order_sn = 'SELLER_TEST004'),
 2004, 3004, '企业版', '响应式企业官网开发',
 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&h=400&fit=crop',
 '{"category":"开发服务","type":"网站开发","tech":"Vue+Node.js"}',
 1, 6999.00, 6999.00, 6499.00, 0.00, 0, 20, 3, NOW(), NOW()),

-- 海报设计
((SELECT buyer_id FROM xunshop_order WHERE order_sn = 'SELLER_TEST005'),
 10319,
 (SELECT id FROM xunshop_order WHERE order_sn = 'SELLER_TEST005'),
 2005, 3005, '5张套餐', '活动海报设计套餐',
 'https://images.unsplash.com/photo-1626785774573-4b799315345d?w=400&h=400&fit=crop',
 '{"category":"设计服务","type":"海报设计","quantity":"5张不同主题"}',
 1, 599.00, 599.00, 599.00, 0.00, 0, 5, 2, NOW(), NOW()),

-- 营销策划
((SELECT buyer_id FROM xunshop_order WHERE order_sn = 'SELLER_TEST006'),
 10319,
 (SELECT id FROM xunshop_order WHERE order_sn = 'SELLER_TEST006'),
 2006, 3006, '年度方案', '全年营销策划方案',
 'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=400&h=400&fit=crop',
 '{"category":"咨询服务","type":"营销策划","duration":"12个月"}',
 1, 3999.00, 3999.00, 3999.00, 0.00, 0, 10, 1, NOW(), NOW()),

-- PPT模板
((SELECT buyer_id FROM xunshop_order WHERE order_sn = 'SELLER_TEST007'),
 10319,
 (SELECT id FROM xunshop_order WHERE order_sn = 'SELLER_TEST007'),
 2007, 3007, '商务版', '高端商务PPT模板',
 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=400&fit=crop',
 '{"category":"数字产品","type":"PPT模板","pages":"50+页"}',
 1, 199.00, 199.00, 199.00, 0.00, 0, 0, 0, NOW(), NOW()),

-- 技术咨询
((SELECT buyer_id FROM xunshop_order WHERE order_sn = 'SELLER_TEST008'),
 10319,
 (SELECT id FROM xunshop_order WHERE order_sn = 'SELLER_TEST008'),
 2008, 3008, '基础咨询', '区块链技术咨询服务',
 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=400&h=400&fit=crop',
 '{"category":"咨询服务","type":"技术咨询","topic":"区块链应用"}',
 1, 1999.00, 1999.00, 1999.00, 0.00, 0, 3, 1, NOW(), NOW());