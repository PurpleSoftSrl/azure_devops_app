part of file_detail;

class _FileDetailController with ShareMixin {
  _FileDetailController._(this.api, this.args);

  final AzureApiService api;
  final RepoDetailArgs args;

  final fileContent = ValueNotifier<ApiResponse<FileDetailResponse?>?>(null);

  Future<void> init() async {
    final fileRes = await api.getFileDetail(
      projectName: args.projectName,
      repoName: args.repositoryName,
      path: args.filePath ?? '/',
      branch: args.branch,
    );

    fileContent.value = fileRes;

    // register all builtin languages
    for (final lang in builtinLanguages.entries) {
      highlight.registerLanguage(lang.value);
    }
  }

  void shareFile() {
    shareUrl(_fileUrl);
  }

  String get _fileUrl =>
      '${api.basePath}/${args.projectName}/_git/${args.repositoryName}?path=${args.filePath}&version=GB${args.branch}';
}

/// Map file extension to highlighting package language id
const Map<String, String> languageExtensions = {
  'as': 'actionscript',
  'adoc': 'asciidoc',
  'ahk': 'autohotkey',
  'au3': 'autoit',
  'x++': 'axapta',
  'sh': 'bash',
  'bas': 'basic',
  'bf': 'brainfuck',
  'capnp': 'capnproto',
  'coffee': 'coffeescript',
  'cs': 'csharp',
  'zone': 'dns',
  'bat': 'dos',
  'xlsx': 'excel',
  'f90': 'fortran',
  'fs': 'fsharp',
  'gms': 'gams',
  'dat': 'gauss',
  'feature': 'gherkin',
  'm': 'objectivec',
  'ml': 'ocaml',
  'scad': 'openscad',
  'ps1': 'powershell',
  'pde': 'processing',
  'proto': 'protobuf',
  'pp': 'puppet',
  'pb': 'purebasic',
  'py': 'python',
  're': 'reasonml',
  'rfx': 'roboconf',
  'rsc': 'routeros',
  'rules': 'ruleslanguage',
  'rs': 'rust',
  'st': 'smalltalk',
  'do': 'stata',
  'step': 'step21',
  'ts': 'taggerscript',
  'asm': 'x86asm',
  'xq': 'xquery',
  'zep': 'zephir',
};
