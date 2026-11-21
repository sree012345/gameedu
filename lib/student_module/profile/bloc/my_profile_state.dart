part of 'my_profile_bloc.dart';

enum MyProfileStatus { loading, loaded, failure }

final class MyProfileState extends Equatable {
  const MyProfileState({
    this.status = MyProfileStatus.loading,
    this.profile,
    this.error,
  });

  final MyProfileStatus status;
  final UserProfile? profile;
  final String? error;

  MyProfileState copyWith({
    MyProfileStatus? status,
    UserProfile? profile,
    String? error,
    bool clearError = false,
  }) {
    return MyProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, profile, error];
}
