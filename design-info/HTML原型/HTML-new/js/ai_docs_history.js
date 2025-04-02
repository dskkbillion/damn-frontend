// AI对话历史记录页面脚本

// 模拟历史记录数据
const historyData = [
    { id: '1', content: '车钥匙丢了怎么办？', date: '3/16/2025' },
    { id: '2', content: '车钥匙丢了怎么办？', date: '3/16/2025' },
    { id: '3', content: '车钥匙丢了怎么办？', date: '3/16/2025' },
    { id: '4', content: '车钥匙丢了怎么办？', date: '3/16/2025' },
    { id: '5', content: '我想打官司，该做什么？', date: '3/16/2025' },
    { id: '6', content: '如何改造家里的一个角落？', date: '3/16/2025' },
    { id: '7', content: '车钥匙丢了怎么办？', date: '3/16/2025' },
    { id: '8', content: '你好', date: '3/16/2025' }
];

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 初始化搜索框
    const searchInput = document.querySelector('.search-box input');
    searchInput.addEventListener('input', function() {
        filterHistory(this.value);
    });
    
    // 渲染历史记录列表
    renderHistoryList();
});

// 渲染历史记录列表
function renderHistoryList(filter = '') {
    const historyList = document.getElementById('historyList');
    historyList.innerHTML = '';
    
    // 过滤历史记录
    const filteredHistory = historyData.filter(item => 
        item.content.toLowerCase().includes(filter.toLowerCase())
    );
    
    // 如果没有匹配的记录
    if (filteredHistory.length === 0) {
        historyList.innerHTML = `
            <div class="no-history">
                <div class="no-history-text">没有找到匹配的历史记录</div>
            </div>
        `;
        return;
    }
    
    // 渲染历史记录
    filteredHistory.forEach(item => {
        const historyItem = document.createElement('div');
        historyItem.className = 'history-item';
        historyItem.setAttribute('onclick', `viewHistory('${item.id}')`);
        
        historyItem.innerHTML = `
            <div class="history-content">${item.content}</div>
            <div class="history-date">${item.date}</div>
        `;
        
        historyList.appendChild(historyItem);
    });
}

// 过滤历史记录
function filterHistory(keyword) {
    renderHistoryList(keyword);
}

// 查看历史记录详情
function viewHistory(id) {
    // 在实际应用中，这里会跳转到对话详情页面
    // 这里简单模拟跳转
    window.location.href = `ai_docs_input.html?history=${id}`;
}

// 添加滑动手势支持
let startX, startY;
const historyList = document.getElementById('historyList');

historyList.addEventListener('touchstart', function(e) {
    startX = e.touches[0].clientX;
    startY = e.touches[0].clientY;
}, false);

historyList.addEventListener('touchmove', function(e) {
    if (!startX || !startY) return;
    
    const diffX = startX - e.touches[0].clientX;
    const diffY = startY - e.touches[0].clientY;
    
    // 如果水平滑动距离大于垂直滑动距离，且水平滑动距离大于50px
    if (Math.abs(diffX) > Math.abs(diffY) && Math.abs(diffX) > 50) {
        // 这里可以添加左右滑动的逻辑，例如显示删除按钮等
        // 在这个简单实现中，我们不做具体操作
    }
    
    startX = null;
    startY = null;
}, false);