import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../domain/entities/request.dart';
import '../controllers/request_controller.dart';

class RequestCreatePage extends ConsumerStatefulWidget {
  const RequestCreatePage({super.key});

  @override
  ConsumerState<RequestCreatePage> createState() => _RequestCreatePageState();
}

class _RequestCreatePageState extends ConsumerState<RequestCreatePage> {
  final _reason = TextEditingController();
  final _amount = TextEditingController();
  final _currency = TextEditingController(text: 'TRY');
  final _startDate = TextEditingController();
  final _endDate = TextEditingController();
  final _category = TextEditingController();
  RequestType _type = RequestType.leave;

  @override
  void dispose() {
    _reason.dispose();
    _amount.dispose();
    _currency.dispose();
    _startDate.dispose();
    _endDate.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final notifier = ref.read(requestControllerProvider.notifier);
    final needsAmount = _type == RequestType.advance || _type == RequestType.expense;
    final needsDates = _type == RequestType.leave;
    final needsCategory = _type == RequestType.expense;

    final amount = needsAmount && _amount.text.trim().isNotEmpty
        ? double.tryParse(_amount.text.trim())
        : null;
    final currency = needsAmount && _currency.text.trim().isNotEmpty
        ? _currency.text.trim()
        : null;
    final startDate = needsDates ? _parseDate(_startDate.text.trim()) : null;
    final endDate = needsDates ? _parseDate(_endDate.text.trim()) : null;
    final category = needsCategory && _category.text.trim().isNotEmpty
        ? _category.text.trim()
        : null;
    try {
      await notifier.createRequest(
        type: _type,
        reason: _reason.text.trim(),
        amount: amount,
        currency: currency,
        startDate: startDate,
        endDate: endDate,
        category: category,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request created.')),
      );
      context.go(Routes.requests);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Create failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(requestControllerProvider);
    final needsAmount = _type == RequestType.advance || _type == RequestType.expense;
    final needsDates = _type == RequestType.leave;
    final needsCategory = _type == RequestType.expense;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Request')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<RequestType>(
            value: _type,
            items: const [
              DropdownMenuItem(
                value: RequestType.leave,
                child: Text('Leave'),
              ),
              DropdownMenuItem(
                value: RequestType.advance,
                child: Text('Advance'),
              ),
              DropdownMenuItem(
                value: RequestType.expense,
                child: Text('Expense'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _type = value);
            },
            decoration: const InputDecoration(labelText: 'Type'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reason,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(),
            ),
          ),
          if (needsDates) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _startDate,
              decoration: const InputDecoration(
                labelText: 'Start Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _endDate,
              decoration: const InputDecoration(
                labelText: 'End Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          if (needsAmount) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _currency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          if (needsCategory) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : _submit,
              child: state.isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _parseDate(String value) {
    if (value.isEmpty) return null;
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }
}
