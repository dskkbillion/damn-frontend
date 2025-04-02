// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 解析URL参数
    const urlParams = new URLSearchParams(window.location.search);
    
    // 显示搜索条件摘要
    displaySearchSummary(urlParams);
    
    // 加载搜索结果
    loadSearchResults(urlParams);
});

// 显示搜索条件摘要
function displaySearchSummary(params) {
    const summaryElement = document.getElementById('searchSummary');
    let summaryText = '';
    
    if (params.has('orderNumber')) {
        summaryText += `订单号: ${params.get('orderNumber')} `;
    }
    
    if (params.has('status')) {
        const statusMap = {
            'pending': '待确认',
            'inProgress': '进行中',
            'delivered': '已交付',
            'afterSale': '售后'
        };
        summaryText += `状态: ${statusMap[params.get('status')] || params.get('status')} `;
    }
    
    if (params.has('startDate') && params.has('endDate')) {
        summaryText += `时间: ${params.get('startDate')} 至 ${params.get('endDate')} `;
    } else if (params.has('startDate')) {
        summaryText += `时间: ${params.get('startDate')}之后 `;
    } else if (params.has('endDate')) {
        summaryText += `时间: ${params.get('endDate')}之前 `;
    }
    
    if (params.has('buyerName')) {
        summaryText += `买家: ${params.get('buyerName')} `;
    }
    
    summaryElement.textContent = summaryText || '全部订单';
}

// 加载搜索结果
function loadSearchResults(params) {
    // 在实际应用中，这里应该是从API获取数据
    // 这里我们使用模拟数据
    const mockResults = getMockResults();
    
    // 如果有搜索条件，过滤结果
    let filteredResults = mockResults;
    
    if (params.has('orderNumber')) {
        const orderNumber = params.get('orderNumber');
        filteredResults = filteredResults.filter(order => 
            order.id.toString().includes(orderNumber)
        );
    }
    
    if (params.has('status')) {
        const status = params.get('status');
        filteredResults = filteredResults.filter(order => 
            order.status === status
        );
    }
    
    if (params.has('buyerName')) {
        const buyerName = params.get('buyerName');
        filteredResults = filteredResults.filter(order => 
            order.buyerName.includes(buyerName)
        );
    }
    
    // 显示结果
    displayResults(filteredResults);
}

// 显示结果
function displayResults(results) {
    const resultsContainer = document.getElementById('searchResults');
    const noResultsElement = document.getElementById('noResults');
    const loadMoreElement = document.getElementById('loadMore');
    
    // 清空结果容器
    resultsContainer.innerHTML = '';
    
    if (results.length === 0) {
        // 没有结果
        noResultsElement.style.display = 'flex';
        loadMoreElement.style.display = 'none';
        return;
    }
    
    // 有结果
    noResultsElement.style.display = 'none';
    
    // 获取模板
    const template = document.getElementById('orderItemTemplate').innerHTML;
    
    // 添加结果
    results.forEach(order => {
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
        if (order.status === 'pending') {
            actionsHtml = `
                <button class="order-action-button action-secondary" onclick="event.stopPropagation(); rejectOrder(${order.id})">拒绝</button>
                <button class="order-action-button action-primary" onclick="event.stopPropagation(); acceptOrder(${order.id})">接受</button>
            `;
        } else if (order.status === 'inProgress') {
            actionsHtml = `
                <button class="order-action-button action-primary" onclick="event.stopPropagation(); deliverOrder(${order.id})">交付</button>
            `;
        }
        
        orderHtml = orderHtml.replace('{orderActions}', actionsHtml);
        
        // 创建元素并添加到容器
        const div = document.createElement('div');
        div.innerHTML = orderHtml;
        resultsContainer.appendChild(div.firstElementChild);
    });
    
    // 显示加载更多按钮（如果结果超过10条）
    loadMoreElement.style.display = results.length > 10 ? 'block' : 'none';
}

// 获取状态文本
function getStatusText(status) {
    const statusMap = {
        'pending': '待确认',
        'inProgress': '进行中',
        'delivered': '已交付',
        'afterSale': '售后'
    };
    return statusMap[status] || status;
}

// 加载更多结果
function loadMoreResults() {
    // 在实际应用中，这里应该加载下一页数据
    alert('加载更多结果');
}

// 跳转到订单详情
function goToOrderDetail(orderId) {
    window.location.href = `seller_order_detail.html?id=${orderId}`;
}

// 接受订单
function acceptOrder(orderId) {
    // 在实际应用中，这里应该调用API接受订单
    alert(`接受订单 ${orderId}`);
    // 刷新页面或更新订单状态
}

// 拒绝订单
function rejectOrder(orderId) {
    // 在实际应用中，这里应该调用API拒绝订单
    alert(`拒绝订单 ${orderId}`);
    // 刷新页面或更新订单状态
}

// 交付订单
function deliverOrder(orderId) {
    // 在实际应用中，这里应该调用API交付订单
    alert(`交付订单 ${orderId}`);
    // 跳转到交付页面
}

// 获取模拟数据
function getMockResults() {
    return [
        {
            id: 1001,
            buyerName: '用户1068',
            buyerId: 'ID1068',
            status: 'pending',
            image: 'imgs/IMG20250308191357_20250326010856.jpg',
            title: '商品名称',
            description: '商品描述信息，这里是一些详细的描述内容...',
            price: '169',
            time: '2025-03-20 14:30'
        },
        {
            id: 1002,
            buyerName: '用户928',
            buyerId: 'ID928',
            status: 'pending',
            image: 'imgs/IMG20250308211749_20250326010856.jpg',
            title: '商品名称',
            description: '商品描述信息，这里是一些详细的描述内容...',
            price: '861',
            time: '2025-03-19 09:15'
        },
        {
            id: 1003,
            buyerName: '用户847',
            buyerId: 'ID847',
            status: 'inProgress',
            image: 'imgs/IMG20250309142054_20250326010856.jpg',
            title: '商品名称',
            description: '商品描述信息，这里是一些详细的描述内容...',
            price: '892',
            time: '2025-03-18 16:45'
        }
    ];
}