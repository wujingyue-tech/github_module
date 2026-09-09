import 'package:flutter_test/flutter_test.dart';
import 'package:github_module/core/app_info.dart';

void main() {
  test('label is marketing version plus store build', () {
    const info = AppInfo(version: '2026.1.0', buildNumber: '12');
    expect(info.label, '2026.1.0 (12)');
  });
}
