// ui_components.dart

import 'package:flutter/material.dart';

class CircularProgressBar extends StatelessWidget {
  final int riskProbability;
  final double size;
  final bool displayText;

  const CircularProgressBar({super.key, required this.riskProbability, this.size = 100, this.displayText = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (displayText) const Text(
          'Risk Probability',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: riskProbability / 100,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  riskProbability >= 75
                      ? Colors.red
                      : riskProbability >= 40
                      ? Colors.yellow
                      : Colors.green,
                ),
              ),
            ),
            Text(
              '$riskProbability%',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}

class TacticCard extends StatefulWidget {
  final String name;
  final int severity;
  final String description;

  const TacticCard({
    super.key,
    required this.name,
    required this.severity,
    required this.description,
  });

  @override
  _TacticCardState createState() => _TacticCardState();
}

class _TacticCardState extends State<TacticCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: widget.severity > 80 ? Colors.red : widget.severity > 40 ? Colors.yellow : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.severity}%',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(widget.description),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
