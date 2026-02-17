import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cowork/shared/utils/date_input.dart';

class AppDateField extends StatefulWidget {
  const AppDateField({
    super.key,
    required this.controller,
    required this.labelText,
    this.onDateChanged,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String labelText;
  final ValueChanged<DateTime?>? onDateChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  @override
  State<AppDateField> createState() => _AppDateFieldState();
}

class _AppDateFieldState extends State<AppDateField> {
  String? _errorText;

  DateTime get _effectiveFirstDate => widget.firstDate ?? DateInput.defaultMinDate;
  DateTime get _effectiveLastDate => widget.lastDate ?? DateInput.defaultMaxDate;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChanged);
    _handleChanged();
  }

  @override
  void didUpdateWidget(covariant AppDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleChanged);
      widget.controller.addListener(_handleChanged);
      _handleChanged();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChanged);
    super.dispose();
  }

  void _handleChanged() {
    final text = widget.controller.text.trim();
    DateTime? parsed;
    String? nextError;

    if (text.isEmpty) {
      nextError = null;
    } else if (text.length != 10) {
      nextError = 'Tarih GG/AA/YYYY formatinda olmali.';
    } else {
      parsed = DateInput.tryParseDayMonthYear(
        text,
        minDate: _effectiveFirstDate,
        maxDate: _effectiveLastDate,
      );
      if (parsed == null) {
        nextError =
            'Gecersiz tarih. Aralik ${_effectiveFirstDate.year}-${_effectiveLastDate.year}.';
      }
    }

    if (_errorText != nextError) {
      setState(() => _errorText = nextError);
    }
    widget.onDateChanged?.call(parsed);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = DateInput.tryParseDayMonthYear(
          widget.controller.text.trim(),
          minDate: _effectiveFirstDate,
          maxDate: _effectiveLastDate,
        ) ??
        _clampDate(now, _effectiveFirstDate, _effectiveLastDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: _clampDate(initial, _effectiveFirstDate, _effectiveLastDate),
      firstDate: _effectiveFirstDate,
      lastDate: _effectiveLastDate,
    );

    if (picked == null) return;
    widget.controller.text = DateInput.formatDayMonthYear(picked);
  }

  DateTime _clampDate(DateTime value, DateTime min, DateTime max) {
    if (value.isBefore(min)) return min;
    if (value.isAfter(max)) return max;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        DayMonthYearTextInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: 'GG/AA/YYYY',
        border: const OutlineInputBorder(),
        counterText: '',
        errorText: _errorText,
        suffixIcon: IconButton(
          onPressed: widget.enabled ? _pickDate : null,
          icon: const Icon(Icons.calendar_today_outlined),
          tooltip: 'Takvimden sec',
        ),
      ),
      maxLength: 10,
    );
  }
}
