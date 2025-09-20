# 聊天室内订单状态追踪功能

## 一、需求背景

### 当前问题
在轻咨询模式下（Issue #105），用户体验流程是：
1. 用户在聊天室与顾问对话
2. 5轮对话后显示付费提示
3. 用户点击付费按钮 → 跳转支付页面 → 完成支付
4. **问题出现**：返回聊天室后，用户不知道：
   - 支付是否成功？
   - 能否继续咨询？
   - 订单当前是什么状态？

### 用户痛点
- **信息断层**：付费后看不到任何反馈，产生焦虑
- **重复提示**：已付费用户可能再次看到付费提示
- **查看不便**：需要退出聊天室去订单列表查看状态

### 需求目标
在聊天室内直接展示订单状态，让用户清楚知道付费情况和咨询进度。

## 二、技术分析

### 现有基础
1. **聊天室数据结构**
   - 已有 `productId`（商品ID）
   - 已有 `productName`（商品名称）
   - 已有商品价格、图片等信息

2. **订单数据结构**
   - 有 `feature` 字段（JSONObject类型，可存扩展信息）
   - 支持 `keyword` 搜索（可搜商品名称）
   - 订单包含商品信息（order_item表）

3. **关键问题**
   - 商品名称可能重复，不够精确
   - 订单与聊天室没有直接关联
   - 需要能精确找到"这个聊天室产生的订单"

## 三、解决方案

### 方案选择：路径2 + productId精确查询

#### 核心思路
1. 订单创建时，在 `feature` 字段存储 `chatRoomId`
2. 增加 `productId` 精确查询能力
3. 前端通过 `productId` 查询订单，再用 `chatRoomId` 精确匹配

#### 为什么选这个方案？
- **改动最小**：利用现有 feature 字段，不改表结构
- **查询精确**：productId 是唯一的，避免商品名重复问题
- **易于实现**：前后端改动都很少

## 四、实施方案

### 后端改动（预计0.5天）

#### 1. 订单创建接口改造
**文件**：`OrderService.java`
**改动**：创建订单时存储聊天室关联信息
```java
// 在createOrder方法中添加
if (request.getChatRoomId() != null) {
    JSONObject feature = order.getFeature() != null
        ? order.getFeature()
        : new JSONObject();
    feature.put("chatRoomId", request.getChatRoomId());
    feature.put("productId", request.getProductId());
    feature.put("createFrom", "chat"); // 标记来源
    order.setFeature(feature);
}
```

#### 2. 订单查询接口增强
**文件**：`OrderQuery.java`
**改动**：支持按productId精确查询
```java
// 添加字段
private Long productId;

// 在buildQueryWrapper方法中添加查询逻辑
if (productId != null) {
    // 查询包含该商品的订单
    Set<Long> orderIds = orderItemService.lambdaQuery()
        .eq(OrderItem::getProductId, productId)
        .list()
        .stream()
        .map(OrderItem::getOrderId)
        .collect(Collectors.toSet());

    if (!orderIds.isEmpty()) {
        queryWrapper.in(Order::getId, orderIds);
    }
}
```

#### 3. 接口协议
**创建订单请求**：
```json
POST /api/shop/order/create
{
  "productId": 123,
  "variantId": 456,
  "chatRoomId": 789,  // 新增字段
  // ... 其他字段
}
```

**查询订单请求**：
```json
POST /api/project/order/list
{
  "productId": 123,  // 新增：按商品ID查询
  "pageNum": 1,
  "pageSize": 10,
  "type": "buyer"
}
```

**订单响应**（feature字段包含关联信息）：
```json
{
  "id": 10001,
  "orderSn": "ORD202412001",
  "state": "awaitingPayment",
  "feature": {
    "chatRoomId": 789,
    "productId": 123,
    "createFrom": "chat"
  },
  // ... 其他字段
}
```

### 前端改动（预计1天）

#### 1. 修改付费跳转逻辑
**文件**：`payment_prompt_bubble.dart`
```dart
// 付费按钮点击时传递chatRoomId
ElevatedButton(
  onPressed: () {
    context.push(
      '/product/$productId/purchase'
      '?variantId=${variant['id']}'
      '&chatRoomId=$chatRoomId'  // 传递聊天室ID
    );
  },
)
```

#### 2. 创建订单时传递chatRoomId
**文件**：`order_remote_data_source_impl.dart`
```dart
Future<OrderCreationResult> createOrder({
  required int productId,
  required int variantId,
  int? chatRoomId,  // 新增参数
  // ... 其他参数
}) async {
  final response = await coreDioClient.post(
    '/api/shop/order/create',
    data: {
      'productId': productId,
      'variantId': variantId,
      'chatRoomId': chatRoomId,  // 传递给后端
      // ... 其他字段
    },
  );
}
```

#### 3. 新增订单状态组件
**文件**：`chat_order_status_bar.dart`（新建）
```dart
class ChatOrderStatusBar extends StatefulWidget {
  final ChatRoom chatRoom;
  final int chatRoomId;

  @override
  _ChatOrderStatusBarState createState() => _ChatOrderStatusBarState();
}

class _ChatOrderStatusBarState extends State<ChatOrderStatusBar> {
  Order? _currentOrder;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadOrder();
    // 每30秒刷新一次
    _refreshTimer = Timer.periodic(
      Duration(seconds: 30),
      (_) => _loadOrder()
    );
  }

  Future<void> _loadOrder() async {
    final orderRepo = getIt<IOrderRepository>();

    // 使用productId精确查询
    final result = await orderRepo.getOrderList(
      productId: widget.chatRoom.productId,
      userRole: _getUserRole(),
      page: 1,
      limit: 10,
    );

    result.fold(
      (failure) => print('查询失败: $failure'),
      (orders) {
        // 优先匹配chatRoomId
        final matchedOrder = orders.firstWhere(
          (order) {
            final feature = order.feature as Map<String, dynamic>?;
            return feature?['chatRoomId'] == widget.chatRoomId;
          },
          orElse: () => orders.first,  // 没有匹配就用最新的
        );

        setState(() {
          _currentOrder = matchedOrder;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentOrder == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(_currentOrder!.state).withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: _getStatusColor(_currentOrder!.state),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shopping_bag,
            size: 16,
            color: _getStatusColor(_currentOrder!.state),
          ),
          SizedBox(width: 8),
          Text(
            '订单${_getSimplifiedStatus(_currentOrder!.state)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _getStatusColor(_currentOrder!.state),
            ),
          ),
          Spacer(),
          if (_currentOrder!.state == OrderStatus.awaitingPayment)
            TextButton(
              onPressed: () => _navigateToPayment(),
              child: Text('去支付'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
              ),
            )
          else
            TextButton(
              onPressed: () => _navigateToOrderDetail(),
              child: Text('查看详情'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
              ),
            ),
        ],
      ),
    );
  }
}
```

#### 4. 集成到聊天室页面
**文件**：`chat_room_page_refactored.dart`
```dart
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      // 订单状态栏（新增）
      if (chatRoom.productId != null)
        ChatOrderStatusBar(
          chatRoom: chatRoom,
          chatRoomId: widget.chatId,
        ),

      // 商品信息头部（原有）
      if (_showProductHeader && chatRoom.hasProduct)
        ProductChatHeader(...),

      // 聊天消息列表（原有）
      Expanded(
        child: CustomChatList(...),
      ),
    ],
  );
}
```

## 五、前后端协调流程

### 开发流程
1. **后端先行**（Day 1 上午）
   - 实现 productId 查询功能
   - 修改订单创建接口支持 chatRoomId
   - 提供接口文档

2. **前端开发**（Day 1 下午 - Day 2 上午）
   - 根据接口文档调整订单创建调用
   - 开发 ChatOrderStatusBar 组件
   - 集成到聊天室页面

3. **联调测试**（Day 2 下午）
   - 测试订单创建流程
   - 验证订单状态显示
   - 边界情况处理

### 接口约定
- 后端保证向后兼容：chatRoomId 是可选字段
- 前端做好降级：查询失败不影响聊天功能
- 订单状态使用现有枚举，不新增状态

### 测试要点
1. 新订单创建后能正确关联聊天室
2. 通过 productId 能查询到相关订单
3. feature 字段正确存储和返回
4. 订单状态变化后前端能更新显示

## 六、风险与应对

1. **性能风险**：频繁查询订单
   - 应对：30秒刷新间隔，避免频繁请求

2. **数据一致性**：多个聊天室对应同一商品
   - 应对：通过 chatRoomId 精确匹配

3. **兼容性**：旧订单没有 chatRoomId
   - 应对：降级显示最新订单

## 七、预期效果

### 用户体验改进
- ✅ 付费后立即看到"已付费"状态
- ✅ 实时查看订单进度
- ✅ 不再重复显示付费提示
- ✅ 可快速跳转支付或查看详情

### 技术收益
- 代码改动少，风险可控
- 数据关联清晰
- 易于后续扩展（如推送通知）

---

**相关Issue**: #105 (轻咨询功能)
**分支**: refactor/light-consultation
**优先级**: 高
**标签**: enhancement, 轻咨询