// 卖家端订单待确认页面脚本

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
            time: '2024-03-23 16:55',
            sender: '系统',
            text: '买家已提交要求'
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

// 复制文本
function copyText() {
    const text = document.querySelector('.text-content p')?.textContent;
    if (text) {
        navigator.clipboard.writeText(text).then(() => {
            alert('文本已复制');
        });
    }
}

// 联系买家
function contactBuyer() {
    window.location.href = '../../../tabs/sellerscreens/chat/seller_chat.html';
}

// 显示材料问题对话框
function showMaterialIssueDialog() {
    // 创建弹窗元素
    const dialog = document.createElement('div');
    dialog.style.position = 'fixed';
    dialog.style.left = '50%';
    dialog.style.top = '50%';
    dialog.style.transform = 'translate(-50%, -50%)';
    dialog.style.backgroundColor = 'white';
    dialog.style.padding = '20px';
    dialog.style.borderRadius = '12px';
    dialog.style.boxShadow = '0 4px 12px rgba(0, 0, 0, 0.15)';
    dialog.style.zIndex = '100';
    dialog.style.textAlign = 'center';
    dialog.style.width = '80%';
    dialog.style.maxWidth = '300px';

    dialog.innerHTML = `
        <h3 style="margin-top: 0; margin-bottom: 15px; font-size: 16px; font-weight: 600;">材料有问题？</h3>
        <p style="font-size: 14px; color: #666; margin-bottom: 20px;">请选择您要进行的操作：</p>
        <button class="action-button secondary" style="width: 100%; margin-bottom: 10px;" onclick="requestMaterialResubmit()">请求买家补充材料</button>
        <button class="action-button error" style="width: 100%; background-color: #f44336; color: white;" onclick="rejectOrderWithReason()">拒绝接单</button>
        <button class="action-button" style="width: 100%; margin-top: 10px; background-color: #eee; color: #333;" onclick="closeDialog()">取消</button>
    `;

    // 添加弹窗到页面
    document.body.appendChild(dialog);

    // 添加遮罩层
    const overlay = document.createElement('div');
    overlay.style.position = 'fixed';
    overlay.style.left = '0';
    overlay.style.top = '0';
    overlay.style.width = '100%';
    overlay.style.height = '100%';
    overlay.style.backgroundColor = 'rgba(0, 0, 0, 0.5)';
    overlay.style.zIndex = '99';
    overlay.id = 'materialIssueOverlay';
    overlay.onclick = closeDialog; // 点击遮罩层关闭弹窗
    document.body.appendChild(overlay);
}

// 关闭弹窗
function closeDialog() {
    const dialog = document.querySelector('div[style*="position: fixed"]');
    const overlay = document.getElementById('materialIssueOverlay');
    if (dialog) {
        document.body.removeChild(dialog);
    }
    if (overlay) {
        document.body.removeChild(overlay);
    }
}

// 请求买家补充材料
function requestMaterialResubmit() {
    closeDialog();
    // 在实际应用中，这里应该调用API请求补充材料
    alert('已向买家发送补充材料请求');
    // 可以跳转到特定页面或刷新当前页面
}

// 拒绝接单（带原因）
function rejectOrderWithReason() {
    closeDialog();
    // 在实际应用中，这里应该显示拒绝原因输入框，然后调用API拒绝订单
    const reason = prompt("请输入拒绝接单的原因：");
    if (reason !== null) { // 用户点击了确定
        alert(`已拒绝接单，原因：${reason}`);
        // 刷新订单列表或跳转
        const activeTab = document.querySelector('.tab-item.active');
        const status = activeTab ? activeTab.getAttribute('data-status') : 'all';
        // 假设有 loadOrders 函数用于刷新列表
        if (typeof loadOrders === 'function') {
            loadOrders(status);
        } else {
            // 如果当前页面没有 loadOrders 函数，尝试返回列表页
            window.location.href = 'seller_orders.html';
        }
    }
}

// 接受订单
function acceptOrder() {
    if (confirm('确定要接受此订单吗？接单后需按时完成交付。')) {
        alert('已接受订单');
        window.location.href = 'seller_order_in_progress.html';
    }
}