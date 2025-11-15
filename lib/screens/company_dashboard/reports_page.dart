import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  final String companyId;
  final String companyPromoCode;

  const ReportsPage({
    super.key,
    required this.companyId,
    required this.companyPromoCode,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String? selectedEmployeeId;
  String? selectedEmployeeName;
  ReportType? selectedReportType;
  DateTime? selectedMonth;
  DateTime? selectedYear;
  DateTime? selectedQuarterEnd;

  List<Map<String, dynamic>> employees = [];
  bool isLoadingEmployees = true;
  Map<String, dynamic> reportData = {};
  bool isLoadingReport = false;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  /// Load employees from Firestore (users collection with type == 'employee')
  Future<void> _loadEmployees() async {
    setState(() => isLoadingEmployees = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'employee')
          .where('promoCode', isEqualTo: widget.companyPromoCode)
          .get();

      employees = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'No name',
          'surname': data['surname'] ?? '',
        };
      }).toList();
    } catch (e) {
      // keep simple logging
      print('Error loading employees: $e');
    }

    setState(() => isLoadingEmployees = false);
  }

  /// Load report data from Firestore based on selected report type and employee
  Future<void> _loadReportData() async {
    if (selectedEmployeeId == null || selectedReportType == null) return;

    setState(() => isLoadingReport = true);

    try {
      DateTime startDate;
      DateTime endDate;

      switch (selectedReportType!) {
        case ReportType.monthly:
          if (selectedMonth == null) return;
          startDate = DateTime(selectedMonth!.year, selectedMonth!.month, 1);
          endDate = DateTime(selectedMonth!.year, selectedMonth!.month + 1, 0, 23, 59, 59);
          break;
        case ReportType.quarterly:
          if (selectedQuarterEnd == null) return;
          // quarter considered as 3 months ending at selectedQuarterEnd
          startDate = DateTime(selectedQuarterEnd!.year, selectedQuarterEnd!.month - 2, 1);
          endDate = DateTime(selectedQuarterEnd!.year, selectedQuarterEnd!.month + 1, 0, 23, 59, 59);
          break;
        case ReportType.yearly:
          if (selectedYear == null) return;
          startDate = DateTime(selectedYear!.year, 1, 1);
          endDate = DateTime(selectedYear!.year, 12, 31, 23, 59, 59);
          break;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('employee_action_history')
          .where('userId', isEqualTo: selectedEmployeeId)
          .get();

      Map<String, dynamic> data = {};
      int totalMinutes = 0;
      int sundaysWorked = 0;

      final docs = snapshot.docs.where((doc) {
        final timestamp = doc.data()['datetimeStart'] as Timestamp;
        final docDate = timestamp.toDate();
        return docDate.isAfter(startDate) && docDate.isBefore(endDate);
      }).toList();

      for (var doc in docs) {
        final docData = doc.data() as Map<String, dynamic>;
        final date = (docData['datetimeStart'] as Timestamp).toDate();
        final dateKey = DateFormat('yyyy-MM-dd').format(date);

        if (date.weekday == DateTime.sunday) {
          sundaysWorked++;
        }

        final startTime = docData['startTime'] as String?;
        final endTime = docData['endTime'] as String?;
        final breakStart = docData['breakStart'] as String?;
        final breakEnd = docData['breakEnd'] as String?;

        Map<String, int> timeData = {};
        if (startTime != null && endTime != null) {
          timeData = _calculateWorkedMinutes(startTime, endTime, breakStart, breakEnd);
          totalMinutes += timeData['workedMinutes'] ?? 0;
        }

        data[dateKey] = <String, dynamic>{
          'startTime': startTime,
          'endTime': endTime,
          'breakStart': breakStart,
          'breakEnd': breakEnd,
          'workedMinutes': timeData['workedMinutes'] ?? 0,
          'grossMinutes': timeData['grossMinutes'] ?? 0,
          'breakMinutes': timeData['breakMinutes'] ?? 0,
        };
      }

      reportData = <String, dynamic>{
        'data': data,
        'totalMinutes': totalMinutes,
        'sundaysWorked': sundaysWorked,
        'startDate': startDate,
        'endDate': endDate,
      };
    } catch (e) {
      print('Error loading report: $e');
    }

    setState(() => isLoadingReport = false);
  }

  /// Calculate net worked minutes (end - start - break)
  Map<String, int> _calculateWorkedMinutes(String start, String end, String? breakStart, String? breakEnd) {
    try {
      final startParts = start.split(':');
      final endParts = end.split(':');
      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      int grossMinutes = endMinutes - startMinutes;
      int breakMinutes = 0;

      if (breakStart != null && breakEnd != null) {
        final breakStartParts = breakStart.split(':');
        final breakEndParts = breakEnd.split(':');
        final breakStartMinutes = int.parse(breakStartParts[0]) * 60 + int.parse(breakStartParts[1]);
        final breakEndMinutes = int.parse(breakEndParts[0]) * 60 + int.parse(breakEndParts[1]);
        breakMinutes = breakEndMinutes - breakStartMinutes;
      }

      final workedMinutes = grossMinutes - breakMinutes;

      return {
        'grossMinutes': grossMinutes > 0 ? grossMinutes : 0,
        'breakMinutes': breakMinutes > 0 ? breakMinutes : 0,
        'workedMinutes': workedMinutes > 0 ? workedMinutes : 0,
      };
    } catch (e) {
      return {
        'grossMinutes': 0,
        'breakMinutes': 0,
        'workedMinutes': 0,
      };
    }
  }

  bool _shouldShowTable() {
    if (selectedReportType == ReportType.monthly && selectedMonth != null) {
      return true;
    }
    if (selectedReportType == ReportType.quarterly && selectedQuarterEnd != null) {
      return true;
    }
    if (selectedReportType == ReportType.yearly && selectedYear != null) {
      return true;
    }
    return false;
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    // format e.g. 7h 05m -> keep minutes padded
    final minsStr = mins.toString().padLeft(2, '0');
    return '${hours}h ${minsStr}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: isLoadingEmployees
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmployeeFilter(),
            const SizedBox(height: 16),
            _buildReportTypeFilter(),
            const SizedBox(height: 16),
            _buildDateFilter(),
            const SizedBox(height: 24),
            if (selectedEmployeeId != null && selectedReportType != null)
              ElevatedButton.icon(
                onPressed: _loadReportData,
                icon: const Icon(Icons.search),
                label: const Text('Generate report'),
              ),
            const SizedBox(height: 24),
            if (isLoadingReport)
              const Center(child: CircularProgressIndicator())
            else if (selectedEmployeeId != null && selectedReportType != null && _shouldShowTable())
              _buildReportTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select employee:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          value: selectedEmployeeId,
          hint: const Text('Select employee'),
          items: employees.map((emp) {
            return DropdownMenuItem<String>(
              value: emp['id'],
              child: Text('${emp['name']} ${emp['surname']}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedEmployeeId = value;
              final emp = employees.firstWhere((e) => e['id'] == value);
              selectedEmployeeName = '${emp['name']} ${emp['surname']}';
              reportData = {};
            });
          },
        ),
      ],
    );
  }

  Widget _buildReportTypeFilter() {
    final isEnabled = selectedEmployeeId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report type:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ReportType>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          value: selectedReportType,
          hint: const Text('Select report type'),
          items: const [
            DropdownMenuItem(value: ReportType.monthly, child: Text('Monthly report')),
            DropdownMenuItem(value: ReportType.quarterly, child: Text('Quarter (3 months)')),
            DropdownMenuItem(value: ReportType.yearly, child: Text('Yearly report')),
          ],
          onChanged: isEnabled
              ? (value) {
            setState(() {
              selectedReportType = value;
              selectedMonth = null;
              selectedYear = null;
              selectedQuarterEnd = null;
              reportData = {};
            });
          }
              : null,
        ),
      ],
    );
  }

  Widget _buildDateFilter() {
    final isEnabled = selectedEmployeeId != null && selectedReportType != null;

    if (selectedReportType == ReportType.monthly) {
      return _buildMonthPicker(isEnabled);
    } else if (selectedReportType == ReportType.quarterly) {
      return _buildQuarterPicker(isEnabled);
    } else if (selectedReportType == ReportType.yearly) {
      return _buildYearPicker(isEnabled);
    }

    return const SizedBox.shrink();
  }

  Widget _buildMonthPicker(bool isEnabled) {
    final months = [
      {'value': 1, 'name': 'January'},
      {'value': 2, 'name': 'February'},
      {'value': 3, 'name': 'March'},
      {'value': 4, 'name': 'April'},
      {'value': 5, 'name': 'May'},
      {'value': 6, 'name': 'June'},
      {'value': 7, 'name': 'July'},
      {'value': 8, 'name': 'August'},
      {'value': 9, 'name': 'September'},
      {'value': 10, 'name': 'October'},
      {'value': 11, 'name': 'November'},
      {'value': 12, 'name': 'December'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select month:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          value: selectedMonth?.month,
          hint: const Text('Select month'),
          items: months.map((month) {
            return DropdownMenuItem<int>(
              value: month['value'] as int,
              child: Text(month['name'] as String),
            );
          }).toList(),
          onChanged: isEnabled
              ? (value) {
            if (value != null) {
              setState(() {
                final now = DateTime.now();
                selectedMonth = DateTime(now.year, value, 1);
                reportData = {};
              });
            }
          }
              : null,
        ),
      ],
    );
  }

  Widget _buildQuarterPicker(bool isEnabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select quarter end month:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isEnabled
              ? () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedQuarterEnd ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDatePickerMode: DatePickerMode.year,
            );
            if (date != null) {
              setState(() {
                selectedQuarterEnd = date;
                reportData = {};
              });
            }
          }
              : null,
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              selectedQuarterEnd != null
                  ? '${DateFormat('MMMM yyyy', 'en_US').format(DateTime(selectedQuarterEnd!.year, selectedQuarterEnd!.month - 2, 1))} - ${DateFormat('MMMM yyyy', 'en_US').format(selectedQuarterEnd!)}'
                  : 'Select month',
              style: TextStyle(
                color: isEnabled ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearPicker(bool isEnabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select year:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isEnabled
              ? () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedYear ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDatePickerMode: DatePickerMode.year,
            );
            if (date != null) {
              setState(() {
                selectedYear = date;
                reportData = {};
              });
            }
          }
              : null,
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              selectedYear != null ? '${selectedYear!.year}' : 'Select year',
              style: TextStyle(
                color: isEnabled ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportTable() {
    final Map<String, dynamic> data =
    reportData['data'] != null ? Map<String, dynamic>.from(reportData['data']) : {};
    final totalMinutes = reportData.isNotEmpty ? reportData['totalMinutes'] as int : 0;
    final sundaysWorked = reportData.isNotEmpty ? reportData['sundaysWorked'] as int : 0;

    DateTime startDate;
    DateTime endDate;

    switch (selectedReportType!) {
      case ReportType.monthly:
        startDate = DateTime(selectedMonth!.year, selectedMonth!.month, 1);
        endDate = DateTime(selectedMonth!.year, selectedMonth!.month + 1, 0);
        break;
      case ReportType.quarterly:
        startDate = DateTime(selectedQuarterEnd!.year, selectedQuarterEnd!.month - 2, 1);
        endDate = DateTime(selectedQuarterEnd!.year, selectedQuarterEnd!.month + 1, 0);
        break;
      case ReportType.yearly:
        startDate = DateTime(selectedYear!.year, 1, 1);
        endDate = DateTime(selectedYear!.year, 12, 31);
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report: $selectedEmployeeName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMonthlyTables(data, startDate, endDate),
            const Divider(height: 32, thickness: 2),
            _buildSummary(totalMinutes, sundaysWorked),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTables(Map<String, dynamic> data, DateTime startDate, DateTime endDate) {
    List<Widget> tables = [];
    DateTime currentMonth = DateTime(startDate.year, startDate.month, 1);

    while (currentMonth.isBefore(endDate) || currentMonth.month == endDate.month) {
      tables.add(_buildMonthTable(data, currentMonth));
      tables.add(const SizedBox(height: 24));
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    }

    return Column(children: tables);
  }

  Widget _buildMonthTable(Map<String, dynamic> data, DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('MMMM yyyy', 'en_US').format(month),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: const {
            0: FlexColumnWidth(1), // Date
            1: FlexColumnWidth(2), // Working Time
            2: FlexColumnWidth(2), // Break Time
            3: FlexColumnWidth(1.2), // Net Time
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade200),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Working Time', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Break Time', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Net Time', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...List.generate(daysInMonth, (index) {
              final day = index + 1;
              final date = DateTime(month.year, month.month, day);
              final dateKey = DateFormat('yyyy-MM-dd').format(date);
              final dayData = data[dateKey];

              final workingText = (dayData != null)
                  ? _formatMinutes(dayData['grossMinutes'] ?? 0)
                  : '';

              final breakText = (dayData != null)
                  ? _formatMinutes(dayData['breakMinutes'] ?? 0)
                  : '';

              final netText = (dayData != null) ? _formatMinutes(dayData['workedMinutes'] ?? 0) : '';

              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(DateFormat('dd.MM').format(date)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(workingText),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(breakText),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(netText),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildSummary(int totalMinutes, int sundaysWorked) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total worked: ${_formatMinutes(totalMinutes)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Sundays worked: $sundaysWorked times',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

enum ReportType {
  monthly,
  quarterly,
  yearly,
}
