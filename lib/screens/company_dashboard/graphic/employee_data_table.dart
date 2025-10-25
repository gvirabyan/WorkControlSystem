import 'package:flutter/material.dart';
import 'package:pot/l10n/app_localizations.dart';

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
              AppLocalizations.of(context)!
                  .translate('table_schedule')
                  .replaceAll('{scheduleType}', scheduleType),
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
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.translate(
                      'employee_schedule_table_content_goes_here'),
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
  late final List<String> _pageTitles;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageTitles = [
      AppLocalizations.of(context)!.translate('work_schedule'),
      AppLocalizations.of(context)!.translate('vacation_schedule'),
      AppLocalizations.of(context)!.translate('break_schedule'),
    ];
  }

  // Page widgets using the table with different schedule types
  late final List<Widget> _pages = <Widget>[
    EmployeeDataTable(
        scheduleType:
            AppLocalizations.of(context)!.translate('work_schedule')),
    EmployeeDataTable(
        scheduleType:
            AppLocalizations.of(context)!.translate('vacation_schedule')),
    EmployeeDataTable(
        scheduleType:
            AppLocalizations.of(context)!.translate('break_schedule')),
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
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.access_time),
            label: AppLocalizations.of(context)!.translate('work_schedule'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.beach_access),
            label:
                AppLocalizations.of(context)!.translate('vacation_schedule'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.coffee),
            label: AppLocalizations.of(context)!.translate('break_schedule'),
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
