import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  
  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(), 
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                message!,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }

  
  static Future<void> showLoadingDialog(BuildContext context, {String? message}) {
    return showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: LoadingIndicator(message: message),
        );
      },
    );
  }

  
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
