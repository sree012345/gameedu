import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// FAQ groups. [general] questions are shown only under "All".
enum FaqCategory { general, classes, chat, events }

extension FaqCategoryLabel on FaqCategory {
  String get label {
    switch (this) {
      case FaqCategory.general:
        return 'General';
      case FaqCategory.classes:
        return 'Classes';
      case FaqCategory.chat:
        return 'Chat';
      case FaqCategory.events:
        return 'Events';
    }
  }
}

/// One question with its answer.
class FaqItem extends Equatable {
  const FaqItem({
    required this.id,
    required this.category,
    required this.icon,
    required this.question,
    required this.answer,
  });

  final String id;
  final FaqCategory category;
  final IconData icon;
  final String question;
  final String answer;

  /// Search: the text is looked for in the question and in the answer.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return question.toLowerCase().contains(q) || answer.toLowerCase().contains(q);
  }

  @override
  List<Object?> get props => [id, category, question, answer];
}
