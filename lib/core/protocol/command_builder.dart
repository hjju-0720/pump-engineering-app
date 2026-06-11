import 'op_code.dart';
import 'packet_type.dart';
import 'pump_packet.dart';

class CommandBuilder {
  const CommandBuilder();

  PumpPacket getStatus() => const PumpPacket(
        type: PacketType.command,
        opCode: OpCode.initialScreenInformation,
      );

  PumpPacket getDeliveryStatus() => const PumpPacket(
        type: PacketType.command,
        opCode: OpCode.deliveryStatus,
      );

  PumpPacket getPumpCheck() {
    return const PumpPacket(
      type: PacketType.command,
      opCode: OpCode.getPumpCheck,
    );
  }

  PumpPacket startStepBolus({required int doseInHundredthsUnit, int speed = 0}) {
    return PumpPacket(
      type: PacketType.command,
      opCode: OpCode.setStepBolusStart,
      parameters: [
        doseInHundredthsUnit & 0xFF,
        (doseInHundredthsUnit >> 8) & 0xFF,
        speed & 0xFF,
      ],
    );
  }

  PumpPacket stopStepBolus() => const PumpPacket(
        type: PacketType.command,
        opCode: OpCode.setStepBolusStop,
      );
}
