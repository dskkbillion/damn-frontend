// AI对话问答页面脚本

// 模拟AI回答数据
const aiResponses = {
    '如何改造家里的一个角落？': '改造家里的一个角落可以从以下几个方面考虑：\n1. 确定角落的用途，如阅读区、工作区或休闲区\n2. 选择合适的家具，如小书架、单人沙发或工作台\n3. 添加适当的照明，如落地灯或壁灯\n4. 搭配装饰品，如绿植、挂画或抱枕\n5. 考虑收纳需求，如增加储物盒或挂钩',
    '我想打官司，该做什么？': '打官司需要以下步骤：\n1. 收集相关证据和材料\n2. 咨询专业律师，了解案件可行性\n3. 确定诉讼请求和法律依据\n4. 准备诉讼材料，包括起诉状等\n5. 向有管辖权的法院提交诉讼材料\n6. 按照法院通知参加庭审\n7. 等待法院判决\n\n建议您先咨询专业律师，获取针对您具体情况的建议。',
    '车钥匙丢了怎么办？': '1.立即通知各相关部门，并尽快联系4S店或专业汽车锁汽修厂咨询。\n2.携带身份证、行驶证等证明材料，确保身份的验证与交接，避免安全隐患。',
    '你好': '你好，我是小帮手，有什么可以帮助你的吗？'
};

// 模拟推荐服务数据
const recommendedServices = [
    {
        id: '1',
        title: '修改诗画框',
        image: 'https://via.placeholder.com/150',
        rating: '5.0',
        reviews: '0',
        price: '1.00'
    },
    {
        id: '2',
        title: '已发布（重该通过）改名',
        image: 'https://via.placeholder.com/150',
        rating: '5.0',
        reviews: '0',
        price: '1.00'
    }
];

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 初始化输入框
    const messageInput = document.getElementById('messageInput');
    messageInput.addEventListener('keypress', function(event) {
        if (event.key === 'Enter') {
            sendMessage();
        }
    });
    
    // 显示推荐服务
    showRecommendedServices();
});

// 显示历史记录页面
function showHistory() {
    window.location.href = 'ai_docs_history.html';
}

// 开始新的聊天
function newChat() {
    window.location.href = 'ai_docs_input.html';
}

// 显示推荐服务
function showRecommendedServices() {
    const servicesContainer = document.querySelector('.services-container');
    
    // 清空服务容器
    servicesContainer.innerHTML = '';
    
    // 添加服务项目
    recommendedServices.forEach(service => {
        const serviceItem = document.createElement('div');
        serviceItem.className = 'service-item';
        
        serviceItem.innerHTML = `
            <div class="service-image">
                <img src="${service.image}" alt="${service.title}">
            </div>
            <div class="service-rating">
                <i class="fas fa-star"></i>
                <span>${service.rating} (${service.reviews})</span>
            </div>
            <div class="service-title">${service.title}</div>
            <div class="service-price">¥${service.price}</div>
            <button class="service-button" onclick="viewService('${service.id}')">让TA看看</button>
        `;
        
        servicesContainer.appendChild(serviceItem);
    });
}

// 查看服务详情
function viewService(serviceId) {
    // 在实际应用中，这里会跳转到服务详情页面
    // 这里简单模拟跳转
    alert(`查看服务详情：${serviceId}`);
}

// 发送消息
function sendMessage() {
    const messageInput = document.getElementById('messageInput');
    const message = messageInput.value.trim();
    
    if (message) {
        // 清空输入框
        messageInput.value = '';
        
        // 添加用户消息
        addUserMessage(message);
        
        // 模拟AI思考时间
        setTimeout(() => {
            // 添加AI回答
            addAiMessage(message);
        }, 1000);
    }
}

// 添加用户消息
function addUserMessage(message) {
    const chatContainer = document.getElementById('chatContainer');
    
    const userMessage = document.createElement('div');
    userMessage.className = 'message user-message';
    
    userMessage.innerHTML = `
        <div class="message-content">
            <div class="message-text">${message}</div>
        </div>
        <div class="message-avatar">
            <img src="https://via.placeholder.com/40" alt="用户头像">
        </div>
    `;
    
    chatContainer.appendChild(userMessage);
    
    // 滚动到底部
    scrollToBottom();
}

// 添加AI回答
function addAiMessage(question) {
    const chatContainer = document.getElementById('chatContainer');
    
    // 获取AI回答
    let answer = aiResponses[question] || '我不太理解您的问题，能否换个方式描述？';
    
    const aiMessage = document.createElement('div');
    aiMessage.className = 'message ai-message';
    
    aiMessage.innerHTML = `
        <div class="message-avatar">
            <i class="fas fa-robot"></i>
        </div>
        <div class="message-content">
            <div class="message-text">${answer.replace(/\n/g, '<br>')}</div>
        </div>
    `;
    
    chatContainer.appendChild(aiMessage);
    
    // 滚动到底部
    scrollToBottom();
}

// 切换语音输入
function toggleVoiceInput() {
    // 这里应该实现语音输入功能
    // 简单模拟一下
    alert('语音输入功能暂未实现');
}

// 滚动到底部
function scrollToBottom() {
    const chatContainer = document.getElementById('chatContainer');
    chatContainer.scrollTop = chatContainer.scrollHeight;
}