// 搜索结果页面脚本

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 获取URL参数中的搜索关键词
    const urlParams = new URLSearchParams(window.location.search);
    const keyword = urlParams.get('keyword');
    
    // 设置搜索框的值
    if (keyword) {
        document.getElementById('searchInput').value = keyword;
        document.getElementById('clearSearch').style.display = 'block';
    }
    
    // 监听搜索框输入事件
    const searchInput = document.getElementById('searchInput');
    searchInput.addEventListener('input', function() {
        toggleClearButton();
    });
    
    // 监听搜索框回车事件
    searchInput.addEventListener('keypress', function(event) {
        if (event.key === 'Enter') {
            searchAgain();
        }
    });
    
    // 更新结果数量
    updateResultCount();
});

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

// 再次搜索
function searchAgain() {
    const searchInput = document.getElementById('searchInput');
    const keyword = searchInput.value.trim();
    
    if (keyword) {
        // 重新加载页面，带上新的搜索关键词
        window.location.href = `search_result.html?keyword=${encodeURIComponent(keyword)}`;
    }
}

// 筛选结果
function filterResults(filter) {
    // 移除所有筛选项的active类
    document.querySelectorAll('.filter-item').forEach(item => {
        item.classList.remove('active');
    });
    
    // 给当前点击的筛选项添加active类
    document.querySelector(`.filter-item[data-filter="${filter}"]`).classList.add('active');
    
    // 模拟筛选结果
    // 在实际应用中，这里会根据筛选条件重新请求数据或筛选现有数据
    
    // 更新结果数量
    let count;
    switch(filter) {
        case 'all':
            count = 24;
            break;
        case 'design':
            count = 8;
            break;
        case 'writing':
            count = 5;
            break;
        case 'translation':
            count = 3;
            break;
        case 'programming':
            count = 4;
            break;
        case 'video':
            count = 2;
            break;
        case 'audio':
            count = 2;
            break;
        default:
            count = 24;
    }
    
    document.getElementById('resultCount').textContent = count;
    
    // 模拟加载中效果
    const searchResults = document.getElementById('searchResults');
    searchResults.style.opacity = '0.5';
    
    setTimeout(() => {
        searchResults.style.opacity = '1';
    }, 300);
}

// 更新结果数量
function updateResultCount() {
    const resultItems = document.querySelectorAll('.result-item');
    document.getElementById('resultCount').textContent = resultItems.length;
}

// 查看服务详情
function viewService(serviceId) {
    // 在实际应用中，这里会跳转到服务详情页面
    window.location.href = `item_homepage.html?id=${serviceId}`;
}

// 加载更多结果
function loadMore() {
    // 模拟加载更多结果
    const searchResults = document.getElementById('searchResults');
    const loadMoreButton = document.querySelector('.load-more');
    
    // 显示加载中状态
    loadMoreButton.innerHTML = '<span>加载中...</span>';
    
    // 模拟网络请求延迟
    setTimeout(() => {
        // 添加新的结果项
        for (let i = 0; i < 3; i++) {
            const resultItem = document.createElement('div');
            resultItem.className = 'result-item';
            resultItem.setAttribute('onclick', `viewService('100${6 + i}')`);
            
            resultItem.innerHTML = `
                <div class="result-image">
                    <img src="https://via.placeholder.com/100" alt="服务图片">
                </div>
                <div class="result-details">
                    <div class="result-title">新增服务 ${i + 1}</div>
                    <div class="result-description">这是一个新加载的服务项目描述，展示了加载更多功能</div>
                    <div class="result-seller">
                        <span class="seller-name">服务提供商 ${i + 1}</span>
                        <span class="seller-rating">
                            <i class="fas fa-star"></i>
                            <span>4.${7 + i}</span>
                        </span>
                    </div>
                    <div class="result-price">¥${199 + i * 50}起</div>
                </div>
            `;
            
            searchResults.appendChild(resultItem);
        }
        
        // 恢复加载按钮状态
        loadMoreButton.innerHTML = '<span>加载更多</span><i class="fas fa-chevron-down"></i>';
        
        // 更新结果数量
        updateResultCount();
        
        // 如果结果数量达到一定值，隐藏加载更多按钮
        if (document.querySelectorAll('.result-item').length >= 10) {
            loadMoreButton.style.display = 'none';
        }
    }, 1000);
}