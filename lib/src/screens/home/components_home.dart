part of home;

class _HomeItem extends StatelessWidget {
  const _HomeItem({
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
    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
        ),
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
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.parameters,
    required this.project,
    required this.onTap,
  });

  final _HomeParameters parameters;
  final Project project;
  final void Function(Project p) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: parameters.projectCardHeight,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: InkWell(
        onTap: () => onTap(project),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: project.defaultTeamImageUrl!,
                  httpHeaders: AzureApiServiceInherited.of(context).apiService.headers,
                  errorWidget: (_, __, ___) => Icon(DevOpsIcons.project),
                  width: 30,
                  height: 30,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(project.name!),
              const Spacer(),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
