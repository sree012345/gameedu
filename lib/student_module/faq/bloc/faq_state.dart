part of 'faq_bloc.dart';

enum FaqStatus { loading, loaded, failure }

final class FaqState extends Equatable {
  const FaqState({
    this.status = FaqStatus.loading,
    this.items = const [],
    this.query = '',
    this.category,
    this.expandedId,
  });

  final FaqStatus status;

  /// All the FAQs.
  final List<FaqItem> items;

  /// Text of the search box.
  final String query;

  /// Selected chip. null = All.
  final FaqCategory? category;

  /// The question that is open (only one at a time).
  final String? expandedId;

  /// What the list shows: the selected chip + the search text.
  List<FaqItem> get visible => items
      .where((f) => category == null || f.category == category)
      .where((f) => f.matches(query))
      .toList();

  FaqState copyWith({
    FaqStatus? status,
    List<FaqItem>? items,
    String? query,
    FaqCategory? category,
    String? expandedId,
    bool clearCategory = false,
    bool clearExpanded = false,
  }) {
    return FaqState(
      status: status ?? this.status,
      items: items ?? this.items,
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      expandedId: clearExpanded ? null : (expandedId ?? this.expandedId),
    );
  }

  @override
  List<Object?> get props => [status, items, query, category, expandedId];
}
