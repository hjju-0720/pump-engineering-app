import 'package:flutter/material.dart';
import '../../../models/device_status.dart';

class TopBar extends StatelessWidget {
  final DeviceStatus deviceStatus;
  final VoidCallback onBleScan;
  final VoidCallback onBleDisconnect;

  const TopBar({
    super.key,
    required this.deviceStatus,
    required this.onBleScan,
    required this.onBleDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Pump Engineering App',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 24),
        Text(
          '● ${deviceStatus.connectionState}',
          style: const TextStyle(color: Colors.greenAccent),
        ),
        const SizedBox(width: 24),
        Text(deviceStatus.deviceName),
        const SizedBox(width: 24),
        OutlinedButton(
          onPressed: onBleScan,
          child: const Text('BLE Scan'),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: onBleDisconnect,
          child: const Text('Disconnect'),
        ),
        const Spacer(),
        const Text('MTU: 247  |  PHY: 1M  |  Bonded'),
      ],
    );
  }
}