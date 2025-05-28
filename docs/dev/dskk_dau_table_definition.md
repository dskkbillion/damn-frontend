# dskk_dau表字段定义文档

## 表概述
`dskk_dau`表是一个通用用户行为数据表，用于记录各类用户行为，包括但不限于页面浏览、产品购买、登录注册、购物车操作等事件。本表可同时服务于多个系统：
- **推荐系统**：追踪推荐内容的点击和转化
- **数据分析面板**：提供用户行为统计和可视化
- **用户画像系统**：构建用户兴趣和行为特征
- **营销系统**：分析转化漏斗和用户旅程

## 表结构

| 字段名 | 类型 | 是否必填 | 默认值 | 描述 |
|--------|------|----------|--------|------|
| id | int | 是 | 自增 | 主键，自增ID |
| member_id | int | 否 | null | 用户ID，关联到用户表（非游客时填写） |
| path | varchar(255) | 否 | null | 页面路径，如"/page/8" |
| intervals | int | 否 | null | 停留时间（单位：秒） |
| leave_time | datetime | 否 | null | 用户离开页面的时间 |
| update_time | datetime | 否 | null | 记录更新时间 |
| create_time | datetime | 是 | 无 | 记录创建时间 |
| is_del | tinyint(1) | 是 | 0 | 是否删除：0=否，1=是 |
| sort | int | 否 | 0 | 排序值（升序） |
| business_type | varchar(255) | 否 | null | 业务类型（见下方说明） |
| business_id | int | 否 | null | 业务ID（如产品ID，分类ID等） |
| user_sign | varchar(255) | 否 | null | 用户标识符（包括登录用户和游客） |
| device_info | varchar(255) | 否 | null | 设备信息（如Desktop/Android/iOS/Web等） |
| feature | json | 否 | null | 业务扩展数据（JSON格式） |

## business_id字段说明

`business_id`字段根据不同的`business_type`有不同的含义：

| business_type | business_id含义 | 说明 |
|--------------|-----------------|------|
| view | 被查看对象的ID | 如果feature.view_type="product"，则为产品ID；<br>如果feature.view_type="article"，则为文章ID；<br>如果feature.view_type="category"，则为分类ID |
| click | 被点击对象的ID | 如果feature.click_type="recommendation"，则为推荐商品ID；<br>如果feature.click_type="ad"，则为广告ID |
| search | 搜索ID | 搜索行为的唯一标识，通常为系统生成的搜索会话ID |
| login | 用户ID | 登录用户的ID，与member_id相同 |
| register | 用户ID | 注册用户的ID，与member_id相同 |
| cart | 商品ID | 被加入、移除或更新购物车的商品ID |
| favorite | 收藏对象ID | 被收藏的商品、文章或其他内容的ID |
| order | 订单ID | 创建的订单ID |
| pay | 支付ID | 支付记录的ID，可以是订单ID或系统生成的支付流水号 |
| comment | 评论对象ID | 被评论的内容ID，如商品ID、文章ID等 |
| share | 分享对象ID | 被分享的内容ID，如商品ID、文章ID等 |

### 特殊说明

1. **多重关联**：某些情况下，`business_id`可能需要关联多个对象，此时应在`feature`字段中存储额外关联：
   ```json
   // 例如评论商品时：
   {
     "comment_id": 12345,  // 评论本身的ID
     "product_id": 42,     // 商品ID作为business_id
     "reply_to": 98765     // 如果是回复其他评论，存储原评论ID
   }
   ```

2. **组合ID**：对于涉及多个对象的操作，可以使用主要对象的ID作为`business_id`：
   ```json
   // 例如将商品A和商品B一起加入购物车：
   {
     "primary_item_id": 123,    // 主要商品ID作为business_id
     "secondary_items": [456, 789]  // 次要商品ID存储在feature中
   }
   ```

3. **ID类型转换**：尽管`business_id`字段类型为整数，但有些系统可能使用字符串ID，这种情况下应在应用层进行转换，或将完整ID存储在`feature`中：
   ```json
   // 例如处理非数字ID：
   {
     "full_id": "SKU-A1B2C3",  // 完整字符串ID
     "numeric_id": 123456      // 转换后的数字ID作为business_id
   }
   ```

## 业务类型(business_type)说明

`business_type`字段采用核心分类设计，通过与`feature`字段结合使用，可实现更精细的行为分类：

### 核心业务类型

| 业务类型 | 描述 | 适用场景 |
|----------|------|----------|
| view | 页面/内容浏览 | 任何类型的页面访问、商品详情浏览、文章阅读等 |
| click | 点击行为 | 按钮点击、商品推荐点击、广告点击等 |
| search | 搜索行为 | 用户搜索操作 |
| login | 用户登录 | 登录系统 |
| register | 用户注册 | 注册新账号 |
| cart | 购物车操作 | 加入购物车、移除商品等 |
| favorite | 收藏操作 | 收藏商品、内容等 |
| order | 下单行为 | 创建订单 |
| pay | 支付行为 | 完成支付 |
| comment | 评论行为 | 发表评论、回复等 |
| share | 分享行为 | 分享内容到社交媒体等 |

## 业务类型使用规范

为确保数据一致性，我们采用"核心类型+feature详情"的方式记录用户行为：

### 1. 浏览类型细分(view)

使用统一的`view`类型，通过`feature.view_type`区分具体子类型：

```json
// 商品详情页浏览
{
  "view_type": "product",
  "product_id": 12345,
  "category_id": 42,
  "source": "recommendation"  // 如果是推荐来源
}

// 文章阅读
{
  "view_type": "article",
  "article_id": 789,
  "read_percent": 0.85,  // 阅读进度
  "time_spent": 127  // 阅读时间(秒)
}

// 分类页浏览
{
  "view_type": "category",
  "category_id": 42,
  "products_count": 24,
  "filter_applied": true
}

// 首页浏览
{
  "view_type": "homepage",
  "sections_visible": ["banner", "hot_products", "recommendations"]
}
```

### 2. 点击行为细分(click)

使用统一的`click`类型，通过`feature.click_type`区分具体子类型：

```json
// 推荐商品点击
{
  "click_type": "recommendation",
  "item_id": 12345,
  "position": 3,
  "scenario": "home_page",
  "rec_id": "20250330_home_rec"
}

// 广告点击
{
  "click_type": "ad",
  "ad_id": "summer_sale_2025",
  "position": "banner_top",
  "campaign_id": "summer_2025"
}

// 导航菜单点击
{
  "click_type": "navigation",
  "menu_item": "categories",
  "destination": "/categories"
}
```

### 3. 购物车操作(cart)

使用`cart`类型，通过`feature.action`区分具体操作：

```json
// 添加到购物车
{
  "action": "add",
  "quantity": 2,
  "price": 299.99,
  "source": "product_detail"
}

// 从购物车移除
{
  "action": "remove",
  "item_id": 12345,
  "cart_id": "cart_user_123"
}

// 更新购物车商品数量
{
  "action": "update_quantity",
  "quantity": 5,
  "previous_quantity": 2
}
```

## 与推荐系统集成

推荐系统会监听所有`business_type="view"`且`feature.view_type="product"`的记录，并检查以下条件：

1. **对于点击事件**：
   - 当`feature.source="recommendation"`时映射为`is_clicked=1`

2. **对于转化事件**：
   - 监听`business_type=order`或`business_type=pay`
   - 当相关商品之前通过推荐点击时映射为`is_converted=1`

这种方案的优点：
- 统一了基本行为类型，减少类型重叠
- 通过`feature`字段提供丰富的上下文信息
- 保持了系统的扩展性和灵活性
- 简化了数据分析和查询

## 用户识别与游客处理

系统支持同时追踪登录用户和游客行为：

1. **登录用户**：
   - `member_id`填写实际用户ID
   - `user_sign`可使用格式：`user_[用户ID]_[时间戳]`

2. **游客用户**：
   - `member_id`保持为null
   - `user_sign`使用设备生成的唯一标识，格式建议：`guest_[设备ID]_[时间戳]`
   - `feature`中可添加`{"is_guest": true}`标记

## 数据分析面板使用指南

dskk_dau表可用于构建多种数据分析面板：

### 用户活跃度分析
- **日活用户(DAU)**：统计每日`business_type=login`的去重`member_id`数量
- **月活用户(MAU)**：统计每月`business_type=login`的去重`member_id`数量
- **游客比例**：统计`member_id IS NULL`的记录占比

### 用户行为漏斗
可构建从浏览到购买的完整漏斗：
1. 浏览商品：`business_type=view AND feature.view_type="product"`
2. 加入购物车：`business_type=cart AND feature.action="add"`
3. 创建订单：`business_type=order`
4. 完成支付：`business_type=pay`

### 热门商品分析
- 浏览量最高：`business_type=view AND feature.view_type="product"`按`business_id`分组统计
- 购买率最高：商品购买次数与浏览次数的比率

## 处理器职责分离

系统中处理器职责明确分离：

1. **RecommendationEventsProcessor**:
   - 负责处理推荐相关的事件
   - 监听`business_type=view AND feature.view_type="product" AND feature.source="recommendation"`
   - 更新unified_recommendation_records表

2. **ProductProcessor**:
   - 负责处理商品数据，更新Milvus向量库
   - 不负责更新unified_recommendation_records表
   - 专注于维护商品向量索引，支持语义搜索

3. **AnalyticsProcessor**:
   - 负责处理用于数据分析的事件
   - 汇总统计数据到分析表
   - 生成报表数据

4. **UserActivityProcessor**:
   - 负责处理用户活跃度相关事件（登录、注册等）
   - 更新用户活跃度统计
   - 计算DAU/MAU指标

各处理器完全独立，确保职责清晰，避免数据混乱。

## 注意事项

1. `user_sign`必须唯一标识一次会话，建议使用格式：类型前缀_ID_时间戳
2. `business_id`根据业务类型的不同指向不同实体的ID
3. `business_type`应使用核心类型，具体细节通过`feature`字段区分
4. **针对推荐系统的事件，需设置`feature.source="recommendation"`和`feature.view_type="product"`**
5. 游客行为应通过`member_id`为空和特殊的`user_sign`前缀识别
6. 确保JSON格式正确，否则无法被正确解析

## 实现代码示例

### 记录商品页面浏览(推荐来源)
```javascript
function recordProductView(productId, userId, recommendationInfo) {
  const eventData = {
    member_id: userId,
    business_type: "view",
    business_id: productId,
    user_sign: `user_${userId}_${Date.now()}`,
    feature: JSON.stringify({
      view_type: "product",
      source: "recommendation",
      scenario: recommendationInfo.scenario,
      position: recommendationInfo.position,
      rec_id: recommendationInfo.recId
    })
  };
  
  api.recordUserEvent(eventData);
}
```

### 记录文章阅读
```javascript
function recordArticleRead(articleId, userId, readPercent, timeSpent) {
  const eventData = {
    member_id: userId,
    business_type: "view",
    business_id: articleId,
    user_sign: `user_${userId}_${Date.now()}`,
    feature: JSON.stringify({
      view_type: "article",
      read_percent: readPercent,
      time_spent: timeSpent,
      source: "featured_articles"
    })
  };
  
  api.recordUserEvent(eventData);
}
```

### 记录用户登录事件
```javascript
function recordUserLogin(userId, loginMethod) {
  const eventData = {
    member_id: userId,
    business_type: "login",
    business_id: userId,  // 业务ID为用户自身ID
    user_sign: `user_${userId}_${Date.now()}`,
    feature: JSON.stringify({
      login_method: loginMethod,  // 如"password", "wechat", "sms"等
      login_success: true,
      device_id: getDeviceId()
    })
  };
  
  api.recordUserEvent(eventData);
}
```

### 记录购物车操作
```javascript
function recordCartAction(itemId, userId, action, quantity) {
  const eventData = {
    member_id: userId || null,  // 游客可以为null
    business_type: "cart",
    business_id: itemId,
    user_sign: userId ? `user_${userId}_${Date.now()}` : `guest_${getDeviceId()}_${Date.now()}`,
    feature: JSON.stringify({
      action: action,  // "add", "remove", "update_quantity"
      quantity: quantity,
      is_guest: !userId,
      item_price: getItemPrice(itemId)
    })
  };
  
  api.recordUserEvent(eventData);
}