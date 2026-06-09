import '../utils/hex_utils.dart';
import 'crc16.dart';
import 'packet_type.dart';

class PumpPacket {
  static const List<int> startPlain = [0xA5, 0xA5];
  static const List<int> endPlain = [0x5A, 0x5A];

  final PacketType type;
  final int opCode;
  final List<int> parameters;
  final bool encrypted;

  const PumpPacket({
    required this.type,
    required this.opCode,
    this.parameters = const [],
    this.encrypted = false,
  });

  List<int> encode() {
    final body = <int>[
      type.value,
      opCode,
      ...parameters,
    ];

    final crc = Crc16.generate(body, encrypted: encrypted);

    return <int>[
      ...startPlain,
      body.length,
      ...body,
      crc & 0xFF,
      (crc >> 8) & 0xFF,
      ...endPlain,
    ];
  }

  static PumpPacket parse(
      List<int> raw, {
        bool encrypted = false,
        bool danaI = true,
      }) {
    if (raw.length < 9) {
      throw const FormatException('Packet too short');
    }

    if (raw[0] != startPlain[0] || raw[1] != startPlain[1]) {
      throw const FormatException('Invalid packet start');
    }

    if (raw[raw.length - 2] != endPlain[0] ||
        raw[raw.length - 1] != endPlain[1]) {
      throw const FormatException('Invalid packet end');
    }

    final length = raw[2];
    final bodyStart = 3;
    final bodyEnd = bodyStart + length;

    if (bodyEnd + 4 != raw.length) {
      throw FormatException(
        'Length mismatch. length=$length, rawLength=${raw.length}',
      );
    }

    final body = raw.sublist(bodyStart, bodyEnd);

    final receivedCrc = raw[bodyEnd] | (raw[bodyEnd + 1] << 8);
    final calculatedCrc = Crc16.generate(
      body,
      encrypted: encrypted,
      danaI: danaI,
    );

    if (receivedCrc != calculatedCrc) {
      throw FormatException(
        'CRC mismatch. received=0x${receivedCrc.toRadixString(16)}, '
            'calculated=0x${calculatedCrc.toRadixString(16)}',
      );
    }

    final packetType = PacketType.fromValue(body[0]);

    if (packetType == null) {
      throw FormatException(
        'Unknown packet type: 0x${body[0].toRadixString(16)}',
      );
    }

    return PumpPacket(
      type: packetType,
      opCode: body[1],
      parameters: body.length > 2 ? body.sublist(2) : const [],
      encrypted: encrypted,
    );
  }

  String toHex() => HexUtils.toHex(encode());
}