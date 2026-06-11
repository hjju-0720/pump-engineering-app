import 'packet_type.dart';

class OpCodeName {
  static String getName(PacketType type, int opCode) {
    if (type == PacketType.notify) {
      switch (opCode) {
        case 0x01:
          return 'Delivery Complete';
        case 0x02:
          return 'Delivery Rate';
        case 0x03:
          return 'Alarm Notify';
        default:
          return 'Unknown Notify';
      }
    }

    if (type == PacketType.response) {
      switch (opCode) {
        case 0x02:
          return 'Initial Screen Response';
        case 0x03:
          return 'Delivery Status Response';
        case 0x4A:
          return 'Step Bolus Start Response';
        case 0x21:
          return 'Pump Check Response';
        default:
          return 'Unknown Response';
      }
    }

    switch (opCode) {
      case 0x02:
        return 'Get Initial Screen Information';
      case 0x03:
        return 'Get Delivery Status';
      case 0x20:
        return 'Get Shipping Information';
      case 0x21:
        return 'Get Pump Check';
      case 0x22:
        return 'Get User Time Change Flag';
      case 0x23:
        return 'Clear User Time Change Flag';
      case 0x24:
        return 'Get More Information';
      case 0x25:
        return 'Set History Upload Mode';
      case 0x26:
        return 'Get Today Delivery Total';
      case 0x44:
        return 'Stop Step Bolus';
      case 0x4A:
        return 'Start Step Bolus';
      case 0x69:
        return 'Suspend On';
      case 0x6A:
        return 'Suspend Off';
      default:
        return 'Unknown Command';
    }
  }
}