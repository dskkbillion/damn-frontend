// 订单页面脚本
console.log('orders.js 已加载');

// 模拟订单数据
const mockOrders = [
    {
        orderId: '1001',
        sellerName: '设计师小明',
        sellerId: 'ID12345',
        orderStatus: '待付款',
        statusCode: 'awaitingPayment',
        orderImage: '../../../imgs/IMG20250308191357_20250326010856.jpg',
        orderTitle: 'Logo设计 - 标准版',
        orderDescription: '提供3种方案，无限修改，包含源文件',
        orderPrice: '299',
        orderTime: '2024-03-25 14:30',
        actions: [
            { text: '取消订单', type: 'secondary', action: 'cancelOrder' },
            { text: '去付款', type: 'primary', action: 'payOrder' }
        ]
    },
    {
        orderId: '1002',
        sellerName: '插画师小红',
        sellerId: 'ID67890',
        orderStatus: '等待提交要求',
        statusCode: 'awaitingSubmission',
        orderImage: '../../../imgs/IMG20250308211749_20250326010856.jpg',
        orderTitle: '人物插画定制',
        orderDescription: '根据您的需求定制人物插画，包含一次修改机会',
        orderPrice: '199',
        orderTime: '2024-03-24 10:15',
        actions: [
            { text: '提交要求', type: 'primary', action: 'submitRequirements' }
        ]
    },
    {
        orderId: '1003',
        sellerName: '文案大师',
        sellerId: 'ID24680',
        orderStatus: '等待卖家接单',
        statusCode: 'awaitingStart',
        orderImage: '../../../imgs/IMG20250309142054_20250326010856.jpg',
        orderTitle: '产品文案撰写',
        orderDescription: '为您的产品撰写吸引人的文案，包含关键词优化',
        orderPrice: '149',
        orderTime: '2024-03-23 16:45',
        actions: [
            { text: '联系卖家', type: 'secondary', action: 'contactSeller' },
            { text: '申请售后', type: 'secondary', action: 'applyAfterSale' }
        ]
    },
    {
        orderId: '1004',
        sellerName: '网页设计师',
        sellerId: 'ID13579',
        orderStatus: '等待卖家交付',
        statusCode: 'awaitingDelivery',
        orderImage: '../../../imgs/IMG20250310160953_20250326010856.jpg',
        orderTitle: '网站首页设计',
        orderDescription: '响应式网站首页设计，包含移动端适配',
        orderPrice: '499',
        orderTime: '2024-03-22 09:30',
        actions: [
            { text: '联系卖家', type: 'secondary', action: 'contactSeller' },
            { text: '申请售后', type: 'secondary', action: 'applyAfterSale' }
        ]
    },
    {
        orderId: '1005',
        sellerName: '视频剪辑师',
        sellerId: 'ID97531',
        orderStatus: '等待确认',
        statusCode: 'awaitingConfirmation',
        orderImage: '../../../imgs/IMG20250310160956_20250326010856.jpg',
        orderTitle: '短视频剪辑',
        orderDescription: '15-30秒短视频剪辑，包含转场特效和背景音乐',
        orderPrice: '249',
        orderTime: '2024-03-21 13:20',
        actions: [
            { text: '申请修改', type: 'secondary', action: 'requestRevision' },
            { text: '确认收货', type: 'primary', action: 'confirmReceipt' }
        ]
    },
    {
        orderId: '1006',
        sellerName: '平面设计师',
        sellerId: 'ID86420',
        orderStatus: '待评价',
        statusCode: 'awaitingEvaluation',
        orderImage: '../../../imgs/IMG20250310162729_20250326010856.jpg',
        orderTitle: '海报设计',
        orderDescription: '活动宣传海报设计，包含源文件',
        orderPrice: '199',
        orderTime: '2024-03-20 11:10',
        actions: [
            { text: '去评价', type: 'primary', action: 'evaluateOrder' }
        ]
    },
    {
        orderId: '1007',
        sellerName: '配音演员',
        sellerId: 'ID11223',
        orderStatus: '已完成',
        statusCode: 'orderCompleted',
        orderImage: '../../../imgs/IMG20250314145624_20250326010857.jpg',
        orderTitle: '广告配音',
        orderDescription: '30秒广告配音，专业录音棚录制',
        orderPrice: '299',
        orderTime: '2024-03-19 15:40',
        actions: [
            { text: '再次购买', type: 'primary', action: 'buyAgain' }
        ]
    },
    {
        orderId: '1008',
        sellerName: '翻译专家',
        sellerId: 'ID33445',
        orderStatus: '退款处理中', // 售后状态1：申请退款
        statusCode: 'afterSale',
        afterSaleStatus: 'refund', // 自定义售后子状态
        orderImage: '../../../imgs/IMG20250308233845_20250326010856.jpg',
        orderTitle: '英文文档翻译',
        orderDescription: '专业英文文档翻译，保证准确性和专业性',
        orderPrice: '399',
        orderTime: '2024-03-18 08:50',
        actions: [
            { text: '查看进度', type: 'secondary', action: 'viewAfterSaleDetails' }
        ]
    },
    {
        orderId: '1009',
        sellerName: 'UI设计师',
        sellerId: 'ID55667',
        orderStatus: '平台介入中', // 售后状态2：平台介入
        statusCode: 'afterSale',
        afterSaleStatus: 'intervention', // 自定义售后子状态
        orderImage: '../../../imgs/IMG20250308234545_20250326010856.jpg',
        orderTitle: 'App界面设计',
        orderDescription: '移动应用UI/UX设计',
        orderPrice: '899',
        orderTime: '2024-03-17 11:00',
        actions: [
            { text: '查看进度', type: 'secondary', action: 'viewAfterSaleDetails' }
        ]
    }
];

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOMContentLoaded 事件触发');
    
    // 初始化订单列表
    initOrderList('all');
    
    // 添加一个测试订单项
    addTestOrderItem();
    
    // 设置标签页点击事件
    document.querySelectorAll('.tab-item').forEach(tab => {
        tab.addEventListener('click', function() {
            switchTab(this);
        });
    });
});

// 切换标签页
function switchTab(tabElement) {
    // 移除所有标签的active类
    document.querySelectorAll('.tab-item').forEach(tab => {
        tab.classList.remove('active');
    });
    
    // 给当前点击的标签添加active类
    tabElement.classList.add('active');
    
    // 获取当前标签对应的状态
    const status = tabElement.getAttribute('data-status');
    
    // 根据状态筛选订单
    initOrderList(status);
}

// 初始化订单列表
function initOrderList(status) {
    console.log('initOrderList 函数被调用，状态：', status);
    const orderList = document.getElementById('orderList');
    const noOrders = document.getElementById('noOrders');
    console.log('orderList 元素：', orderList);
    console.log('noOrders 元素：', noOrders);
    
    // 清空订单列表
    orderList.innerHTML = '';
    
    // 根据状态筛选订单
    let filteredOrders = [];
    console.log('mockOrders 数据：', mockOrders);
    
    if (status === 'all') {
        filteredOrders = mockOrders;
    } else if (status === 'awaitingConfirmation') { // 待确认 Tab
        filteredOrders = mockOrders.filter(order =>
            order.statusCode === 'awaitingStart' || order.statusCode === 'awaitingMaterialResubmission'
        );
    } else if (status === 'inProgress') {
        // 进行中 Tab (不包括已取消)
        filteredOrders = mockOrders.filter(order =>
            ['awaitingSubmission', 'awaitingDelivery'].includes(order.statusCode)
        );
    } else if (status === 'paid') {
        // 已支付 Tab
        filteredOrders = mockOrders.filter(order =>
             order.statusCode === 'awaitingPayment' || order.statusCode === 'awaitingConfirmation'
        );
    } else if (status === 'completed') {
        // 已完成 Tab
        filteredOrders = mockOrders.filter(order =>
            order.statusCode === 'awaitingEvaluation' || order.statusCode === 'orderCompleted'
        );
    } else if (status === 'afterSale') {
        // 售后状态包含多个子状态
        filteredOrders = mockOrders.filter(order => order.statusCode === 'afterSale');
    } else {
        // 其他具体状态
        filteredOrders = mockOrders.filter(order => order.statusCode === status);
    }
    // 判断是否有订单
    console.log('过滤后的订单数量：', filteredOrders.length);
    if (filteredOrders.length === 0) {
        console.log('没有订单，显示暂无订单提示');
        orderList.style.display = 'none';
        noOrders.style.display = 'flex';
    } else {
        console.log('有订单，显示订单列表');
        orderList.style.display = 'block';
        noOrders.style.display = 'none';
        
        
        // 渲染订单列表
        filteredOrders.forEach(order => {
            console.log('创建订单项：', order);
            const orderItem = createOrderItem(order);
            console.log('创建的订单项：', orderItem);
            orderList.appendChild(orderItem);
        });
    }
}

// 创建订单项
function createOrderItem(order) {
    console.log('createOrderItem 函数被调用，订单：', order);
    // 获取模板
    const template = document.getElementById('orderItemTemplate').innerHTML;
    console.log('模板内容：', template);
    
    // 创建临时容器
    const container = document.createElement('div');
    
    // 替换模板中的变量
    let orderHtml = template
        .replace('{orderId}', order.orderId)
        .replace('{sellerName}', order.sellerName)
        .replace('{sellerId}', order.sellerId)
        .replace('{orderStatus}', order.orderStatus)
        .replace('{orderImage}', order.orderImage)
        .replace('{orderTitle}', order.orderTitle)
        .replace('{orderDescription}', order.orderDescription)
        .replace('{orderPrice}', order.orderPrice)
        .replace('{orderTime}', order.orderTime);
    
    // 处理订单操作按钮
    let actionsHtml = '';
    if (order.actions && order.actions.length > 0) {
        order.actions.forEach(action => {
            actionsHtml += `<button class="action-button ${action.type}" onclick="handleAction('${action.action}', '${order.orderId}')">${action.text}</button>`;
        });
    }
    
    // 替换操作按钮
    orderHtml = orderHtml.replace('{orderActions}', actionsHtml);
    
    // 设置HTML
    container.innerHTML = orderHtml;
    
    // 返回容器本身，而不是第一个子元素
    return container;
}

// 跳转到订单详情页
function goToOrderDetail(orderId) {
    // 根据订单ID获取订单信息
    const order = mockOrders.find(o => o.orderId === orderId);
    if (!order) return;
    
    // 根据订单状态跳转到不同的页面
    switch (order.statusCode) {
        case 'awaitingConfirmation':
            window.location.href = `order_awaiting_confirmation.html?id=${orderId}`;
            break;
        case 'awaitingSubmission':
        case 'awaitingStart':
        case 'awaitingDelivery':
            window.location.href = `order_in_progress.html?id=${orderId}`;
            break;
        case 'paid':
        case 'awaitingPayment':
            window.location.href = `order_paid.html?id=${orderId}`;
            break;
        case 'orderCompleted':
        case 'awaitingEvaluation':
            window.location.href = `order_detail.html?id=${orderId}`;
            break;
        case 'applyingForRefund':
        case 'awaitingRefund':
            window.location.href = `order_refund.html?id=${orderId}`;
            break;
        case 'applyingForMediation':
            window.location.href = `order_platform_intervention.html?id=${orderId}`;
            break;
        default:
            window.location.href = `order_detail.html?id=${orderId}`;
    }
}

// 处理订单操作
function handleAction(action, orderId) {
    event.stopPropagation(); // 阻止事件冒泡，防止触发订单项的点击事件
    
    switch (action) {
        case 'cancelOrder':
            // 取消订单
            alert(`取消订单 ${orderId}`);
            break;
        case 'payOrder':
            // 去付款
            window.location.href = `../../../outer/about/payment.html?id=${orderId}`;
            break;
        case 'submitRequirements':
            // 提交要求，跳转到进行中页面
            window.location.href = `order_in_progress.html?id=${orderId}`;
            break;
        case 'contactSeller':
            // 联系卖家
            window.location.href = `../../../outer/chatroom.html?seller=${getSellerIdByOrderId(orderId)}`;
            break;
        case 'applyAfterSale': // 这个 action 可能需要根据具体场景触发不同的售后流程
            // 暂时跳转到退款页面作为示例
            window.location.href = `order_refund.html?id=${orderId}`;
            break;
        case 'viewAfterSaleDetails':
            // 查看售后详情，根据售后子状态跳转
            const orderForAfterSale = mockOrders.find(o => o.orderId === orderId);
            if (orderForAfterSale && orderForAfterSale.afterSaleStatus === 'refund') {
                window.location.href = `order_refund.html?id=${orderId}`;
            } else if (orderForAfterSale && orderForAfterSale.afterSaleStatus === 'intervention') {
                window.location.href = `order_platform_intervention.html?id=${orderId}`;
            } else {
                // 默认或未知售后状态，跳转到通用详情页
                window.location.href = `order_detail.html?id=${orderId}`;
            }
            
            break;
        case 'requestRevision':
            // 申请修改，跳转到材料重传页面
            window.location.href = `order_repost_materials.html?id=${orderId}`;
            break;
        case 'confirmReceipt':
            // 确认收货
            alert(`确认收货 ${orderId}`);
            // 确认后跳转到评价页面
            window.location.href = `order_evaluation.html?id=${orderId}`;
            break;
        case 'evaluateOrder':
            // 去评价
            window.location.href = `order_evaluation.html?id=${orderId}`;
            break;
        case 'buyAgain':
            // 再次购买
            alert(`再次购买 ${orderId}`);
            break;
        case 'viewRefundDetails':
            // 查看退款详情
            window.location.href = `order_refund.html?id=${orderId}`;
            break;
        default:
            console.log(`未知操作: ${action}`);
    }
}

// 根据订单ID获取卖家ID（模拟函数）
function getSellerIdByOrderId(orderId) {
    const order = mockOrders.find(o => o.orderId === orderId);
    return order ? order.sellerId : '';
}

// 添加测试订单项
function addTestOrderItem() {
    console.log('添加测试订单项');
    const orderList = document.getElementById('orderList');
    const noOrders = document.getElementById('noOrders');
    
    if (!orderList || !noOrders) {
        console.error('找不到订单列表或暂无订单提示元素');
        return;
    }
    
    // 显示订单列表，隐藏暂无订单提示
    orderList.style.display = 'block';
    noOrders.style.display = 'none';
    
    // 创建一个简单的订单项
    const orderItem = document.createElement('div');
    orderItem.className = 'order-item';
    orderItem.innerHTML = `
        <div class="order-header">
            <div class="seller-info">
                <span class="seller-name">测试卖家</span>
                <span class="seller-id">ID12345</span>
            </div>
            <div class="order-status">测试状态</div>
        </div>
        <div class="order-content">
            <div class="order-image">
                <img src="../../../imgs/IMG20250308191357_20250326010856.jpg" alt="订单图片">
            </div>
            <div class="order-details">
                <div class="order-title">测试订单标题</div>
                <div class="order-description">测试订单描述</div>
                <div class="order-price">¥100</div>
            </div>
        </div>
        <div class="order-footer">
            <div class="order-time">2025-03-27 10:00</div>
            <div class="order-actions">
                <button class="action-button primary">测试按钮</button>
            </div>
        </div>
    `;
    
    // 添加到订单列表
    orderList.appendChild(orderItem);
    console.log('测试订单项已添加');
}