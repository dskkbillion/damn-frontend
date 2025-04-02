// 显示提现对话框
function showWithdrawDialog() {
    document.getElementById('withdrawDialog').style.display = 'flex';
}

// 隐藏提现对话框
function hideWithdrawDialog() {
    document.getElementById('withdrawDialog').style.display = 'none';
}

// 显示税务信息对话框
function showTaxInfoDialog() {
    document.getElementById('taxInfoDialog').style.display = 'flex';
    
    // 如果已有税务信息，则填充表单
    const taxInfo = getTaxInfo();
    if (taxInfo) {
        document.getElementById('taxId').value = taxInfo.id || '';
        document.getElementById('taxName').value = taxInfo.name || '';
        document.getElementById('taxAddress').value = taxInfo.address || '';
    }
}

// 隐藏税务信息对话框
function hideTaxInfoDialog() {
    document.getElementById('taxInfoDialog').style.display = 'none';
}

// 处理提现
function processWithdraw() {
    const amount = document.getElementById('withdrawAmount').value;
    const bankId = document.getElementById('withdrawBank').value;
    
    if (!amount || amount <= 0) {
        alert('请输入有效的提现金额');
        return;
    }
    
    if (bankId === '3') {
        // 添加新银行卡
        window.location.href = 'seller_wallet_cards.html?add=true';
        return;
    }
    
    // 这里应该有提现的逻辑
    // 但在这个HTML原型中，我们只是模拟成功并返回上一页
    alert('提现申请已提交，请等待处理');
    hideWithdrawDialog();
}

// 保存税务信息
function saveTaxInfo() {
    const taxId = document.getElementById('taxId').value;
    const taxName = document.getElementById('taxName').value;
    const taxAddress = document.getElementById('taxAddress').value;
    
    if (!taxId || !taxName || !taxAddress) {
        alert('请填写完整的税务信息');
        return;
    }
    
    // 保存税务信息
    // 在实际应用中，这里应该调用API保存数据
    // 这里我们只是模拟保存到localStorage
    const taxInfo = {
        id: taxId,
        name: taxName,
        address: taxAddress
    };
    
    localStorage.setItem('sellerTaxInfo', JSON.stringify(taxInfo));
    
    alert('税务信息保存成功');
    hideTaxInfoDialog();
}

// 获取税务信息
function getTaxInfo() {
    // 在实际应用中，这里应该从API获取数据
    // 这里我们只是模拟从localStorage获取
    const taxInfoStr = localStorage.getItem('sellerTaxInfo');
    return taxInfoStr ? JSON.parse(taxInfoStr) : null;
}

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 初始化页面数据
    // 在实际应用中，这里应该从API获取数据
    // 这里我们只是使用静态数据
    
    // 如果需要，可以在这里添加其他初始化逻辑
});