// 订单搜索页面脚本

// 模拟搜索历史数据
let searchHistory = [
    '设计Logo',
    '插画定制',
    '文案撰写',
    '视频剪辑'
];

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 初始化搜索历史列表
    renderSearchHistory();
    
    // 监听搜索框输入事件
    const searchInput = document.getElementById('searchInput');
    searchInput.addEventListener('input', function() {
        toggleClearButton();
    });
    
    // 监听搜索框回车事件
    searchInput.addEventListener('keypress', function(event) {
        if (event.key === 'Enter') {
            searchOrders();
        }
    });
    
    // 初始化清除按钮状态
    toggleClearButton();
});

// 渲染搜索历史列表
function renderSearchHistory() {
    const historyList = document.getElementById('historyList');
    historyList.innerHTML = '';
    
    if (searchHistory.length === 0) {
        historyList.innerHTML = '<div class="no-history">暂无搜索历史</div>';
        return;
    }
    
    const template = document.getElementById('historyItemTemplate').innerHTML;
    
    searchHistory.forEach(keyword => {
        const historyItem = template
            .replace(/{keyword}/g, keyword);
        
        const container = document.createElement('div');
        container.innerHTML = historyItem;
        historyList.appendChild(container.firstChild);
    });
}

// 切换清除按钮显示状态
function toggleClearButton() {
    const searchInput = document.getElementById('searchInput');
    const clearButton = document.getElementById('clearSearch');
    
    if (searchInput.value) {
        clearButton.style.display = 'block';
    } else {
        clearButton.style.display = 'none';
    }
}

// 清空搜索框
function clearSearch() {
    const searchInput = document.getElementById('searchInput');
    searchInput.value = '';
    toggleClearButton();
    searchInput.focus();
}

// 设置搜索关键词
function setSearch(keyword) {
    const searchInput = document.getElementById('searchInput');
    searchInput.value = keyword;
    toggleClearButton();
    searchInput.focus();
}

// 搜索订单
function searchOrders() {
    const searchInput = document.getElementById('searchInput');
    const keyword = searchInput.value.trim();
    
    if (!keyword) {
        alert('请输入搜索关键词');
        return;
    }
    
    // 添加到搜索历史
    addToHistory(keyword);
    
    // 跳转到搜索结果页面
    window.location.href = `order_search_result.html?keyword=${encodeURIComponent(keyword)}`;
}

// 添加到搜索历史
function addToHistory(keyword) {
    // 如果已存在，则移除旧的
    const index = searchHistory.indexOf(keyword);
    if (index !== -1) {
        searchHistory.splice(index, 1);
    }
    
    // 添加到历史记录的开头
    searchHistory.unshift(keyword);
    
    // 限制历史记录数量
    if (searchHistory.length > 10) {
        searchHistory.pop();
    }
    
    // 保存到本地存储
    saveHistory();
}

// 删除单条历史记录
function deleteHistory(event, keyword) {
    // 阻止事件冒泡
    event.stopPropagation();
    
    // 从历史记录中删除
    const index = searchHistory.indexOf(keyword);
    if (index !== -1) {
        searchHistory.splice(index, 1);
    }
    
    // 保存到本地存储
    saveHistory();
    
    // 重新渲染历史记录列表
    renderSearchHistory();
}

// 清空所有历史记录
function clearHistory() {
    if (confirm('确定要清空所有搜索历史吗？')) {
        searchHistory = [];
        saveHistory();
        renderSearchHistory();
    }
}

// 保存历史记录到本地存储
function saveHistory() {
    try {
        localStorage.setItem('orderSearchHistory', JSON.stringify(searchHistory));
    } catch (e) {
        console.error('保存搜索历史失败', e);
    }
}

// 从本地存储加载历史记录
function loadHistory() {
    try {
        const history = localStorage.getItem('orderSearchHistory');
        if (history) {
            searchHistory = JSON.parse(history);
        }
    } catch (e) {
        console.error('加载搜索历史失败', e);
        searchHistory = [];
    }
}

// 页面加载时加载历史记录
loadHistory();