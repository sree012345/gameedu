part of 'community_list_bloc.dart';

sealed class CommunityListEvent extends Equatable {
  const CommunityListEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the current user and starts listening to their communities.
/// Dispatch again to retry after a failure.
final class CommunityListStarted extends CommunityListEvent {
  const CommunityListStarted();
}
