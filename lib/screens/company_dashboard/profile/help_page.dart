import 'package:flutter/material.dart';
import 'package:pot/l10n/app_localizations.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppLocalizations.of(context)!.translate('faq'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q1'),
            answer: AppLocalizations.of(context)!.translate('faq_a1'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q2'),
            answer: AppLocalizations.of(context)!.translate('faq_a2'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q3'),
            answer: AppLocalizations.of(context)!.translate('faq_a3'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q4'),
            answer: AppLocalizations.of(context)!.translate('faq_a4'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q5'),
            answer: AppLocalizations.of(context)!.translate('faq_a5'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q6'),
            answer: AppLocalizations.of(context)!.translate('faq_a6'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q7'),
            answer: AppLocalizations.of(context)!.translate('faq_a7'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q8'),
            answer: AppLocalizations.of(context)!.translate('faq_a8'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q9'),
            answer: AppLocalizations.of(context)!.translate('faq_a9'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q10'),
            answer: AppLocalizations.of(context)!.translate('faq_a10'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q11'),
            answer: AppLocalizations.of(context)!.translate('faq_a11'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q12'),
            answer: AppLocalizations.of(context)!.translate('faq_a12'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q13'),
            answer: AppLocalizations.of(context)!.translate('faq_a13'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q14'),
            answer: AppLocalizations.of(context)!.translate('faq_a14'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q15'),
            answer: AppLocalizations.of(context)!.translate('faq_a15'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q16'),
            answer: AppLocalizations.of(context)!.translate('faq_a16'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q17'),
            answer: AppLocalizations.of(context)!.translate('faq_a17'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q18'),
            answer: AppLocalizations.of(context)!.translate('faq_a18'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q19'),
            answer: AppLocalizations.of(context)!.translate('faq_a19'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q20'),
            answer: AppLocalizations.of(context)!.translate('faq_a20'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q21'),
            answer: AppLocalizations.of(context)!.translate('faq_a21'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q22'),
            answer: AppLocalizations.of(context)!.translate('faq_a22'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q23'),
            answer: AppLocalizations.of(context)!.translate('faq_a23'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q24'),
            answer: AppLocalizations.of(context)!.translate('faq_a24'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q25'),
            answer: AppLocalizations.of(context)!.translate('faq_a25'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q26'),
            answer: AppLocalizations.of(context)!.translate('faq_a26'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q27'),
            answer: AppLocalizations.of(context)!.translate('faq_a27'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q28'),
            answer: AppLocalizations.of(context)!.translate('faq_a28'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q29'),
            answer: AppLocalizations.of(context)!.translate('faq_a29'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q30'),
            answer: AppLocalizations.of(context)!.translate('faq_a30'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q31'),
            answer: AppLocalizations.of(context)!.translate('faq_a31'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q32'),
            answer: AppLocalizations.of(context)!.translate('faq_a32'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q33'),
            answer: AppLocalizations.of(context)!.translate('faq_a33'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q34'),
            answer: AppLocalizations.of(context)!.translate('faq_a34'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q35'),
            answer: AppLocalizations.of(context)!.translate('faq_a35'),
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.translate('faq_q36'),
            answer: AppLocalizations.of(context)!.translate('faq_a36'),
          ),
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
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
