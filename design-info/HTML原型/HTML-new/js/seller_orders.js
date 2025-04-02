// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 加载订单数据
    loadOrders('all');
});

// 切换标签
function switchTab(tabElement) {
    // 移除所有标签的active类
    document.querySelectorAll('.tab-item').forEach(tab => {
        tab.classList.remove('active');
    });
    
    // 为当前标签添加active类
    tabElement.classList.add('active');
    
    // 获取标签对应的状态
    const status = tabElement.getAttribute('data-status');
    
    // 加载对应状态的订单
    loadOrders(status);
}

// 加载订单
function loadOrders(status) {
    // 在实际应用中，这里应该是从API获取数据
    // 这里我们使用模拟数据
    const mockOrders = getMockOrders();
    
    // 根据状态过滤订单
    let filteredOrders = mockOrders;
    if (status === 'all') {
        filteredOrders = mockOrders;
    } else if (status === 'awaitingConfirmation') { // 待确认 Tab
        filteredOrders = mockOrders.filter(order => order.status === 'pending'); // 等待您接单
    } else if (status === 'inProgress') {
        filteredOrders = mockOrders.filter(order => order.status === 'awaitingDelivery'); // 等待交付
    } else if (status === 'paid') {
        filteredOrders = mockOrders.filter(order => order.status === 'awaitingComfirm'); // 等待买家确认
    } else if (status === 'completed') {
        filteredOrders = mockOrders.filter(order =>
            order.status === 'orderCompleted' || order.status === 'awatingEvaluation'
        );
    } else if (status === 'afterSale') { // 售后 Tab
        filteredOrders = mockOrders.filter(order => order.status === 'afterSale');
    }
    // 可以选择性地添加已取消订单的过滤逻辑，或者在 'all' 中显示
    // else if (status === 'cancelled') {
    //     filteredOrders = mockOrders.filter(order => order.status === 'cancelled');
    // }
    
    // 显示订单
    displayOrders(filteredOrders);
}

// 显示订单
function displayOrders(orders) {
    const orderListElement = document.getElementById('orderList');
    const noOrdersElement = document.getElementById('noOrders');
    
    // 清空订单列表
    orderListElement.innerHTML = '';
    
    if (orders.length === 0) {
        // 没有订单
        noOrdersElement.style.display = 'flex';
        return;
    }
    
    // 有订单
    noOrdersElement.style.display = 'none';
    
    // 获取模板
    const template = document.getElementById('orderItemTemplate').innerHTML;
    
    // 添加订单
    orders.forEach(order => {
        let orderHtml = template
            .replace('{orderId}', order.id)
            .replace('{buyerName}', order.buyerName)
            .replace('{buyerId}', order.buyerId)
            .replace('{orderStatus}', getStatusText(order.status))
            .replace('{orderImage}', order.image)
            .replace('{orderTitle}', order.title)
            .replace('{orderDescription}', order.description)
            .replace('{orderPrice}', order.price)
            .replace('{orderTime}', order.time);
        
        // 添加操作按钮
        let actionsHtml = '';
        // 根据原型截图更新操作按钮
        if (order.status === 'pending') { // 等待您接单
            actionsHtml = `
                <button class="order-action-button action-secondary" onclick="event.stopPropagation(); showMaterialIssueDialogWrapper(${order.id})">材料有问题？</button>
                <button class="order-action-button action-primary" onclick="event.stopPropagation(); acceptOrder(${order.id})">同意接单</button>
            `;
        } else if (order.status === 'awaitingDelivery') { // 等待交付
            actionsHtml = `
                <button class="order-action-button action-primary" onclick="event.stopPropagation(); deliverOrder(${order.id})">交付</button>
            `;
        } else if (order.status === 'awaitingComfirm') { // 等待买家确认
             actionsHtml = `
                 <button class="order-action-button action-secondary" onclick="event.stopPropagation(); contactBuyerWrapper(${order.id})">联系买家</button>
                 <button class="order-action-button action-primary" onclick="event.stopPropagation(); viewDelivery(${order.id})">查看交付</button>
             `;
        } else if (order.status === 'paid') { // 已支付 (这个状态在原型中似乎不直接显示，而是合并到 awaitingComfirm 或 awaitingEvaluation)
             actionsHtml = ``; // 暂无按钮
        } else if (order.status === 'awatingEvaluation') { // 待评价
            actionsHtml = `
                <button class="order-action-button action-secondary" onclick="event.stopPropagation(); viewDelivery(${order.id})">查看交付</button>
            `;
        } else if (order.status === 'orderCompleted') { // 已完成
            actionsHtml = `
                <button class="order-action-button action-secondary" onclick="event.stopPropagation(); viewDelivery(${order.id})">查看交付</button>
            `;
        } else if (order.status === 'afterSale') { // 售后
             // 根据 afterSaleStatus 决定按钮
             if (order.afterSaleStatus === 'refund_processing') { // 退款处理中
                 actionsHtml = `
                     <button class="order-action-button action-secondary" onclick="event.stopPropagation(); contactBuyerWrapper(${order.id})">联系买家</button>
                     <button class="order-action-button action-primary" onclick="event.stopPropagation(); handleAfterSale(${order.id})">处理退款</button>
                 `;
             } else if (order.afterSaleStatus === 'intervention_processing') { // 平台介入中
                 actionsHtml = `
                     <button class="order-action-button action-secondary" onclick="event.stopPropagation(); contactBuyerWrapper(${order.id})">联系买家</button>
                     <button class="order-action-button action-primary" onclick="event.stopPropagation(); handleAfterSale(${order.id})">查看进度</button>
                 `;
             } else { // 其他售后状态，如已完成
                 actionsHtml = `
                     <button class="order-action-button action-secondary" onclick="event.stopPropagation(); viewDelivery(${order.id})">查看详情</button>
                 `;
             }
        } else if (order.status === 'cancelled') { // 已取消
             actionsHtml = `
                 <button class="order-action-button action-secondary" onclick="event.stopPropagation(); deleteRecord(${order.id})">删除记录</button>
                 <button class="order-action-button action-primary" onclick="event.stopPropagation(); viewOrder(${order.id})">查看订单</button>
             `;
        }
        
        orderHtml = orderHtml.replace('{orderActions}', actionsHtml);
        
        // 创建元素并添加到容器
        const div = document.createElement('div');
        div.innerHTML = orderHtml;
        orderListElement.appendChild(div.firstElementChild);
        
        // 为订单状态添加对应的类
        const statusElement = div.querySelector('.order-status');
        if (statusElement) {
            statusElement.classList.add(order.status);
        }
    });
}

// 获取状态文本
function getStatusText(status) {
    const statusMap = {
        'pending': '等待您接单',
        'awaitingDelivery': '等待交付',
        'awaitingComfirm': '等待买家确认', // 更新文本
        'paid': '已支付', // 添加状态
        'awatingEvaluation': '等待买家评价', // 更新文本
        'orderCompleted': '已完成',
        'afterSale': '售后处理中', // 默认售后文本，具体可在渲染时根据 afterSaleStatus 覆盖
        'cancelled': '已取消' // 添加状态
    };
    return statusMap[status] || status;
}

// 跳转到订单详情
function goToOrderDetail(orderId) {
    // 根据订单ID获取订单信息
    const order = getMockOrders().find(o => o.id === parseInt(orderId));
    if (!order) return;
    
    // 根据订单状态跳转到不同的页面
    switch (order.status) {
        case 'pending': // 等待您接单
            window.location.href = `seller_order_awaiting_confirmation.html?id=${orderId}`;
            break;
        case 'awaitingDelivery': // 等待交付
            window.location.href = `seller_order_in_progress.html?id=${orderId}`;
            break;
        case 'awaitingComfirm': // 等待买家确认
            window.location.href = `seller_order_detail.html?id=${orderId}`; // 跳转到通用详情页
            break;
        case 'paid': // 已支付 (在原型中似乎不直接作为列表项状态，而是详情页状态)
             window.location.href = `seller_order_paid.html?id=${orderId}`; // 跳转到已支付页面
             break;
        case 'awatingEvaluation': // 等待买家评价
        case 'orderCompleted': // 已完成
            window.location.href = `seller_order_detail.html?id=${orderId}`; // 跳转到通用详情页
            break;
        case 'afterSale':
            // 根据具体的售后状态跳转
            if (order.afterSaleStatus === 'refund') {
                window.location.href = `seller_order_refund.html?id=${orderId}`;
            } else if (order.afterSaleStatus === 'intervention') {
                window.location.href = `seller_order_platform_intervention.html?id=${orderId}`;
            } else if (order.afterSaleStatus === 'redelivery') {
                window.location.href = `seller_order_redelivery.html?id=${orderId}`;
            } else {
                window.location.href = `seller_order_detail.html?id=${orderId}`; // 默认跳转到详情页
            }
            break;
        case 'cancelled': // 已取消
             window.location.href = `seller_order_cancelled.html?id=${orderId}`;
             break;
        default:
            window.location.href = `seller_order_detail.html?id=${orderId}`;
    }
}

// 接受订单
function acceptOrder(orderId) {
    // 在实际应用中，这里应该调用API接受订单
    alert(`接受订单 ${orderId}`);
    // 刷新订单列表
    const activeTab = document.querySelector('.tab-item.active');
    const status = activeTab.getAttribute('data-status');
    loadOrders(status);
}

// 拒绝订单 - 现在通过弹窗处理
// function rejectOrder(orderId) { ... }

// 材料有问题弹窗的包装器 (因为弹窗逻辑在 seller_order_awaiting_confirmation.js 中)
function showMaterialIssueDialogWrapper(orderId) {
    // 实际应用中，可能需要传递更多信息或确保弹窗脚本已加载
    if (typeof showMaterialIssueDialog === 'function') {
         // 可以在这里传递 orderId 给弹窗内的函数使用
         // 例如，修改弹窗内的 rejectOrderWithReason 函数签名
        showMaterialIssueDialog();
    } else {
        // 备用方案或错误处理
        alert('无法打开材料问题对话框');
        // 或者尝试加载脚本？这比较复杂
    }
}

// 联系买家按钮的包装器
function contactBuyerWrapper(orderId) {
     // 获取买家信息，然后跳转到聊天页面
     const order = getMockOrders().find(o => o.id === parseInt(orderId));
     if (order && order.buyerId) {
         window.location.href = `../../../outer/chatroom.html?buyer=${order.buyerId}`; // 假设聊天链接需要买家ID
     } else {
         alert('无法获取买家信息');
     }
}

// 删除记录
function deleteRecord(orderId) {
     alert(`删除订单记录 ${orderId}`);
     // TODO: 实现删除记录逻辑并刷新列表
}

// 查看订单 (已取消或已完成)
function viewOrder(orderId) {
     goToOrderDetail(orderId);
}

// 交付订单
function deliverOrder(orderId) {
    // 跳转到进行中页面进行交付
    window.location.href = `seller_order_in_progress.html?id=${orderId}`;
}

// 查看交付
function viewDelivery(orderId) {
    // 跳转到订单详情页查看交付
    window.location.href = `seller_order_detail.html?id=${orderId}`;
}

// 处理售后
function handleAfterSale(orderId) {
    // 根据订单ID获取订单信息
    const order = getMockOrders().find(o => o.id === parseInt(orderId));
    if (!order) return;
    
    // 根据具体的售后状态跳转
    if (order.afterSaleStatus === 'refund') {
        window.location.href = `seller_order_refund.html?id=${orderId}`;
    } else if (order.afterSaleStatus === 'intervention') {
        window.location.href = `seller_order_platform_intervention.html?id=${orderId}`;
    } else if (order.afterSaleStatus === 'redelivery') {
        window.location.href = `seller_order_redelivery.html?id=${orderId}`;
    } else {
        window.location.href = `seller_order_detail.html?id=${orderId}`; // 默认跳转到详情页
    }
}

// 获取模拟订单数据 - 增加更多状态
function getMockOrders() {
    return [
        // --- 待确认 Tab ---
        {
            id: 1001, buyerName: '用户1068', buyerId: 'ID1068', status: 'pending', // 等待您接单
            image: '../../../imgs/IMG20250308191357_20250326010856.jpg', title: '商品名称A', description: '描述A...', price: '169', time: '2025-03-20 14:30'
        },
         {
            id: 1006, buyerName: '用户524', buyerId: 'ID524', status: 'pending', // 等待您接单
            image: '../../../imgs/IMG20250310160953_20250326010856.jpg', title: '商品名称F', description: '描述F...', price: '250', time: '2025-03-21 10:00'
        },
        // --- 进行中 Tab ---
        {
            id: 1002, buyerName: '用户928', buyerId: 'ID928', status: 'awaitingDelivery', // 等待交付
            image: '../../../imgs/IMG20250308211749_20250326010856.jpg', title: '商品名称B', description: '描述B...', price: '861', time: '2025-03-19 09:15'
        },
        // --- 已支付 Tab ---
        {
            id: 1003, buyerName: '用户847', buyerId: 'ID847', status: 'awaitingComfirm', // 等待买家确认
            image: '../../../imgs/IMG20250309142054_20250326010856.jpg', title: '商品名称C', description: '描述C...', price: '892', time: '2025-03-18 16:45'
        },
        // --- 已完成 Tab ---
         {
            id: 1007, buyerName: '用户413', buyerId: 'ID413', status: 'awatingEvaluation', // 等待买家评价
            image: '../../../imgs/IMG20250308233845_20250326010856.jpg', title: '商品名称G', description: '描述G...', price: '420', time: '2025-03-16 18:00'
        },
        {
            id: 1004, buyerName: '用户756', buyerId: 'ID756', status: 'orderCompleted', // 已完成
            image: '../../../imgs/IMG20250310160953_20250326010856.jpg', title: '商品名称D', description: '描述D...', price: '543', time: '2025-03-15 11:20'
        },
        // --- 售后 Tab ---
        {
            id: 1005, buyerName: '用户635', buyerId: 'ID635', status: 'afterSale', afterSaleStatus: 'refund_processing', // 退款处理中
            image: '../../../imgs/IMG20250308233845_20250326010856.jpg', title: '商品名称E', description: '描述E...', price: '1280', time: '2025-03-10 08:45'
        },
         {
            id: 1008, buyerName: '用户302', buyerId: 'ID302', status: 'afterSale', afterSaleStatus: 'intervention_processing', // 平台介入中
            image: '../../../imgs/IMG20250308191357_20250326010856.jpg', title: '商品名称H', description: '描述H...', price: '99', time: '2025-03-09 12:00'
        },
        // --- 其他 (可能显示在 'all' Tab) ---
         {
            id: 1009, buyerName: '用户211', buyerId: 'ID211', status: 'cancelled', // 已取消
            image: '../../../imgs/IMG20250308211749_20250326010856.jpg', title: '商品名称I', description: '描述I...', price: '300', time: '2025-03-22 15:00'
        }
    ];
}