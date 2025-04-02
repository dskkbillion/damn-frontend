// 退款页面脚本

// 选择退款原因
function selectReason(element) {
    // 移除所有选项的active类
    document.querySelectorAll('.reason-option').forEach(option => {
        option.classList.remove('active');
    });
    
    // 给当前选项添加active类
    element.classList.add('active');
}

// 处理文件上传
function handleFileUpload(input) {
    const files = input.files;
    const evidenceList = document.getElementById('evidenceList');
    
    // 限制最多上传3张图片
    const currentCount = evidenceList.children.length;
    const remainingSlots = 3 - currentCount;
    
    if (remainingSlots <= 0) {
        alert('最多只能上传3张图片');
        return;
    }
    
    // 处理上传的图片
    for (let i = 0; i < Math.min(files.length, remainingSlots); i++) {
        const file = files[i];
        
        // 检查文件类型
        if (!file.type.startsWith('image/')) {
            alert('请上传图片文件');
            continue;
        }
        
        // 检查文件大小
        if (file.size > 5 * 1024 * 1024) { // 5MB
            alert(`文件 ${file.name} 超过5MB限制，请选择更小的文件。`);
            continue;
        }
        
        // 创建图片预览
        const reader = new FileReader();
        reader.onload = function(e) {
            // 创建凭证项
            const evidenceItem = document.createElement('div');
            evidenceItem.className = 'evidence-item';
            
            // 图片
            const img = document.createElement('img');
            img.className = 'evidence-image';
            img.src = e.target.result;
            
            // 删除按钮
            const removeButton = document.createElement('div');
            removeButton.className = 'evidence-remove';
            removeButton.innerHTML = '<i class="fas fa-times"></i>';
            removeButton.onclick = function() {
                evidenceItem.remove();
            };
            
            // 组装凭证项
            evidenceItem.appendChild(img);
            evidenceItem.appendChild(removeButton);
            
            // 添加到列表
            evidenceList.appendChild(evidenceItem);
        };
        
        reader.readAsDataURL(file);
    }
    
    // 清空文件输入，以便可以再次选择相同的文件
    input.value = '';
}

// 提交退款申请
function submitRefund() {
    // 获取表单数据
    const refundAmount = document.querySelector('.amount-input').value;
    const reasonElement = document.querySelector('.reason-option.active');
    const reason = reasonElement ? reasonElement.querySelector('.option-text').textContent : '';
    const description = document.querySelector('.form-textarea').value;
    
    // 验证表单
    if (!reason) {
        alert('请选择退款原因');
        return;
    }
    
    if (!description) {
        alert('请填写退款说明');
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
        alert('退款申请已提交，卖家将在24小时内处理您的申请。');
        
        // 跳转到订单详情页面
        window.location.href = 'order_detail.html';
    }, 1000);
}