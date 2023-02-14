part of login;

class _LoginScreen extends StatelessWidget {
  const _LoginScreen(this.ctrl, this.parameters);

  final _LoginController ctrl;
  final _LoginParameters parameters;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: AppRouter.askBeforeClosingApp,
      child: AppPage(
        init: ctrl.init,
        dispose: ctrl.dispose,
        title: 'Az DevOps',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Insert your Personal Access Token to manage your organization's projects",
                    style: context.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: ctrl.showInfo,
                  icon: Icon(Icons.info_outline),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Form(
              child: Column(
                children: [
                  DevOpsFormField(
                    formFieldKey: ctrl.formFieldKey,
                    onChanged: (value) => ctrl.pat = value,
                    hint: 'Personal Access Token',
                    onFieldSubmitted: ctrl.login,
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  LoadingButton(
                    onPressed: ctrl.login,
                    text: 'Submit',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
