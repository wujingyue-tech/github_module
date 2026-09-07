String sanitizeLogDump(String raw) {
  var out = raw;
  out = out.replaceAll(RegExp(r'github_pat_[A-Za-z0-9_]+'), '[redacted]');
  out = out.replaceAll(RegExp(r'ghp_[A-Za-z0-9]+'), '[redacted]');
  out = out.replaceAllMapped(
    RegExp(r'(Authorization\s*[:=]\s*).+$', caseSensitive: false, multiLine: true),
    (match) => '${match[1]}[redacted]',
  );
  return out;
}
