import 'package:github_module/core/error/app_exception.dart';
import 'package:github_module/core/request_cancel.dart';

bool shouldReport(Object error) {
  if (error is RequestCancelledException) return false;
  if (error is AppException && error.code == AppErrorCode.emptyToken) {
    return false;
  }
  return true;
}
