// 卖家端重新交付订单详情页面脚本

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
            text: '买家已支付订单'
        },
        {
            time: '2024-03-23 16:50',
            sender: '买家',
            text: '我需要一份关于智能家居产品的宣传文案，重点突出产品的便捷性和智能化特点。文案长度约300字，需要包含以下关键词：智能控制、远程操作、节能环保。'
        },
        {
            time: '2024-03-23 17:30',
            sender: '系统',
            text: '卖家已接单'
        },
        {
            time: '2024-03-24 10:15',
            sender: '卖家',
            text: '您好，我已完成文案，请查收。'
        },
        {
            time: '2024-03-24 11:30',
            sender: '买家',
            text: '您好，我对文案有一些修改意见，希望能更突出产品的智能控制和节能环保特性，并增加一些具体的使用场景描述。'
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

// 切换交付内容标签页
function switchDeliveryTab(tab, tabName) {
    // 移除所有标签页的active类
    document.querySelectorAll('.my-delivery .tab').forEach(t => {
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

// 重新交付订单
function redeliverOrder() {
    const deliveryText = document.getElementById('deliveryText').value.trim();
    
    if (!deliveryText) {
        alert('请填写交付内容');
        return;
    }
    
    // 在实际应用中，这里应该调用API提交交付内容
    alert('您的内容已重新交付，等待买家确认');
    
    // 跳转到订单详情页面
    window.location.href = 'seller_order_detail.html';
}