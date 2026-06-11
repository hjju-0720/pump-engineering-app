import 'package:flutter/material.dart';
import 'panel.dart';

class CommandPanel extends StatefulWidget {
  final VoidCallback onGetStatus;
  final VoidCallback onGetDeliveryStatus;
  final void Function(double doseU) onBolus;
  final VoidCallback onStopBolus;
  final VoidCallback onExportLogs;
  final VoidCallback onGetPumpCheck;

  const CommandPanel({
    super.key,
    required this.onGetStatus,
    required this.onGetDeliveryStatus,
    required this.onBolus,
    required this.onStopBolus,
    required this.onExportLogs,
    required this.onGetPumpCheck,
  });

  @override
  State<CommandPanel> createState() => _CommandPanelState();
}

class _CommandPanelState extends State<CommandPanel> {
  final TextEditingController _doseController =
  TextEditingController(text: '5.0');

  double get _doseU {
    return double.tryParse(_doseController.text.trim()) ?? 0;
  }

  void _increaseDose() {
    final next = (_doseU + 0.1).clamp(0.0, 25.0);
    _doseController.text = next.toStringAsFixed(1);
    setState(() {});
  }

  void _decreaseDose() {
    final next = (_doseU - 0.1).clamp(0.0, 25.0);
    _doseController.text = next.toStringAsFixed(1);
    setState(() {});
  }

  void _executeBolus() {
    final dose = _doseU;

    if (dose <= 0 || dose > 25.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dose must be greater than 0 and less than or equal to 25.0 U'),
        ),
      );
      return;
    }

    widget.onBolus(dose);
  }

  @override
  Widget build(BuildContext context) {
    return Panel(
      title: 'COMMAND CENTER',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Information',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: widget.onGetStatus,
                  child: const Text('Get Status'),
                ),
                ElevatedButton(
                  onPressed: widget.onGetDeliveryStatus,
                  child: const Text('Delivery Status'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Sync Time'),
                ),
                ElevatedButton(
                  onPressed: widget.onExportLogs,
                  child: const Text('Export CSV'),
                ),
                ElevatedButton(
                  onPressed: widget.onGetPumpCheck,
                  child: const Text('Pump Check'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Bolus Control',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _decreaseDose,
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: TextField(
                    controller: _doseController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'Dose',
                      suffixText: 'U',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                IconButton(
                  onPressed: _increaseDose,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _executeBolus,
              child: Text('Execute Bolus ${_doseU.toStringAsFixed(1)} U'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: widget.onStopBolus,
              child: const Text('Stop Bolus'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Basal / Device Control',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Start Basal'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Stop Basal'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Suspend'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Enter DFU'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Clear Logs'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}