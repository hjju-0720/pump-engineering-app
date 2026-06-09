import 'package:flutter/material.dart';

class Panel extends StatelessWidget {
  final String title;
  final Widget child;

  const Panel({super.key, required this.title, required this.child});

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
          Text(title, style: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}
