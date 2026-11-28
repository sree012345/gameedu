part of 'community_list_bloc.dart';

enum CommunityListStatus { initial, loading, success, failure }

final class CommunityListState extends Equatable {
  const CommunityListState({
    this.status = CommunityListStatus.initial,
    this.communities = const [],
    this.currentUser,
    this.errorMessage,
  });

  final CommunityListStatus status;
  final List<CommunityModel> communities;
  final CommunityUser? currentUser;
  final String? errorMessage;

  /// Only admins can create communities.
  bool get canCreate => currentUser?.isAdmin ?? false;

  bool isCleared(CommunityModel community) =>
      currentUser != null && community.isChatClearedFor(currentUser!.id);

  int unreadFor(CommunityModel community) =>
      currentUser == null ? 0 : community.unreadFor(currentUser!.id);

  CommunityListState copyWith({
    CommunityListStatus? status,
    List<CommunityModel>? communities,
    CommunityUser? currentUser,
    String? errorMessage,
  }) {
    return CommunityListState(
      status: status ?? this.status,
      communities: communities ?? this.communities,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, communities, currentUser, errorMessage];
}