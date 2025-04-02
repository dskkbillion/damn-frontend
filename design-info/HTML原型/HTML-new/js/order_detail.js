// 订单详情页面脚本

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 初始化进度条
    updateProgressBar();
    
    // 初始化交流记录
    initCommunicationHistory();
    
    // 根据订单状态更新UI
    updateUIByOrderStatus();
});

// 更新进度条
function updateProgressBar() {
    const steps = document.querySelectorAll('.step');
    const progressLineActive = document.getElementById('progressLineActive');
    
    // 计算当前进度
    let completedSteps = 0;
    let totalSteps = steps.length;
    
    steps.forEach(step => {
        if (step.classList.contains('completed')) {
            completedSteps++;
        }
    });
    
    // 如果有活动步骤，也计入进度
    const activeStep = document.querySelector('.step.active');
    if (activeStep) {
        const activeStepIndex = Array.from(steps).indexOf(activeStep);
        const progressPercentage = (activeStepIndex / (totalSteps - 1)) * 100;
        progressLineActive.style.width = `${progressPercentage}%`;
    } else {
        // 如果没有活动步骤，只显示已完成步骤的进度
        const progressPercentage = (completedSteps / (totalSteps - 1)) * 100;
        progressLineActive.style.width = `${progressPercentage}%`;
    }
}

// 初始化交流记录
function initCommunicationHistory() {
    const messageList = document.getElementById('messageList');
    const messageTemplate = document.getElementById('messageTemplate').innerHTML;
    
    // 模拟消息数据
    const messages = [
        {
            time: '2024-03-23 16:50',
            sender: '系统',
            text: '订单已创建，等待卖家接单'
        },
        {
            time: '2024-03-23 17:15',
            sender: '买家',
            text: '请问大概什么时候能完成？'
        },
        {
            time: '2024-03-23 17:20',
            sender: '卖家',
            text: '您好，我会尽快处理您的订单，预计24小时内完成。'
        }
    ];
    
    // 添加消息到列表
    messages.forEach(message => {
        let messageHTML = messageTemplate
            .replace('{messageTime}', message.time)
            .replace('{sender}', message.sender)
            .replace('{messageText}', message.text);
        
        // 创建临时元素来转换HTML字符串
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = messageHTML;
        
        // 将消息添加到列表
        messageList.appendChild(tempDiv.firstElementChild);
    });
}

// 根据订单状态更新UI
function updateUIByOrderStatus() {
    // 获取当前订单状态（这里假设是第3步：卖家接单）
    const currentStep = 3;
    
    // 更新底部操作按钮
    updateActionButtons(currentStep);
    
    // 更新卖家交付内容的显示状态
    if (currentStep >= 4) {
        document.getElementById('sellerDelivery').style.display = 'block';
    }
}

// 更新底部操作按钮
function updateActionButtons(currentStep) {
    const orderActions = document.getElementById('orderActions');
    
    // 清空现有按钮
    orderActions.innerHTML = '';
    
    // 根据当前步骤添加不同的按钮
    if (currentStep === 3) {
        // 卖家接单阶段
        const contactButton = document.createElement('button');
        contactButton.className = 'action-button secondary';
        contactButton.textContent = '联系卖家';
        contactButton.onclick = contactSeller;
        orderActions.appendChild(contactButton);
        
        const cancelButton = document.createElement('button');
        cancelButton.className = 'action-button secondary';
        cancelButton.textContent = '取消订单';
        cancelButton.onclick = cancelOrder;
        orderActions.appendChild(cancelButton);
    } else if (currentStep === 4) {
        // 交付阶段
        const contactButton = document.createElement('button');
        contactButton.className = 'action-button secondary';
        contactButton.textContent = '联系卖家';
        contactButton.onclick = contactSeller;
        orderActions.appendChild(contactButton);
        
        const confirmButton = document.createElement('button');
        confirmButton.className = 'action-button primary';
        confirmButton.textContent = '确认收货';
        confirmButton.onclick = confirmDelivery;
        orderActions.appendChild(confirmButton);
    } else if (currentStep === 5) {
        // 确认阶段
        const evaluateButton = document.createElement('button');
        evaluateButton.className = 'action-button primary';
        evaluateButton.textContent = '评价';
        evaluateButton.onclick = evaluateOrder;
        orderActions.appendChild(evaluateButton);
        
        const afterSaleButton = document.createElement('button');
        afterSaleButton.className = 'action-button secondary';
        afterSaleButton.textContent = '申请售后';
        afterSaleButton.onclick = applyAfterSale;
        orderActions.appendChild(afterSaleButton);
    } else if (currentStep >= 6) {
        // 评价或完成阶段
        const viewEvaluationButton = document.createElement('button');
        viewEvaluationButton.className = 'action-button secondary';
        viewEvaluationButton.textContent = '查看评价';
        viewEvaluationButton.onclick = viewEvaluation;
        orderActions.appendChild(viewEvaluationButton);
        
        const afterSaleButton = document.createElement('button');
        afterSaleButton.className = 'action-button secondary';
        afterSaleButton.textContent = '申请售后';
        afterSaleButton.onclick = applyAfterSale;
        orderActions.appendChild(afterSaleButton);
    }
}

// 切换提交内容标签页
function switchSubmissionTab(tab, tabName) {
    // 移除所有标签页的active类
    document.querySelectorAll('.my-submission .tab').forEach(t => {
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

// 切换交付内容标签页
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

// 切换交流记录显示状态
function toggleHistory() {
    const historyContent = document.getElementById('historyContent');
    const historyIcon = document.getElementById('historyIcon');
    
    if (historyContent.style.display === 'none') {
        historyContent.style.display = 'block';
        historyIcon.classList.remove('fa-chevron-down');
        historyIcon.classList.add('fa-chevron-up');
    } else {
        historyContent.style.display = 'none';
        historyIcon.classList.remove('fa-chevron-up');
        historyIcon.classList.add('fa-chevron-down');
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

// 联系卖家
function contactSeller() {
    window.location.href = 'chatroom.html?seller=true';
}

// 取消订单
function cancelOrder() {
    if (confirm('确定要取消订单吗？')) {
        alert('订单已取消');
        window.location.href = 'orders.html';
    }
}

// 确认收货
function confirmDelivery() {
    if (confirm('确认收货后，订单将进入评价阶段。确定要确认收货吗？')) {
        alert('已确认收货');
        window.location.reload();
    }
}

// 评价订单
function evaluateOrder() {
    window.location.href = 'order_evaluation.html';
}

// 申请售后
function applyAfterSale() {
    window.location.href = 'order_postsale.html';
}

// 查看评价
function viewEvaluation() {
    alert('查看评价功能尚未实现');
}