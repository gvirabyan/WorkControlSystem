import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  // Dummy data for dates
  final List<String> dates = const [
    '2024-05-25',
    '2024-05-24',
    '2024-05-23',
    '2024-05-22',
    '2024-05-21',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work History'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: dates.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(dates[index]),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryDetailPage(date: dates[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class HistoryDetailPage extends StatelessWidget {
  final String date;

  const HistoryDetailPage({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    // Dummy data for a specific date's history
    final List<String> dailyHistory = [
      'Start Work: 09:00 AM',
      'Break: 12:30 PM - 01:30 PM',
      'Continue Work: 01:30 PM',
      'Finish Work: 05:00 PM',
      'Total hours: 7.5'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('History for $date'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: dailyHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(dailyHistory[index]),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Go back to the list of dates
            },
            child: const Text('Back'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
