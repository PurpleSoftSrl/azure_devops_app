part of home;

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
    final apiService = AzureApiServiceInherited.of(context).apiService;
    return Container(
      height: parameters.projectCardHeight,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: InkWell(
        key: ValueKey(project.name),
        onTap: () => onTap(project),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: apiService.isImageUnauthorized
                    ? SizedBox(
                        height: 30,
                        width: 30,
                        child: Icon(DevOpsIcons.project),
                      )
                    : CachedNetworkImage(
                        imageUrl: project.defaultTeamImageUrl!,
                        httpHeaders: apiService.headers,
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
