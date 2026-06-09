import 'package:flutter/material.dart';
import '../../../models/event_log.dart';
import 'panel.dart';

class EventLogPanel extends StatelessWidget {
  final List<EventLog> logs;

  const EventLogPanel({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Panel(
      title: 'EVENT LOG',
      child: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final time = _time(log.timestamp);
          return Text('$time  ${log.level.padRight(5)}  ${log.message}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13));
        },
      ),
    );
  }

  String _time(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}:'
        '${t.second.toString().padLeft(2, '0')}.'
        '${t.millisecond.toString().padLeft(3, '0')}';
  }
}
