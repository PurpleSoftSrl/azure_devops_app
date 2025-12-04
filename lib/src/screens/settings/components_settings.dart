part of settings;

class _ThemeModeRadio extends StatelessWidget {
  const _ThemeModeRadio({
    required this.mode,
    required this.icon,
  });

  final String mode;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isSelected = AppTheme.themeMode == mode;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: isSelected ? null : context.colorScheme.onSecondary),
          const SizedBox(
            height: 5,
          ),
          Text(
            mode,
            style: context.textTheme.titleSmall!.copyWith(color: isSelected ? null : context.colorScheme.onSecondary),
          ),
          Radio<String>(
            value: mode,
            fillColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? context.themeExtension.onBackground
                  : context.colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchDirectoryWidget extends StatelessWidget {
  const _SwitchDirectoryWidget({
    required this.directories,
    required this.onSwitch,
  });

  final List<UserTenant> directories;
  final Future<void> Function(UserTenant) onSwitch;

  @override
  Widget build(BuildContext context) {
    final currentDirectory = directories.firstWhereOrNull((d) => d.isCurrent);
    return ListView(
      children: [
        if (currentDirectory != null) ...[
          Text(
            'Current directory',
            style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
          ),
          ListTile(
            title: Text(currentDirectory.displayName, style: context.textTheme.bodyMedium),
            contentPadding: EdgeInsets.zero,
          ),
        ],
        const SizedBox(height: 20),
        Text(
          'Other directories',
          style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
        ),
        ...ListTile.divideTiles(
          context: context,
          tiles: [
            for (final tenant in directories.where((d) => !d.isCurrent))
              ListTile(
                title: Text(tenant.displayName, style: context.textTheme.bodyMedium),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => onSwitch(tenant),
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ),
      ],
    );
  }
}
