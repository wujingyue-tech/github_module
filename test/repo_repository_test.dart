import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/core/request_cancel.dart';
import 'package:learn_flutter/features/repos/data/github_repo_remote.dart';
import 'package:learn_flutter/features/repos/data/repo_repository_impl.dart';

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
  test('parses repo list into domain entities', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.github.com/'))
      ..httpClientAdapter = _Adapter(
        status: 200,
        body: '''
[
  {
    "id": 1,
    "name": "hello",
    "full_name": "octocat/hello",
    "owner": {
      "login": "octocat",
      "avatar_url": "https://example.com/a.png",
      "type": "User"
    },
    "private": false,
    "description": null,
    "fork": false,
    "forks_count": 0,
    "stargazers_count": 3,
    "size": 1,
    "default_branch": "main",
    "open_issues_count": 0,
    "pushed_at": "2020-01-01T00:00:00Z",
    "created_at": "2020-01-01T00:00:00Z",
    "updated_at": "2020-01-01T00:00:00Z",
    "license": { "name": "MIT" }
  }
]
''',
      );
    final repo = RepoRepositoryImpl(GitHubRepoRemote(dio));
    final repos = await repo.listRepos(page: 1);
    expect(repos, hasLength(1));
    expect(repos.first.name, 'hello');
    expect(repos.first.description, isNull);
    expect(repos.first.licenseName, 'MIT');
    expect(repos.first.owner.login, 'octocat');
  });

  test('cancel stops the HTTP call', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.github.com/'))
      ..httpClientAdapter = _CancelAdapter();
    final repo = RepoRepositoryImpl(GitHubRepoRemote(dio));
    final cancel = RequestCancel();
    final future = repo.listRepos(page: 1, cancel: cancel);
    await Future<void>.delayed(Duration.zero);
    cancel.cancel();
    await expectLater(future, throwsA(isA<RequestCancelledException>()));
  });
}

class _CancelAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await cancelFuture;
    throw DioException(requestOptions: options, type: DioExceptionType.cancel);
  }

  @override
  void close({bool force = false}) {}
}
