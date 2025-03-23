import 'package:flutter/material.dart';
import '../../features/authentication/view/login_screen.dart';
import '../../features/authentication/view/signup_screen.dart';
import '../../features/bottom_bar/view/bottom_bar.dart';
import '../../features/chat/view/chat_screen.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/profile/view/profile_screen.dart';
import '../../features/splash/view/splash_screen.dart';
import '../constants/app_enum.dart';
import '../route/route.dart';

import 'package:flutter/material.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> navigateTo(
      String routeName, {
        Object? arguments,
        TransitionType? transitionType,
      }) async {
    await navigatorKey.currentState?.push(
      createRoute(
        getPageFromRouteName(routeName, arguments: arguments is Map<String, dynamic> ? arguments : null),
        transitionType: transitionType,
      ),
    );
  }

  static Future<void> replaceWith(
      String routeName, {
        Object? arguments,
        TransitionType? transitionType,
      }) async {
    await navigatorKey.currentState?.pushReplacement(
      createRoute(
        getPageFromRouteName(routeName, arguments: arguments is Map<String, dynamic> ? arguments : null),
        transitionType: transitionType,
      ),
    );
  }

  static Route createRoute(
      Widget page, {
        RouteSettings? settings,
        TransitionType? transitionType,
      }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transitionType) {
          case TransitionType.fade:
            return FadeTransition(opacity: animation, child: child);
          case TransitionType.slideRightToLeft:
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          case TransitionType.slideLeftToRight:
            var begin = const Offset(-1.0, 0.0);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          case TransitionType.scale:
            return ScaleTransition(scale: animation, child: child);
          case TransitionType.rotation:
            return RotationTransition(turns: animation, child: child);
          default:
            return FadeTransition(opacity: animation, child: child);
        }
      },
    );
  }

  static Widget getPageFromRouteName(String routeName, {Map<String,dynamic>? arguments}) {
    switch (routeName) {
      case AppRoute.splash:
        return const SplashScreen();
      case AppRoute.bottomBar:
        return BottomNavBar();
      case AppRoute.login:
        return const LoginScreen();
      case AppRoute.signup:
        return const SignupScreen();
      case AppRoute.home:
        return const HomeScreen();
      case AppRoute.profile:
        return ProfileScreen();

      case AppRoute.chatScreen:

        return ChatScreen(chatRoomId: arguments!['roomId'], receiverId: arguments['matchedUserId'],receiverName: arguments['name'],);
      default:
        return const SplashScreen();
    }
  }

  static Route<dynamic>? routeSetting(RouteSettings settings) {
    switch (settings.name) {
      case AppRoute.splash:
        return createRoute(const SplashScreen());
      case AppRoute.bottomBar:
        return createRoute(BottomNavBar());
      case AppRoute.login:
        return createRoute(const LoginScreen());
      case AppRoute.signup:
        return createRoute(const SignupScreen());
      case AppRoute.home:
        return createRoute(const HomeScreen());
      case AppRoute.profile:
        return createRoute(ProfileScreen());

      default:
        return createRoute(const SplashScreen());
    }
  }
}







