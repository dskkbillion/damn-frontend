import 'package:go_router/go_router.dart';
import '../pages/profile_page.dart'; // 引入 ProfilePage
// import '../pages/simple_profile_page.dart'; // 不再需要 SimpleProfilePage
// import '../pages/edit_profile_page.dart'; // 如果有其他页面

class ProfileRoutes {
  ProfileRoutes._(); // 私有构造函数，防止实例化

  // 通过静态 getter 暴露路由列表
  static List<RouteBase> get routes => _routes;

  // 模块内部路由定义
  static final List<RouteBase> _routes = [
    GoRoute(
      path: '/profile', 
      name: 'profile', // 建议添加 name
      builder: (context, state) => const ProfilePage(),
    ),
    // GoRoute(
    //   path: '/profile/edit', 
    //   name: 'editProfile',
    //   builder: (context, state) => const EditProfilePage(),
    // ),
    // ... 其他 profile 模块路由 ...
  ];
} 