part of 'contact_bloc.dart';

enum ContactStatus { idle, sending, success }

final class ContactState extends Equatable {
  const ContactState({
    this.status = ContactStatus.idle,
    this.subjectError,
    this.messageError,
    this.message,
  });

  final ContactStatus status;

  /// Error text under the subject box.
  final String? subjectError;

  /// Error text under the message box.
  final String? messageError;

  /// One-shot snackbar text (send failed ...).
  final String? message;

  bool get sending => status == ContactStatus.sending;

  ContactState copyWith({
    ContactStatus? status,
    String? subjectError,
    String? messageError,
    String? message,
    bool clearSubjectError = false,
    bool clearMessageError = false,
    bool clearMessage = false,
  }) {
    return ContactState(
      status: status ?? this.status,
      subjectError: clearSubjectError
          ? null
          : (subjectError ?? this.subjectError),
      messageError: clearMessageError
          ? null
          : (messageError ?? this.messageError),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, subjectError, messageError, message];
}
