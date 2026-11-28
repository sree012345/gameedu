part of 'participant_picker_bloc.dart';

enum ParticipantPickerStatus { initial, loading, success, failure }

final class ParticipantPickerState extends Equatable {
  const ParticipantPickerState({
    this.status = ParticipantPickerStatus.initial,
    this.users = const [],
    this.selectedIds = const {},
    this.query = '',
    this.errorMessage,
  });

  final ParticipantPickerStatus status;
  final List<CommunityUser> users;
  final Set<String> selectedIds;
  final String query;
  final String? errorMessage;

  List<CommunityUser> get visibleUsers {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return users;
    return users.where((u) => u.name.toLowerCase().contains(q)).toList();
  }

  ParticipantPickerState copyWith({
    ParticipantPickerStatus? status,
    List<CommunityUser>? users,
    Set<String>? selectedIds,
    String? query,
    String? errorMessage,
  }) {
    return ParticipantPickerState(
      status: status ?? this.status,
      users: users ?? this.users,
      selectedIds: selectedIds ?? this.selectedIds,
      query: query ?? this.query,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, selectedIds, query, errorMessage];
}
