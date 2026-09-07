import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/core/logging/sanitize_log_dump.dart';

void main() {
  test('redacts GitHub tokens and Authorization', () {
    const raw = '''
ghp_abc123XYZ
github_pat_11AAAA_bbbb
Authorization: Bearer ghp_abc123XYZ
authorization: token secret
''';
    final out = sanitizeLogDump(raw);
    expect(out, isNot(contains('ghp_abc')));
    expect(out, isNot(contains('github_pat_11')));
    expect(out, isNot(contains('secret')));
    expect(out, contains('[redacted]'));
  });
}
