import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/contact_service.dart';

part 'contact_event.dart';
part 'contact_state.dart';

/// "Contact Us": checks the form and saves the message.
class ContactBloc extends Bloc<ContactEvent, ContactState> {
  ContactBloc({ContactService? service})
    : _service = service ?? ContactService(),
      super(const ContactState()) {
    on<ContactSubjectChanged>(
      (event, emit) => emit(state.copyWith(clearSubjectError: true)),
    );
    on<ContactMessageChanged>(
      (event, emit) => emit(state.copyWith(clearMessageError: true)),
    );
    on<ContactSubmitted>(_onSubmitted);
  }

  static const int minSubject = 3;
  static const int minMessage = 10;

  final ContactService _service;

  Future<void> _onSubmitted(
    ContactSubmitted event,
    Emitter<ContactState> emit,
  ) async {
    if (state.sending) return;

    final subject = event.subject.trim();
    final message = event.message.trim();

    String? subjectError;
    String? messageError;

    if (subject.isEmpty) {
      subjectError = 'Enter a subject';
    } else if (subject.length < minSubject) {
      subjectError = 'Subject is too short';
    }

    if (message.isEmpty) {
      messageError = 'Write your message';
    } else if (message.length < minMessage) {
      messageError = 'Write at least $minMessage characters';
    }

    if (subjectError != null || messageError != null) {
      emit(
        ContactState(subjectError: subjectError, messageError: messageError),
      );
      return;
    }

    emit(const ContactState(status: ContactStatus.sending));

    try {
      await _service.sendMessage(subject: subject, message: message);
      if (emit.isDone) return;
      emit(const ContactState(status: ContactStatus.success));
    } on ContactFailure catch (e) {
      if (emit.isDone) return;
      emit(ContactState(message: e.message));
      emit(const ContactState());
    } catch (_) {
      if (emit.isDone) return;
      emit(const ContactState(message: 'Could not send your message'));
      emit(const ContactState());
    }
  }
}
