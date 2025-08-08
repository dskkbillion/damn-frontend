import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration validator for required environment variables
/// This validator ensures all necessary configuration is present before app starts
class ConfigValidator {
  /// List of required environment variables
  static const List<String> requiredVariables = [
    'BACKEND_BASE_URL',
    'MODEL_BASE_URL',
  ];

  /// List of optional environment variables with descriptions
  static const Map<String, String> optionalVariables = {
    'WECHAT_APP_ID': 'Required for WeChat login/payment',
    'WECHAT_UNIVERSAL_LINK': 'Required for WeChat on iOS',
    'INTERNATIONAL_API_URL': 'Optional: International API URL (defaults to BACKEND_BASE_URL)',
    'INTERNATIONAL_MODEL_URL': 'Optional: International model URL (defaults to MODEL_BASE_URL)',
  };

  /// Validates that all required environment variables are present
  /// Throws [ConfigurationException] if any required variable is missing
  static void validateRequired() {
    final List<String> missingVariables = [];
    
    for (final variable in requiredVariables) {
      final value = dotenv.env[variable];
      if (value == null || value.isEmpty) {
        missingVariables.add(variable);
      }
    }
    
    if (missingVariables.isNotEmpty) {
      throw ConfigurationException(
        'Missing required environment variables: ${missingVariables.join(', ')}\n'
        'Please ensure all required variables are set in your .env file.',
        missingVariables: missingVariables,
      );
    }
  }

  /// Validates optional environment variables and returns warnings
  static List<String> validateOptional() {
    final List<String> warnings = [];
    
    optionalVariables.forEach((variable, description) {
      final value = dotenv.env[variable];
      if (value == null || value.isEmpty) {
        warnings.add('$variable is not set. $description');
      }
    });
    
    return warnings;
  }

  /// Performs full validation of all environment variables
  /// Returns true if all required variables are present
  static bool validate({bool throwOnError = true}) {
    try {
      validateRequired();
      
      // Check for optional variables and log warnings
      final warnings = validateOptional();
      if (warnings.isNotEmpty) {
        print('Configuration warnings:');
        for (final warning in warnings) {
          print('  - $warning');
        }
      }
      
      return true;
    } catch (e) {
      if (throwOnError) {
        rethrow;
      }
      print('Configuration validation failed: $e');
      return false;
    }
  }

  /// Gets a required environment variable
  /// Throws [ConfigurationException] if the variable is not set
  static String getRequired(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw ConfigurationException(
        'Required environment variable "$key" is not set.\n'
        'Please add it to your .env file.',
        missingVariables: [key],
      );
    }
    return value;
  }

  /// Gets an optional environment variable with a fallback
  /// This should only be used for truly optional variables
  static String? getOptional(String key) {
    final value = dotenv.env[key];
    return (value != null && value.isNotEmpty) ? value : null;
  }

  /// Prints a helpful message about required configuration
  static void printConfigurationHelp() {
    print('\n===== Configuration Requirements =====');
    print('\nRequired environment variables:');
    for (final variable in requiredVariables) {
      print('  - $variable');
    }
    
    print('\nOptional environment variables:');
    optionalVariables.forEach((variable, description) {
      print('  - $variable: $description');
    });
    
    print('\nExample .env file:');
    print('---');
    print('BACKEND_BASE_URL=https://your-api-server.com/api');
    print('MODEL_BASE_URL=http://your-model-server.com:5107');
    print('WECHAT_APP_ID=your_wechat_app_id');
    print('WECHAT_UNIVERSAL_LINK=https://your-domain.com/wechat/');
    print('---\n');
  }
}

/// Exception thrown when configuration validation fails
class ConfigurationException implements Exception {
  final String message;
  final List<String> missingVariables;

  ConfigurationException(this.message, {this.missingVariables = const []});

  @override
  String toString() => 'ConfigurationException: $message';
}