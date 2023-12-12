part of project_detail;

class _StatsChip extends StatelessWidget {
  const _StatsChip({
    required this.name,
    required this.value,
  });

  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Chip(
        // padding: EdgeInsets.only(left: 10, right: 10),
        // labelPadding: EdgeInsets.zero,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
        // side: BorderSide(color: Colors.transparent),
        // backgroundColor: Colors.grey.shade300, TODO remove
        label: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$name    ',
                style: context.textTheme.labelMedium!.copyWith(color: context.colorScheme.onBackground),
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
