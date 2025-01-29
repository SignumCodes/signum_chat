import 'package:flutter/material.dart';
import 'package:signum_chat/features/start_chat/view/start_chat_screen.dart';

import '../../features/authentication/view/login_screen.dart';
import '../../features/authentication/view/signup_screen.dart';
import '../../features/bottom_bar/view/bottom_bar.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/profile/view/profile_screen.dart';
import '../../features/splash/view/splash_screen.dart';
import '../constants/app_enum.dart';
import '../route/route.dart';

import 'package:flutter/material.dart';
import 'package:signum_chat/features/start_chat/view/start_chat_screen.dart';
import '../../features/authentication/view/login_screen.dart';
import '../../features/authentication/view/signup_screen.dart';
import '../../features/bottom_bar/view/bottom_bar.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/profile/view/profile_screen.dart';
import '../../features/splash/view/splash_screen.dart';
import '../constants/app_enum.dart';
import '../route/route.dart';

class AppNavigator {
  static Future<void> navigateTo(
      BuildContext context,
      String routeName, {
        Object? arguments,
        TransitionType? transitionType,
      }) async {
    await Navigator.push(
      context,
      createRoute(
        getPageFromRouteName(routeName),
        transitionType: transitionType,
      ),
    );
  }

  static Future<void> replaceWith(
      BuildContext context,
      String routeName, {
        Object? arguments,
        TransitionType? transitionType,
      }) async {
    await Navigator.pushReplacement(
      context,
      createRoute(
        getPageFromRouteName(routeName),
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
            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.ease));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          case TransitionType.slideLeftToRight:
            var begin = Offset(-1.0, 0.0);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.ease));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          case TransitionType.slideTopToBottom:
            var begin = Offset(0.0, -1.0);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.ease));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          case TransitionType.slideBottomToTop:
            var begin = Offset(0.0, 1.0);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.ease));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          case TransitionType.scale:
            return ScaleTransition(scale: animation, child: child);
          case TransitionType.rotation:
            return RotationTransition(turns: animation, child: child);
          case TransitionType.size:
            return SizeTransition(
                sizeFactor: animation, axis: Axis.vertical, child: child);
          case TransitionType.flip:
            var tween = Tween(begin: 0.0, end: 1.0);
            var flipAnimation = animation.drive(tween);
            return AnimatedBuilder(
              animation: flipAnimation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(flipAnimation.value * 3.1416),
                  child: child,
                );
              },
              child: child,
            );
          case TransitionType.rotateAndScale:
            var rotationAnimation =
            Tween(begin: 0.0, end: 1.0).animate(animation);
            var scaleAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..rotateZ(rotationAnimation.value * 3.1416)
                    ..scale(scaleAnimation.value),
                  child: child,
                );
              },
              child: child,
            );
          case TransitionType.customCurve:
            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.decelerate));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          case TransitionType.bounce:
            var tween = Tween(begin: 1.5, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.bounceOut));
            return ScaleTransition(scale: tween, child: child);
          case TransitionType.elastic:
            var tween = Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.elasticOut));
            return ScaleTransition(scale: tween, child: child);
          case TransitionType.zoomIn:
            var tween = Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut));
            return ScaleTransition(scale: tween, child: child);
          default:
            return FadeTransition(opacity: animation, child: child);
        }
      },
    );
  }

  static Widget getPageFromRouteName(String routeName) {
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
        return  ProfileScreen();
      case AppRoute.startChat:
        return const StartChatScreen();
      default:
        return const SplashScreen();
    }
  }

  static routeSetting(RouteSettings settings) {
    switch (settings.name) {
      case AppRoute.splash:
        return AppNavigator.createRoute(const SplashScreen());
      case AppRoute.bottomBar:
        return AppNavigator.createRoute(BottomNavBar());
      case AppRoute.login:
        return AppNavigator.createRoute(const LoginScreen());
      case AppRoute.signup:
        return AppNavigator.createRoute(const SignupScreen());
      case AppRoute.home:
        return AppNavigator.createRoute(const HomeScreen());
      case AppRoute.profile:
        return AppNavigator.createRoute( ProfileScreen());
      case AppRoute.startChat:
        return AppNavigator.createRoute(const StartChatScreen());
      default:
        return AppNavigator.createRoute(const SplashScreen());
    }
  }
}







