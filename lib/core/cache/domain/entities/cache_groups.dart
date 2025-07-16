/// 缓存组定义
/// 
/// 用于组织和管理不同类型的缓存数据
class CacheGroups {
  /// 用户相关数据
  /// 包括：用户信息、用户设置、用户权限等
  static const String user = 'user';
  
  /// 商品相关数据
  /// 包括：商品详情、商品图片信息等
  static const String product = 'product';
  
  /// 分类相关数据
  /// 包括：商品分类树、分类详情等
  static const String category = 'category';
  
  /// 订单相关数据
  /// 包括：订单详情、订单状态等
  static const String order = 'order';
  
  /// 聊天相关数据
  /// 包括：聊天室信息、最近消息等
  static const String chat = 'chat';
  
  /// 搜索相关数据
  /// 包括：搜索结果、搜索建议、热搜词等
  static const String search = 'search';
  
  /// 配置相关数据
  /// 包括：应用配置、远程配置等
  static const String config = 'config';
  
  /// 临时数据
  /// 包括：临时计算结果、短期缓存等
  static const String temporary = 'temp';
  
  /// HTTP响应缓存
  /// 包括：API响应数据
  static const String http = 'http';
  
  /// AI相关数据
  /// 包括：AI对话历史、推荐缓存等
  static const String ai = 'ai';
  
  /// 收藏相关数据
  static const String favorites = 'favorites';
  
  /// 卖家相关数据
  /// 包括：卖家信息、店铺数据等
  static const String seller = 'seller';

  // 私有构造函数，防止实例化
  CacheGroups._();
  
  /// 获取所有缓存组
  static List<String> get all => [
        user,
        product,
        category,
        order,
        chat,
        search,
        config,
        temporary,
        http,
        ai,
        favorites,
        seller,
      ];
      
  /// 获取需要在用户登出时清理的组
  static List<String> get userRelatedGroups => [
        user,
        order,
        chat,
        favorites,
        ai,
      ];
}