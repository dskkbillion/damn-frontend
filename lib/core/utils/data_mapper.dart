/// Utility class for safely parsing data, often from JSON maps.
class DataMapper {
  /// Safely parses an integer from [value]. Returns 0 if parsing fails or value is null.
  static int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  /// Safely parses a nullable integer from [value]. Returns null if parsing fails or value is null.
  static int? toIntN(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
     if (value is double) return value.toInt();
    return null;
  }

  /// Safely parses a double from [value]. Returns 0.0 if parsing fails or value is null.
   static double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Safely parses a nullable double from [value]. Returns null if parsing fails or value is null.
  static double? toDoubleN(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Safely parses a string from [value]. Returns an empty string if value is null or not a string.
  static String toStringVal(dynamic value, {String fallback = ''}) {
    return value?.toString() ?? fallback;
  }

   /// Safely parses a nullable string from [value]. Returns null if value is null.
  static String? toStringN(dynamic value) {
    return value?.toString();
  }

  /// Safely parses a nullable DateTime from [value] (assuming ISO 8601 string). Returns null if parsing fails.
  static DateTime? toDateTimeN(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    // Add handling for other potential date formats if needed
    return null;
  }

   /// Safely parses a nullable list of strings from [value].
  /// Assumes value is List<dynamic> where elements can be converted to string.
  static List<String>? toStringListN(dynamic value) {
    if (value is List) {
      return value.map((e) => e?.toString()).whereType<String>().toList();
    }
    return null;
  }

   /// Safely parses a boolean from [value]. Returns false if value is null or not a boolean.
  static bool toBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return false;
  }

  /// Safely parses a nullable boolean from [value]. Returns null if value is null.
  static bool? toBoolN(dynamic value) {
     if (value == null) return null;
    if (value is bool) return value;
     if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return null; // Or throw an error if strict parsing is needed
  }
} 