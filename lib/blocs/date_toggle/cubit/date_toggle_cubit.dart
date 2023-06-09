import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'date_toggle_state.dart';

class DateToggleCubit extends Cubit<DateState> {
  DateToggleCubit() : super(DateState.initial());

  void dateButtonPressed(DateTime selectedDate) {
    emit(state.copyWith(selectedDate: selectedDate));
  }
}
