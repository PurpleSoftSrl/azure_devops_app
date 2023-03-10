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
        builder: (_) => Column(
          children: [
            const SizedBox(
              height: 80,
            ),
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
                  Link(
                    uri: Uri.parse(
                      'https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate',
                    ),
                    builder: (_, link) => SizedBox(
                      height: 48,
                      child: InkWell(
                        onTap: link,
                        child: Row(
                          children: [
                            Text(
                              'PAT documentation link',
                              style: context.textTheme.titleSmall!.copyWith(decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
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
