part of splash;

class _SplashScreen extends StatelessWidget {
  const _SplashScreen(this.ctrl, this.parameters);

  final _SplashController ctrl;
  final _SplashParameters parameters;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: context.themeExtension.background,
        child: AppPage.empty(
          init: ctrl.init,
          builder: (_) => Center(
            child: Image.asset(
              'assets/logos/logo.png',
              height: 250,
            ),
          ),
        ),
      ),
    );
  }
}
