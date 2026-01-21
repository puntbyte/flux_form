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
        appBar: AppBar(title: const Text('Cross-Field Validation')),
        drawer: const AppDrawer(),
        body: const _BookingView(),
      ),
    );
  }
}

class _BookingView extends StatelessWidget {
  const _BookingView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BookingCubit>().state;
    final cubit = context.read<BookingCubit>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('End Date must be greater than Start Date.\n(Lexicographical String Check)'),
          const SizedBox(height: 20),

          TextField(
            onChanged: (v) => cubit.dateChanged(start: v),
            decoration: InputDecoration(
              labelText: 'Start Date (YYYY-MM-DD)',
              hintText: '2023-01-01',
              errorText: state.start.displayError(state.status),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            onChanged: (v) => cubit.dateChanged(end: v),
            decoration: InputDecoration(
              labelText: 'End Date (YYYY-MM-DD)',
              hintText: '2023-01-05',
              errorText: state.end.displayError(state.status),
            ),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: cubit.submit,
            child: const Text('Book Now'),
          ),

          if (state.status.isSucceeded)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Booking Confirmed!',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
