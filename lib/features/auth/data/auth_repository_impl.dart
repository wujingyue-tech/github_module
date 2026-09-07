import 'package:learn_flutter/features/auth/domain/auth_repository.dart';
import 'package:learn_flutter/features/auth/domain/user.dart';

import 'github_auth_remote.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final GitHubAuthRemote _remote;

  @override
  Future<User> getUser({String? token, Map<String, String>? headers}) async {
    final dto = await _remote.getUser(token: token, headers: headers);
    return dto.toDomain();
  }
}
