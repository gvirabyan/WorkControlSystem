import 'package:flutter/material.dart';
import 'package:pot/l10n/app_localizations.dart';

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
      title: Text(AppLocalizations.of(context)!.translate('filter_documents')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _startDate == null
                      ? AppLocalizations.of(context)!.translate('start_date')
                      : '${AppLocalizations.of(context)!.translate('from')}${_startDate!.toLocal().toString().split(' ')[0]}',
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
                      ? AppLocalizations.of(context)!.translate('end_date')
                      : '${AppLocalizations.of(context)!.translate('to')}${_endDate!.toLocal().toString().split(' ')[0]}',
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
          Text(AppLocalizations.of(context)!.translate('document_type')),
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
          child: Text(AppLocalizations.of(context)!.translate('cancel')),
        ),
        TextButton(
          onPressed: () {
            widget.onApplyFilter(_startDate, _endDate, _documentTypes);
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.translate('apply')),
        ),
      ],
    );
  }
}
