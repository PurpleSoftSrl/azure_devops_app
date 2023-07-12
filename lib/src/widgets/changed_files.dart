import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:flutter/material.dart';

class GroupedFiles extends StatelessWidget {
  const GroupedFiles({required this.groupedFiles, this.onTap, this.bottomSpace = true});

  final Map<String, Set<ChangedFileDiff>> groupedFiles;
  final dynamic Function(ChangedFileDiff)? onTap;
  final bool bottomSpace;

  @override
  Widget build(BuildContext context) {
    final fileCount = groupedFiles.values.expand((f) => f).length;
    final changeType = groupedFiles.entries.first.value.first.changeType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: const Divider(thickness: .5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '$fileCount $changeType file${fileCount == 1 ? '' : 's'}',
                style: context.textTheme.titleMedium,
              ),
            ),
            Expanded(child: const Divider(thickness: .5)),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        ...groupedFiles.entries.map(
          (entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              if (entry.key != '/')
                Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Icon(
                        DevOpsIcons.repository,
                        color: context.colorScheme.secondary.withOpacity(.8),
                      ),
                    ),
                    Flexible(child: Text(entry.key.startsWith('/') ? entry.key.substring(1) : entry.key)),
                  ],
                ),
              ...entry.value.map(
                (fileName) => InkWell(
                  onTap: () => onTap?.call(fileName),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 30,
                          child: Icon(Icons.circle, size: 5),
                        ),
                        Flexible(
                          child: Text(
                            fileName.fileName,
                            style: context.textTheme.titleSmall!.copyWith(
                              color: context.colorScheme.onSecondary,
                              decoration: onTap == null ? null : TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (bottomSpace)
          const SizedBox(
            height: 40,
          ),
      ],
    );
  }
}

class ChangedFileDiff {
  ChangedFileDiff({
    required this.commitId,
    required this.parentCommitId,
    required this.path,
    required this.directory,
    required this.fileName,
    required this.changeType,
  });

  final String commitId;
  final String parentCommitId;
  final String path;
  final String directory;
  final String fileName;
  final String changeType;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChangedFileDiff && other.path == path;
  }

  @override
  int get hashCode {
    return path.hashCode;
  }
}
