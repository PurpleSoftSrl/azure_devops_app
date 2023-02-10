import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({
    super.key,
    required this.description,
    required this.onRetry,
  });

  final String description;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/illustrations/error.png',
            width: 150,
          ),
          const SizedBox(
            height: 40,
          ),
          Text(
            'Error',
            style: context.textTheme.headlineLarge,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            description,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          LoadingButton(
            onPressed: onRetry,
            text: 'Tap to retry',
          ),
        ],
      ),
    );
  }
}
