part of 'create_community_bloc.dart';

enum CreateCommunityStatus { initial, submitting, success, failure }

final class CreateCommunityState extends Equatable {
  const CreateCommunityState({
    this.status = CreateCommunityStatus.initial,
    this.name = '',
    this.description = '',
    this.nameError,
    this.imageFile,
    this.participantIds = const [],
    this.createdCommunityId,
    this.errorMessage,
  });

  final CreateCommunityStatus status;
  final String name;
  final String description;
  final String? nameError;
  final File? imageFile;
  final List<String> participantIds;
  final String? createdCommunityId;
  final String? errorMessage;

  bool get isSubmitting => status == CreateCommunityStatus.submitting;

  CreateCommunityState copyWith({
    CreateCommunityStatus? status,
    String? name,
    String? description,
    String? nameError,
    bool clearNameError = false,
    File? imageFile,
    bool clearImage = false,
    List<String>? participantIds,
    String? createdCommunityId,
    String? errorMessage,
  }) {
    return CreateCommunityState(
      status: status ?? this.status,
      name: name ?? this.name,
      description: description ?? this.description,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      imageFile: clearImage ? null : (imageFile ?? this.imageFile),
      participantIds: participantIds ?? this.participantIds,
      createdCommunityId: createdCommunityId ?? this.createdCommunityId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        name,
        description,
        nameError,
        imageFile?.path,
        participantIds,
        createdCommunityId,
        errorMessage,
      ];
}