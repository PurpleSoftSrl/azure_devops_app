part of commit_detail;

class _GroupedFiles extends StatelessWidget {
  const _GroupedFiles({required this.groupedFiles, required this.onTap});

  final Map<String, Set<String>> groupedFiles;
  final dynamic Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...groupedFiles.entries.map(
          (entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              if (entry.key != '/') Text(entry.key.startsWith('/') ? entry.key.substring(1) : entry.key),
              ...entry.value.map(
                (fileName) => InkWell(
                  onTap: () => onTap('${entry.key}/$fileName'),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 5),
                    child: Text(
                      fileName,
                      style: context.textTheme.titleSmall!.copyWith(
                        color: context.colorScheme.onSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
