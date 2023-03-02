part of splash;

class _SplashScreen extends StatelessWidget {
  const _SplashScreen(this.ctrl, this.parameters);

  final _SplashController ctrl;
  final _SplashParameters parameters;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colorScheme.background,
      child: AppPage.empty(
        init: ctrl.init,
        dispose: ctrl.dispose,
        builder: (_) => Center(
          child: Image.asset(
            'assets/logos/logo.png',
            height: 250,
          ),
        ),
      ),
    );
  }
}
