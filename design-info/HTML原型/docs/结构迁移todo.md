# DSKK前端HTML文件结构迁移计划

## 概述

本文档详细描述了将DSKK-renew/new-proto/HTML-new目录中的HTML文件按照React路由逻辑进行重组的计划。这个迁移计划参考了demo-repository项目的路由结构，旨在使HTML文件的组织更加清晰，更好地体现页面之间的关系和导航逻辑。

## 目标文件结构

```
DSKK-renew/new-proto/HTML-new/
├── css/                  # CSS文件目录
├── js/                   # JavaScript文件目录
├── imgs/                 # 图片文件目录
├── (tabs)/               # 主标签页模块
│   ├── homepage/         # 首页相关页面
│   │   ├── index.html             # 主页
│   │   ├── search.html            # 搜索页面
│   │   ├── search_result.html     # 搜索结果页面
│   │   ├── load_portrait.html     # 加载头像页面
│   │   └── service_detail.html    # 服务详情页面
│   ├── ai_docs/          # AI对话相关页面
│   │   ├── ai_docs.html           # AI对话页面
│   │   ├── ai_docs_history.html   # AI对话历史记录页面
│   │   ├── ai_docs_input.html     # AI对话输入页面
│   │   ├── ai_docs_question.html  # AI对话问答页面
│   │   ├── ai_docs_detail.html    # AI对话详情页面
│   │   ├── create_profile_1.html  # 创建个人资料第一步页面
│   │   ├── create_profile_2.html  # 创建个人资料第二步页面
│   │   ├── docs_homepage.html     # 文档主页页面
│   │   ├── docs.html              # 文档页面
│   │   └── furnish_view.html      # 装饰视图页面
│   ├── chat/             # 消息相关页面
│   │   ├── chat.html              # 消息页面
│   │   └── chat_detail.html       # 聊天详情页面
│   └── profile/          # 个人资料相关页面
│       ├── profile.html           # 个人资料页面
│       ├── notification.html      # 通知页面
│       ├── saved_list.html        # 收藏页面
│       ├── favorites.html         # 收藏页面
│       ├── time_manage.html       # 时间管理页面
│       ├── wallet.html            # 钱包页面
│       ├── wallet_record.html     # 交易记录页面
│       ├── wallet_cards.html      # 银行卡页面
│       ├── accountSafe/           # 账号安全相关页面
│       │   ├── account_safe.html        # 账号安全页面
│       │   ├── deactivation.html        # 停用账号页面
│       │   ├── edit_avatar.html         # 编辑头像页面
│       │   └── edit_nickname.html       # 编辑昵称页面
│       ├── likedStory/            # 喜欢的故事相关页面
│       │   ├── story.html               # 故事页面
│       │   └── story_list.html          # 故事列表页面
│       └── orders/               # 订单相关页面
│           ├── order_evaluation.html    # 评价页面
│           ├── orders.html              # 订单页面
│           ├── order_postsale.html      # 售后服务页面
│           ├── order_search.html        # 订单搜索页面
│           ├── order_search_result.html # 订单搜索结果页面
│           └── order_detail.html        # 订单详情页面
├── (sellerscreens)/      # 卖家页面模块
│   ├── chat/             # 卖家聊天相关页面
│   │   └── seller_chat.html       # 卖家聊天页面
│   ├── post/             # 卖家发布相关页面
│   │   ├── seller_post.html       # 卖家发布页面
│   │   ├── [id]/                  # 特定项目相关页面
│   │   │   └── seller_item_edit.html  # 项目编辑页面
│   │   └── story/                 # 故事相关页面
│   │       ├── seller_story_edit.html # 故事编辑页面
│   │       └── seller_story_view.html # 故事查看页面
│   └── profile/          # 卖家个人资料相关页面
│       ├── seller_profile.html    # 卖家个人资料页面
│       ├── seller_time_manage.html # 卖家时间管理页面
│       ├── authentication/        # 认证相关页面
│       │   ├── seller_authentication.html      # 认证主页页面
│       │   ├── seller_authentication_status.html # 认证状态页面
│       │   └── seller_authentication_detail.html # 认证申请详情页面
│       ├── notification/          # 通知相关页面
│       │   ├── seller_auto_reply.html          # 自动回复设置页面
│       │   └── seller_notification.html        # 卖家通知页面
│       ├── orders/                # 卖家订单相关页面
│       │   ├── seller_orders.html             # 卖家订单页面
│       │   ├── seller_order_search.html       # 卖家订单搜索页面
│       │   ├── seller_order_search_result.html # 卖家订单搜索结果页面
│       │   └── seller_order_detail.html       # 卖家订单详情页面
│       └── wallet/                # 卖家钱包相关页面
│           ├── seller_wallet_cards.html       # 卖家银行卡页面
│           ├── seller_wallet.html             # 卖家钱包页面
│           ├── record/                        # 记录相关页面
│           │   ├── seller_record_detail.html      # 记录详情页面
│           │   └── seller_record.html             # 记录页面
└── (outer)/              # 外部页面模块
    ├── chatroom.html             # 聊天室页面
    ├── modal.html                # 模态框页面
    ├── seller_guide.html         # 卖家指南页面
    ├── about/                    # 关于相关页面
    │   ├── about_us.html               # 关于我们页面
    │   ├── payment.html                # 支付页面
    │   └── privacy.html                # 隐私政策页面
    ├── home/                     # 首页相关页面
    │   ├── item_homepage.html          # 项目主页页面
    │   ├── mystory.html                # 我的故事页面
    │   ├── review.html                 # 评论页面
    │   └── user_profile.html           # 用户资料页面
    ├── login/                    # 登录相关页面
    │   ├── login.html                  # 登录主页页面
    │   ├── login_container.html        # 登录容器页面
    │   └── mobile/                     # 移动端登录相关页面
    │       ├── mobile_login.html            # 移动端登录页面
    │       └── verify_code.html             # 验证码页面
    ├── order/                    # 订单相关页面
    │   ├── application.html            # 应用页面
    │   ├── order_application.html      # 订单申请页面
    │   └── refund.html                 # 退款页面
    └── reminder/                 # 提醒相关页面
        ├── error.html                  # 错误页面
        ├── login_error.html            # 登录错误页面
        └── payment_reminder.html       # 支付提醒页面
```

## 迁移任务清单

### 1. 准备工作

- [x] 备份当前的HTML-new目录
- [x] 创建新的目录结构
- [ ] 准备路径更新脚本（可选）

### 2. 迁移主标签页模块 (tabs)

#### 2.1 首页相关页面 (homepage)

- [x] 创建(tabs)/homepage目录
- [x] 移动index.html到(tabs)/homepage目录
- [x] 移动search.html到(tabs)/homepage目录
- [x] 移动search_result.html到(tabs)/homepage目录
- [x] 移动load_portrait.html到(tabs)/homepage目录
- [x] 移动service_detail.html到(tabs)/homepage目录
- [x] 更新这些文件中的相对路径引用

#### 2.2 AI对话相关页面 (ai_docs)

- [x] 创建(tabs)/ai_docs目录
- [x] 移动ai_docs.html到(tabs)/ai_docs目录
- [x] 移动ai_docs_history.html到(tabs)/ai_docs目录
- [x] 移动ai_docs_input.html到(tabs)/ai_docs目录
- [x] 移动ai_docs_question.html到(tabs)/ai_docs目录
- [x] 移动ai_docs_detail.html到(tabs)/ai_docs目录
- [ ] 移动create_profile_1.html到(tabs)/ai_docs目录（如果存在）
- [ ] 移动create_profile_2.html到(tabs)/ai_docs目录（如果存在）
- [ ] 移动docs_homepage.html到(tabs)/ai_docs目录（如果存在）
- [ ] 移动docs.html到(tabs)/ai_docs目录（如果存在）
- [ ] 移动furnish_view.html到(tabs)/ai_docs目录（如果存在）
- [x] 更新这些文件中的相对路径引用

#### 2.3 消息相关页面 (chat)

- [x] 创建(tabs)/chat目录
- [x] 移动chat.html到(tabs)/chat目录
- [x] 移动chat_detail.html到(tabs)/chat目录
- [x] 更新这些文件中的相对路径引用

#### 2.4 个人资料相关页面 (profile)

- [x] 创建(tabs)/profile目录
- [x] 移动profile.html到(tabs)/profile目录
- [x] 移动notification.html到(tabs)/profile目录
- [x] 移动saved_list.html到(tabs)/profile目录
- [x] 移动favorites.html到(tabs)/profile目录
- [x] 移动time_manage.html到(tabs)/profile目录
- [x] 移动wallet.html到(tabs)/profile目录
- [x] 移动wallet_record.html到(tabs)/profile目录
- [x] 移动wallet_cards.html到(tabs)/profile目录
- [x] 更新这些文件中的相对路径引用

##### 2.4.1 账号安全相关页面 (accountSafe)

- [x] 创建(tabs)/profile/accountSafe目录
- [x] 移动account_safe.html到(tabs)/profile/accountSafe目录
- [x] 移动deactivation.html到(tabs)/profile/accountSafe目录
- [x] 移动edit_avatar.html到(tabs)/profile/accountSafe目录
- [x] 移动edit_nickname.html到(tabs)/profile/accountSafe目录
- [x] 更新这些文件中的相对路径引用

##### 2.4.2 喜欢的故事相关页面 (likedStory)

- [x] 创建(tabs)/profile/likedStory目录
- [x] 移动story.html到(tabs)/profile/likedStory目录
- [x] 移动story_list.html到(tabs)/profile/likedStory目录
- [x] 更新这些文件中的相对路径引用

##### 2.4.3 订单相关页面 (orders)

- [x] 创建(tabs)/profile/orders目录
- [x] 移动order_evaluation.html到(tabs)/profile/orders目录
- [x] 移动orders.html到(tabs)/profile/orders目录
- [x] 移动order_postsale.html到(tabs)/profile/orders目录
- [x] 移动order_search.html到(tabs)/profile/orders目录
- [x] 移动order_search_result.html到(tabs)/profile/orders目录
- [x] 移动order_detail.html到(tabs)/profile/orders目录
- [x] 更新这些文件中的相对路径引用

### 3. 迁移卖家页面模块 (sellerscreens)

#### 3.1 卖家聊天相关页面 (chat)

- [x] 创建(sellerscreens)/chat目录
- [x] 移动seller_chat.html到(sellerscreens)/chat目录
- [x] 更新这些文件中的相对路径引用

#### 3.2 卖家发布相关页面 (post)

- [x] 创建(sellerscreens)/post目录
- [x] 移动seller_post.html到(sellerscreens)/post目录
- [x] 更新这些文件中的相对路径引用

##### 3.2.1 特定项目相关页面 ([id])

- [x] 创建(sellerscreens)/post/[id]目录
- [x] 移动seller_item_edit.html到(sellerscreens)/post/[id]目录
- [x] 更新这些文件中的相对路径引用

##### 3.2.2 故事相关页面 (story)

- [x] 创建(sellerscreens)/post/story目录
- [x] 移动seller_story_edit.html到(sellerscreens)/post/story目录
- [x] 移动seller_story_view.html到(sellerscreens)/post/story目录
- [x] 更新这些文件中的相对路径引用

#### 3.3 卖家个人资料相关页面 (profile)

- [x] 创建(sellerscreens)/profile目录
- [x] 移动seller_profile.html到(sellerscreens)/profile目录
- [x] 移动seller_time_manage.html到(sellerscreens)/profile目录
- [x] 更新这些文件中的相对路径引用

##### 3.3.1 认证相关页面 (authentication)

- [x] 创建(sellerscreens)/profile/authentication目录
- [x] 移动seller_authentication.html到(sellerscreens)/profile/authentication目录
- [x] 移动seller_authentication_status.html到(sellerscreens)/profile/authentication目录
- [x] 移动seller_authentication_detail.html到(sellerscreens)/profile/authentication目录
- [x] 更新这些文件中的相对路径引用

##### 3.3.2 通知相关页面 (notification)

- [x] 创建(sellerscreens)/profile/notification目录
- [x] 移动seller_auto_reply.html到(sellerscreens)/profile/notification目录
- [x] 移动seller_notification.html到(sellerscreens)/profile/notification目录
- [x] 更新这些文件中的相对路径引用

##### 3.3.3 卖家订单相关页面 (orders)

- [x] 创建(sellerscreens)/profile/orders目录
- [x] 移动seller_orders.html到(sellerscreens)/profile/orders目录
- [x] 移动seller_order_search.html到(sellerscreens)/profile/orders目录
- [x] 移动seller_order_search_result.html到(sellerscreens)/profile/orders目录
- [x] 移动seller_order_detail.html到(sellerscreens)/profile/orders目录
- [x] 更新这些文件中的相对路径引用

##### 3.3.4 卖家钱包相关页面 (wallet)

- [x] 创建(sellerscreens)/profile/wallet目录
- [x] 移动seller_wallet_cards.html到(sellerscreens)/profile/wallet目录
- [x] 移动seller_wallet.html到(sellerscreens)/profile/wallet目录
- [x] 创建(sellerscreens)/profile/wallet/record目录
- [x] 移动seller_record_detail.html到(sellerscreens)/profile/wallet/record目录
- [x] 移动seller_record.html到(sellerscreens)/profile/wallet/record目录
- [x] 更新这些文件中的相对路径引用

### 4. 迁移外部页面模块 (outer)

- [x] 创建(outer)目录
- [x] 移动chatroom.html到(outer)目录
- [x] 移动modal.html到(outer)目录
- [x] 移动seller_guide.html到(outer)目录

#### 4.1 关于相关页面 (about)

- [x] 创建(outer)/about目录
- [x] 移动about_us.html到(outer)/about目录
- [x] 移动payment.html到(outer)/about目录
- [x] 移动privacy.html到(outer)/about目录
- [x] 更新这些文件中的相对路径引用

#### 4.2 首页相关页面 (home)

- [x] 创建(outer)/home目录
- [x] 移动item_homepage.html到(outer)/home目录
- [x] 移动mystory.html到(outer)/home目录
- [x] 移动review.html到(outer)/home目录
- [x] 移动user_profile.html到(outer)/home目录
- [x] 更新这些文件中的相对路径引用

#### 4.3 登录相关页面 (login)

- [x] 创建(outer)/login目录
- [x] 移动login.html到(outer)/login目录
- [x] 移动login_container.html到(outer)/login目录

##### 4.3.1 移动端登录相关页面 (mobile)

- [x] 创建(outer)/login/mobile目录
- [x] 移动mobile_login.html到(outer)/login/mobile目录
- [x] 移动verify_code.html到(outer)/login/mobile目录
- [x] 更新这些文件中的相对路径引用

#### 4.4 订单相关页面 (order)

- [x] 创建(outer)/order目录
- [x] 移动application.html到(outer)/order目录
- [x] 移动order_application.html到(outer)/order目录
- [ ] 移动order_detail_outer.html到(outer)/order目录（文件不存在）
- [x] 移动refund.html到(outer)/order目录
- [x] 更新这些文件中的相对路径引用

#### 4.5 提醒相关页面 (reminder)

- [x] 创建(outer)/reminder目录
- [x] 移动error.html到(outer)/reminder目录
- [x] 移动login_error.html到(outer)/reminder目录
- [x] 移动payment_reminder.html到(outer)/reminder目录
- [x] 更新这些文件中的相对路径引用

### 5. 更新资源引用

- [x] 更新所有HTML文件中的CSS引用路径
- [x] 更新所有HTML文件中的JavaScript引用路径
- [x] 更新所有HTML文件中的图片引用路径
- [x] 更新所有HTML文件中的页面链接路径

### 6. 测试与验证

- [x] 测试所有页面是否能正常加载
- [x] 测试所有页面之间的跳转是否正常
- [x] 测试所有功能是否正常工作
- [x] 修复发现的问题

## 注意事项

1. 在迁移过程中，需要特别注意更新HTML文件中的相对路径引用，包括：
   - CSS文件引用
   - JavaScript文件引用
   - 图片文件引用
   - 页面链接

2. 可以考虑使用脚本自动更新路径引用，但需要谨慎测试。

3. 建议分批次进行迁移，每完成一个模块就进行测试，确保没有问题后再继续下一个模块。

4. 迁移完成后，需要全面测试所有页面和功能，确保没有遗漏或错误。

## 迁移脚本示例（可选）

以下是一个简单的Python脚本示例，可以帮助自动更新HTML文件中的路径引用：

```python
import os
import re

def update_paths(file_path, old_prefix, new_prefix):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # 更新href属性
    content = re.sub(r'href=[\'"](' + old_prefix + r'[^\'"]*)[\'"]', 
                     r'href="' + new_prefix + r'\1"', content)
    
    # 更新src属性
    content = re.sub(r'src=[\'"](' + old_prefix + r'[^\'"]*)[\'"]', 
                     r'src="' + new_prefix + r'\1"', content)
    
    # 更新action属性
    content = re.sub(r'action=[\'"](' + old_prefix + r'[^\'"]*)[\'"]', 
                     r'action="' + new_prefix + r'\1"', content)
    
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(content)

def process_directory(directory, old_prefix, new_prefix):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.html'):
                file_path = os.path.join(root, file)
                update_paths(file_path, old_prefix, new_prefix)

# 使用示例
# process_directory('DSKK-renew/new-proto/HTML-new/(tabs)', './', '../')
```

注意：这只是一个简单的示例，实际使用时可能需要根据具体情况进行调整。

## 结论

通过按照React路由逻辑重组HTML文件，我们可以使项目结构更加清晰，更好地体现页面之间的关系和导航逻辑。这将有助于提高代码的可维护性和可读性，同时也为将来可能的React迁移做好准备。