// 重置表单
function resetForm() {
    document.getElementById('orderNumber').value = '';
    document.getElementById('orderStatus').value = '';
    document.getElementById('startDate').value = '';
    document.getElementById('endDate').value = '';
    document.getElementById('buyerName').value = '';
}

// 搜索订单
function searchOrders() {
    // 获取表单数据
    const orderNumber = document.getElementById('orderNumber').value;
    const orderStatus = document.getElementById('orderStatus').value;
    const startDate = document.getElementById('startDate').value;
    const endDate = document.getElementById('endDate').value;
    const buyerName = document.getElementById('buyerName').value;
    
    // 构建查询参数
    const params = new URLSearchParams();
    if (orderNumber) params.append('orderNumber', orderNumber);
    if (orderStatus) params.append('status', orderStatus);
    if (startDate) params.append('startDate', startDate);
    if (endDate) params.append('endDate', endDate);
    if (buyerName) params.append('buyerName', buyerName);
    
    // 跳转到搜索结果页面
    window.location.href = `seller_order_search_result.html?${params.toString()}`;
}

// 初始化日期选择器默认值
document.addEventListener('DOMContentLoaded', function() {
    // 设置默认的日期范围为过去30天
    const today = new Date();
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(today.getDate() - 30);
    
    // 格式化日期为YYYY-MM-DD
    const formatDate = (date) => {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    };
    
    // 设置默认日期
    document.getElementById('startDate').value = formatDate(thirtyDaysAgo);
    document.getElementById('endDate').value = formatDate(today);
});