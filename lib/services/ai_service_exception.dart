class AIServiceException implements Exception {
  final String source;
  final String message;
  final int? statusCode;
  final bool isAuthError;

  const AIServiceException({
    required this.source,
    required this.message,
    this.statusCode,
    this.isAuthError = false,
  });

  @override
  String toString() {
    final codeInfo = statusCode != null ? ' (status: $statusCode)' : '';
    return '$source error$codeInfo: $message';
  }
}
