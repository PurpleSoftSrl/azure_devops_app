import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/widgets/navigation_button.dart';
import 'package:flutter/material.dart';

class WorkCard extends StatelessWidget {
  const WorkCard({
    required this.title,
    required this.onTap,
    required this.icon,
    required this.index,
  });

  final String title;
  final VoidCallback onTap;
  final IconData icon;
  final int index;

  @override
  Widget build(BuildContext context) {
    return NavigationButton(
      inkwellKey: ValueKey(title),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                icon,
                color: context.colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            title,
            style: context.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
