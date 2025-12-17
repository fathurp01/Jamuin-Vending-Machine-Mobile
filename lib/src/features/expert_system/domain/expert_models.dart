class ExpertQuestion {
  const ExpertQuestion({
    required this.id,
    required this.text,
    required this.options,
  });

  final String id;
  final String text;
  final List<ExpertOption> options;

  factory ExpertQuestion.fromJson(Map<String, Object?> json) {
    return ExpertQuestion(
      id: (json['id'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
      options: ((json['options'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => ExpertOption.fromJson(e.cast<String, Object?>()))
          .toList(growable: false),
    );
  }
}

class ExpertOption {
  const ExpertOption({required this.id, required this.text});

  final String id;
  final String text;

  factory ExpertOption.fromJson(Map<String, Object?> json) {
    return ExpertOption(
      id: (json['id'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
    );
  }
}

class ExpertRecommendation {
  const ExpertRecommendation({
    required this.productId,
    required this.productName,
    required this.alasan,
  });

  final int productId;
  final String productName;
  final String alasan;

  factory ExpertRecommendation.fromJson(Map<String, Object?> json) {
    return ExpertRecommendation(
      productId: ((json['productId'] as num?) ?? 0).toInt(),
      productName: (json['productName'] as String?) ?? '',
      alasan: (json['alasan'] as String?) ?? '',
    );
  }
}

class ExpertInitResult {
  const ExpertInitResult({
    required this.message,
    required this.totalQuestions,
    required this.totalRules,
  });

  final String message;
  final int totalQuestions;
  final int totalRules;

  factory ExpertInitResult.fromJson(Map<String, Object?> json) {
    return ExpertInitResult(
      message: (json['message'] as String?) ?? '',
      totalQuestions: ((json['totalQuestions'] as num?) ?? 0).toInt(),
      totalRules: ((json['totalRules'] as num?) ?? 0).toInt(),
    );
  }
}

class ExpertStartResult {
  const ExpertStartResult({
    required this.isComplete,
    required this.sessionId,
    required this.nextQuestion,
  });

  final bool isComplete;
  final String sessionId;
  final ExpertQuestion? nextQuestion;

  factory ExpertStartResult.fromJson(Map<String, Object?> json) {
    final next = json['nextQuestion'];
    return ExpertStartResult(
      isComplete: (json['isComplete'] as bool?) ?? false,
      sessionId: (json['sessionId'] as String?) ?? '',
      nextQuestion: next is Map
          ? ExpertQuestion.fromJson(next.cast<String, Object?>())
          : null,
    );
  }
}

class ExpertDiagnoseResult {
  const ExpertDiagnoseResult({
    required this.isComplete,
    required this.sessionId,
    required this.nextQuestion,
    required this.recommendation,
  });

  final bool isComplete;
  final String sessionId;
  final ExpertQuestion? nextQuestion;
  final ExpertRecommendation? recommendation;

  factory ExpertDiagnoseResult.fromJson(Map<String, Object?> json) {
    final next = json['nextQuestion'];
    final rec = json['recommendation'];

    return ExpertDiagnoseResult(
      isComplete: (json['isComplete'] as bool?) ?? false,
      sessionId: (json['sessionId'] as String?) ?? '',
      nextQuestion: next is Map
          ? ExpertQuestion.fromJson(next.cast<String, Object?>())
          : null,
      recommendation: rec is Map
          ? ExpertRecommendation.fromJson(rec.cast<String, Object?>())
          : null,
    );
  }
}
