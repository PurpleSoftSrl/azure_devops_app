part of settings;

class _ThemeModeRadio extends StatelessWidget {
  const _ThemeModeRadio({
    required this.mode,
    required this.onChanged,
    required this.icon,
  });

  final String mode;
  final void Function(String) onChanged;
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
          Radio(
            groupValue: true,
            activeColor: isSelected ? context.colorScheme.onBackground : context.colorScheme.onSecondary,
            value: isSelected,
            fillColor: MaterialStateProperty.resolveWith(
              (states) => states.contains(MaterialState.selected) ? null : context.colorScheme.onSecondary,
            ),
            onChanged: (_) => onChanged(mode),
          ),
        ],
      ),
    );
  }
}
