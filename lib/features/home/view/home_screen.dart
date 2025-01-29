import 'package:flutter/material.dart';
import 'package:signum_chat/core/constants/app_enum.dart';
import 'package:signum_chat/core/route/route.dart';
import 'package:signum_chat/core/services/app_navigator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: ()=>AppNavigator.navigateTo(context,AppRoute.startChat,transitionType: TransitionType.zoomIn), child: const Text('Start Chat')),
      ),
    );
  }
}
