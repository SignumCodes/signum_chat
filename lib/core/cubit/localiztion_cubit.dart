import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en', 'US'));

  void changeLocale(Locale locale) {
    emit(locale);
  }
}
