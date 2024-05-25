import 'package:flutter/material.dart';
import '../utils/ui_components.dart';

class AnalysisDetailScreen extends StatelessWidget {
  final String title;
  final String thumbnail;
  final Map<String, dynamic> aiReport;

  const AnalysisDetailScreen({super.key,
    required this.title,
    required this.thumbnail,
    required this.aiReport,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.network(thumbnail),
              const SizedBox(height: 20),
              CircularProgressBar(riskProbability: aiReport['risk_probability']),
              const SizedBox(height: 10),
              Text(
                aiReport['summary'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: aiReport['tactics'].length,
                itemBuilder: (context, index) {
                  final tactic = aiReport['tactics'][index];
                  return TacticCard(
                    name: tactic['name'],
                    severity: tactic['severity'],
                    description: tactic['description'],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
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
                    color: widget.severity > 80
                        ? Colors.red
                        : widget.severity > 40
                        ? Colors.yellow
                        : Colors.green,
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
