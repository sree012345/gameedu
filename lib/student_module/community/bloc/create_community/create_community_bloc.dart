import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/community_exception.dart';
import '../../data/services/community_firebase_service.dart';

part 'create_community_event.dart';
part 'create_community_state.dart';

class CreateCommunityBloc
    extends Bloc<CreateCommunityEvent, CreateCommunityState> {
  CreateCommunityBloc({required CommunityFirebaseService service})
      : _service = service,
        super(const CreateCommunityState()) {
    on<CreateCommunityNameChanged>((event, emit) {
      emit(state.copyWith(
        name: event.name,
        clearNameError: true,
      ));
    });

    on<CreateCommunityDescriptionChanged>((event, emit) {
      emit(state.copyWith(description: event.description));
    });

    on<CreateCommunityImageChanged>((event, emit) {
      emit(state.copyWith(
        imageFile: event.file,
        clearImage: event.file == null,
      ));
    });

    on<CreateCommunityParticipantsChanged>((event, emit) {
      emit(state.copyWith(participantIds: event.participantIds));
    });

    on<CreateCommunitySubmitted>(_onSubmitted);
  }

  final CommunityFirebaseService _service;

  Future<void> _onSubmitted(
    CreateCommunitySubmitted event,
    Emitter<CreateCommunityState> emit,
  ) async {
    if (state.isSubmitting) return;

    final name = state.name.trim();

    if (name.length < 2) {
      emit(state.copyWith(nameError: 'Enter a community name'));
      return;
    }

    emit(state.copyWith(
      status: CreateCommunityStatus.submitting,
      clearNameError: true,
    ));

    try {
      final admin = await _service.loadCurrentUser();

      if (!admin.isAdmin) {
        throw const CommunityException('Only admins can create communities.');
      }

      final id = await _service.createCommunity(
        admin: admin,
        name: name,
        description: state.description.trim(),
        participantIds: state.participantIds,
        image: state.imageFile,
      );

      emit(state.copyWith(
        status: CreateCommunityStatus.success,
        createdCommunityId: id,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CreateCommunityStatus.failure,
        errorMessage: CommunityException.messageOf(error),
      ));
    }
  }
}