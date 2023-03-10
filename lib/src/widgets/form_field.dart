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
  });

  final VoidCallback? onFieldSubmitted;
  final void Function(String) onChanged;
  final String? hint;
  final String? label;
  final int? maxLines;
  final GlobalKey<FormFieldState<dynamic>>? formFieldKey;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    Widget child = TextFormField(
      key: formFieldKey,
      onChanged: onChanged,
      validator: (s) => s!.isEmpty ? 'Fill this field' : null,
      maxLines: maxLines,
      initialValue: initialValue,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        hintText: hint,
        hintStyle: context.textTheme.labelLarge!.copyWith(color: context.colorScheme.onSurface.withOpacity(.4)),
        fillColor: context.colorScheme.surface,
        filled: true,
      ),
      onFieldSubmitted: onFieldSubmitted == null ? null : (_) => onFieldSubmitted!(),
    );

    if (label != null) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label!,
            style: context.textTheme.labelMedium,
          ),
          const SizedBox(
            height: 10,
          ),
          child,
        ],
      );
    }

    return child;
  }
}
