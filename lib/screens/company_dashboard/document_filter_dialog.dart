import 'package:flutter/material.dart';

class DocumentFilterDialog extends StatefulWidget {
  final Function(DateTime?, DateTime?, Map<String, bool>) onApplyFilter;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Map<String, bool> initialDocumentTypes;

  const DocumentFilterDialog({
    super.key,
    required this.onApplyFilter,
    this.initialStartDate,
    this.initialEndDate,
    required this.initialDocumentTypes,
  });

  @override
  State<DocumentFilterDialog> createState() => _DocumentFilterDialogState();
}

class _DocumentFilterDialogState extends State<DocumentFilterDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  late Map<String, bool> _documentTypes;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _documentTypes = Map.from(widget.initialDocumentTypes);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Documents'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _startDate == null
                      ? 'Start Date'
                      : 'From: ${_startDate!.toLocal().toString().split(' ')[0]}',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _startDate) {
                    setState(() {
                      _startDate = picked;
                    });
                  }
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  _endDate == null
                      ? 'End Date'
                      : 'To: ${_endDate!.toLocal().toString().split(' ')[0]}',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _endDate) {
                    setState(() {
                      _endDate = picked;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Document Type'),
          ..._documentTypes.keys.map((String key) {
            return CheckboxListTile(
              title: Text(key),
              value: _documentTypes[key],
              onChanged: (bool? value) {
                setState(() {
                  _documentTypes[key] = value!;
                });
              },
            );
          }).toList(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onApplyFilter(_startDate, _endDate, _documentTypes);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
