part of 'community_details_bloc.dart';

enum CommunityDetailsStatus { initial, loading, success, failure }

final class CommunityDetailsState extends Equatable {
  const CommunityDetailsState({
    this.status = CommunityDetailsStatus.initial,
    this.community,
    this.currentUser,
    this.members = const [],
    this.media = const [],
    this.isUpdating = false,
    this.errorMessage,
    this.infoMessage,
  });

  final CommunityDetailsStatus status;
  final CommunityModel? community;
  final CommunityUser? currentUser;

  /// Admin first, then participants.
  final List<CommunityUser> members;
  final List<CommunityMessage> media;
  final bool isUpdating;

  /// One-shot messages for the UI (cleared on the next emit).
  final String? errorMessage;
  final String? infoMessage;

  /// Media after the time this user cleared the chat.
  List<CommunityMessage> get visibleMedia {
    final cleared = (community == null || currentUser == null)
        ? null
        : community!.clearedAtFor(currentUser!.id);
    if (cleared == null) return media;
    return media.where((m) => m.createdAt.isAfter(cleared)).toList();
  }

  bool get isAdmin =>
      community != null &&
      currentUser != null &&
      community!.adminId == currentUser!.id;

  CommunityDetailsState copyWith({
    CommunityDetailsStatus? status,
    CommunityModel? community,
    CommunityUser? currentUser,
    List<CommunityUser>? members,
    List<CommunityMessage>? media,
    bool? isUpdating,
    String? errorMessage,
    String? infoMessage,
  }) {
    return CommunityDetailsState(
      status: status ?? this.status,
      community: community ?? this.community,
      currentUser: currentUser ?? this.currentUser,
      members: members ?? this.members,
      media: media ?? this.media,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        community,
        currentUser,
        members,
        media,
        isUpdating,
        errorMessage,
        infoMessage,
      ];
}