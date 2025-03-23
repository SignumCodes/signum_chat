import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({this.duration = const Duration(seconds: 2)}) : super(SplashInitial()) {
    _startTimer();
  }

  final Duration duration;
  Timer? _timer;

  void _startTimer() {
    _timer = Timer(duration, () async {
      bool isAuthenticated = _checkUserAuth();
      if (!isClosed) {
        emit(isAuthenticated ? SplashAuthenticated() : SplashUnauthenticated());
      }
    });
  }

  bool _checkUserAuth() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null; // Returns true if a user is signed in
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
