part of 'inventory_cubit.dart';

class InventoryState extends Equatable with FormMixin {
  // We use the base type 'ListInput' here so that methods like
  // .addItem() or .removeItem() (which return ListInput) assign correctly.
  final SimpleListInput<String, String> groceries;

  final SubmissionStatus status;

  InventoryState({
    SimpleListInput<String, String>? groceries,
    this.status = SubmissionStatus.idle,
  }) : // Initialize with our specific subclass that contains all the rules
       groceries = groceries ?? const GroceryListInput.untouched();

  @override
  List<FormInput> get inputs => [groceries];

  InventoryState copyWith({
    SimpleListInput<String, String>? groceries,
    SubmissionStatus? status,
  }) {
    return InventoryState(
      groceries: groceries ?? this.groceries,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [groceries, status];
}
