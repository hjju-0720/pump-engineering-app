import 'package:flutter/material.dart';
import 'panel.dart';

class DebugPanel extends StatelessWidget {
  const DebugPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Panel(
      title: 'MOTOR / SENSOR DEBUG',
      child: Text(
        'Target Steps     2500\n'
        'Actual Steps     2498\n'
        'Encoder Count    2498\n'
        'Motor PWM        64%\n'
        'Motor Current    220 mA\n'
        'Motor State      STOPPED\n\n'
        'Pressure         32 mmHg\n'
        'Temperature      36.4 °C\n'
        'Battery Voltage  3.84 V',
        style: TextStyle(fontFamily: 'monospace', height: 1.6),
      ),
    );
  }
}
