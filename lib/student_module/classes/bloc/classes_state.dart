part of 'classes_bloc.dart';

enum ClassesStatus { loading, loaded, failure }

enum ClassesView { all, mine }

final class ClassesState extends Equatable {
  const ClassesState({
    this.status = ClassesStatus.loading,
    this.items = const [],
    this.view = ClassesView.all,
    this.query = '',
    this.topic,
    this.refreshing = false,
    this.error,
  });

  final ClassesStatus status;
  final List<ClassItem> items;
  final ClassesView view;
  final String query;

  /// Selected topic key, null = All Topics.
  final String? topic;
  final bool refreshing;
  final String? error;

  /// Topic keys found in the loaded classes (for the "All Topics" filter).
  List<String> get topics {
    final set = <String>{
      for (final c in items)
        if (c.topic.isNotEmpty) c.topic,
    };
    return set.toList()..sort();
  }

  /// What the list shows (search + topic filter applied).
  /// "My Classes" is empty until enrolments exist.
  List<ClassItem> get visible {
    if (view == ClassesView.mine) return const [];

    final q = query.trim().toLowerCase();

    return [
      for (final c in items)
        if ((topic == null || c.topic == topic) &&
            (q.isEmpty ||
                c.title.toLowerCase().contains(q) ||
                c.mentorName.toLowerCase().contains(q) ||
                c.topicLabel.toLowerCase().contains(q)))
          c,
    ];
  }

  ClassesState copyWith({
    ClassesStatus? status,
    List<ClassItem>? items,
    ClassesView? view,
    String? query,
    String? topic,
    bool? refreshing,
    String? error,
    bool clearTopic = false,
    bool clearError = false,
  }) {
    return ClassesState(
      status: status ?? this.status,
      items: items ?? this.items,
      view: view ?? this.view,
      query: query ?? this.query,
      topic: clearTopic ? null : (topic ?? this.topic),
      refreshing: refreshing ?? this.refreshing,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    view,
    query,
    topic,
    refreshing,
    error,
  ];
}
