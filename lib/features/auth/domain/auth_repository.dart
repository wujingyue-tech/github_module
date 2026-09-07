import 'user.dart';

abstract interface class AuthRepository {
  Future<User> getUser({String? token, Map<String, String>? headers});
}
