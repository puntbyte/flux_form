// lib/features/booking/booking_page.dart

import 'package:example/errors/auth_error.dart';
import 'package:example/features/booking/cubit/booking_cubit.dart';
import 'package:example/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking — DateTimeInput · SchemaValidator · blur'),
        ),
        drawer: const AppDrawer(),
        body: BlocBuilder<BookingCubit, BookingState>(
          builder: (_, state) => _BookingBody(state),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BookingBody extends StatelessWidget {
  final BookingState state;

  const _BookingBody(this.state);

  // Helpers — kept local so the page has no dependency on BookingError display
  // logic bleeding into the cubit.
  String _fmt(DateTime? d) => d == null ? 'Select a date…' : '${d.day}/${d.month}/${d.year}';

  String _errMsg(BookingError? e) => switch (e) {
    BookingError.required => 'Please select a date',
    BookingError.invalidDate => 'Check-in cannot be in the past',
    BookingError.checkOutBeforeCheckIn => 'Check-out must be after check-in',
    BookingError.tooShort => 'Minimum stay is 1 night',
    BookingError.tooLong => 'Maximum stay is 30 nights',
    null => '',
    _ => 'Invalid',
  };

  @override
  Widget build(BuildContext context) {
    // FIX: cubit now exposes checkInSelected, checkOutSelected, guestsChanged,
    // book, reset — NOT dateChanged / submit / state.start / state.end.
    final cubit = context.read<BookingCubit>();
    final schema = state.schema;

    // The cross-field SchemaValidator error (order / min / max nights).
    final crossError = schema.schemaErrors.firstOrNull as BookingError?;
    final nights = schema.nightCount;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const _FeatureTag(
          'DateTimeInput · SchemaValidator cross-field · '
          'blur mode · NumberInputBuilder',
        ),
        const SizedBox(height: 20),

        // ── Check-in date picker ─────────────────────────────────────────────
        // Cubit calls: checkIn.setValue(d).markTouched()
        // This mirrors the blur contract: update value then immediately reveal
        // the error (the "blur" event is the picker closing).
        _DatePickerField(
          label: 'Check-in Date',
          display: _fmt(schema.checkIn.value),
          errorText: _errMsg(schema.checkIn.displayError(state.status)),
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            // FIX: cubit.checkInSelected — NOT cubit.dateChanged
            cubit.checkInSelected(d);
          },
        ),
        const SizedBox(height: 16),

        // ── Check-out date picker ────────────────────────────────────────────
        // Shows per-field error OR cross-field SchemaValidator error.
        _DatePickerField(
          label: 'Check-out Date',
          display: _fmt(schema.checkOut.value),
          errorText: schema.checkOut.displayError(state.status) != null
              ? _errMsg(schema.checkOut.displayError(state.status))
              : (state.status.isFailure && crossError != null)
              ? _errMsg(crossError)
              : '',
          onTap: () async {
            final earliest = schema.checkIn.value ?? DateTime.now();
            final d = await showDatePicker(
              context: context,
              initialDate: earliest.add(const Duration(days: 1)),
              firstDate: earliest,
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            // FIX: cubit.checkOutSelected — NOT cubit.dateChanged
            cubit.checkOutSelected(d);
          },
        ),
        const SizedBox(height: 20),

        // ── Guests stepper — NumberInputBuilder ──────────────────────────────
        // FIX: state.schema.guests — NOT state.start / state.end
        Row(
          children: [
            const Text('Guests:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              onPressed: () => cubit.guestsChanged(-1),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              '${schema.guests.value}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () => cubit.guestsChanged(1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        if (schema.guests.displayError(state.status) != null)
          Text(
            schema.guests.displayError(state.status)!,
            style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
          ),

        // ── Stay summary ─────────────────────────────────────────────────────
        if (nights != null && nights > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$nights night${nights > 1 ? 's' : ''} · '
              '${schema.guests.value} guest${schema.guests.value > 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // FIX: cubit.book — NOT cubit.submit
        ElevatedButton(
          onPressed: state.status.isInProgress ? null : cubit.book,
          child: state.status.isInProgress
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Book Now'),
        ),

        if (state.status.isSuccess) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✓ Booking confirmed!',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                // FIX: schema.values — derived from namedInputs, NOT state.start/end
                Text('${schema.values}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: cubit.reset,
            child: const Text('Reset'),
          ),
        ],
      ],
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  final String label;
  final String display;
  final String errorText;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.display,
    required this.errorText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_month_outlined),
          errorText: errorText.isEmpty ? null : errorText,
        ),
        child: Text(
          display,
          style: TextStyle(
            color: display.startsWith('Select') ? Colors.grey : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _FeatureTag extends StatelessWidget {
  final String text;

  const _FeatureTag(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.orange.shade50,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 10, color: Colors.orange.shade800),
    ),
  );
}
