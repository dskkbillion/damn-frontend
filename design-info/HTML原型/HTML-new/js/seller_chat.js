// 卖家聊天页面脚本

// 显示选项菜单
function showOptions() {
    document.getElementById('optionsMenu').style.display = 'block';
    document.getElementById('overlay').style.display = 'block';
}

// 隐藏选项菜单
function hideOptionsMenu() {
    document.getElementById('optionsMenu').style.display = 'none';
    document.getElementById('overlay').style.display = 'none';
}

// 标记所有消息为已读
function markAllAsRead() {
    // 移除所有未读标记
    const unreadItems = document.querySelectorAll('.chat-item.unread');
    unreadItems.forEach(item => {
        item.classList.remove('unread');
    });
    
    // 移除所有消息角标
    const badges = document.querySelectorAll('.chat-badge');
    badges.forEach(badge => {
        badge.style.display = 'none';
    });
    
    // 隐藏选项菜单
    hideOptionsMenu();
    
    // 显示操作成功提示
    alert('已将所有消息标记为已读');
}

// 跳转到自动回复设置页面
function setAutoReply() {
    window.location.href = '../../profile/notification/seller_auto_reply.html';
}