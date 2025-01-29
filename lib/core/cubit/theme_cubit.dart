import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_state.dart';


// enum AppTheme { light, dark }
//
// class ThemeCubit extends Cubit<AppTheme> {
//
//   ThemeCubit() : super(AppTheme.light);
//
//
//   void toggleTheme() {
//     if (state == AppTheme.light) {
//       emit(AppTheme.dark);
//     } else {
//       emit(AppTheme.light);
//     }
//   }
//
//
//   void setLightTheme() {
//     emit(AppTheme.light);
//   }
//
//
//   void setDarkTheme() {
//     emit(AppTheme.dark);
//   }
// }




class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(DarkThemeState());


  void toggleTheme() {
    if (state is LightThemeState) {
      emit(DarkThemeState());
    } else if (state is DarkThemeState) {
      emit(LightThemeState());
    }
  }


  void setLightTheme() {
    emit(LightThemeState());
  }


  void setDarkTheme() {
    emit(DarkThemeState());
  }


  void loadTheme() {
    emit(ThemeLoadingState());

  }


  void setError(String message) {
    emit(ThemeErrorState(message));
  }
}
