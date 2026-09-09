import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_module/features/auth/data/user_dto.dart';
import 'package:github_module/features/session/data/auth_store_impl.dart';
import 'package:github_module/features/session/data/settings_store_impl.dart';
import 'package:github_module/features/session/domain/auth_store.dart';
import 'package:github_module/features/session/domain/settings_store.dart';

/// Session I/O defaults. Separate from `di.dart` so `sessionProvider` can
/// read these without a circular import through Dio interceptors.
final authStoreProvider = Provider<AuthStore>(
  (ref) =>
      AuthStoreImpl(encodeUser: UserDto.encode, decodeUser: UserDto.tryDecode),
);

final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => SettingsStoreImpl(),
);
