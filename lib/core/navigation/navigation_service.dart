import 'package:flutter/material.dart';

/// Abstract interface for a navigation service.
/// This allows decoupling navigation logic from the UI and makes it testable.
abstract class NavigationService {
  GlobalKey<NavigatorState>? get navigatorKey;

  /// Navigates to a named route.
  ///
  /// [routeName] The name of the route to navigate to.
  /// [arguments] Optional arguments to pass to the route.
  Future<T?>? navigateTo<T extends Object?>(String routeName, {Object? arguments});

  /// Navigates back to the previous route.
  ///
  /// [result] Optional result to pass back to the previous route.
  void goBack<T extends Object?>([T? result]);
} 