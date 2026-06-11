import 'packet_type.dart';
import 'pump_packet.dart';

class PacketInterpreter {
  static String _pumpModelName(int model) {
    switch (model) {
      case 0x05:
        return 'Dana RS Pump';
      case 0x06:
        return 'Dana RS Easy - Domestic';
      case 0x07:
        return 'Dana-i';
      default:
        return 'Unknown Model';
    }
  }

  static String _initialStatusDescription(int status) {
    final flags = <String>[];

    if ((status & 0x01) != 0) flags.add('Suspend');
    if ((status & 0x02) != 0) flags.add('Bolus Block');
    if ((status & 0x04) != 0) flags.add('Extended Bolus');
    if ((status & 0x08) != 0) flags.add('Dual Bolus');
    if ((status & 0x10) != 0) flags.add('Temporary Basal');
    if ((status & 0x20) != 0) flags.add('Button Lock');

    if (flags.isEmpty) return 'Normal';

    return flags.join(', ');
  }

  static String interpret(PumpPacket packet) {
    if (packet.type == PacketType.command) {
      return _interpretCommand(packet);
    }

    if (packet.type == PacketType.response) {
      return _interpretResponse(packet);
    }

    if (packet.type == PacketType.notify) {
      return _interpretNotify(packet);
    }

    return 'No interpretation available.';
  }

  static String _interpretCommand(PumpPacket packet) {
    switch (packet.opCode) {
      case 0x02:
        return 'Request initial screen information.';

      case 0x03:
        return 'Request current delivery status.';

      case 0x44:
        return 'Stop current step bolus delivery.';

      case 0x4A:
        if (packet.parameters.length < 3) {
          return 'Invalid Step Bolus Start command: missing parameters.';
        }

        final rawDose = packet.parameters[0] | (packet.parameters[1] << 8);
        final doseU = rawDose / 100.0;
        final speed = packet.parameters[2];

        return '''
        Command : Start Step Bolus
        Dose    : ${doseU.toStringAsFixed(2)} U
        Speed   : $speed
        ''';

      case 0x21:
        return 'Command : Get Pump Check';

      case 0x69:
        return 'Set suspend ON.';

      case 0x6A:
        return 'Set suspend OFF.';

      default:
        return 'Unknown command.';
    }
  }

  static String _interpretResponse(PumpPacket packet) {
    switch (packet.opCode) {
      case 0x02:
        if (packet.parameters.length < 18) {
          return 'Invalid Initial Screen Information response: missing parameters.';
        }

        final status = packet.parameters[0];
        final dailyDeliveryRate =
        packet.parameters[1] | (packet.parameters[2] << 8);
        final dailyMaxRate =
        packet.parameters[3] | (packet.parameters[4] << 8);
        final reservoirRate =
        packet.parameters[5] | (packet.parameters[6] << 8);
        final currentBasalRate =
        packet.parameters[7] | (packet.parameters[8] << 8);
        final temporaryRatio = packet.parameters[9];
        final batteryRatio = packet.parameters[10];
        final activeInsulin =
        packet.parameters[15] | (packet.parameters[16] << 8);
        final error = packet.parameters[17];

        return '''
          Response            : Initial Screen Information
          Status Flags        : 0x${status.toRadixString(16).padLeft(2, '0').toUpperCase()}
          Daily Delivery      : ${(dailyDeliveryRate / 100.0).toStringAsFixed(2)} U
          Daily Max           : ${(dailyMaxRate / 100.0).toStringAsFixed(2)} U
          Reservoir           : ${(reservoirRate / 100.0).toStringAsFixed(2)} U
          Current Basal       : ${(currentBasalRate / 100.0).toStringAsFixed(2)} U/h
          Temporary Ratio     : $temporaryRatio %
          Battery             : $batteryRatio %
          Active Insulin      : ${(activeInsulin / 100.0).toStringAsFixed(2)} U
          Error               : 0x${error.toRadixString(16).padLeft(2, '0').toUpperCase()}
          Status Description  : ${_initialStatusDescription(status)}
          ''';

      case 0x21:
        if (packet.parameters.length < 3) {
          return 'Invalid Pump Check response: missing check values.';
        }

        final model = packet.parameters[0];
        final protocolVersion = packet.parameters[1];
        final productCode = packet.parameters[2];

        return '''
Response         : Pump Check
Model Code       : 0x${model.toRadixString(16).padLeft(2, '0').toUpperCase()} (${_pumpModelName(model)})
Protocol Version : $protocolVersion
Product Code     : $productCode
''';

      case 0x4A:
        if (packet.parameters.isEmpty) {
          return 'Invalid Step Bolus Start response: missing status.';
        }

        final status = packet.parameters[0];

        return '''
Response : Step Bolus Start
Status   : ${_bolusStartStatus(status)}
Raw      : 0x${status.toRadixString(16).padLeft(2, '0').toUpperCase()}
''';

      case 0x44:
        if (packet.parameters.isEmpty) {
          return 'Invalid Step Bolus Stop response: missing status.';
        }

        return '''
Response : Step Bolus Stop
Status   : ${packet.parameters[0] == 0x00 ? 'OK' : 'ERROR'}
''';

      default:
        return 'Unknown response.';
    }
  }

  static String _interpretNotify(PumpPacket packet) {
    switch (packet.opCode) {
      case 0x01:
        if (packet.parameters.length < 2) {
          return 'Invalid delivery complete notify.';
        }

        final rawDose = packet.parameters[0] | (packet.parameters[1] << 8);
        final doseU = rawDose / 100.0;

        return '''
Notify : Delivery Complete
Dose   : ${doseU.toStringAsFixed(2)} U
''';

      case 0x02:
        if (packet.parameters.length < 2) {
          return 'Invalid delivery rate notify.';
        }

        final rawDose = packet.parameters[0] | (packet.parameters[1] << 8);
        final doseU = rawDose / 100.0;

        return '''
Notify        : Delivery Progress
Delivered Dose: ${doseU.toStringAsFixed(2)} U
''';

      case 0x03:
        if (packet.parameters.length < 2) {
          return 'Invalid alarm notify.';
        }

        final alarmCode = packet.parameters[0] | (packet.parameters[1] << 8);

        return '''
Notify     : Alarm
Alarm Code : 0x${alarmCode.toRadixString(16).padLeft(4, '0').toUpperCase()}
Alarm Name : ${_alarmName(alarmCode)}
''';

      default:
        return 'Unknown notify.';
    }
  }

  static String _bolusStartStatus(int status) {
    if (status == 0x00) return 'OK';

    final messages = <String>[];

    if ((status & 0x10) != 0) messages.add('Bolus MAX');
    if ((status & 0x20) != 0) messages.add('Delivery Command Error');
    if ((status & 0x40) != 0) messages.add('Speed Error');
    if ((status & 0x80) != 0) messages.add('Bolus Safety Rate Error');

    if (messages.isEmpty) {
      return 'ERROR';
    }

    return messages.join(', ');
  }

  static String _alarmName(int code) {
    switch (code) {
      case 0x01:
        return 'Battery 0% Alarm';
      case 0x02:
        return 'Pump Error';
      case 0x03:
        return 'Occlusion';
      case 0x04:
        return 'Low Battery';
      case 0x05:
        return 'Shutdown';
      case 0x06:
        return 'Basal Compare';
      case 0x07:
        return 'Glucose Check';
      case 0x08:
        return 'Low Reservoir';
      case 0x09:
        return 'Empty Reservoir';
      case 0x0A:
        return 'Shaft Check';
      case 0x0B:
        return 'Basal MAX';
      case 0x0C:
        return 'Daily MAX';
      default:
        return 'Unknown Alarm';
    }
  }
}