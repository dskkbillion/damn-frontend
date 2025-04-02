// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 加载交易记录
    loadRecords('all');
    
    // 初始化日期选择器
    initDatePickers();
});

// 初始化日期选择器
function initDatePickers() {
    // 设置开始日期为一个月前
    const startDate = new Date();
    startDate.setMonth(startDate.getMonth() - 1);
    document.getElementById('startDate').valueAsDate = startDate;
    
    // 设置结束日期为今天
    const endDate = new Date();
    document.getElementById('endDate').valueAsDate = endDate;
}

// 切换标签
function switchTab(tabElement) {
    // 移除所有标签的active类
    document.querySelectorAll('.tab-item').forEach(tab => {
        tab.classList.remove('active');
    });
    
    // 为当前标签添加active类
    tabElement.classList.add('active');
    
    // 获取标签对应的类型
    const type = tabElement.getAttribute('data-type');
    
    // 加载对应类型的交易记录
    loadRecords(type);
}

// 加载交易记录
function loadRecords(type) {
    // 获取交易记录数据
    const records = getRecords();
    
    // 根据类型过滤记录
    let filteredRecords = records;
    if (type !== 'all') {
        filteredRecords = records.filter(record => record.type === type);
    }
    
    // 显示记录
    displayRecords(filteredRecords);
}

// 显示交易记录
function displayRecords(records) {
    const recordListElement = document.getElementById('recordList');
    const noRecordsElement = document.getElementById('noRecords');
    
    // 清空记录列表
    recordListElement.innerHTML = '';
    
    if (records.length === 0) {
        // 没有记录
        noRecordsElement.style.display = 'flex';
        return;
    }
    
    // 有记录
    noRecordsElement.style.display = 'none';
    
    // 按日期分组记录
    const groupedRecords = groupRecordsByDate(records);
    
    // 添加记录
    Object.keys(groupedRecords).forEach(date => {
        // 添加日期分组标题
        const dateTitle = document.createElement('div');
        dateTitle.className = 'date-group-title';
        dateTitle.textContent = formatDateTitle(date);
        recordListElement.appendChild(dateTitle);
        
        // 添加该日期下的记录
        groupedRecords[date].forEach(record => {
            const recordItem = createRecordItem(record);
            recordListElement.appendChild(recordItem);
        });
    });
}

// 按日期分组记录
function groupRecordsByDate(records) {
    const groups = {};
    
    records.forEach(record => {
        const date = record.time.split(' ')[0]; // 提取日期部分
        if (!groups[date]) {
            groups[date] = [];
        }
        groups[date].push(record);
    });
    
    return groups;
}

// 格式化日期标题
function formatDateTitle(dateStr) {
    const date = new Date(dateStr);
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    
    if (dateStr === today.toISOString().split('T')[0]) {
        return '今天';
    } else if (dateStr === yesterday.toISOString().split('T')[0]) {
        return '昨天';
    } else {
        return dateStr;
    }
}

// 创建记录项
function createRecordItem(record) {
    const recordItem = document.createElement('div');
    recordItem.className = 'record-item';
    recordItem.setAttribute('data-id', record.id);
    recordItem.onclick = () => goToRecordDetail(record.id);
    
    // 设置图标
    let iconClass = '';
    let iconName = '';
    
    switch (record.type) {
        case 'income':
            iconClass = 'income';
            iconName = 'fa-arrow-down';
            break;
        case 'expense':
            iconClass = 'expense';
            iconName = 'fa-arrow-up';
            break;
        case 'withdraw':
            iconClass = 'withdraw';
            iconName = 'fa-money-bill-transfer';
            break;
    }
    
    // 设置状态
    let statusClass = '';
    let statusText = '';
    
    switch (record.status) {
        case 'success':
            statusClass = 'success';
            statusText = '成功';
            break;
        case 'pending':
            statusClass = 'pending';
            statusText = '处理中';
            break;
        case 'failed':
            statusClass = 'failed';
            statusText = '失败';
            break;
    }
    
    recordItem.innerHTML = `
        <div class="record-icon ${iconClass}">
            <i class="fas ${iconName}"></i>
        </div>
        <div class="record-content">
            <div class="record-title">${record.title}</div>
            <div class="record-time">${record.time}</div>
        </div>
        <div class="record-amount ${iconClass}">${record.type === 'expense' ? '-' : '+'}${record.amount}</div>
        ${record.status ? `<div class="record-status ${statusClass}">${statusText}</div>` : ''}
    `;
    
    return recordItem;
}

// 跳转到记录详情
function goToRecordDetail(recordId) {
    window.location.href = `seller_record_detail.html?id=${recordId}`;
}

// 获取交易记录数据
function getRecords() {
    // 在实际应用中，这里应该从API获取数据
    // 这里我们只是使用模拟数据
    return [
        {
            id: 1,
            type: 'income',
            title: '订单收入',
            amount: '¥169.00',
            time: '2025-03-25 14:30',
            status: 'success',
            orderId: '1001',
            description: '用户购买服务'
        },
        {
            id: 2,
            type: 'withdraw',
            title: '提现',
            amount: '¥500.00',
            time: '2025-03-24 10:15',
            status: 'pending',
            bankCard: '**** **** **** 1234',
            description: '提现到招商银行'
        },
        {
            id: 3,
            type: 'expense',
            title: '平台服务费',
            amount: '¥15.00',
            time: '2025-03-23 09:45',
            status: 'success',
            orderId: '1001',
            description: '订单服务费'
        },
        {
            id: 4,
            type: 'income',
            title: '订单收入',
            amount: '¥299.00',
            time: '2025-03-20 16:20',
            status: 'success',
            orderId: '1000',
            description: '用户购买服务'
        },
        {
            id: 5,
            type: 'withdraw',
            title: '提现',
            amount: '¥1000.00',
            time: '2025-03-15 11:30',
            status: 'success',
            bankCard: '**** **** **** 1234',
            description: '提现到招商银行'
        }
    ];
}

// 显示筛选对话框
function showFilterDialog() {
    document.getElementById('filterDialog').style.display = 'flex';
}

// 隐藏筛选对话框
function hideFilterDialog() {
    document.getElementById('filterDialog').style.display = 'none';
}

// 重置筛选条件
function resetFilter() {
    // 重置交易类型
    document.getElementById('typeAll').checked = true;
    document.getElementById('typeIncome').checked = false;
    document.getElementById('typeExpense').checked = false;
    document.getElementById('typeWithdraw').checked = false;
    
    // 重置日期范围
    initDatePickers();
    
    // 重置金额范围
    document.getElementById('minAmount').value = '';
    document.getElementById('maxAmount').value = '';
}

// 应用筛选条件
function applyFilter() {
    // 在实际应用中，这里应该根据筛选条件过滤数据
    // 这里我们只是简单地重新加载所有记录
    loadRecords('all');
    
    // 隐藏对话框
    hideFilterDialog();
    
    // 显示成功提示
    alert('筛选条件已应用');
}