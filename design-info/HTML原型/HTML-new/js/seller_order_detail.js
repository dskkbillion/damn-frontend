// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 初始化页面
    initializePage();
});

// 初始化页面
function initializePage() {
    // 设置默认状态
    const currentStep = 6; // 当前在第6步（评价）
    updateProgress(currentStep);
    updateStatusTip('info', '等待买家确认收货，等待买家评价');
    updateActionButtons(currentStep);
}

// 更新进度条
function updateProgress(currentStep) {
    const steps = document.querySelectorAll('.step');
    const progressLine = document.getElementById('progressLineActive');
    
    // 计算进度线宽度
    const totalSteps = steps.length - 1;
    const stepWidth = 100 / totalSteps;
    const progress = Math.min((currentStep - 1) * stepWidth, 100);
    progressLine.style.width = `${progress}%`;
    
    // 更新步骤状态
    steps.forEach((step, index) => {
        const stepNum = index + 1;
        const label = step.querySelector('.step-label').textContent;
        
        if (stepNum < currentStep) {
            step.className = 'step completed';
            step.innerHTML = `<i class="fas fa-check"></i><span class="step-label">${label}</span>`;
        } else if (stepNum === currentStep) {
            step.className = 'step active';
        } else {
            step.className = 'step';
        }
    });
}

// 更新状态提示
function updateStatusTip(status, message) {
    const statusTip = document.getElementById('statusTip');
    if (statusTip) {
        statusTip.className = `status-tip ${status}`;
        statusTip.textContent = message;
    }
}

// 切换买家提交内容标签页
function switchSubmissionTab(tab, tabName) {
    // 移除所有标签页的active类
    document.querySelectorAll('.buyer-content .tab').forEach(t => {
        t.classList.remove('active');
    });
    
    // 添加active类到当前标签页
    tab.classList.add('active');
    
    // 隐藏所有内容
    document.getElementById('textContent').style.display = 'none';
    document.getElementById('attachmentContent').style.display = 'none';
    
    // 显示选中的内容
    if (tabName === 'text') {
        document.getElementById('textContent').style.display = 'block';
    } else if (tabName === 'attachment') {
        document.getElementById('attachmentContent').style.display = 'block';
    }
}

// 切换卖家交付内容标签页
function switchDeliveryTab(tab, tabName) {
    // 移除所有标签页的active类
    document.querySelectorAll('.seller-delivery .tab').forEach(t => {
        t.classList.remove('active');
    });
    
    // 添加active类到当前标签页
    tab.classList.add('active');
    
    // 隐藏所有内容
    document.getElementById('deliveryTextContent').style.display = 'none';
    document.getElementById('deliveryAttachmentContent').style.display = 'none';
    
    // 显示选中的内容
    if (tabName === 'text') {
        document.getElementById('deliveryTextContent').style.display = 'block';
    } else if (tabName === 'attachment') {
        document.getElementById('deliveryAttachmentContent').style.display = 'block';
    }
}
// 初始化交流记录
function initCommunicationHistory() {
    const messageList = document.getElementById('messageList');
    if (!messageList) return;
    
    // 模拟消息数据
    const messages = [
        {
            time: '2024-01-19 16:55',
            sender: '系统',
            text: '订单已创建，等待卖家接单'
        },
        {
            time: '2024-01-19 17:10',
            sender: '卖家',
            text: '您好，我已收到您的订单，正在处理中'
        },
        {
            time: '2024-01-19 17:15',
            sender: '买家',
            text: '好的，谢谢，请问大概什么时候能完成？'
        }
    ];
    
    // 清空消息列表
    messageList.innerHTML = '';
    
    // 添加消息到列表
    messages.forEach(message => {
        const messageItem = document.createElement('div');
        messageItem.className = 'message-item';
        messageItem.innerHTML = `
            <div class="message-time">${message.time}</div>
            <div class="message-content">
                <div class="message-sender">${message.sender}</div>
                <div class="message-text">${message.text}</div>
            </div>
        `;
        messageList.appendChild(messageItem);
    });
}

// 获取文件图标
function getFileIcon(type) {
    const iconMap = {
        'image': 'fa-image',
        'document': 'fa-file-alt',
        'pdf': 'fa-file-pdf',
        'zip': 'fa-file-archive'
    };
    return iconMap[type] || 'fa-file';
}

// 切换交流记录显示状态
function toggleHistory() {
    const historyContent = document.getElementById('historyContent');
    const historyIcon = document.getElementById('historyIcon');
    
    if (historyContent.style.display === 'none') {
        historyContent.style.display = 'block';
        historyIcon.classList.remove('fa-chevron-down');
        historyIcon.classList.add('fa-chevron-up');
        
        // 初始化交流记录
        initCommunicationHistory();
    } else {
        historyContent.style.display = 'none';
        historyIcon.classList.remove('fa-chevron-up');
        historyIcon.classList.add('fa-chevron-down');
    }
}

// 复制文本
function copyText() {
    const text = document.querySelector('.text-content p')?.textContent;
    if (text) {
        navigator.clipboard.writeText(text).then(() => {
            alert('文本已复制');
        });
    }
}

// 查看完整提交内容
function viewFullSubmission() {
    alert('查看完整提交内容功能尚未实现');
}

// 查看完整交付内容
function viewFullDelivery() {
    alert('查看完整交付内容功能尚未实现');
}

// 下载文件
function downloadFile(fileName) {
    // 在实际应用中，这里应该调用API下载文件
    alert(`下载文件：${fileName}`);
}

// 显示材料问题对话框
function showMaterialIssueDialog() {
    // 在实际应用中，这里应该显示对话框
    alert('显示材料问题对话框');
}

// 接受订单
function acceptOrder() {
    // 在实际应用中，这里应该调用API接受订单
    alert('订单已接受');
    // 刷新页面
    location.reload();
}

// 联系买家
function contactBuyer() {
    window.location.href = '../../../tabs/sellerscreens/chat/seller_chat.html';
}

// 更新底部操作按钮
function updateActionButtons(currentStep) {
    const orderActions = document.getElementById('orderActions');
    if (!orderActions) return;
    
    // 清空现有按钮
    orderActions.innerHTML = '';
    
    // 根据当前步骤添加不同的按钮
    if (currentStep === 1 || currentStep === 2) {
        // 等待接单阶段
        const contactButton = document.createElement('button');
        contactButton.className = 'action-button secondary';
        contactButton.textContent = '联系买家';
        contactButton.onclick = contactBuyer;
        orderActions.appendChild(contactButton);
        
        const materialButton = document.createElement('button');
        materialButton.className = 'action-button secondary';
        materialButton.textContent = '材料有问题？';
        materialButton.onclick = showMaterialIssueDialog;
        orderActions.appendChild(materialButton);
        
        const acceptButton = document.createElement('button');
        acceptButton.className = 'action-button primary';
        acceptButton.textContent = '同意接单';
        acceptButton.onclick = acceptOrder;
        orderActions.appendChild(acceptButton);
    } else if (currentStep === 3) {
        // 已接单阶段
        const contactButton = document.createElement('button');
        contactButton.className = 'action-button secondary';
        contactButton.textContent = '联系买家';
        contactButton.onclick = contactBuyer;
        orderActions.appendChild(contactButton);
        
        const deliverButton = document.createElement('button');
        deliverButton.className = 'action-button primary';
        deliverButton.textContent = '交付';
        deliverButton.onclick = deliverOrder;
        orderActions.appendChild(deliverButton);
    } else if (currentStep >= 4) {
        // 交付后阶段
        const contactButton = document.createElement('button');
        contactButton.className = 'action-button secondary';
        contactButton.textContent = '联系买家';
        contactButton.onclick = contactBuyer;
        orderActions.appendChild(contactButton);
    }
}

// 交付订单
function deliverOrder() {
    // 在实际应用中，这里应该跳转到交付页面
    window.location.href = 'seller_order_deliver.html';
}