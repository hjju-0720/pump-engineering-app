import 'package:flutter/material.dart';
import '../../../models/device_status.dart';
import 'panel.dart';

class DeviceStatusPanel extends StatelessWidget {
  final DeviceStatus status;

  const DeviceStatusPanel({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Panel(
      title: 'DEVICE STATUS',
      child: Text(
        'Connection        ${status.connectionState}\n'
        'Device Name       ${status.deviceName}\n'
        'Firmware Version  ${status.firmwareVersion}\n'
        'Battery           ${status.batteryPercent}%\n'
        'Reservoir         ${status.reservoirUnits.toStringAsFixed(1)} U\n'
        'RSSI              ${status.rssi} dBm\n\n'
        'THERAPY STATE\n'
        '${status.therapyState}\n\n'
        'Basal Delivery    ${status.therapyState == 'BASAL_RUNNING' ? 'Running' : 'Stopped'}\n'
        'Last Bolus        ${status.lastBolusUnits.toStringAsFixed(2)} U\n'
        'Daily Total       ${status.dailyTotalUnits.toStringAsFixed(2)} U\n'
        'System Status     ${status.therapyState == 'ALARM' ? 'Alarm' : 'Normal'}',
        style: const TextStyle(fontFamily: 'monospace', height: 1.6),
      ),
    );
  }
}
