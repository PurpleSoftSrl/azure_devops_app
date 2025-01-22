import 'package:azure_devops/src/models/saved_query.dart';

extension ChildQueryExt on ChildQuery {
  String get projectId => url.isEmpty ? '' : url.substring(0, url.indexOf('/_apis/')).split('/').last;
}
