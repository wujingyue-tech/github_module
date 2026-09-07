import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:learn_flutter/features/auth/data/github_auth_remote.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter({required this.status, required this.body});

  final int status;
  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const userJson = '''
{
  "login": "octocat",
  "avatar_url": "https://example.com/a.png",
  "type": "User",
  "public_repos": 2,
  "followers": 1,
  "following": 0,
  "created_at": "2020-01-01T00:00:00Z",
  "updated_at": "2020-01-01T00:00:00Z"
}
''';

  AuthRepositoryImpl repositoryWith({
    required int status,
    required String body,
  }) {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.github.com/'))
      ..httpClientAdapter = _Adapter(status: status, body: body);
    return AuthRepositoryImpl(GitHubAuthRemote(dio));
  }

  test('parses current user into a domain entity', () async {
    final repo = repositoryWith(status: 200, body: userJson);
    final user = await repo.getUser(token: 't');
    expect(user.login, 'octocat');
    expect(user.publicRepos, 2);
    expect(user.createdAt, DateTime.utc(2020, 1, 1));
  });

  test(
    'throws invalidToken on 401 and keeps the DioException as cause',
    () async {
      final repo = repositoryWith(status: 401, body: '{"message":"bad"}');
      try {
        await repo.getUser(token: 'bad');
        fail('expected AppException');
      } on AppException catch (error) {
        expect(error.code, AppErrorCode.invalidToken);
        expect(error.cause, isA<DioException>());
      }
    },
  );
}
