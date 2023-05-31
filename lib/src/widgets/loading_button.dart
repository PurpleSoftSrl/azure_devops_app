import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class LoadingButton extends StatefulWidget {
  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  final dynamic Function() onPressed;
  final String text;

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: MaterialButton(
        color: context.colorScheme.primary,
        minWidth: double.maxFinite,
        shape: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        elevation: 0,
        onPressed: () async {
          setState(() => _isLoading = true);

          // catch exceptions to avoid infinite loading
          try {
            await widget.onPressed();
          } catch (e) {
            print(e);
          }

          if (mounted) setState(() => _isLoading = false);
        },
        child: _isLoading
            ? CircularProgressIndicator(
                backgroundColor: context.colorScheme.background,
              )
            : Text(
                widget.text,
                style: context.textTheme.labelLarge!.copyWith(color: context.colorScheme.onPrimary),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
