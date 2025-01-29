import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'core/dependency/dependencies.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: initProviders(),
      child: const MyApp(),
    ),
  );
}


