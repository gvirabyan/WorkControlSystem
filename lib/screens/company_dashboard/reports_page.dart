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
  DateTime? selectedQuarterStart;

  List<Map<String, dynamic>> employees = [];
  bool isLoadingEmployees = true;
  Map<String, dynamic> reportData = {};
  bool isLoadingReport = false;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

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
          'name': data['name'] ?? 'Без имени',
          'surname': data['surname'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error loading employees: $e');
    }

    setState(() => isLoadingEmployees = false);
  }

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
          endDate = DateTime(selectedMonth!.year, selectedMonth!.month + 1, 0);
          break;
        case ReportType.quarterly:
          if (selectedQuarterStart == null) return;
          startDate = DateTime(selectedQuarterStart!.year, selectedQuarterStart!.month - 2, 1);
          endDate = DateTime(selectedQuarterStart!.year, selectedQuarterStart!.month + 1, 0);
          break;
        case ReportType.yearly:
          if (selectedYear == null) return;
          startDate = DateTime(selectedYear!.year, 1, 1);
          endDate = DateTime(selectedYear!.year, 12, 31);
          break;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('workLogs')
          .where('userId', isEqualTo: selectedEmployeeId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      Map<String, dynamic> data = {};
      int totalMinutes = 0;
      int sundaysWorked = 0;

      for (var doc in snapshot.docs) {
        final docData = doc.data() as Map<String, dynamic>;
        final date = (docData['date'] as Timestamp).toDate();
        final dateKey = DateFormat('yyyy-MM-dd').format(date);

        if (date.weekday == DateTime.sunday) {
          sundaysWorked++;
        }

        final startTime = docData['startTime'] as String?;
        final endTime = docData['endTime'] as String?;
        final breakStart = docData['breakStart'] as String?;
        final breakEnd = docData['breakEnd'] as String?;

        int workedMinutes = 0;
        if (startTime != null && endTime != null) {
          workedMinutes = _calculateWorkedMinutes(startTime, endTime, breakStart, breakEnd);
          totalMinutes += workedMinutes;
        }

        data[dateKey] = <String, dynamic>{
          'startTime': startTime,
          'endTime': endTime,
          'breakStart': breakStart,
          'breakEnd': breakEnd,
          'workedMinutes': workedMinutes,
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

  int _calculateWorkedMinutes(String start, String end, String? breakStart, String? breakEnd) {
    try {
      final startParts = start.split(':');
      final endParts = end.split(':');
      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      int totalMinutes = endMinutes - startMinutes;

      if (breakStart != null && breakEnd != null) {
        final breakStartParts = breakStart.split(':');
        final breakEndParts = breakEnd.split(':');
        final breakStartMinutes = int.parse(breakStartParts[0]) * 60 + int.parse(breakStartParts[1]);
        final breakEndMinutes = int.parse(breakEndParts[0]) * 60 + int.parse(breakEndParts[1]);
        totalMinutes -= (breakEndMinutes - breakStartMinutes);
      }

      return totalMinutes > 0 ? totalMinutes : 0;
    } catch (e) {
      return 0;
    }
  }

  bool _shouldShowTable() {
    if (selectedReportType == ReportType.monthly && selectedMonth != null) {
      return true;
    }
    if (selectedReportType == ReportType.quarterly && selectedQuarterStart != null) {
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
    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчеты'),
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
                label: const Text('Сформировать отчет'),
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
          'Выберите сотрудника:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          value: selectedEmployeeId,
          hint: const Text('Выберите сотрудника'),
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
          'Тип отчета:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ReportType>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          value: selectedReportType,
          hint: const Text('Выберите тип отчета'),
          items: const [
            DropdownMenuItem(value: ReportType.monthly, child: Text('Месячный отчет')),
            DropdownMenuItem(value: ReportType.quarterly, child: Text('Отчет за 3 месяца')),
            DropdownMenuItem(value: ReportType.yearly, child: Text('Годовой отчет')),
          ],
          onChanged: isEnabled
              ? (value) {
            setState(() {
              selectedReportType = value;
              selectedMonth = null;
              selectedYear = null;
              selectedQuarterStart = null;
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
      {'value': 1, 'name': 'Январь'},
      {'value': 2, 'name': 'Февраль'},
      {'value': 3, 'name': 'Март'},
      {'value': 4, 'name': 'Апрель'},
      {'value': 5, 'name': 'Май'},
      {'value': 6, 'name': 'Июнь'},
      {'value': 7, 'name': 'Июль'},
      {'value': 8, 'name': 'Август'},
      {'value': 9, 'name': 'Сентябрь'},
      {'value': 10, 'name': 'Октябрь'},
      {'value': 11, 'name': 'Ноябрь'},
      {'value': 12, 'name': 'Декабрь'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Выберите месяц:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          value: selectedMonth?.month,
          hint: const Text('Выберите месяц'),
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
          'Выберите конечный месяц квартала:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isEnabled
              ? () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedQuarterStart ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDatePickerMode: DatePickerMode.year,
            );
            if (date != null) {
              setState(() {
                selectedQuarterStart = date;
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
              selectedQuarterStart != null
                  ? '${DateFormat('MMMM yyyy', 'ru').format(DateTime(selectedQuarterStart!.year, selectedQuarterStart!.month - 2, 1))} - ${DateFormat('MMMM yyyy', 'ru').format(selectedQuarterStart!)}'
                  : 'Выберите месяц',
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
          'Выберите год:',
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
              selectedYear != null ? '${selectedYear!.year}' : 'Выберите год',
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
    final data = reportData.isNotEmpty ? reportData['data'] as Map<String, dynamic> : {};
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
        startDate = DateTime(selectedQuarterStart!.year, selectedQuarterStart!.month - 2, 1);
        endDate = DateTime(selectedQuarterStart!.year, selectedQuarterStart!.month + 1, 0);
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
              'Отчет: $selectedEmployeeName',
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
          DateFormat('MMMM yyyy', 'ru').format(month),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade200),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Дата', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Рабочее время', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...List.generate(daysInMonth, (index) {
              final day = index + 1;
              final date = DateTime(month.year, month.month, day);
              final dateKey = DateFormat('yyyy-MM-dd').format(date);
              final dayData = data[dateKey];

              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(DateFormat('dd.MM').format(date)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: dayData != null
                        ? Text(
                      '${dayData['startTime']} - ${dayData['endTime']} | '
                          '${dayData['breakStart'] ?? ''} - ${dayData['breakEnd'] ?? ''} | '
                          'Отработано: ${_formatMinutes(dayData['workedMinutes'])}',
                    )
                        : const Text(''),
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
            'Итого отработано: ${_formatMinutes(totalMinutes)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Работа в воскресенье: $sundaysWorked раз',
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