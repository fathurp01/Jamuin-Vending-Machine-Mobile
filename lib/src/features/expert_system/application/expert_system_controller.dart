import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/expert_models.dart';
import 'expert_system_providers.dart';

sealed class ExpertSystemUiState {
  const ExpertSystemUiState();
}

final class ExpertInitial extends ExpertSystemUiState {
  const ExpertInitial();
}

final class ExpertLoading extends ExpertSystemUiState {
  const ExpertLoading();
}

final class ExpertQuestionState extends ExpertSystemUiState {
  const ExpertQuestionState({
    required this.sessionId,
    required this.question,
    required this.answered,
  });

  final String sessionId;
  final ExpertQuestion question;
  final List<AnsweredExpertQuestion> answered;
}

final class ExpertRecommendationState extends ExpertSystemUiState {
  const ExpertRecommendationState({
    required this.recommendation,
    required this.answered,
  });

  final ExpertRecommendation recommendation;
  final List<AnsweredExpertQuestion> answered;
}

final class ExpertError extends ExpertSystemUiState {
  const ExpertError(this.message);

  final String message;
}

class AnsweredExpertQuestion {
  const AnsweredExpertQuestion({
    required this.questionText,
    required this.answerText,
  });

  final String questionText;
  final String answerText;
}

class ExpertSystemController extends Notifier<ExpertSystemUiState> {
  @override
  ExpertSystemUiState build() => const ExpertInitial();

  final _answered = <AnsweredExpertQuestion>[];

  List<AnsweredExpertQuestion> get answered => List.unmodifiable(_answered);

  Future<void> start() async {
    state = const ExpertLoading();
    try {
      final repo = ref.read(expertSystemRepositoryProvider);
      await repo.initialize();
      final started = await repo.start();

      final q = started.nextQuestion;
      if (q == null) {
        state = const ExpertError('No questions available.');
        return;
      }

      _answered.clear();
      state = ExpertQuestionState(
        sessionId: started.sessionId,
        question: q,
        answered: answered,
      );
    } catch (e, stack) {
      print('❌ Expert System start error: $e');
      print('   Stack: $stack');
      state = ExpertError('Failed to start consultation: ${e.toString()}');
    }
  }

  Future<void> submit({
    required String sessionId,
    required ExpertQuestion question,
    required ExpertOption option,
  }) async {
    _answered.add(
      AnsweredExpertQuestion(
        questionText: question.text,
        answerText: option.text,
      ),
    );

    state = const ExpertLoading();
    try {
      final repo = ref.read(expertSystemRepositoryProvider);
      final result = await repo.diagnose(
        sessionId: sessionId,
        questionId: question.id,
        selectedOptionId: option.id,
      );

      if (result.isComplete) {
        final rec = result.recommendation;
        if (rec == null) {
          state = const ExpertError(
            'Diagnosis completed but no recommendation returned.',
          );
          return;
        }
        state = ExpertRecommendationState(
          recommendation: rec,
          answered: answered,
        );
        return;
      }

      final next = result.nextQuestion;
      if (next == null) {
        state = const ExpertError('No next question returned.');
        return;
      }

      state = ExpertQuestionState(
        sessionId: result.sessionId,
        question: next,
        answered: answered,
      );
    } catch (e, stack) {
      print('❌ Expert System submit error: $e');
      print('   Stack: $stack');

      // Check if it's a session expired error (404)
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('404') || errorMsg.contains('session not found')) {
        state = const ExpertError(
          'Session expired. Please restart the consultation.',
        );
      } else {
        state = ExpertError('Failed to submit answer: ${e.toString()}');
      }
    }
  }

  void reset() {
    _answered.clear();
    state = const ExpertInitial();
  }
}

final expertSystemControllerProvider =
    NotifierProvider<ExpertSystemController, ExpertSystemUiState>(
      ExpertSystemController.new,
    );
