import 'package:flutter/material.dart';

class MotorDebugPage extends StatefulWidget {
  const MotorDebugPage({super.key});

  @override
  State<MotorDebugPage> createState() => _MotorDebugPageState();
}

class _MotorDebugPageState extends State<MotorDebugPage> {
  int targetSteps = 2500;
  int actualSteps = 2498;
  int encoderCount = 2498;
  int pwmPercent = 0;
  int motorCurrentMa = 0;
  String motorState = 'STOPPED';

  void _startForward() {
    setState(() {
      motorState = 'FORWARD';
      pwmPercent = 45;
      motorCurrentMa = 180;
      targetSteps += 500;
      actualSteps += 498;
      encoderCount = actualSteps;
    });
  }

  void _startReverse() {
    setState(() {
      motorState = 'REVERSE';
      pwmPercent = 45;
      motorCurrentMa = 175;
      targetSteps -= 500;
      actualSteps -= 497;
      encoderCount = actualSteps;
    });
  }

  void _stopMotor() {
    setState(() {
      motorState = 'STOPPED';
      pwmPercent = 0;
      motorCurrentMa = 0;
    });
  }

  void _simulateStall() {
    setState(() {
      motorState = 'STALL_DETECTED';
      pwmPercent = 80;
      motorCurrentMa = 420;
      actualSteps += 10;
      encoderCount = actualSteps;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stepError = targetSteps - actualSteps;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Motor Debug',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Motor, encoder, PWM and current diagnostic view',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _StatusPanel(
                    targetSteps: targetSteps,
                    actualSteps: actualSteps,
                    encoderCount: encoderCount,
                    stepError: stepError,
                    pwmPercent: pwmPercent,
                    motorCurrentMa: motorCurrentMa,
                    motorState: motorState,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ControlPanel(
                    onForward: _startForward,
                    onReverse: _startReverse,
                    onStop: _stopMotor,
                    onStall: _simulateStall,
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

class _StatusPanel extends StatelessWidget {
  final int targetSteps;
  final int actualSteps;
  final int encoderCount;
  final int stepError;
  final int pwmPercent;
  final int motorCurrentMa;
  final String motorState;

  const _StatusPanel({
    required this.targetSteps,
    required this.actualSteps,
    required this.encoderCount,
    required this.stepError,
    required this.pwmPercent,
    required this.motorCurrentMa,
    required this.motorState,
  });

  @override
  Widget build(BuildContext context) {
    final isFault = motorState.contains('STALL');

    return _Panel(
      title: 'MOTOR STATUS',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ValueRow(label: 'Motor State', value: motorState, isFault: isFault),
          _ValueRow(label: 'Target Steps', value: '$targetSteps'),
          _ValueRow(label: 'Actual Steps', value: '$actualSteps'),
          _ValueRow(label: 'Step Error', value: '$stepError'),
          _ValueRow(label: 'Encoder Count', value: '$encoderCount'),
          _ValueRow(label: 'PWM Duty', value: '$pwmPercent %'),
          _ValueRow(label: 'Motor Current', value: '$motorCurrentMa mA'),
          const SizedBox(height: 24),
          const Text(
            'Diagnostic Judgment',
            style: TextStyle(
              color: Colors.lightBlueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFault
                ? 'Potential stall or occlusion condition detected.'
                : stepError.abs() <= 5
                ? 'Motor movement is within expected tolerance.'
                : 'Step mismatch requires investigation.',
            style: TextStyle(
              color: isFault
                  ? Colors.redAccent
                  : stepError.abs() <= 5
                  ? Colors.greenAccent
                  : Colors.orangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  final VoidCallback onForward;
  final VoidCallback onReverse;
  final VoidCallback onStop;
  final VoidCallback onStall;

  const _ControlPanel({
    required this.onForward,
    required this.onReverse,
    required this.onStop,
    required this.onStall,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'MOTOR COMMAND',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(onPressed: onForward, child: const Text('Forward Step')),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onReverse, child: const Text('Reverse Step')),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onStop, child: const Text('Stop Motor')),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onStall,
            child: const Text('Simulate Stall / Occlusion'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Later this page will be connected to firmware telemetry packets:',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          const Text(
            '- Target step\n'
                '- Actual encoder count\n'
                '- PWM duty\n'
                '- Motor current\n'
                '- Stall flag\n'
                '- Occlusion flag',
            style: TextStyle(fontFamily: 'monospace'),
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
          Text(title,
              style: const TextStyle(
                color: Colors.lightBlueAccent,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isFault;

  const _ValueRow({
    required this.label,
    required this.value,
    this.isFault = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              color: isFault ? Colors.redAccent : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}