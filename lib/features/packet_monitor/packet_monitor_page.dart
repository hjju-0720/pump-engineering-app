import 'package:flutter/material.dart';

import '../../models/packet_log.dart';
import '../dashboard/widgets/packet_monitor_panel.dart';

class PacketMonitorPage extends StatefulWidget {
  final List<PacketLog> logs;
  final VoidCallback onClearLogs;

  const PacketMonitorPage({
    super.key,
    required this.logs,
    required this.onClearLogs,
  });

  @override
  State<PacketMonitorPage> createState() => _PacketMonitorPageState();
}

class _PacketMonitorPageState extends State<PacketMonitorPage> {
  String _directionFilter = 'ALL';
  String _typeFilter = 'ALL';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PacketLog> get _filteredLogs {
    final keyword = _searchController.text.trim().toUpperCase();

    return widget.logs.where((log) {
      final directionOk =
          _directionFilter == 'ALL' || log.direction == _directionFilter;

      final typeOk =
          _typeFilter == 'ALL' ||
              log.packetTypeText == _typeFilter ||
              (_typeFilter == 'ERR' && log.parseStatus == 'ERR');

      final searchable =
      '${log.label} ${log.opCodeText} ${log.packetTypeText} ${log.hex}'
          .toUpperCase();

      final searchOk = keyword.isEmpty || searchable.contains(keyword);

      return directionOk && typeOk && searchOk;
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
            directionFilter: _directionFilter,
            typeFilter: _typeFilter,
            searchController: _searchController,
            onDirectionChanged: (value) {
              setState(() {
                _directionFilter = value;
              });
            },
            onTypeChanged: (value) {
              setState(() {
                _typeFilter = value;
              });
            },
            onSearchChanged: () => setState(() {}),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: PacketMonitorPanel(logs: filtered),
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
          'Packet Monitor',
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
  final String directionFilter;
  final String typeFilter;
  final TextEditingController searchController;
  final ValueChanged<String> onDirectionChanged;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onSearchChanged;

  const _FilterBar({
    required this.directionFilter,
    required this.typeFilter,
    required this.searchController,
    required this.onDirectionChanged,
    required this.onTypeChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Dropdown(
          label: 'Direction',
          value: directionFilter,
          items: const ['ALL', 'TX', 'RX'],
          onChanged: onDirectionChanged,
        ),
        const SizedBox(width: 12),
        _Dropdown(
          label: 'Type',
          value: typeFilter,
          items: const ['ALL', 'CMD', 'RSP', 'NTF', 'ERR'],
          onChanged: onTypeChanged,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Search label / opcode / hex',
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

class _Dropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          for (final item in items)
            DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
        ],
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}