import 'package:github_module/core/error/app_exception.dart';
import 'package:github_module/features/auth/domain/auth_repository.dart';
import 'package:github_module/features/auth/domain/sample_user.dart';
import 'package:github_module/features/auth/domain/user.dart';

/// In-memory [AuthRepository] for snapshot preview and notifier tests.
class FakeAuthRepository implements AuthRepository {
  const FakeAuthRepository({this.user, this.error});

  factory FakeAuthRepository.success([User? user]) {
    return FakeAuthRepository(user: user ?? previewUser);
  }

  factory FakeAuthRepository.error([
    AppErrorCode code = AppErrorCode.invalidToken,
  ]) {
    return FakeAuthRepository(error: AppException(code));
  }

  final User? user;
  final Object? error;

  @override
  Future<User> getUser({String? token, Map<String, String>? headers}) async {
    if (error != null) throw error!;
    return user!;
  }
}
