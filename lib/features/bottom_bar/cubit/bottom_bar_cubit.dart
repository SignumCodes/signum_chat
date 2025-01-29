import 'package:flutter_bloc/flutter_bloc.dart';

// Cubit to manage the selected page index
class BottomBarCubit extends Cubit<int> {
  BottomBarCubit() : super(0); // Initial page index is 0

  void changePage(int index) {
    emit(index);
  }
}
