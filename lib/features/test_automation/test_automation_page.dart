import 'package:flutter/material.dart';

class TestAutomationPage extends StatefulWidget {
  const TestAutomationPage({super.key});

  @override
  State<TestAutomationPage> createState() => _TestAutomationPageState();
}

class _TestAutomationPageState extends State<TestAutomationPage> {
  final List<double> doses = [5, 10, 15, 20, 25];
  final Map<double, TextEditingController> controllers = {};
  double tolerancePercent = 5.0;

  @override
  void initState() {
    super.initState();
    for (final dose in doses) {
      controllers[dose] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  double measuredUnitsFromMg(double mg) {
    // U-100 insulin approximation:
    // 1 U = 10 uL ≈ 10 mg when density is approximated as 1 g/mL.
    return mg / 10.0;
  }

  double errorPercent({
    required double expectedU,
    required double measuredU,
  }) {
    return ((measuredU - expectedU) / expectedU) * 100.0;
  }

  bool isPass(double error) {
    return error.abs() <= tolerancePercent;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bolus Delivery Test',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlueAccent,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter electronic scale measurement in mg. Measured dose is calculated using U-100 approximation: 1U ≈ 10mg.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              const Text('Tolerance'),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: TextEditingController(
                    text: tolerancePercent.toStringAsFixed(1),
                  ),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    suffixText: '%',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) {
                      setState(() {
                        tolerancePercent = parsed;
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF101820),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                const _HeaderRow(),
                const Divider(height: 1),
                for (final dose in doses)
                  _DoseResultRow(
                    expectedU: dose,
                    controller: controllers[dose]!,
                    tolerancePercent: tolerancePercent,
                    measuredUnitsFromMg: measuredUnitsFromMg,
                    errorPercent: errorPercent,
                    isPass: isPass,
                    onChanged: () => setState(() {}),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text('Expected U')),
          SizedBox(width: 160, child: Text('Scale mg')),
          SizedBox(width: 140, child: Text('Measured U')),
          SizedBox(width: 120, child: Text('Error %')),
          SizedBox(width: 100, child: Text('Result')),
        ],
      ),
    );
  }
}

class _DoseResultRow extends StatelessWidget {
  final double expectedU;
  final TextEditingController controller;
  final double tolerancePercent;
  final double Function(double mg) measuredUnitsFromMg;
  final double Function({
  required double expectedU,
  required double measuredU,
  }) errorPercent;
  final bool Function(double error) isPass;
  final VoidCallback onChanged;

  const _DoseResultRow({
    required this.expectedU,
    required this.controller,
    required this.tolerancePercent,
    required this.measuredUnitsFromMg,
    required this.errorPercent,
    required this.isPass,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final measuredMg = double.tryParse(controller.text.trim());
    final measuredU =
    measuredMg == null ? null : measuredUnitsFromMg(measuredMg);
    final error = measuredU == null
        ? null
        : errorPercent(expectedU: expectedU, measuredU: measuredU);
    final pass = error == null ? null : isPass(error);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text('${expectedU.toStringAsFixed(2)} U'),
          ),
          SizedBox(
            width: 160,
            child: TextField(
              controller: controller,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                suffixText: 'mg',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => onChanged(),
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(
              measuredU == null ? '-' : '${measuredU.toStringAsFixed(2)} U',
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              error == null ? '-' : '${error.toStringAsFixed(2)}%',
              style: TextStyle(
                color: error == null
                    ? Colors.white
                    : error.abs() <= tolerancePercent
                    ? Colors.greenAccent
                    : Colors.redAccent,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              pass == null ? '-' : pass ? 'PASS' : 'FAIL',
              style: TextStyle(
                color: pass == null
                    ? Colors.white
                    : pass
                    ? Colors.greenAccent
                    : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}