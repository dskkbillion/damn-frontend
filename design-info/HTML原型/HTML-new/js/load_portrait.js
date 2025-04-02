// 加载头像页面脚本

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 初始化页面
    initPage();
});

// 初始化页面
function initPage() {
    // 检查是否有已保存的临时头像
    const savedPortrait = localStorage.getItem('tempPortrait');
    if (savedPortrait) {
        // 显示已保存的头像
        displayPortrait(savedPortrait);
        // 启用提交按钮
        enableSubmitButton();
    }
}

// 打开相机
function openCamera() {
    // 在实际应用中，这里会调用设备相机
    // 在这个HTML原型中，我们模拟点击文件上传按钮，但限制为相机
    const input = document.getElementById('portraitUpload');
    input.setAttribute('capture', 'user');
    input.click();
}

// 打开相册
function openGallery() {
    // 在实际应用中，这里会打开设备相册
    // 在这个HTML原型中，我们模拟点击文件上传按钮
    const input = document.getElementById('portraitUpload');
    input.removeAttribute('capture');
    input.click();
}

// 预览选择的图片
function previewImage(input) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        
        reader.onload = function(e) {
            displayPortrait(e.target.result);
            
            // 保存临时头像到本地存储
            localStorage.setItem('tempPortrait', e.target.result);
            
            // 启用提交按钮
            enableSubmitButton();
        }
        
        reader.readAsDataURL(input.files[0]);
    }
}

// 显示头像
function displayPortrait(src) {
    const portraitPreview = document.getElementById('portraitPreview');
    
    // 移除默认头像图标
    const defaultAvatar = portraitPreview.querySelector('.default-avatar');
    if (defaultAvatar) {
        defaultAvatar.style.display = 'none';
    }
    
    // 检查是否已有图片元素
    let imgElement = portraitPreview.querySelector('img');
    
    if (!imgElement) {
        // 创建新的图片元素
        imgElement = document.createElement('img');
        portraitPreview.appendChild(imgElement);
    }
    
    // 设置图片源
    imgElement.src = src;
}

// 启用提交按钮
function enableSubmitButton() {
    const submitButton = document.getElementById('submitButton');
    submitButton.disabled = false;
}

// 保存头像
function savePortrait() {
    // 在实际应用中，这里会上传头像到服务器
    // 在这个HTML原型中，我们只是模拟成功并跳转到下一页
    
    // 清除临时头像
    localStorage.removeItem('tempPortrait');
    
    // 显示成功消息
    alert('头像上传成功！');
    
    // 跳转到主页或下一步
    window.location.href = 'index.html';
}

// 跳过上传头像
function skipUpload() {
    // 清除临时头像
    localStorage.removeItem('tempPortrait');
    
    // 跳转到主页或下一步
    window.location.href = 'index.html';
}