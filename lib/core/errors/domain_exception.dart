/// Domain Layer에서 발생하는 예외
class DomainException implements Exception {
  final String message;
  final String? code;

  DomainException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'DomainException: $message${code != null ? ' ($code)' : ''}';
}
