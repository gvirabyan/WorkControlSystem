import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pot/l10n/app_localizations.dart';

class VacationRequestForm extends StatefulWidget {
  final String userId;

  const VacationRequestForm({
    super.key,
    required this.userId,
  });

  @override
  State<VacationRequestForm> createState() => _VacationRequestFormState();
}

class _VacationRequestFormState extends State<VacationRequestForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _reasonController = TextEditingController();

  String? _companyPromoCode;
  bool _isLoadingData = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchCompanyPromoCode();
  }

  Future<void> _fetchCompanyPromoCode() async {
    final localizations = AppLocalizations.of(context)!;
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _companyPromoCode = docSnapshot.data()?['promoCode'] as String?;
          _isLoadingData = false;
        });
      } else {
        setState(() {
          _isLoadingData = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(localizations.translate('user_data_not_found'))),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${localizations.translate('error_fetching_company_code')}: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final localizations = AppLocalizations.of(context)!;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _startDate!.isAfter(_endDate!)) {
            _endDate = null;
          }
        } else {
          if (_startDate != null && picked.isBefore(_startDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(localizations
                      .translate('end_date_cannot_be_earlier'))),
            );
            return;
          }
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submitRequest() async {
    final localizations = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations
                  .translate('please_select_both_start_and_end_dates'))),
        );
        return;
      }

      if (_companyPromoCode == null || _companyPromoCode!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations
                  .translate('company_code_is_missing'))),
        );
        return;
      }

      setState(() {
        _isSending = true;
      });

      try {
        await FirebaseFirestore.instance.collection('vacations').add({
          'userId': widget.userId,
          'promoCode': _companyPromoCode!,
          'startDate': Timestamp.fromDate(_startDate!),
          'endDate': Timestamp.fromDate(_endDate!),
          'reason': _reasonController.text.trim(),
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(localizations
                    .translate('vacation_request_sent_successfully'))),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '${localizations.translate('error_sending_request')}: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSending = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Widget _buildDateSelectionTile(
      BuildContext context, String label, DateTime? date, VoidCallback onTap) {
    final localizations = AppLocalizations.of(context)!;
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        date == null
            ? localizations.translate('tap_to_select_date')
            : DateFormat('dd.MM.yyyy').format(date),
        style: TextStyle(
            fontSize: 16, color: date == null ? Colors.grey : Colors.black),
      ),
      trailing: const Icon(Icons.calendar_month),
      onTap: onTap,
      tileColor: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black26),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
            title: Text(localizations.translate('new_vacation_request')),
            backgroundColor: Colors.teal),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final promoCodeDisplay =
        _companyPromoCode ?? localizations.translate('not_available');

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('new_vacation_request')),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                margin: const EdgeInsets.only(bottom: 20),
                color: Colors.teal.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    '${localizations.translate('company_code')}: $promoCodeDisplay',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800),
                  ),
                ),
              ),
              _buildDateSelectionTile(
                context,
                localizations.translate('start_date'),
                _startDate,
                () => _selectDate(context, true),
              ),
              const SizedBox(height: 15),
              _buildDateSelectionTile(
                context,
                localizations.translate('end_date'),
                _endDate,
                () => _selectDate(context, false),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: localizations.translate('reason_comment'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.info_outline),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.translate('please_specify_a_reason');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSending || _companyPromoCode == null
                    ? null
                    : _submitRequest,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        localizations.translate('send_request'),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
