part of login;

class _LoginScreen extends StatelessWidget {
  const _LoginScreen(this.ctrl, this.parameters);

  final _LoginController ctrl;
  final _LoginParameters parameters;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => AppRouter.askBeforeClosingApp(didPop: didPop),
      child: AppPage(
        init: () async => true,
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
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(child: Text('Sign in with your Personal Access Token', style: context.textTheme.titleMedium)),
                IconButton(onPressed: ctrl.showInfo, icon: Icon(Icons.info_outline)),
              ],
            ),
            const SizedBox(height: 10),
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
                              'How to create a PAT?',
                              style: context.textTheme.titleSmall!.copyWith(decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  LoadingButton(onPressed: ctrl.login, text: 'Submit'),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Row(
              children: [
                Expanded(child: const Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Or', style: context.textTheme.titleMedium),
                ),
                Expanded(child: const Divider()),
              ],
            ),
            const SizedBox(height: 50),
            LoadingButton(onPressed: ctrl.loginWithMicrosoft, text: 'Sign in with Microsoft'),
            const SizedBox(height: 100),
            Link(
              uri: Uri.parse('https://github.com/PurpleSoftSrl/azure_devops_app'),
              builder: (_, link) => InkWell(
                onTap: link,
                child: Text.rich(
                  textAlign: TextAlign.center,
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
            const SizedBox(height: 20),
            Link(
              uri: Uri.parse('https://www.purplesoft.io?utm_source=azdevops_app&utm_medium=app&utm_campaign=azdevops'),
              builder: (_, link) => InkWell(
                onTap: () => ctrl.openPurplesoftWebsite(link),
                child: Text.rich(
                  textAlign: TextAlign.center,
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
