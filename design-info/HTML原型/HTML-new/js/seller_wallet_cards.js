// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 加载银行卡列表
    loadCards();
    
    // 检查是否需要自动打开添加银行卡对话框
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('add') === 'true') {
        showAddCardDialog();
    }
});

// 加载银行卡列表
function loadCards() {
    const cardsList = document.getElementById('cardsList');
    
    // 获取银行卡数据
    const cards = getCards();
    
    // 清空列表
    cardsList.innerHTML = '';
    
    // 如果没有银行卡，显示提示信息
    if (cards.length === 0) {
        cardsList.innerHTML = `
            <div class="empty-state">
                <div class="empty-icon">
                    <i class="fas fa-credit-card"></i>
                </div>
                <div class="empty-text">您还没有添加银行卡</div>
                <div class="empty-subtext">添加银行卡后可以进行提现操作</div>
            </div>
        `;
        return;
    }
    
    // 添加银行卡到列表
    cards.forEach((card, index) => {
        const cardItem = document.createElement('div');
        cardItem.className = `card-item ${card.bankCode} white-text`;
        cardItem.innerHTML = `
            <div class="card-bank">
                <div class="bank-logo">
                    <i class="fas fa-university"></i>
                </div>
                <div class="bank-name">${getBankName(card.bankCode)}</div>
            </div>
            <div class="card-number">${formatCardNumber(card.cardNumber)}</div>
            <div class="card-holder">${card.cardHolder}</div>
            <div class="card-branch">${card.bankBranch}</div>
            <div class="card-actions">
                <div class="card-action" onclick="deleteCard(${index})">
                    <i class="fas fa-trash-alt"></i>
                </div>
            </div>
        `;
        cardsList.appendChild(cardItem);
    });
}

// 格式化银行卡号
function formatCardNumber(cardNumber) {
    // 只显示后四位，其他用星号代替
    return `**** **** **** ${cardNumber.slice(-4)}`;
}

// 获取银行名称
function getBankName(bankCode) {
    const bankNames = {
        'ICBC': '工商银行',
        'CCB': '建设银行',
        'ABC': '农业银行',
        'BOC': '中国银行',
        'CMBC': '招商银行',
        'PSBC': '邮政储蓄银行',
        'SPDB': '浦发银行',
        'CIB': '兴业银行'
    };
    
    return bankNames[bankCode] || '银行卡';
}

// 获取银行卡数据
function getCards() {
    // 在实际应用中，这里应该从API获取数据
    // 这里我们只是模拟从localStorage获取
    const cardsStr = localStorage.getItem('sellerBankCards');
    return cardsStr ? JSON.parse(cardsStr) : [];
}

// 保存银行卡数据
function saveCards(cards) {
    // 在实际应用中，这里应该调用API保存数据
    // 这里我们只是模拟保存到localStorage
    localStorage.setItem('sellerBankCards', JSON.stringify(cards));
}

// 显示添加银行卡对话框
function showAddCardDialog() {
    document.getElementById('addCardDialog').style.display = 'flex';
    
    // 清空表单
    document.getElementById('cardHolder').value = '';
    document.getElementById('cardNumber').value = '';
    document.getElementById('bankName').value = '';
    document.getElementById('bankBranch').value = '';
    document.getElementById('phoneNumber').value = '';
}

// 隐藏添加银行卡对话框
function hideAddCardDialog() {
    document.getElementById('addCardDialog').style.display = 'none';
}

// 添加银行卡
function addCard() {
    const cardHolder = document.getElementById('cardHolder').value;
    const cardNumber = document.getElementById('cardNumber').value;
    const bankCode = document.getElementById('bankName').value;
    const bankBranch = document.getElementById('bankBranch').value;
    const phoneNumber = document.getElementById('phoneNumber').value;
    
    // 验证表单
    if (!cardHolder) {
        alert('请输入持卡人姓名');
        return;
    }
    
    if (!cardNumber) {
        alert('请输入银行卡号');
        return;
    }
    
    if (!bankCode) {
        alert('请选择开户银行');
        return;
    }
    
    if (!bankBranch) {
        alert('请输入开户支行');
        return;
    }
    
    if (!phoneNumber) {
        alert('请输入预留手机号');
        return;
    }
    
    // 创建银行卡对象
    const card = {
        cardHolder,
        cardNumber,
        bankCode,
        bankBranch,
        phoneNumber
    };
    
    // 获取现有银行卡
    const cards = getCards();
    
    // 添加新银行卡
    cards.push(card);
    
    // 保存银行卡
    saveCards(cards);
    
    // 隐藏对话框
    hideAddCardDialog();
    
    // 重新加载银行卡列表
    loadCards();
    
    // 显示成功提示
    alert('银行卡添加成功');
}

// 删除银行卡
function deleteCard(index) {
    // 保存要删除的索引
    window.cardIndexToDelete = index;
    
    // 显示确认对话框
    document.getElementById('deleteConfirmDialog').style.display = 'flex';
}

// 隐藏删除确认对话框
function hideDeleteConfirmDialog() {
    document.getElementById('deleteConfirmDialog').style.display = 'none';
}

// 确认删除银行卡
function confirmDeleteCard() {
    // 获取要删除的索引
    const index = window.cardIndexToDelete;
    
    // 获取现有银行卡
    const cards = getCards();
    
    // 删除指定银行卡
    cards.splice(index, 1);
    
    // 保存银行卡
    saveCards(cards);
    
    // 隐藏对话框
    hideDeleteConfirmDialog();
    
    // 重新加载银行卡列表
    loadCards();
    
    // 显示成功提示
    alert('银行卡删除成功');
}