import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/faq_repository.dart';
import '../models/faq_item.dart';

part 'faq_event.dart';
part 'faq_state.dart';

/// The FAQ page: loading, search, category chips and open / close.
class FaqBloc extends Bloc<FaqEvent, FaqState> {
  FaqBloc({FaqRepository repository = const FaqRepository()})
    : _repository = repository,
      super(const FaqState()) {
    on<FaqStarted>(_onStarted);
    on<FaqSearchChanged>(_onSearchChanged);
    on<FaqCategorySelected>(_onCategorySelected);
    on<FaqToggled>(_onToggled);
  }

  final FaqRepository _repository;

  Future<void> _onStarted(FaqStarted event, Emitter<FaqState> emit) async {
    emit(state.copyWith(status: FaqStatus.loading));

    try {
      final items = await _repository.fetchFaqs();
      if (emit.isDone) return;

      emit(
        state.copyWith(
          status: FaqStatus.loaded,
          items: items,
          // the first question is open when the page opens
          expandedId: items.isEmpty ? null : items.first.id,
        ),
      );
    } catch (_) {
      if (emit.isDone) return;
      emit(state.copyWith(status: FaqStatus.failure));
    }
  }

  void _onSearchChanged(FaqSearchChanged event, Emitter<FaqState> emit) {
    emit(state.copyWith(query: event.query));
  }

  void _onCategorySelected(
    FaqCategorySelected event,
    Emitter<FaqState> emit,
  ) {
    if (event.category == null) {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(category: event.category));
    }
  }

  void _onToggled(FaqToggled event, Emitter<FaqState> emit) {
    if (state.expandedId == event.id) {
      emit(state.copyWith(clearExpanded: true));
    } else {
      emit(state.copyWith(expandedId: event.id));
    }
  }
}
