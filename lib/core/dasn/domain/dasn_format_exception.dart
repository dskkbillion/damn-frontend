/// Raised when a DASN projection/action cannot be safely decoded.
class DasnProjectionFormatException extends FormatException {
  DasnProjectionFormatException(super.message, [super.source]);
}
