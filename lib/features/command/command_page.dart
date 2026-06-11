import 'package:flutter/material.dart';

import '../../core/utils/hex_utils.dart';

class CommandPage extends StatefulWidget {
  final VoidCallback onGetStatus;
  final VoidCallback onGetDeliveryStatus;
  final void Function(double doseU) onBolus;
  final VoidCallback onStopBolus;
  final void Function(List<int> rawPacket) onRawPacketSend;
  final VoidCallback onGetPumpCheck;

  const CommandPage({
    super.key,
    required this.onGetStatus,
    required this.onGetDeliveryStatus,
    required this.onBolus,
    required this.onStopBolus,
    required this.onRawPacketSend,
    required this.onGetPumpCheck,
  });

  @override
  State<CommandPage> createState() => _CommandPageState();
}

class _CommandPageState extends State<CommandPage> {
  final TextEditingController _doseController =
  TextEditingController(text: '5.0');

  final TextEditingController _rawPacketController = TextEditingController();

  double get _doseU =>
      double.tryParse(_doseController.text.trim()) ?? 0.0;

  @override
  void dispose() {
    _doseController.dispose();
    _rawPacketController.dispose();
    super.dispose();
  }

  void _executeBolus() {
    final dose = _doseU;

    if (dose <= 0 || dose > 25.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dose must be > 0 and <= 25.0 U'),
        ),
      );
      return;
    }

    widget.onBolus(dose);
  }

  void _sendRawPacket() {
    try {
      final raw = _parseHex(_rawPacketController.text);
      widget.onRawPacketSend(raw);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid HEX packet: $e'),
        ),
      );
    }
  }

  List<int> _parseHex(String input) {
    final cleaned = input
        .replaceAll(',', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('\t', ' ')
        .trim();

    if (cleaned.isEmpty) {
      throw const FormatException('empty input');
    }

    final parts = cleaned.split(RegExp(r'\s+'));
    return parts.map((p) => int.parse(p, radix: 16)).toList();
  }

  void _setBolusDose(double dose) {
    setState(() {
      _doseController.text = dose.toStringAsFixed(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const _PageTitle(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _CommandSection(
                  title: 'Connection / Status',
                  children: [
                    _CommandButton(
                      label: 'Get Status',
                      onPressed: widget.onGetStatus,
                    ),
                    _CommandButton(
                      label: 'Delivery Status',
                      onPressed: widget.onGetDeliveryStatus,
                    ),
                    _CommandButton(
                      label: 'Sync Time',
                      onPressed: () {},
                    ),
                    _CommandButton(
                      label: 'Get Pump Check',
                      onPressed: widget.onGetPumpCheck,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CommandSection(
                  title: 'Bolus Control',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _doseController,
                            keyboardType:
                            const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Bolus Dose',
                              suffixText: 'U',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _SmallButton(
                          label: '-0.1',
                          onPressed: () =>
                              _setBolusDose((_doseU - 0.1).clamp(0.1, 25.0)),
                        ),
                        const SizedBox(width: 4),
                        _SmallButton(
                          label: '+0.1',
                          onPressed: () =>
                              _setBolusDose((_doseU + 0.1).clamp(0.1, 25.0)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final d in [1.0, 5.0, 10.0, 15.0, 20.0, 25.0])
                          _SmallButton(
                            label: '${d.toStringAsFixed(0)}U',
                            onPressed: () => _setBolusDose(d),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _CommandButton(
                      label: 'Execute Bolus ${_doseU.toStringAsFixed(1)} U',
                      onPressed: _executeBolus,
                    ),
                    _CommandButton(
                      label: 'Stop Bolus',
                      onPressed: widget.onStopBolus,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _CommandSection(
                  title: 'Basal / Device Control',
                  children: [
                    _CommandButton(label: 'Start Basal', onPressed: () {}),
                    _CommandButton(label: 'Stop Basal', onPressed: () {}),
                    _CommandButton(label: 'Suspend', onPressed: () {}),
                    _CommandButton(label: 'Resume', onPressed: () {}),
                    _CommandButton(label: 'Enter DFU', onPressed: () {}),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CommandSection(
            title: 'Raw Packet Send',
            children: [
              TextField(
                controller: _rawPacketController,
                minLines: 2,
                maxLines: 5,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: const InputDecoration(
                  labelText: 'HEX Packet',
                  hintText: 'A5 A5 02 A1 02 ... 5A 5A',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _CommandButton(
                    label: 'Send Raw Packet',
                    onPressed: _sendRawPacket,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Example packets can be copied from Packet Monitor.',
                      style: TextStyle(color: Colors.white.withOpacity(0.55)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          'Command',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.lightBlueAccent,
          ),
        ),
        SizedBox(width: 12),
        Text(
          'Manual command execution and raw packet transmission',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

class _CommandSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _CommandSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101820),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.lightBlueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _CommandButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _CommandButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SmallButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}