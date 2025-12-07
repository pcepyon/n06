import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/ai_generated_message.dart';
import '../../domain/entities/llm_context.dart';
import '../../domain/repositories/ai_message_repository.dart';
import '../dtos/ai_generated_message_dto.dart';

/// Supabase implementation of AIMessageRepository.
///
/// Manages AI-generated messages in Supabase database.
/// Messages are typically created by Edge Function and read by Flutter app.
class SupabaseAIMessageRepository implements AIMessageRepository {
  final SupabaseClient _supabase;

  SupabaseAIMessageRepository(this._supabase);

  @override
  Future<void> saveMessage(AIGeneratedMessage message) async {
    final dto = AIGeneratedMessageDto.fromEntity(message);
    await _supabase.from('ai_generated_messages').insert(dto.toJson());
  }

  @override
  Future<AIGeneratedMessage?> getLatestMessage(String userId) async {
    final response = await _supabase
        .from('ai_generated_messages')
        .select()
        .eq('user_id', userId)
        .order('generated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;

    return AIGeneratedMessageDto.fromJson(response).toEntity();
  }

  @override
  Future<List<AIGeneratedMessage>> getRecentMessages(
    String userId, {
    int limit = 7,
  }) async {
    final response = await _supabase
        .from('ai_generated_messages')
        .select()
        .eq('user_id', userId)
        .order('generated_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => AIGeneratedMessageDto.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<AIGeneratedMessage?> getTodayMessage(String userId) async {
    // Get today's date range (start of day to end of day)
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final response = await _supabase
        .from('ai_generated_messages')
        .select()
        .eq('user_id', userId)
        .gte('generated_at', todayStart.toUtc().toIso8601String())
        .lt('generated_at', todayEnd.toUtc().toIso8601String())
        .order('generated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;

    return AIGeneratedMessageDto.fromJson(response).toEntity();
  }

  @override
  Future<AIGeneratedMessage> generateMessage({
    required LLMContext context,
  }) async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      throw Exception('Not authenticated');
    }

    final response = await _supabase.functions.invoke(
      'generate-ai-message',
      headers: {
        'Authorization': 'Bearer ${session.accessToken}',
      },
      body: context.toJson(),
    );

    if (response.status != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to generate message');
    }

    final data = response.data;
    if (data == null || data['success'] != true) {
      throw Exception(
          'Failed to generate message: ${data?['error'] ?? 'Unknown error'}');
    }

    final message = data['message'] as String;

    // Return generated message as entity
    // Note: The Edge Function has already saved it to database
    return AIGeneratedMessage(
      id: '', // DB generates this
      userId: session.user.id,
      message: message,
      contextSnapshot: context.toJson(),
      generatedAt: DateTime.now(),
      triggerType: context.triggerType,
    );
  }
}
