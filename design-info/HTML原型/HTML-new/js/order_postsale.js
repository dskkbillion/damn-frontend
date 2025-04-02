// 售后服务页面脚本

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 初始化下拉菜单状态
    document.querySelectorAll('.dropdown-menu').forEach(menu => {
        menu.classList.remove('active');
    });
    
    // 点击页面其他区域关闭下拉菜单
    document.addEventListener('click', function(event) {
        if (!event.target.closest('.select-container')) {
            document.querySelectorAll('.dropdown-menu').forEach(menu => {
                menu.classList.remove('active');
            });
        }
    });
    
    // 监听单选按钮变化
    document.querySelectorAll('input[name="refundType"]').forEach(radio => {
        radio.addEventListener('change', function() {
            updateRefundAmount();
        });
    });
    
    // 初始化退款金额
    updateRefundAmount();
});

// 切换标签页
function switchTab(tabElement) {
    // 移除所有标签的active类
    document.querySelectorAll('.tab').forEach(tab => {
        tab.classList.remove('active');
    });
    
    // 给当前点击的标签添加active类
    tabElement.classList.add('active');
    
    // 获取当前标签对应的内容ID
    const tabId = tabElement.getAttribute('data-tab');
    
    // 隐藏所有内容
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    
    // 显示当前标签对应的内容
    if (tabId === 'refund') {
        document.getElementById('refundContent').classList.add('active');
    } else if (tabId === 'platform') {
        document.getElementById('platformContent').classList.add('active');
    }
    
    // 隐藏退款详情页面
    document.getElementById('refundDetail').style.display = 'none';
}

// 切换下拉菜单
function toggleDropdown(dropdownId) {
    // 关闭所有下拉菜单
    document.querySelectorAll('.dropdown-menu').forEach(menu => {
        if (menu.id !== dropdownId) {
            menu.classList.remove('active');
        }
    });
    
    // 切换当前下拉菜单的显示状态
    const dropdown = document.getElementById(dropdownId);
    dropdown.classList.toggle('active');
}

// 选择退款原因
function selectReason(reason) {
    document.getElementById('selectedReason').textContent = reason;
    document.getElementById('reasonDropdown').classList.remove('active');
}

// 选择平台介入原因
function selectPlatformReason(reason) {
    document.getElementById('selectedPlatformReason').textContent = reason;
    document.getElementById('platformReasonDropdown').classList.remove('active');
}

// 更新退款金额
function updateRefundAmount() {
    const refundType = document.querySelector('input[name="refundType"]:checked').value;
    const orderPrice = parseFloat(document.getElementById('orderPrice').textContent);
    
    if (refundType === 'full') {
        document.getElementById('refundAmount').textContent = orderPrice.toFixed(0);
    } else {
        // 部分退款，这里可以添加部分退款的逻辑
        // 例如显示输入框让用户输入退款金额
        document.getElementById('refundAmount').textContent = (orderPrice * 0.5).toFixed(0);
    }
}

// 提交退款申请
function submitRefund() {
    const reason = document.getElementById('selectedReason').textContent;
    const description = document.querySelector('#refundContent textarea').value;
    const refundType = document.querySelector('input[name="refundType"]:checked').value;
    const refundAmount = document.getElementById('refundAmount').textContent;
    
    if (!description) {
        alert('请填写申请说明');
        return;
    }
    
    // 这里可以添加提交退款申请的逻辑
    // 例如发送请求到服务器
    
    // 显示退款详情页面
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById('refundDetail').style.display = 'block';
    
    // 模拟提交成功
    alert('退款申请已提交');
}

// 提交平台介入申请
function submitPlatformIntervention() {
    const reason = document.getElementById('selectedPlatformReason').textContent;
    const description = document.querySelector('#platformContent textarea').value;
    
    if (!description) {
        alert('请填写详细说明');
        return;
    }
    
    // 这里可以添加提交平台介入申请的逻辑
    // 例如发送请求到服务器
    
    // 模拟提交成功
    alert('平台介入申请已提交');
    
    // 返回订单列表页面
    window.location.href = 'orders.html';
}

// 联系卖家
function contactSeller() {
    window.location.href = 'chatroom.html?seller=123456';
}

// 查看物流
function viewLogistics() {
    alert('查看物流信息');
}

// 平台介入
function platformIntervention() {
    // 切换到平台介入标签页
    switchTab(document.querySelector('.tab[data-tab="platform"]'));
}

// 编辑申请
function editApplication() {
    // 隐藏退款详情页面
    document.getElementById('refundDetail').style.display = 'none';
    
    // 显示退款申请表单
    document.getElementById('refundContent').classList.add('active');
}

// 撤销申请
function cancelApplication() {
    if (confirm('确定要撤销申请吗？')) {
        // 这里可以添加撤销申请的逻辑
        // 例如发送请求到服务器
        
        // 返回订单列表页面
        window.location.href = 'orders.html';
    }
}