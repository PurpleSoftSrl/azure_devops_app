part of login;

class _LoginController {
  factory _LoginController({required AzureApiService apiService}) {
    return instance ??= _LoginController._(apiService);
  }

  _LoginController._(this.apiService);

  static _LoginController? instance;

  final AzureApiService apiService;

  final formFieldKey = GlobalKey<FormFieldState<dynamic>>();

  String pat = '';

  void dispose() {
    instance = null;
  }

  void init() {
    print('$_LoginController initialized');
  }

  Future<void> login() async {
    final isValid = formFieldKey.currentState!.validate();
    if (!isValid) return;

    final isLogged = await apiService.login(pat);
    if (isLogged == LoginStatus.failed) {
      return AlertService.error(
        'Login error',
        description: 'Check that your PAT is correct and retry',
      );
    }

    if (isLogged == LoginStatus.unauthorized) {
      return AlertService.error(
        'Unauthorized',
        description: 'Check that your PAT is correct and has permissions for all organizations',
      );
    }

    await AppRouter.goToChooseProjects();
  }

  void showInfo() {
    AlertService.error(
      'Info',
      description:
          'Your PAT is stored on your device and is only used as an http header to communicate with Azure API, '
          "it's not stored anywhere else.\n\n"
          "Check that your PAT has access to all the organizations, otherwise it won't work.\n\n"
          'You can create a new PAT at this link:\n'
          'https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate',
    );
  }
}
