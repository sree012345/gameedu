part of 'faq_bloc.dart';

sealed class FaqEvent extends Equatable {
  const FaqEvent();

  @override
  List<Object?> get props => [];
}

/// Load the FAQs.
final class FaqStarted extends FaqEvent {
  const FaqStarted();
}

/// The text of the search box changed.
final class FaqSearchChanged extends FaqEvent {
  const FaqSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// A chip was tapped. null = "All".
final class FaqCategorySelected extends FaqEvent {
  const FaqCategorySelected(this.category);

  final FaqCategory? category;

  @override
  List<Object?> get props => [category];
}

/// A question was tapped: open it (closes the one that was open) or close it.
final class FaqToggled extends FaqEvent {
  const FaqToggled(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
