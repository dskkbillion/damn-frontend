// 应用页面脚本

// 选择服务选项
function selectServiceOption(element) {
    // 移除所有选项的active类
    document.querySelectorAll('.service-option').forEach(option => {
        option.classList.remove('active');
    });
    
    // 给当前选项添加active类
    element.classList.add('active');
    
    // 更新订单金额
    updateOrderAmount();
}

// 选择交付时间选项
function selectDeliveryOption(element) {
    // 移除所有选项的active类
    document.querySelectorAll('.delivery-option').forEach(option => {
        option.classList.remove('active');
    });
    
    // 给当前选项添加active类
    element.classList.add('active');
    
    // 更新订单金额
    updateOrderAmount();
}

// 更新订单金额
function updateOrderAmount() {
    // 获取选中的服务选项价格
    const serviceOption = document.querySelector('.service-option.active');
    const servicePrice = serviceOption ? parseInt(serviceOption.querySelector('.option-price').textContent.replace(/[^\d]/g, '')) : 0;
    
    // 获取选中的交付时间附加费
    const deliveryOption = document.querySelector('.delivery-option.active');
    const deliveryPrice = deliveryOption ? parseInt(deliveryOption.querySelector('.option-price').textContent.replace(/[^\d]/g, '')) : 0;
    
    // 计算总金额
    const totalAmount = servicePrice + deliveryPrice;
    
    // 更新显示
    document.querySelector('.amount-value').textContent = `¥${totalAmount}`;
}

// 文件上传处理
document.getElementById('fileUpload').addEventListener('change', function(event) {
    const files = event.target.files;
    const uploadedFilesContainer = document.getElementById('uploadedFiles');
    
    // 处理每个上传的文件
    for (let i = 0; i < files.length; i++) {
        const file = files[i];
        
        // 检查文件大小
        if (file.size > 10 * 1024 * 1024) { // 10MB
            alert(`文件 ${file.name} 超过10MB限制，请选择更小的文件。`);
            continue;
        }
        
        // 创建文件项
        const fileItem = document.createElement('div');
        fileItem.className = 'file-item';
        
        // 文件名
        const fileName = document.createElement('div');
        fileName.className = 'file-name';
        fileName.textContent = file.name;
        
        // 删除按钮
        const removeButton = document.createElement('div');
        removeButton.className = 'file-remove';
        removeButton.innerHTML = '<i class="fas fa-times"></i>';
        removeButton.onclick = function() {
            fileItem.remove();
        };
        
        // 组装文件项
        fileItem.appendChild(fileName);
        fileItem.appendChild(removeButton);
        
        // 添加到容器
        uploadedFilesContainer.appendChild(fileItem);
    }
    
    // 清空文件输入，以便可以再次选择相同的文件
    event.target.value = '';
});

// 提交申请
function submitApplication() {
    // 获取表单数据
    const serviceType = document.querySelector('.service-option.active .option-name').textContent;
    const requirement = document.querySelector('.form-textarea').value;
    const deliveryTime = document.querySelector('.delivery-option.active .option-days').textContent;
    const contact = document.querySelector('.form-input').value;
    const amount = document.querySelector('.amount-value').textContent;
    
    // 验证表单
    if (!requirement) {
        alert('请填写需求描述');
        return;
    }
    
    if (!contact) {
        alert('请填写联系方式');
        return;
    }
    
    // 在实际应用中，这里会将数据提交到服务器
    // 在这个HTML原型中，我们只是显示一个成功消息并跳转
    
    // 显示提交中状态
    const submitButton = document.querySelector('.submit-button');
    const originalText = submitButton.textContent;
    submitButton.textContent = '提交中...';
    submitButton.disabled = true;
    
    // 模拟网络请求延迟
    setTimeout(() => {
        // 显示成功消息
        alert('申请提交成功！卖家将尽快与您联系。');
        
        // 跳转到订单页面
        window.location.href = 'orders.html';
    }, 1000);
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
    // 初始化订单金额
    updateOrderAmount();
});