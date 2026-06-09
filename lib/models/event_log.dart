class EventLog {
  final DateTime timestamp;
  final String level;
  final String message;

  const EventLog({
    required this.timestamp,
    required this.level,
    required this.message,
  });
}
