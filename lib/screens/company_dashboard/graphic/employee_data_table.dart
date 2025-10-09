import 'package:flutter/material.dart';

// Placeholder for EmployeeDataTable. Replace with your actual table.
class EmployeeDataTable extends StatelessWidget {
  final String scheduleType;
  const EmployeeDataTable({super.key, required this.scheduleType});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Table: $scheduleType',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E88E5),
              ),
            ),
            const SizedBox(height: 20),
            // Replace with your actual data table
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Employee schedule table content goes here...',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New widget replacing the old GraphicsScreen
class GraphicsScreen extends StatefulWidget {
  const GraphicsScreen({super.key});

  @override
  State<GraphicsScreen> createState() => _GraphicsScreenState();
}

class _GraphicsScreenState extends State<GraphicsScreen> {
  int _selectedIndex = 0;

  // Titles for AppBar
  static const List<String> _pageTitles = [
    'Work Schedule',
    'Vacation Schedule',
    'Break Schedule',
  ];

  // Page widgets using the table with different schedule types
  late final List<Widget> _pages = <Widget>[
    const EmployeeDataTable(scheduleType: 'Work Schedule'),
    const EmployeeDataTable(scheduleType: 'Vacation Schedule'),
    const EmployeeDataTable(scheduleType: 'Break Schedule'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]), // Dynamic title
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Display the currently selected page/table
      body: _pages[_selectedIndex],

      // Navigation buttons at the bottom
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Work Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.beach_access),
            label: 'Vacation Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.coffee),
            label: 'Break Schedule',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Show all buttons
      ),
    );
  }
}

