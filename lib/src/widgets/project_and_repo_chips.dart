import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class ProjectChip extends StatelessWidget {
  const ProjectChip({
    required this.onTap,
    required this.projectName,
  });

  final VoidCallback onTap;
  final String projectName;

  @override
  Widget build(BuildContext context) {
    return _InternalChip(
      onTap: onTap,
      title: 'Project:',
      text: projectName,
    );
  }
}

class RepositoryChip extends StatelessWidget {
  const RepositoryChip({
    required this.onTap,
    required this.repositoryName,
  });

  final VoidCallback onTap;
  final String? repositoryName;

  @override
  Widget build(BuildContext context) {
    return _InternalChip(
      onTap: onTap,
      title: 'Repository:',
      text: repositoryName,
    );
  }
}

class _InternalChip extends StatelessWidget {
  const _InternalChip({
    required this.onTap,
    required this.text,
    required this.title,
  });

  final VoidCallback onTap;
  final String title;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
          ),
          const SizedBox(
            width: 8,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                text ?? '-',
                style:
                    context.textTheme.titleSmall!.copyWith(decoration: text == null ? null : TextDecoration.underline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
