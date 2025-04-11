import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:flutter/material.dart';

class LoadingButton extends StatefulWidget {
  const LoadingButton({
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.margin,
  });

  final dynamic Function() onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? margin;

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> with AppLogger {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin ?? const EdgeInsets.symmetric(horizontal: 50),
      child: MaterialButton(
        color: widget.backgroundColor ?? context.colorScheme.primary,
        disabledColor: widget.backgroundColor ?? context.colorScheme.primary,
        minWidth: double.maxFinite,
        shape: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        elevation: 0,
        onPressed: _isLoading
            ? null
            : () async {
                setState(() => _isLoading = true);

                // catch exceptions to avoid infinite loading
                try {
                  await widget.onPressed();
                } catch (e) {
                  logDebug(e.toString());
                }

                if (mounted) setState(() => _isLoading = false);
              },
        child: _isLoading
            ? CircularProgressIndicator(
                backgroundColor: context.themeExtension.background,
              )
            : Text(
                widget.text,
                style: context.textTheme.labelLarge!.copyWith(color: widget.textColor ?? context.colorScheme.onPrimary),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
