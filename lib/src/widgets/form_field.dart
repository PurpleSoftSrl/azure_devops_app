import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class DevOpsFormField extends StatelessWidget {
  const DevOpsFormField({
    this.formFieldKey,
    this.label,
    this.hint,
    required this.onChanged,
    this.onFieldSubmitted,
    this.maxLines,
    this.initialValue,
    this.textCapitalization,
    this.autofocus = false,
    this.textInputAction,
    this.enabled = true,
    this.fillColor,
    this.controller,
    this.validator,
    this.suffix,
    this.readOnly = false,
    this.onTap,
  });

  final VoidCallback? onFieldSubmitted;
  final void Function(String) onChanged;
  final String? hint;
  final String? label;
  final int? maxLines;
  final GlobalKey<FormFieldState<dynamic>>? formFieldKey;
  final String? initialValue;
  final TextCapitalization? textCapitalization;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final bool enabled;
  final Color? fillColor;
  final TextEditingController? controller;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  String? _validateField(String? s) {
    if (validator != null) return validator!(s);

    return s!.isEmpty ? 'Fill this field' : null;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = TextFormField(
      controller: controller,
      key: formFieldKey,
      onChanged: onChanged,
      validator: _validateField,
      maxLines: maxLines,
      initialValue: initialValue,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      textInputAction: textInputAction,
      autofocus: autofocus,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        hintText: hint,
        hintStyle: context.textTheme.labelLarge!.copyWith(color: context.colorScheme.onSurface.withValues(alpha: .4)),
        fillColor: fillColor ?? context.colorScheme.surface,
        filled: true,
        suffixIcon: suffix,
      ),
      onFieldSubmitted: onFieldSubmitted == null ? null : (_) => onFieldSubmitted!(),
    );

    if (label != null) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label!, style: context.textTheme.labelSmall!.copyWith(height: 1, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          child,
        ],
      );
    }

    return child;
  }
}
