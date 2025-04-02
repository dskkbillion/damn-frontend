// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 初始化星级评分
    initRatingStars();
});

// 初始化星级评分
function initRatingStars() {
    const stars = document.querySelectorAll('.rating-stars i');
    
    // 为每个星星添加点击事件
    stars.forEach((star, index) => {
        star.addEventListener('click', () => {
            // 设置当前星星及之前的星星为选中状态
            for (let i = 0; i <= index; i++) {
                stars[i].classList.remove('far');
                stars[i].classList.add('fas');
            }
            
            // 设置之后的星星为未选中状态
            for (let i = index + 1; i < stars.length; i++) {
                stars[i].classList.remove('fas');
                stars[i].classList.add('far');
            }
            
            // 更新评分标签
            updateRatingLabel(index + 1);
        });
        
        // 添加鼠标悬停效果
        star.addEventListener('mouseover', () => {
            // 设置当前星星及之前的星星为悬停状态
            for (let i = 0; i <= index; i++) {
                stars[i].classList.remove('far');
                stars[i].classList.add('fas');
            }
        });
        
        // 添加鼠标离开效果
        star.addEventListener('mouseout', () => {
            // 重置所有星星
            resetStars();
        });
    });
}

// 更新评分标签
function updateRatingLabel(rating) {
    const ratingLabel = document.querySelector('.rating-label');
    const labels = ['很差', '较差', '一般', '不错', '很好'];
    
    if (rating > 0 && rating <= 5) {
        ratingLabel.textContent = labels[rating - 1];
    } else {
        ratingLabel.textContent = '点击';
    }
}

// 重置星星状态
function resetStars() {
    const stars = document.querySelectorAll('.rating-stars i');
    const selectedRating = getSelectedRating();
    
    stars.forEach((star, index) => {
        if (index < selectedRating) {
            star.classList.remove('far');
            star.classList.add('fas');
        } else {
            star.classList.remove('fas');
            star.classList.add('far');
        }
    });
}

// 获取当前选中的评分
function getSelectedRating() {
    const stars = document.querySelectorAll('.rating-stars i');
    let rating = 0;
    
    stars.forEach((star, index) => {
        if (star.classList.contains('fas')) {
            rating = index + 1;
        }
    });
    
    return rating;
}

// 提交评价
document.querySelector('.submit-button').addEventListener('click', function() {
    const rating = getSelectedRating();
    const comment = document.querySelector('textarea').value.trim();
    const isAnonymous = document.querySelector('.checkbox-container input').checked;
    
    // 验证评分
    if (rating === 0) {
        alert('请选择评分');
        return;
    }
    
    // 在实际应用中，这里应该调用API提交评价
    // 这里我们只是模拟提交成功
    alert('评价提交成功');
    
    // 跳转到订单列表页面
    window.location.href = 'orders.html';
});