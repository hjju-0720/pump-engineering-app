import 'package:flutter/material.dart';

import '../../../core/protocol/op_code_name.dart';
import '../../../core/protocol/packet_interpreter.dart';
import '../../../models/packet_log.dart';
import 'panel.dart';

class PacketMonitorPanel extends StatelessWidget {
  final List<PacketLog> logs;

  const PacketMonitorPanel({
    super.key,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    return Panel(
      title: 'PACKET MONITOR',
      child: logs.isEmpty
          ? const Text('No packet generated.')
          : Column(
        children: [
          const _HeaderRow(),
          const Divider(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: logs.length,
              separatorBuilder: (_, __) => const Divider(height: 10),
              itemBuilder: (context, index) {
                return _PacketRow(log: logs[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(width: 90, child: Text('Time', style: _headerStyle)),
        SizedBox(width: 36, child: Text('Dir', style: _headerStyle)),
        SizedBox(width: 64, child: Text('Type', style: _headerStyle)),
        SizedBox(width: 64, child: Text('Op', style: _headerStyle)),
        SizedBox(width: 44, child: Text('CRC', style: _headerStyle)),
        Expanded(child: Text('Label / Data', style: _headerStyle)),
      ],
    );
  }
}

class _PacketRow extends StatelessWidget {
  final PacketLog log;

  const _PacketRow({required this.log});

  void _showPacketDetail(BuildContext context, PacketLog log) {
    final packet = log.parsedPacket;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Packet Detail'),
          content: SizedBox(
            width: 520,
            child: packet == null ? Text(
              'Parse Error\n\n${log.parseError ?? 'Unknown error'}\n\n${log.hex}',
              style: const TextStyle(fontFamily: 'monospace'),
            ) : SelectableText(
              'Time        : ${_time(log.timestamp)}\n'
              'Direction   : ${log.direction}\n'
              'Type        : ${packet.type.label}\n'
              'OpCode      : ${log.opCodeText}\n'
              'Name        : ${OpCodeName.getName(packet.type, packet.opCode)}\n'
              'CRC Status  : ${log.parseStatus}\n'
              'Parameters  : ${packet.parameters.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ')}\n\n'
              'Interpretation\n'
              '${PacketInterpreter.interpret(packet)}\n'
              '\nRaw Packet\n'
              '${log.hex}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTx = log.direction == 'TX';
    final isError = log.parseStatus == 'ERR';

    final dirColor = isTx ? Colors.lightBlueAccent : Colors.greenAccent;
    final statusColor = isError ? Colors.redAccent : Colors.greenAccent;

    return InkWell(
      onTap: () => _showPacketDetail(context, log),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(_time(log.timestamp), style: _mono)),
          SizedBox(
            width: 36,
            child: Text(
              log.direction,
              style: _mono.copyWith(color: dirColor, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 64, child: Text(log.packetTypeText, style: _mono)),
          SizedBox(width: 64, child: Text(log.opCodeText, style: _mono)),
          SizedBox(
            width: 44,
            child: Text(
              log.parseStatus,
              style: _mono.copyWith(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.label, style: _mono.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                SelectableText(
                  log.hex,
                  style: _mono.copyWith(color: Colors.white70, fontSize: 11),
                ),
                if (log.parseError != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    log.parseError!,
                    style: _mono.copyWith(color: Colors.redAccent, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
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

const _headerStyle = TextStyle(
  fontFamily: 'monospace',
  fontSize: 11,
  color: Colors.white54,
  fontWeight: FontWeight.bold,
);

const _mono = TextStyle(
  fontFamily: 'monospace',
  fontSize: 12,
);