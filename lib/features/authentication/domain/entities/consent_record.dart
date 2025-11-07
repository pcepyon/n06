import 'package:equatable/equatable.dart';

/// ConsentRecord entity representing user consent for terms and policies
class ConsentRecord extends Equatable {
  final String id;
  final String userId;
  final bool termsOfService;
  final bool privacyPolicy;
  final DateTime agreedAt;

  const ConsentRecord({
    required this.id,
    required this.userId,
    required this.termsOfService,
    required this.privacyPolicy,
    required this.agreedAt,
  });

  ConsentRecord copyWith({
    String? id,
    String? userId,
    bool? termsOfService,
    bool? privacyPolicy,
    DateTime? agreedAt,
  }) {
    return ConsentRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      termsOfService: termsOfService ?? this.termsOfService,
      privacyPolicy: privacyPolicy ?? this.privacyPolicy,
      agreedAt: agreedAt ?? this.agreedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        termsOfService,
        privacyPolicy,
        agreedAt,
      ];
}
