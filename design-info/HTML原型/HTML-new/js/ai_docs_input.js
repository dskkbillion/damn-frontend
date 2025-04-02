// AI对话输入页面脚本

// 模拟AI回答数据
const aiResponses = {
    '如何改造家里的一个角落？': '改造家里的一个角落可以从以下几个方面考虑：\n1. 确定角落的用途，如阅读区、工作区或休闲区\n2. 选择合适的家具，如小书架、单人沙发或工作台\n3. 添加适当的照明，如落地灯或壁灯\n4. 搭配装饰品，如绿植、挂画或抱枕\n5. 考虑收纳需求，如增加储物盒或挂钩',
    '我想打官司，该做什么？': '打官司需要以下步骤：\n1. 收集相关证据和材料\n2. 咨询专业律师，了解案件可行性\n3. 确定诉讼请求和法律依据\n4. 准备诉讼材料，包括起诉状等\n5. 向有管辖权的法院提交诉讼材料\n6. 按照法院通知参加庭审\n7. 等待法院判决\n\n建议您先咨询专业律师，获取针对您具体情况的建议。',
    '车钥匙丢了怎么办？': '1.立即通知各相关部门，并尽快联系4S店或专业汽车锁汽修厂咨询。\n2.携带身份证、行驶证等证明材料，确保身份的验证与交接，避免安全隐患。',
    '你好': '你好，我是小帮手，有什么可以帮助你的吗？'
};

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 初始化输入框
    const messageInput = document.getElementById('messageInput');
    messageInput.addEventListener('keypress', function(event) {
        if (event.key === 'Enter') {
            sendMessage();
        }
    });
    
    // 检查URL参数，如果有历史记录ID，则加载对应的历史记录
    const urlParams = new URLSearchParams(window.location.search);
    const historyId = urlParams.get('history');
    if (historyId) {
        loadHistory(historyId);
    }
});

// 显示历史记录页面
function showHistory() {
    window.location.href = 'ai_docs_history.html';
}

// 开始新的聊天
function newChat() {
    // 清空聊天区域，只保留AI欢迎消息和快捷问题
    const chatContainer = document.getElementById('chatContainer');
    const aiWelcome = chatContainer.querySelector('.ai-message');
    const quickQuestions = chatContainer.querySelector('.quick-questions');
    
    chatContainer.innerHTML = '';
    chatContainer.appendChild(aiWelcome);
    chatContainer.appendChild(quickQuestions);
    
    // 隐藏用户问题和AI回答
    document.getElementById('userQuestion').style.display = 'none';
    document.getElementById('aiAnswer').style.display = 'none';
}

// 加载历史记录
function loadHistory(historyId) {
    // 这里应该从服务器加载历史记录
    // 这里简单模拟一下，使用预设的问题和回答
    
    let question = '';
    switch(historyId) {
        case '1':
        case '2':
        case '3':
        case '4':
        case '7':
            question = '车钥匙丢了怎么办？';
            break;
        case '5':
            question = '我想打官司，该做什么？';
            break;
        case '6':
            question = '如何改造家里的一个角落？';
            break;
        case '8':
            question = '你好';
            break;
        default:
            question = '你好';
    }
    
    // 显示用户问题
    askQuestion(question);
}

// 提问问题
function askQuestion(question) {
    // 隐藏快捷问题
    document.querySelector('.quick-questions').style.display = 'none';
    
    // 显示用户问题
    const userQuestion = document.getElementById('userQuestion');
    const userQuestionText = document.getElementById('userQuestionText');
    userQuestionText.textContent = question;
    userQuestion.style.display = 'flex';
    
    // 滚动到底部
    scrollToBottom();
    
    // 模拟AI思考时间
    setTimeout(() => {
        // 显示AI回答
        showAiAnswer(question);
    }, 1000);
}

// 显示AI回答
function showAiAnswer(question) {
    const aiAnswer = document.getElementById('aiAnswer');
    const aiAnswerText = document.getElementById('aiAnswerText');
    
    // 获取AI回答
    let answer = aiResponses[question] || '我不太理解您的问题，能否换个方式描述？';
    
    // 显示AI回答
    aiAnswerText.textContent = answer;
    aiAnswer.style.display = 'flex';
    
    // 滚动到底部
    scrollToBottom();
}

// 发送消息
function sendMessage() {
    const messageInput = document.getElementById('messageInput');
    const message = messageInput.value.trim();
    
    if (message) {
        // 清空输入框
        messageInput.value = '';
        
        // 提问问题
        askQuestion(message);
    }
}

// 切换语音输入
function toggleVoiceInput() {
    // 这里应该实现语音输入功能
    // 简单模拟一下
    alert('语音输入功能暂未实现');
}

// 打开相机
function openCamera() {
    // 这里应该实现打开相机功能
    // 简单模拟一下
    alert('相机功能暂未实现');
}

// 打开相册
function openGallery() {
    // 这里应该实现打开相册功能
    // 简单模拟一下
    alert('相册功能暂未实现');
}

// 滚动到底部
function scrollToBottom() {
    const chatContainer = document.getElementById('chatContainer');
    chatContainer.scrollTop = chatContainer.scrollHeight;
}