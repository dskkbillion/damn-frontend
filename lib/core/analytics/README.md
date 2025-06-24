# DSKK 埋点系统使用指南

本埋点系统是为DSKK Flutter项目设计的用户行为分析工具，支持自动和手动埋点，与后端 `dskk_dau` 表完全匹配。

## 功能特性

- ✅ **自动页面埋点**: 通过路由监听自动记录页面浏览和停留时间
- ✅ **BLoC事件埋点**: 自动监听BLoC事件并记录相关业务操作
- ✅ **手动精准埋点**: 提供丰富的API支持各种业务场景
- ✅ **推荐系统支持**: 专门优化的推荐点击和转化埋点
- ✅ **本地缓存**: 支持离线缓存，网络恢复后自动上报
- ✅ **批量上报**: 优化网络请求，提升性能
- ✅ **用户识别**: 自动区分登录用户和游客
- ✅ **设备信息**: 自动获取设备信息用于分析

## 快速开始

### 1. 初始化系统

在 `main.dart` 中初始化埋点系统：

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/core/analytics/di/analytics_injection.dart';
import 'lib/core/analytics/observers/router_analytics_observer.dart';
import 'lib/core/analytics/observers/analytics_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化依赖注入
  await configureDependencies();
  
  // 初始化埋点模块
  await initAnalyticsModule();
  
  // 配置BLoC观察器
  Bloc.observer = AnalyticsBlocObserver();
  
  runApp(MyApp());
}
```

### 2. 配置路由观察器

在 `GoRouter` 配置中添加路由观察器：

```dart
final router = GoRouter(
  routes: [...],
  observers: [
    RouterAnalyticsObserver(),
  ],
);
```

### 3. 在依赖注入中注册

确保在项目的依赖注入配置中包含分析模块：

```dart
@InjectableInit()
void configureDependencies() => getIt.init();
```

## 使用方法

### 自动埋点

系统会自动记录以下事件：

1. **页面浏览**: 所有路由变化自动记录
2. **BLoC事件**: 登录、订单、购物车等关键业务事件
3. **页面停留时间**: 自动计算和上报

### 手动埋点

#### 1. 商品相关埋点

```dart
import 'package:get_it/get_it.dart';
import 'lib/core/analytics/analytics_manager.dart';

final analytics = GetIt.instance<AnalyticsManager>();

// 商品浏览
await analytics.trackProductView(
  productId: 12345,
  source: 'home_page',
  position: 1,
);

// 推荐商品点击
await analytics.trackRecommendationClick(
  itemId: 12345,
  scenario: 'home_page',
  position: 1,
  recId: 'rec_20250330_001',
);
```

#### 2. 购物车操作

```dart
// 加入购物车
await analytics.trackCartAction(
  productId: 12345,
  action: 'add',
  quantity: 2,
  price: 299.99,
  sourcePage: 'product_detail',
);

// 移除商品
await analytics.trackCartAction(
  productId: 12345,
  action: 'remove',
);
```

#### 3. 订单相关

```dart
// 创建订单
await analytics.trackOrder(
  action: 'create',
  orderId: 67890,
  amount: 599.98,
  itemCount: 2,
);

// 支付成功
await analytics.trackOrder(
  action: 'pay',
  orderId: 67890,
  amount: 599.98,
);
```

#### 4. 搜索事件

```dart
await analytics.trackSearch(
  query: '手机',
  searchType: 'text',
  resultCount: 25,
);
```

#### 5. 用户登录

```dart
await analytics.trackUserLogin(
  loginMethod: 'sms',
  userId: 12345,
  success: true,
);
```

### 使用封装的Widget

系统提供了封装好的Widget，可以自动处理埋点：

#### 1. 可追踪的商品卡片

```dart
import 'lib/core/analytics/widgets/trackable_widget.dart';

TrackableProductCard(
  productId: product.id,
  source: 'home_page',
  position: index,
  onTap: () {
    Navigator.pushNamed(context, '/product/${product.id}');
  },
  child: ProductCardUI(product: product),
)
```

#### 2. 推荐商品卡片

```dart
TrackableProductCard(
  productId: product.id,
  source: 'recommendation',
  position: index,
  scenario: 'home_page',
  recId: 'rec_20250330_001',
  onTap: () {
    Navigator.pushNamed(context, '/product/${product.id}');
  },
  child: ProductCardUI(product: product),
)
```

#### 3. 可追踪的按钮

```dart
TrackableButton(
  actionName: 'add_to_cart',
  targetId: productId,
  source: 'product_detail',
  onPressed: () {
    // 执行业务逻辑
  },
  child: ElevatedButton(
    child: Text('加入购物车'),
  ),
)
```

### 页面停留时间追踪

使用 `PageTrackingMixin` 自动追踪页面停留时间：

```dart
class ProductDetailPage extends StatefulWidget {
  final int productId;
  // ...
}

class _ProductDetailPageState extends State<ProductDetailPage> 
    with PageTrackingMixin {
  
  @override
  String getPageType() => 'product_detail';
  
  @override
  int? getBusinessId() => widget.productId;
  
  @override
  String? getPageSource() => 'home_page'; // 可以从路由参数获取
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 页面内容
    );
  }
}
```

## 数据格式

### API请求格式

系统发送到后端的数据格式：

```json
{
    "path": "/product/12345",
    "businessType": "pv",
    "businessId": 12345,
    "feature": {
        "view_type": "product",
        "source": "recommendation",
        "scenario": "home_page",
        "position": 1,
        "rec_id": "rec_20250330_001",
        "is_visitor": false
    },
    "deviceInfo": {
        "branch": "Apple",
        "buildNumber": 1,
        "deviceId": "iPhone17,1",
        "deviceName": "iPhone 16 Pro",
        "platform": "iOS"
    },
    "userSign": 12345,
    "interval": 37
}
```

### 业务类型说明

| 业务类型 | 说明 | 使用场景 |
|----------|------|----------|
| `pv` | 页面浏览 | 页面访问、商品详情浏览 |
| `click` | 点击行为 | 按钮点击、商品推荐点击 |
| `cart` | 购物车操作 | 加入购物车、移除商品 |
| `search` | 搜索行为 | 用户搜索操作 |
| `order` | 下单行为 | 创建订单 |
| `pay` | 支付行为 | 完成支付 |
| `login` | 用户登录 | 登录系统 |
| `chat` | 聊天行为 | 发送消息 |

## 推荐系统集成

### 推荐商品展示埋点

```dart
// 展示推荐商品时记录
await analytics.trackEvent(
  businessType: 'recommendation_show',
  businessId: productId,
  feature: {
    'scenario': 'home_page',
    'position': 1,
    'rec_id': 'rec_20250330_001',
  },
);
```

### 推荐商品点击埋点

```dart
// 点击推荐商品时记录
await analytics.trackRecommendationClick(
  itemId: productId,
  scenario: 'home_page',
  position: 1,
  recId: 'rec_20250330_001',
);
```

## 性能优化

### 本地缓存

- 事件先缓存到本地，达到50个或5分钟后批量上报
- 应用关闭时自动保存未上报的事件
- 下次启动时自动恢复并上报

### 错误处理

- 埋点失败不会影响正常业务流程
- 自动重试机制，网络恢复后重新上报
- 详细的日志记录便于调试

### 批量上报

```dart
// 强制上报所有缓存的事件
await analytics.flush();

// 检查缓存状态
print('缓存事件数量: ${analytics.bufferedEventCount}');
print('是否正在上报: ${analytics.isUploading}');
```

## 调试和测试

### 测试连接

```dart
// 测试与后端的连接
bool isConnected = await analytics.testConnection();
print('连接状态: $isConnected');
```

### 日志输出

系统会自动输出详细的日志信息，包括：

- `[AnalyticsManager]` - 核心管理器日志
- `[EventBuffer]` - 缓存和上报日志
- `[AnalyticsApiService]` - API请求日志
- `[RouterAnalyticsObserver]` - 路由埋点日志

### 调试模式

在开发环境中，可以通过日志查看埋点数据：

```bash
flutter logs | grep Analytics
```

## 注意事项

1. **隐私保护**: 确保埋点数据符合隐私保护要求
2. **性能影响**: 埋点操作是异步的，不会阻塞UI
3. **网络优化**: 使用批量上报减少网络请求
4. **数据准确性**: 确保关键业务事件的埋点完整性
5. **错误处理**: 埋点失败不应影响正常业务功能

## 常见问题

### Q: 如何确保推荐系统的埋点准确性？

A: 使用专门的推荐埋点方法，确保包含 `scenario`、`position`、`rec_id` 等关键信息。

### Q: 页面停留时间不准确怎么办？

A: 检查是否正确使用了 `PageTrackingMixin`，确保页面有正确的路由名称。

### Q: 游客和登录用户如何区分？

A: 系统自动处理，游客使用设备生成的唯一标识，登录用户使用用户ID。

### Q: 埋点数据丢失怎么办？

A: 系统有本地缓存机制，即使网络断开也会保存数据，网络恢复后自动上报。 