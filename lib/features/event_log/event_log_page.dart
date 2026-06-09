import 'package:flutter/material.dart';

import '../../models/event_log.dart';
import '../dashboard/widgets/event_log_panel.dart';

class EventLogPage extends StatefulWidget {
  final List<EventLog> logs;
  final VoidCallback onClearLogs;

  const EventLogPage({
    super.key,
    required this.logs,
    required this.onClearLogs,
  });

  @override
  State<EventLogPage> createState() => _EventLogPageState();
}

class _EventLogPageState extends State<EventLogPage> {
  String _levelFilter = 'ALL';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EventLog> get _filteredLogs {
    final keyword = _searchController.text.trim().toUpperCase();

    return widget.logs.where((log) {
      final levelOk = _levelFilter == 'ALL' || log.level == _levelFilter;

      final searchable = '${log.level} ${log.message}'.toUpperCase();
      final searchOk = keyword.isEmpty || searchable.contains(keyword);

      return levelOk && searchOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLogs;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _Header(
            totalCount: widget.logs.length,
            filteredCount: filtered.length,
            onClearLogs: widget.onClearLogs,
          ),
          const SizedBox(height: 12),
          _FilterBar(
            levelFilter: _levelFilter,
            searchController: _searchController,
            onLevelChanged: (value) {
              setState(() {
                _levelFilter = value;
              });
            },
            onSearchChanged: () => setState(() {}),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: EventLogPanel(logs: filtered),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int totalCount;
  final int filteredCount;
  final VoidCallback onClearLogs;

  const _Header({
    required this.totalCount,
    required this.filteredCount,
    required this.onClearLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Event Log',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.lightBlueAccent,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Total: $totalCount  |  Filtered: $filteredCount',
          style: const TextStyle(color: Colors.white70),
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: onClearLogs,
          child: const Text('Clear Logs'),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String levelFilter;
  final TextEditingController searchController;
  final ValueChanged<String> onLevelChanged;
  final VoidCallback onSearchChanged;

  const _FilterBar({
    required this.levelFilter,
    required this.searchController,
    required this.onLevelChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<String>(
            value: levelFilter,
            decoration: const InputDecoration(
              labelText: 'Level',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: 'ALL', child: Text('ALL')),
              DropdownMenuItem(value: 'INFO', child: Text('INFO')),
              DropdownMenuItem(value: 'WARN', child: Text('WARN')),
              DropdownMenuItem(value: 'ERROR', child: Text('ERROR')),
            ],
            onChanged: (value) {
              if (value != null) {
                onLevelChanged(value);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Search event message',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => onSearchChanged(),
          ),
        ),
      ],
    );
  }
}