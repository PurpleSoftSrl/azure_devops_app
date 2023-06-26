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
        init: () async => true,
        dispose: ctrl.dispose,
        title: 'Az DevOps',
        builder: (_) => Column(
          children: [
            Text(
              'Manage your Azure DevOps tasks on the go',
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w500,
                fontFamily: AppTheme.defaultFont,
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Login with your Personal Access Token',
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
              height: 10,
            ),
            Form(
              child: Column(
                children: [
                  DevOpsFormField(
                    formFieldKey: ctrl.formFieldKey,
                    onChanged: ctrl.setPat,
                    hint: 'Personal Access Token',
                    maxLines: 1,
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
            const SizedBox(
              height: 100,
            ),
            Link(
              uri: Uri.parse('https://github.com/PurpleSoftSrl/azure_devops_app'),
              builder: (_, link) => InkWell(
                onTap: link,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Check out Az DevOps ',
                        style: context.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontFamily: AppTheme.defaultFont,
                        ),
                      ),
                      TextSpan(
                        text: 'GitHub repository',
                        style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Link(
              uri: Uri.parse(
                'https://www.purplesoft.io?utm_source=azdevops_app&utm_medium=app&utm_campaign=azdevops',
              ),
              builder: (_, link) => InkWell(
                onTap: () => ctrl.openPurplesoftWebsite(link),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Made with \u2764 by ',
                        style: context.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontFamily: AppTheme.defaultFont,
                        ),
                      ),
                      TextSpan(
                        text: 'PurpleSoft Srl',
                        style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
