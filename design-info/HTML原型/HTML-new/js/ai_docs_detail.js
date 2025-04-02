// AI对话详情页面脚本

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 初始化页面
    initPage();
});

// 初始化页面
function initPage() {
    // 隐藏选项菜单和遮罩层
    document.getElementById('optionsMenu').style.display = 'none';
    document.getElementById('overlay').style.display = 'none';
}

// 显示更多选项菜单
function showMoreOptions() {
    document.getElementById('optionsMenu').style.display = 'block';
    document.getElementById('overlay').style.display = 'block';
}

// 隐藏选项菜单
function hideOptionsMenu() {
    document.getElementById('optionsMenu').style.display = 'none';
    document.getElementById('overlay').style.display = 'none';
}

// 切换收藏状态
function toggleFavorite() {
    const favoriteIcon = document.getElementById('favoriteIcon');
    if (favoriteIcon.classList.contains('far')) {
        // 添加收藏
        favoriteIcon.classList.remove('far');
        favoriteIcon.classList.add('fas');
        showToast('已添加到收藏');
    } else {
        // 取消收藏
        favoriteIcon.classList.remove('fas');
        favoriteIcon.classList.add('far');
        showToast('已取消收藏');
    }
}

// 分享对话
function shareConversation() {
    // 在实际应用中，这里会调用系统分享API
    // 在这个HTML原型中，我们只是显示一个提示
    showToast('分享功能尚未实现');
}

// 删除对话
function deleteConversation() {
    // 显示确认对话框
    if (confirm('确定要删除这个对话吗？此操作无法撤销。')) {
        // 在实际应用中，这里会发送删除请求到服务器
        // 在这个HTML原型中，我们只是显示一个提示并返回历史记录页面
        showToast('对话已删除');
        setTimeout(() => {
            window.location.href = 'ai_docs_history.html';
        }, 1000);
    } else {
        // 用户取消删除，隐藏选项菜单
        hideOptionsMenu();
    }
}

// 报告问题
function reportIssue() {
    // 在实际应用中，这里会显示问题报告表单
    // 在这个HTML原型中，我们只是显示一个提示
    hideOptionsMenu();
    showToast('问题报告功能尚未实现');
}

// 查看服务详情
function viewService(serviceId) {
    // 在实际应用中，这里会跳转到服务详情页面
    // 在这个HTML原型中，我们只是显示一个提示
    showToast(`查看服务 ${serviceId} 详情`);
}

// 查看相关对话
function viewConversation(conversationId) {
    // 在实际应用中，这里会跳转到对话详情页面
    // 在这个HTML原型中，我们只是显示一个提示
    showToast(`查看对话 ${conversationId} 详情`);
}

// 继续对话
function continueConversation() {
    // 跳转到AI对话页面
    window.location.href = 'ai_docs.html';
}

// 创建新对话
function createNewConversation() {
    // 跳转到AI对话页面
    window.location.href = 'ai_docs.html';
}

// 显示提示消息
function showToast(message) {
    // 创建提示元素
    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.textContent = message;
    
    // 添加样式
    toast.style.position = 'fixed';
    toast.style.bottom = '100px';
    toast.style.left = '50%';
    toast.style.transform = 'translateX(-50%)';
    toast.style.backgroundColor = 'rgba(0, 0, 0, 0.7)';
    toast.style.color = 'white';
    toast.style.padding = '10px 16px';
    toast.style.borderRadius = '4px';
    toast.style.zIndex = '1000';
    
    // 添加到页面
    document.body.appendChild(toast);
    
    // 2秒后移除
    setTimeout(() => {
        document.body.removeChild(toast);
    }, 2000);
}