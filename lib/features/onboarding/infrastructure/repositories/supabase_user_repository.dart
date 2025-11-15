import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/user_repository.dart';

/// Supabase implementation of UserRepository
class SupabaseUserRepository implements UserRepository {
  final SupabaseClient _supabase;

  SupabaseUserRepository(this._supabase);

  @override
  Future<void> updateUserName(String userId, String name) async {
    final result = await _supabase
        .from('users')
        .update({'name': name})
        .eq('id', userId)
        .select();

    if (result.isEmpty) {
      throw Exception('사용자를 찾을 수 없습니다: $userId');
    }
  }

  @override
  Future<domain.User?> getUser(String userId) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;

    // Convert authentication user to onboarding user entity
    return domain.User(
      id: response['id'] as String,
      name: response['name'] as String,
      createdAt: DateTime.parse(response['created_at'] as String),
    );
  }

  @override
  Future<void> saveUser(domain.User user) async {
    // Onboarding should not create users.
    // Users are created during authentication flow.
    throw UnimplementedError(
      'Onboarding should not create users. Users are created during authentication.',
    );
  }
}
