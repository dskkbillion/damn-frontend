// 订单已支付页面脚本

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 初始化进度条
    updateProgressBar();
    
    // 初始化交流记录
    initCommunicationHistory();
    
    // 初始化文件上传
    initFileUpload();
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
            time: '2024-03-23 16:45',
            sender: '系统',
            text: '订单已创建'
        },
        {
            time: '2024-03-23 16:47',
            sender: '系统',
            text: '订单支付成功，请提交您的具体要求'
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

// 初始化文件上传
function initFileUpload() {
    const fileUpload = document.getElementById('fileUpload');
    if (!fileUpload) return;
    
    fileUpload.addEventListener('change', function(e) {
        const files = e.target.files;
        if (!files || files.length === 0) return;
        
        const uploadedFiles = document.getElementById('uploadedFiles');
        
        // 处理每个文件
        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            
            // 创建文件项
            const fileItem = document.createElement('div');
            fileItem.className = 'file-item';
            
            // 根据文件类型设置图标
            let iconClass = 'fa-file';
            if (file.type.includes('image')) {
                iconClass = 'fa-image';
            } else if (file.type.includes('pdf')) {
                iconClass = 'fa-file-pdf';
            } else if (file.type.includes('word')) {
                iconClass = 'fa-file-word';
            } else if (file.type.includes('excel') || file.type.includes('sheet')) {
                iconClass = 'fa-file-excel';
            }
            
            // 设置文件项内容
            fileItem.innerHTML = `
                <i class="fas ${iconClass}"></i>
                <span>${file.name}</span>
                <i class="fas fa-times" onclick="removeFile(this)"></i>
            `;
            
            // 添加到上传文件列表
            uploadedFiles.appendChild(fileItem);
        }
        
        // 清空文件输入，以便可以再次选择相同的文件
        fileUpload.value = '';
    });
}

// 触发文件上传
function triggerFileUpload() {
    const fileUpload = document.getElementById('fileUpload');
    if (fileUpload) {
        fileUpload.click();
    }
}

// 移除文件
function removeFile(element) {
    const fileItem = element.parentElement;
    if (fileItem) {
        fileItem.remove();
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

// 联系卖家
function contactSeller() {
    window.location.href = '../chat/chatroom.html?seller=true';
}

// 取消订单
function cancelOrder() {
    if (confirm('确定要取消订单吗？取消后将无法恢复。')) {
        alert('订单已取消');
        window.location.href = 'orders.html';
    }
}

// 提交要求
function submitRequirements() {
    const requirementText = document.getElementById('requirementText').value.trim();
    
    if (!requirementText) {
        alert('请填写您的需求详情');
        return;
    }
    
    // 在实际应用中，这里应该调用API提交要求
    alert('您的要求已提交，等待卖家接单');
    
    // 跳转到订单进行中页面
    window.location.href = 'order_in_progress.html';
}