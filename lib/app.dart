import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/colors.dart';
import 'core/cubit/localiztion_cubit.dart';
import 'core/cubit/theme_cubit.dart';
import 'core/cubit/theme_state.dart';
import 'core/l10n/app_localization.dart';
import 'core/route/route.dart';
import 'core/services/app_navigator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, theme) {
        return BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp(
              locale: locale,
              debugShowCheckedModeBanner: false,
              title: 'Signum Chat',
              supportedLocales: const [
                Locale('en', 'US'),
                Locale('es', 'ES'), // Add more locales as needed
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale?.languageCode) {
                    return supportedLocale;
                  }
                }
                return supportedLocales.first;
              },
              theme: ThemeData(
                brightness: theme is LightThemeState ? Brightness.light : Brightness.dark,
                primaryColor: AppColors.primaryColor,
                hintColor: AppColors.secondaryColor,
              ),
              initialRoute: AppRoute.splash,
              onGenerateRoute: (RouteSettings setting) => AppNavigator.routeSetting(setting),
            );
          },
        );
      },
    );
  }
}
