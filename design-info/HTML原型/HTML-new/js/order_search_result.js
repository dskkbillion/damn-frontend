// 订单搜索结果页面脚本

// 模拟订单数据
const mockOrders = [
    {
        orderId: '1001',
        sellerName: '设计师小明',
        sellerId: 'ID12345',
        orderStatus: '待付款',
        statusCode: 'awaitingPayment',
        orderImage: 'https://via.placeholder.com/80',
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
        orderImage: 'https://via.placeholder.com/80',
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
        orderImage: 'https://via.placeholder.com/80',
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
        orderImage: 'https://via.placeholder.com/80',
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
        orderImage: 'https://via.placeholder.com/80',
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
        orderImage: 'https://via.placeholder.com/80',
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
        orderImage: 'https://via.placeholder.com/80',
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
        orderStatus: '退款处理中',
        statusCode: 'applyingForRefund',
        orderImage: 'https://via.placeholder.com/80',
        orderTitle: '英文文档翻译',
        orderDescription: '专业英文文档翻译，保证准确性和专业性',
        orderPrice: '399',
        orderTime: '2024-03-18 08:50',
        actions: [
            { text: '查看详情', type: 'secondary', action: 'viewRefundDetails' }
        ]
    }
];

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 获取URL参数中的搜索关键词
    const urlParams = new URLSearchParams(window.location.search);
    const keyword = urlParams.get('keyword');
    
    // 设置搜索框的值
    if (keyword) {
        document.getElementById('searchInput').value = keyword;
    }
    
    // 初始化清除按钮状态
    toggleClearButton();
    
    // 监听搜索框输入事件
    const searchInput = document.getElementById('searchInput');
    searchInput.addEventListener('input', function() {
        toggleClearButton();
    });
    
    // 监听搜索框回车事件
    searchInput.addEventListener('keypress', function(event) {
        if (event.key === 'Enter') {
            searchOrders();
        }
    });
    
    // 执行搜索
    searchOrders();
});

// 切换清除按钮显示状态
function toggleClearButton() {
    const searchInput = document.getElementById('searchInput');
    const clearButton = document.getElementById('clearSearch');
    
    if (searchInput.value) {
        clearButton.style.display = 'block';
    } else {
        clearButton.style.display = 'none';
    }
}

// 清空搜索框
function clearSearch() {
    const searchInput = document.getElementById('searchInput');
    searchInput.value = '';
    toggleClearButton();
    searchInput.focus();
}

// 搜索订单
function searchOrders() {
    const searchInput = document.getElementById('searchInput');
    const keyword = searchInput.value.trim();
    
    // 获取当前选中的筛选条件
    const activeFilter = document.querySelector('.filter-item.active').getAttribute('data-filter');
    
    // 筛选订单
    let filteredOrders = filterOrdersByKeyword(mockOrders, keyword);
    
    // 根据筛选条件进一步筛选
    if (activeFilter !== 'all') {
        filteredOrders = filterOrdersByStatus(filteredOrders, activeFilter);
    }
    
    // 渲染搜索结果
    renderSearchResults(filteredOrders);
}

// 根据关键词筛选订单
function filterOrdersByKeyword(orders, keyword) {
    if (!keyword) {
        return orders;
    }
    
    return orders.filter(order => {
        return order.orderId.includes(keyword) ||
               order.sellerName.includes(keyword) ||
               order.sellerId.includes(keyword) ||
               order.orderTitle.includes(keyword) ||
               order.orderDescription.includes(keyword);
    });
}

// 根据状态筛选订单
function filterOrdersByStatus(orders, status) {
    if (status === 'inProgress') {
        // 进行中状态包含多个子状态
        return orders.filter(order => 
            ['awaitingSubmission', 'awaitingStart', 'awaitingDelivery', 'awaitingConfirmation'].includes(order.statusCode)
        );
    } else if (status === 'completed') {
        // 已完成状态
        return orders.filter(order => 
            order.statusCode === 'orderCompleted'
        );
    } else if (status === 'afterSale') {
        // 售后状态包含多个子状态
        return orders.filter(order => 
            ['applyingForRefund', 'awaitingRefund', 'applyingForMediation'].includes(order.statusCode)
        );
    } else {
        // 其他具体状态
        return orders.filter(order => order.statusCode === status);
    }
}

// 渲染搜索结果
function renderSearchResults(orders) {
    const searchResults = document.getElementById('searchResults');
    const noResults = document.getElementById('noResults');
    const loadMore = document.getElementById('loadMore');
    
    // 清空搜索结果
    searchResults.innerHTML = '';
    
    // 判断是否有搜索结果
    if (orders.length === 0) {
        searchResults.style.display = 'none';
        noResults.style.display = 'flex';
        loadMore.style.display = 'none';
    } else {
        searchResults.style.display = 'block';
        noResults.style.display = 'none';
        
        // 渲染搜索结果
        orders.forEach(order => {
            const orderItem = createOrderItem(order);
            searchResults.appendChild(orderItem);
        });
        
        // 判断是否显示加载更多按钮
        if (orders.length >= 10) {
            loadMore.style.display = 'flex';
        } else {
            loadMore.style.display = 'none';
        }
    }
}

// 创建订单项
function createOrderItem(order) {
    // 获取模板
    const template = document.getElementById('orderItemTemplate').innerHTML;
    
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
    
    // 返回第一个子元素（订单项）
    return container.firstChild;
}

// 筛选结果
function filterResults(filterItem) {
    // 移除所有筛选项的active类
    document.querySelectorAll('.filter-item').forEach(item => {
        item.classList.remove('active');
    });
    
    // 给当前点击的筛选项添加active类
    filterItem.classList.add('active');
    
    // 执行搜索
    searchOrders();
}

// 跳转到订单详情页
function goToOrderDetail(orderId) {
    window.location.href = `order_detail.html?id=${orderId}`;
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
            window.location.href = `payment.html?id=${orderId}`;
            break;
        case 'submitRequirements':
            // 提交要求
            window.location.href = `order_detail.html?id=${orderId}&action=submit`;
            break;
        case 'contactSeller':
            // 联系卖家
            window.location.href = `chatroom.html?seller=${getSellerIdByOrderId(orderId)}`;
            break;
        case 'applyAfterSale':
            // 申请售后
            window.location.href = `order_postsale.html?id=${orderId}`;
            break;
        case 'requestRevision':
            // 申请修改
            window.location.href = `order_detail.html?id=${orderId}&action=revision`;
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
            window.location.href = `order_detail.html?id=${orderId}`;
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