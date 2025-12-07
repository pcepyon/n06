import 'package:n06/features/dashboard/domain/entities/ai_generated_message.dart';
import 'package:n06/features/dashboard/domain/entities/llm_context.dart';

/// Repository interface for AI-generated message operations.
///
/// Handles storage and retrieval of AI-generated contextual messages
/// that are displayed on the dashboard to provide empathetic support
/// based on user's journey context.
abstract class AIMessageRepository {
  /// Saves an AI-generated message to storage.
  ///
  /// This is typically called by Edge Function after LLM generates a message.
  Future<void> saveMessage(AIGeneratedMessage message);

  /// Retrieves the most recent message for a user.
  ///
  /// Returns null if no messages exist.
  Future<AIGeneratedMessage?> getLatestMessage(String userId);

  /// Retrieves recent messages for a user (for tone consistency).
  ///
  /// [limit] specifies how many recent messages to fetch (default: 7).
  /// Messages are returned in descending order (newest first).
  Future<List<AIGeneratedMessage>> getRecentMessages(
    String userId, {
    int limit = 7,
  });

  /// Retrieves the message generated today for a user.
  ///
  /// Returns null if no message was generated today.
  /// Used to avoid generating duplicate messages on the same day.
  Future<AIGeneratedMessage?> getTodayMessage(String userId);

  /// Generates a new AI message by calling Edge Function.
  ///
  /// This method calls the generate-ai-message Edge Function which:
  /// 1. Sends context to OpenRouter API
  /// 2. Generates empathetic message using LLM
  /// 3. Saves message to database
  /// 4. Returns the generated message
  ///
  /// The Edge Function handles OpenRouter API key securely on server side.
  /// If API call fails, it falls back to the last successful message.
  Future<AIGeneratedMessage> generateMessage({
    required LLMContext context,
  });
}
