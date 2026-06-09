import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/event_log.dart';
import '../../models/packet_log.dart';

class CsvExportService {
  Future<String> exportPacketLogs(
      List<PacketLog> logs,
      ) async {
    final rows = <List<dynamic>>[];

    rows.add([
      'Timestamp',
      'Direction',
      'Type',
      'Opcode',
      'Status',
      'Label',
      'Raw Data',
    ]);

    for (final log in logs) {
      rows.add([
        log.timestamp.toIso8601String(),
        log.direction,
        log.packetTypeText,
        log.opCodeText,
        log.parseStatus,
        log.label,
        log.hex,
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    final dir = await getApplicationDocumentsDirectory();

    final filename =
        'packet_log_${DateTime.now().millisecondsSinceEpoch}.csv';

    final file = File('${dir.path}/$filename');

    await file.writeAsString(csv);

    return file.path;
  }

  Future<String> exportEventLogs(
      List<EventLog> logs,
      ) async {
    final rows = <List<dynamic>>[];

    rows.add([
      'Timestamp',
      'Level',
      'Message',
    ]);

    for (final log in logs) {
      rows.add([
        log.timestamp.toIso8601String(),
        log.level,
        log.message,
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    final dir = await getApplicationDocumentsDirectory();

    final filename =
        'event_log_${DateTime.now().millisecondsSinceEpoch}.csv';

    final file = File('${dir.path}/$filename');

    await file.writeAsString(csv);

    return file.path;
  }
}