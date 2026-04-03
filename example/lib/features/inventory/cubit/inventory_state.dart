// lib/features/inventory/cubit/inventory_state.dart

part of 'inventory_cubit.dart';

class InventoryState {
  final InventorySchema schema;
  final SubmissionStatus status;

  InventoryState({required this.schema, required this.status});

  factory InventoryState.initial() => InventoryState(
    schema: InventorySchema(),
    status: SubmissionStatus.idle,
  );

  InventoryState copyWith({
    InventorySchema? schema,
    SubmissionStatus? status,
  }) => InventoryState(
    schema: schema ?? this.schema,
    status: status ?? this.status,
  );
}