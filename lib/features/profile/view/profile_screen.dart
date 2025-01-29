import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/cubit/localiztion_cubit.dart';
import '../../../core/l10n/app_localization.dart';

class ProfileScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('hello'))),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context).translate('welcome')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<LocaleCubit>().changeLocale(const Locale('en', 'US'));
            },
            child: const Text('English'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<LocaleCubit>().changeLocale(const Locale('es', 'ES'));
            },
            child: const Text('Español'),
          ),
        ],
      ),
    );
  }
}