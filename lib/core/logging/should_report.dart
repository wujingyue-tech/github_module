import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/core/request_cancel.dart';

bool shouldReport(Object error) {
  if (error is RequestCancelledException) return false;
  if (error is AppException && error.code == AppErrorCode.emptyToken) {
    return false;
  }
  return true;
}
