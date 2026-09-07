class LogDumpReport {
  const LogDumpReport({required this.id});

  final String id;
}

/// Export in-memory logs and POST them to the dump endpoint.
abstract interface class LogDump {
  String exportText();
  Future<LogDumpReport> upload();
}
