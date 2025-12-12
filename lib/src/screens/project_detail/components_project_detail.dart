part of project_detail;

class _StatsChip extends StatelessWidget {
  const _StatsChip({required this.name, required this.value});

  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Chip(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        label: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$name    ',
                style: context.textTheme.labelMedium!.copyWith(color: context.themeExtension.onBackground),
              ),
              TextSpan(
                text: value,
                style: context.textTheme.labelMedium!.copyWith(color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
