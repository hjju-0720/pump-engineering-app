import 'dart:math';
import 'package:flutter/material.dart';

class SensorDebugPage extends StatefulWidget {
  const SensorDebugPage({super.key});

  @override
  State<SensorDebugPage> createState() => _SensorDebugPageState();
}

class _SensorDebugPageState extends State<SensorDebugPage> {
  final Random _random = Random();

  double pressureMmHg = 32.0;
  double batteryVoltage = 3.84;
  double batteryCurrentMa = 18.0;
  double temperatureC = 36.4;
  double reservoirU = 120.3;
  int adcRawPressure = 1840;
  int adcRawBattery = 3120;

  void _refreshMockTelemetry() {
    setState(() {
      pressureMmHg = 30 + _random.nextDouble() * 8;
      batteryVoltage = 3.75 + _random.nextDouble() * 0.15;
      batteryCurrentMa = 15 + _random.nextDouble() * 12;
      temperatureC = 35.8 + _random.nextDouble() * 1.2;
      reservoirU = max(0, reservoirU - _random.nextDouble() * 0.2);
      adcRawPressure = 1700 + _random.nextInt(300);
      adcRawBattery = 3000 + _random.nextInt(250);
    });
  }

  void _simulateOcclusionPressure() {
    setState(() {
      pressureMmHg = 180 + _random.nextDouble() * 40;
      adcRawPressure = 3600 + _random.nextInt(300);
    });
  }

  void _simulateLowBattery() {
    setState(() {
      batteryVoltage = 3.25;
      batteryCurrentMa = 40.0;
      adcRawBattery = 2500;
    });
  }

  String get pressureJudgment {
    if (pressureMmHg >= 150) return 'OCCLUSION SUSPECTED';
    if (pressureMmHg >= 80) return 'HIGH PRESSURE';
    return 'NORMAL';
  }

  String get batteryJudgment {
    if (batteryVoltage < 3.3) return 'LOW BATTERY';
    if (batteryVoltage < 3.5) return 'BATTERY WARNING';
    return 'NORMAL';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Sensor Debug',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Pressure, battery, temperature and ADC telemetry view',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _SensorStatusPanel(
                    pressureMmHg: pressureMmHg,
                    batteryVoltage: batteryVoltage,
                    batteryCurrentMa: batteryCurrentMa,
                    temperatureC: temperatureC,
                    reservoirU: reservoirU,
                    adcRawPressure: adcRawPressure,
                    adcRawBattery: adcRawBattery,
                    pressureJudgment: pressureJudgment,
                    batteryJudgment: batteryJudgment,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _SensorControlPanel(
                    onRefresh: _refreshMockTelemetry,
                    onSimulateOcclusion: _simulateOcclusionPressure,
                    onSimulateLowBattery: _simulateLowBattery,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SensorStatusPanel extends StatelessWidget {
  final double pressureMmHg;
  final double batteryVoltage;
  final double batteryCurrentMa;
  final double temperatureC;
  final double reservoirU;
  final int adcRawPressure;
  final int adcRawBattery;
  final String pressureJudgment;
  final String batteryJudgment;

  const _SensorStatusPanel({
    required this.pressureMmHg,
    required this.batteryVoltage,
    required this.batteryCurrentMa,
    required this.temperatureC,
    required this.reservoirU,
    required this.adcRawPressure,
    required this.adcRawBattery,
    required this.pressureJudgment,
    required this.batteryJudgment,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'SENSOR TELEMETRY',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SensorCard(
            label: 'Pressure',
            value: '${pressureMmHg.toStringAsFixed(1)} mmHg',
            raw: 'ADC Raw: $adcRawPressure',
            status: pressureJudgment,
            isFault: pressureJudgment != 'NORMAL',
          ),
          _SensorCard(
            label: 'Battery Voltage',
            value: '${batteryVoltage.toStringAsFixed(2)} V',
            raw: 'ADC Raw: $adcRawBattery',
            status: batteryJudgment,
            isFault: batteryJudgment != 'NORMAL',
          ),
          _SensorCard(
            label: 'Battery Current',
            value: '${batteryCurrentMa.toStringAsFixed(1)} mA',
            raw: 'Discharge current estimate',
            status: 'MONITORING',
          ),
          _SensorCard(
            label: 'Temperature',
            value: '${temperatureC.toStringAsFixed(1)} °C',
            raw: 'Internal temperature sensor',
            status: temperatureC > 40 ? 'HIGH TEMP' : 'NORMAL',
            isFault: temperatureC > 40,
          ),
          _SensorCard(
            label: 'Reservoir Estimate',
            value: '${reservoirU.toStringAsFixed(1)} U',
            raw: 'Calculated from delivery history',
            status: reservoirU < 20 ? 'LOW RESERVOIR' : 'NORMAL',
            isFault: reservoirU < 20,
          ),
        ],
      ),
    );
  }
}

class _SensorControlPanel extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onSimulateOcclusion;
  final VoidCallback onSimulateLowBattery;

  const _SensorControlPanel({
    required this.onRefresh,
    required this.onSimulateOcclusion,
    required this.onSimulateLowBattery,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'SENSOR SIMULATION',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: onRefresh,
            child: const Text('Refresh Mock Telemetry'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onSimulateOcclusion,
            child: const Text('Simulate High Pressure'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onSimulateLowBattery,
            child: const Text('Simulate Low Battery'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Later this page should be connected to firmware telemetry packets:',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          const Text(
            '- Pressure ADC\n'
                '- Battery voltage ADC\n'
                '- Battery current\n'
                '- Temperature\n'
                '- Reservoir estimate\n'
                '- Sensor fault flags',
            style: TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  final String label;
  final String value;
  final String raw;
  final String status;
  final bool isFault;

  const _SensorCard({
    required this.label,
    required this.value,
    required this.raw,
    required this.status,
    this.isFault = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isFault ? Colors.redAccent : Colors.greenAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B121A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFault ? Colors.redAccent.withOpacity(0.4) : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 180,
            child: Text(
              raw,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(
            width: 160,
            child: Text(
              status,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;

  const _Panel({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101820),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.lightBlueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}