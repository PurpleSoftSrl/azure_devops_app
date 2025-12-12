import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({required this.widget, required this.onRefresh});

  final AppPage widget;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/illustrations/empty.png', height: 200),
        const SizedBox(height: 20),
        if (widget.onEmpty != null) Text(widget.onEmpty!),
        const SizedBox(height: 20),
        if (widget.onResetFilters != null)
          LoadingButton(onPressed: widget.onResetFilters!, text: 'Reset filters')
        else
          LoadingButton(onPressed: onRefresh, text: 'Retry'),
        const SizedBox(height: 40),
      ],
    );
  }
}
