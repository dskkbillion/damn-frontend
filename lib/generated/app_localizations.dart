// Compatibility wrapper for existing code
import 'l10n.dart';
export 'l10n.dart' show S;

// Re-export S as AppLocalizations  
class AppLocalizations extends S {
  // Delegate for localization
  static const delegate = S.delegate;
  
  // Static method to get localization instance
  static S of(context) => S.of(context);
  
  // Static method to get localization instance (nullable)
  static S? maybeOf(context) => S.maybeOf(context);
}