// 订单待确认页面脚本

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
    if (!messageList) return;
    
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
        },
        {
            time: '2024-03-24 10:15',
            sender: '卖家',
            text: '您好，我已完成您的订单，请查收。'
        }
    ];
    
    // 添加消息到列表
    messages.forEach(message => {
        let messageHTML = `
            <div class="message-item">
                <div class="message-time">${message.time}</div>
                <div class="message-content">
                    <div class="message-sender">${message.sender}</div>
                    <div class="message-text">${message.text}</div>
                </div>
            </div>
        `;
        
        // 创建临时元素来转换HTML字符串
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = messageHTML;
        
        // 将消息添加到列表
        messageList.appendChild(tempDiv.firstElementChild);
    });
}

// 根据订单状态更新UI
function updateUIByOrderStatus() {
    // 当前是待确认状态，不需要特殊处理
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
    window.location.href = '../chat/chatroom.html?seller=true';
}

// 申请修改
function requestRevision() {
    if (confirm('确定要申请修改吗？')) {
        alert('已申请修改，等待卖家回应');
    }
}

// 确认收货
function confirmDelivery() {
    if (confirm('确认收货后，订单将进入评价阶段。确定要确认收货吗？')) {
        alert('已确认收货');
        window.location.href = 'order_evaluation.html';
    }
}