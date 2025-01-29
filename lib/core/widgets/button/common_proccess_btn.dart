import 'package:flutter/material.dart';

class CommonProcessButton extends StatelessWidget {
  final String buttonText;
  final Future<void> Function() onPressed; 
  final ValueNotifier<bool> isLoading;

  const CommonProcessButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (context, isProcessing, child) {
        return ElevatedButton(
          onPressed: isProcessing
              ? null 
              : () async {
            isLoading.value = true;
            await onPressed();
            isLoading.value = false;
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              isProcessing ? Colors.grey : Colors.blue, 
            ),
          ),
          child: isProcessing
              ? const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
              : Text(buttonText),
        );
      },
    );
  }
}
