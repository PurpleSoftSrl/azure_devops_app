import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/widgets/form_field.dart';
import 'package:flutter/material.dart';

class DevOpsAnimatedSearchField extends StatelessWidget {
  const DevOpsAnimatedSearchField({
    required this.isSearching,
    required this.onChanged,
    required this.onResetSearch,
    this.hint = 'Search',
    this.margin = const EdgeInsets.only(top: 16),
    required this.child,
  });

  final ValueNotifier<bool> isSearching;
  final void Function(String) onChanged;
  final void Function() onResetSearch;
  final String hint;
  final EdgeInsets margin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isSearching,
      builder: (context, isSearching, __) => SizedBox(
        height: 70,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
          reverseDuration: Duration(milliseconds: 250),
          child: isSearching
              ? Padding(
                  padding: margin,
                  child: DevOpsSearchField(
                    onChanged: onChanged,
                    onResetSearch: onResetSearch,
                    hint: hint,
                  ),
                )
              : child,
        ),
      ),
    );
  }
}

class DevOpsSearchField extends StatefulWidget {
  const DevOpsSearchField({
    required this.onChanged,
    required this.onResetSearch,
    required this.hint,
    this.initialValue,
    this.autofocus = true,
  });

  final void Function(String) onChanged;
  final void Function() onResetSearch;
  final String hint;
  final String? initialValue;
  final bool autofocus;

  @override
  State<DevOpsSearchField> createState() => _DevOpsSearchFieldState();
}

class _DevOpsSearchFieldState extends State<DevOpsSearchField> {
  late final controller = TextEditingController(text: widget.initialValue);

  @override
  Widget build(BuildContext context) {
    return DevOpsFormField(
      autofocus: widget.autofocus,
      onChanged: (s) {
        widget.onChanged.call(s);
        controller.text = s;
      },
      hint: widget.hint,
      maxLines: 1,
      controller: controller,
      validator: (_) => null,
      suffix: GestureDetector(
        onTap: () {
          controller.clear();
          widget.onResetSearch();
        },
        child: Icon(
          Icons.close,
          color: context.themeExtension.onBackground,
        ),
      ),
    );
  }
}

class SearchButton extends StatelessWidget {
  const SearchButton({required this.isSearching});

  final ValueNotifier<bool> isSearching;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        isSearching.value = true;
      },
      icon: Icon(
        Icons.search,
        size: 24,
      ),
    );
  }
}
