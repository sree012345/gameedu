part of 'contact_bloc.dart';

sealed class ContactEvent extends Equatable {
  const ContactEvent();

  @override
  List<Object?> get props => [];
}

/// The user typed in the subject box (clears its error).
final class ContactSubjectChanged extends ContactEvent {
  const ContactSubjectChanged();
}

/// The user typed in the message box (clears its error).
final class ContactMessageChanged extends ContactEvent {
  const ContactMessageChanged();
}

/// The user tapped "Send Message".
final class ContactSubmitted extends ContactEvent {
  const ContactSubmitted({required this.subject, required this.message});

  final String subject;
  final String message;

  @override
  List<Object?> get props => [subject, message];
}
