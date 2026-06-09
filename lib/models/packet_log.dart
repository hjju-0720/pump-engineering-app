import '../core/protocol/pump_packet.dart';
import '../core/utils/hex_utils.dart';

class PacketLog {
  final DateTime timestamp;
  final String direction;
  final String label;
  final List<int> data;
  final PumpPacket? parsedPacket;
  final String? parseError;

  const PacketLog({
    required this.timestamp,
    required this.direction,
    required this.label,
    required this.data,
    this.parsedPacket,
    this.parseError,
  });

  String get hex => HexUtils.toHex(data);

  String get opCodeText {
    final packet = parsedPacket;
    if (packet == null) return '-';
    return '0x${packet.opCode.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  String get packetTypeText {
    final packet = parsedPacket;
    if (packet == null) return '-';
    return packet.type.label;
  }

  String get parseStatus {
    if (parseError != null) return 'ERR';
    if (parsedPacket != null) return 'OK';
    return '-';
  }
}