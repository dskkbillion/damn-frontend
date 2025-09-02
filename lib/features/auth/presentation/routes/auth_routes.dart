import 'package:flutter/material.dart'; // May be needed for context/state access
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import the DI container instance
import '../../../../app/di/injection_container.dart'; // Adjust path if needed

// Import the page and bloc for this route
import '../pages/unified_login_page.dart';
import '../bloc/sms_login/sms_login_cubit.dart';

/// Defines routes specifically for the Auth feature module.
class AuthRoutes {
  // Private constructor to prevent instantiation
  AuthRoutes._();

  /// Static getter for the list of routes defined in this module.
  static List<RouteBase> get routes => _routes;

  // --- Route Paths ---
  static const String loginPath = '/login'; 
  // Add other paths like /register, /forgotPassword if needed

  // Define the routes for this module
  static final List<RouteBase> _routes = [
    GoRoute(
      path: loginPath, // Use the constant
      name: 'login',   // Optional route name
      // Wrap UnifiedLoginPage with BlocProvider for SmsLoginCubit
      builder: (context, state) => BlocProvider(
        // Use GetIt (imported from injection_container) to create the Cubit instance
        create: (_) => getIt<SmsLoginCubit>(),
        child: const UnifiedLoginPage(), 
      ),
      // TODO: Add sub-routes if needed for the login flow
    ),
    // TODO: Add other routes for the auth module 
    // e.g., GoRoute(path: '/register', builder: ...),
  ];
} 