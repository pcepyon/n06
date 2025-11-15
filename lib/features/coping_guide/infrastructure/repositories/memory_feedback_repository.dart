import 'package:n06/features/coping_guide/domain/entities/guide_feedback.dart';
import 'package:n06/features/coping_guide/domain/repositories/feedback_repository.dart';

/// In-memory implementation of FeedbackRepository
///
/// This is a temporary implementation that stores feedback in memory.
/// Feedback is lost when the app restarts.
///
/// For Phase 2, this should be replaced with a Supabase implementation
/// to persist feedback data and enable analytics.
class MemoryFeedbackRepository implements FeedbackRepository {
  final List<GuideFeedback> _feedbacks = [];

  @override
  Future<void> saveFeedback(GuideFeedback feedback) async {
    _feedbacks.add(feedback);
  }

  @override
  Future<List<GuideFeedback>> getFeedbacksBySymptom(String symptomName) async {
    return _feedbacks
        .where((feedback) => feedback.symptomName == symptomName)
        .toList();
  }
}
