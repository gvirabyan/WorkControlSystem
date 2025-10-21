import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'FAQ',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          FAQItem(
            question: 'How to add an employee?',
            answer:
            'In the "Profile" section, you will find your Promo Code. The employee must register using your Promo Code, and they will automatically become your employee.',
          ),
          // You can add more questions like this:
          // FAQItem(
          //   question: 'How to delete my account?',
          //   answer: 'Go to Settings → Delete Account.',
          // ),
        ],
      ),
    );
  }
}

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          Text(
            widget.answer,
            style: const TextStyle(color: Colors.black87, height: 1.4),
          ),
        ],
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
        },
        trailing: Icon(
          _isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}
