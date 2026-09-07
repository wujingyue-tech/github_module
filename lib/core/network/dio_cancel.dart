import 'package:dio/dio.dart';
import 'package:learn_flutter/core/request_cancel.dart';

CancelToken cancelTokenFor(RequestCancel? cancel) {
  final token = CancelToken();
  cancel?.whenCancelled(() => token.cancel());
  return token;
}
