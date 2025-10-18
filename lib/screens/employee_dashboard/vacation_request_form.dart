import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VacationRequestForm extends StatefulWidget {
  final String userId;
  // NOTE: companyPromoCode is removed from the constructor and will be fetched internally.

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

  String? _companyPromoCode; // State to hold the fetched promo code
  bool _isLoadingData = true; // State to track data fetching
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchCompanyPromoCode();
  }

  // --- New function to fetch promoCode from Firestore ---
  Future<void> _fetchCompanyPromoCode() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          // Assuming the promo code is stored directly on the user's document
          _companyPromoCode = docSnapshot.data()?['promoCode'] as String?;
          _isLoadingData = false;
        });
      } else {
        setState(() {
          _isLoadingData = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User data not found.')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching company code: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
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
          // End date cannot be earlier than the start date.
          if (_startDate != null && picked.isBefore(_startDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('End date cannot be earlier than the start date.')),
            );
            return;
          }
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both start and end dates.')),
        );
        return;
      }

      // Stop if promo code is missing
      if (_companyPromoCode == null || _companyPromoCode!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company code is missing. Cannot submit request.')),
        );
        return;
      }

      setState(() {
        _isSending = true;
      });

      try {
        // --- 1. Save to employee's subcollection for individual status tracking ---
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('employeeVacation')
            .add({
          'userId': widget.userId,
          'promoCode': _companyPromoCode!, // Use the fetched promo code
          // NOTE: If 'name' is available, it should be fetched and added here.
          'startDate': Timestamp.fromDate(_startDate!),
          'endDate': Timestamp.fromDate(_endDate!),
          'reason': _reasonController.text.trim(),
          'status': 'pending', // Key status for Admin approval
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vacation request sent successfully! Awaiting approval.')),
          );
          // Navigate back after submission
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error sending request: $e')),
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

  // Date selection widget
  Widget _buildDateSelectionTile(
      BuildContext context, String label, DateTime? date, VoidCallback onTap) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        date == null ? 'Tap to select date' : DateFormat('dd.MM.yyyy').format(date),
        style: TextStyle(fontSize: 16, color: date == null ? Colors.grey : Colors.black),
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
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Vacation Request'), backgroundColor: Colors.teal),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Check if promo code was successfully fetched
    final promoCodeDisplay = _companyPromoCode ?? 'Not available';

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Vacation Request'), // Translated
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
              // Displaying Promo Code for reference
              Card(
                margin: const EdgeInsets.only(bottom: 20),
                color: Colors.teal.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Company Code: $promoCodeDisplay',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                  ),
                ),
              ),

              // Start Date
              _buildDateSelectionTile(
                context,
                'Start Date', // Translated
                _startDate,
                    () => _selectDate(context, true),
              ),
              const SizedBox(height: 15),

              // End Date
              _buildDateSelectionTile(
                context,
                'End Date', // Translated
                _endDate,
                    () => _selectDate(context, false),
              ),
              const SizedBox(height: 25),

              // Reason
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (Comment)', // Translated
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please specify a reason.'; // Translated
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Submission Button
              ElevatedButton(
                onPressed: _isSending || _companyPromoCode == null ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Send Request', // Translated
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
