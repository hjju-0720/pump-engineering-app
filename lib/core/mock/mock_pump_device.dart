import 'dart:async';

import '../protocol/packet_type.dart';
import '../protocol/pump_packet.dart';

class MockPumpDevice {
  final StreamController<List<int>> _rxController =
  StreamController<List<int>>.broadcast();

  Stream<List<int>> get rxStream => _rxController.stream;

  Future<void> handleTx(List<int> tx) async {
    PumpPacket packet;

    try {
      packet = PumpPacket.parse(tx);
    } catch (_) {
      _emitErrorResponse();
      return;
    }

    if (packet.type != PacketType.command) {
      _emitErrorResponse();
      return;
    }

    switch (packet.opCode) {
      case 0x02:
        await _handleGetStatus();
        break;

      case 0x03:
        await _handleGetDeliveryStatus();
        break;

      case 0x4A:
        await _handleStepBolusStart(packet);
        break;

      case 0x44:
        await _handleStepBolusStop();
        break;

      default:
        await _handleUnknownCommand(packet);
        break;
    }
  }

  Future<void> _handleGetStatus() async {
    await _delay();

    final response = const PumpPacket(
      type: PacketType.response,
      opCode: 0x02,
      parameters: [
        0x00, // status
        0x18, 0x0B, // daily delivery rate mock
        0xE8, 0x03, // daily max mock
        0xF0, 0x2E, // reservoir 120.0U mock
        0x78, 0x00, // current basal 1.20U/h mock
        0x00, // temp ratio
        0x55, // battery 85%
        0x00, 0x00, // extended bolus
        0x32, 0x00, // active insulin 0.50U
        0x00, // error
        0x00, // alarm max
      ],
    ).encode();

    _rxController.add(response);
  }

  Future<void> _handleGetDeliveryStatus() async {
    await _delay();

    final response = const PumpPacket(
      type: PacketType.response,
      opCode: 0x03,
      parameters: [
        0x00, // no active delivery
      ],
    ).encode();

    _rxController.add(response);
  }

  Future<void> _handleStepBolusStart(PumpPacket command) async {
    final params = command.parameters;

    if (params.length < 3) {
      await _delay();

      final response = const PumpPacket(
        type: PacketType.response,
        opCode: 0x4A,
        parameters: [0x20], // delivery command error
      ).encode();

      _rxController.add(response);
      return;
    }

    final doseRaw = params[0] | (params[1] << 8);

    await _delay();

    final okResponse = const PumpPacket(
      type: PacketType.response,
      opCode: 0x4A,
      parameters: [0x00],
    ).encode();

    _rxController.add(okResponse);

    await Future.delayed(const Duration(milliseconds: 500));

    final progressHalf = (doseRaw / 2).round();

    final progressNotify = PumpPacket(
      type: PacketType.notify,
      opCode: 0x02,
      parameters: [
        progressHalf & 0xFF,
        (progressHalf >> 8) & 0xFF,
      ],
    ).encode();

    _rxController.add(progressNotify);

    await Future.delayed(const Duration(milliseconds: 500));

    final completeNotify = PumpPacket(
      type: PacketType.notify,
      opCode: 0x01,
      parameters: [
        doseRaw & 0xFF,
        (doseRaw >> 8) & 0xFF,
      ],
    ).encode();

    _rxController.add(completeNotify);
  }

  Future<void> _handleStepBolusStop() async {
    await _delay();

    final response = const PumpPacket(
      type: PacketType.response,
      opCode: 0x44,
      parameters: [0x00],
    ).encode();

    _rxController.add(response);
  }

  Future<void> _handleUnknownCommand(PumpPacket command) async {
    await _delay();

    final response = PumpPacket(
      type: PacketType.response,
      opCode: command.opCode,
      parameters: [0x01],
    ).encode();

    _rxController.add(response);
  }

  void emitOcclusionAlarm() {
    final notify = const PumpPacket(
      type: PacketType.notify,
      opCode: 0x03,
      parameters: [0x03, 0x00],
    ).encode();

    _rxController.add(notify);
  }

  void emitLowBatteryAlarm() {
    final notify = const PumpPacket(
      type: PacketType.notify,
      opCode: 0x03,
      parameters: [0x04, 0x00],
    ).encode();

    _rxController.add(notify);
  }

  void _emitErrorResponse() {
    final response = const PumpPacket(
      type: PacketType.response,
      opCode: 0x00,
      parameters: [0x01],
    ).encode();

    _rxController.add(response);
  }

  Future<void> _delay() {
    return Future.delayed(const Duration(milliseconds: 120));
  }

  void dispose() {
    _rxController.close();
  }
}