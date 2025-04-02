// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 从URL获取记录ID
    const urlParams = new URLSearchParams(window.location.search);
    const recordId = urlParams.get('id');
    
    if (!recordId) {
        // 没有记录ID，返回上一页
        window.location.href = 'seller_record.html';
        return;
    }
    
    // 加载记录详情
    loadRecordDetail(recordId);
});

// 加载记录详情
function loadRecordDetail(recordId) {
    // 获取记录数据
    const record = getRecordById(recordId);
    
    if (!record) {
        // 没有找到记录，返回上一页
        alert('未找到交易记录');
        window.location.href = 'seller_record.html';
        return;
    }
    
    // 显示记录详情
    displayRecordDetail(record);
}

// 获取记录类型文本
function getRecordTypeText(type) {
    switch (type) {
        case 'income':
            return '订单收入';
        case 'expense':
            return '平台服务费';
        case 'withdraw':
            return '提现';
        default:
            return '未知类型';
    }
}

// 获取记录数据
function getRecordById(id) {
    // 在实际应用中，这里应该从API获取数据
    // 这里我们只是使用模拟数据
    const records = [
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
        }
    ];
    
    return records.find(record => record.id === parseInt(id));
}

// 显示记录详情
function displayRecordDetail(record) {
    // 设置金额
    const amountContainer = document.getElementById('recordAmountContainer');
    let amountLabel = '';
    
    switch (record.type) {
        case 'income':
            amountLabel = '收入金额';
            break;
        case 'expense':
            amountLabel = '支出金额';
            break;
        case 'withdraw':
            amountLabel = '提现金额';
            break;
    }
    
    amountContainer.innerHTML = `
        <div class="record-amount-label">${amountLabel}</div>
        <div class="record-amount ${record.type}">${record.type === 'expense' ? '-' : '+'}${record.amount}</div>
    `;
    
    // 设置状态
    const statusContainer = document.getElementById('recordStatusContainer');
    let statusText = '';
    
    switch (record.status) {
        case 'success':
            statusText = '交易成功';
            break;
        case 'pending':
            statusText = '处理中';
            break;
        case 'failed':
            statusText = '交易失败';
            break;
    }
    
    statusContainer.innerHTML = `
        <div class="record-status ${record.status}">${statusText}</div>
    `;
    
    // 设置详情
    document.getElementById('recordType').textContent = getRecordTypeText(record.type);
    document.getElementById('recordTime').textContent = record.time;
    document.getElementById('recordId').textContent = record.id;
    document.getElementById('recordDescription').textContent = record.description;
    
    // 设置订单编号或银行卡
    if (record.orderId) {
        document.getElementById('orderIdItem').style.display = 'flex';
        document.getElementById('orderId').textContent = record.orderId;
    }
    
    if (record.bankCard) {
        document.getElementById('bankCardItem').style.display = 'flex';
        document.getElementById('bankCard').textContent = record.bankCard;
    }
    
    // 设置操作按钮
    const actionsContainer = document.getElementById('recordActions');
    
    if (record.type === 'income' && record.orderId) {
        actionsContainer.innerHTML = `
            <button class="action-button primary" onclick="viewOrder('${record.orderId}')">查看订单</button>
        `;
    } else if (record.type === 'withdraw' && record.status === 'pending') {
        actionsContainer.innerHTML = `
            <button class="action-button secondary" onclick="cancelWithdraw(${record.id})">取消提现</button>
        `;
    } else {
        actionsContainer.style.display = 'none';
    }
}

// 查看订单
function viewOrder(orderId) {
    window.location.href = `seller_order_detail.html?id=${orderId}`;
}

// 取消提现
function cancelWithdraw(recordId) {
    // 在实际应用中，这里应该调用API取消提现
    // 这里我们只是显示提示
    if (confirm('确定要取消提现吗？')) {
        alert('提现已取消');
        window.location.href = 'seller_record.html';
    }
}

// 联系客服
function contactSupport() {
    // 在实际应用中，这里应该跳转到客服页面
    // 这里我们只是显示提示
    alert('正在跳转到客服页面...');
}