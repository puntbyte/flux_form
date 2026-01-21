part of 'inventory_cubit.dart';

class InventoryState extends Equatable with FormMixin {
  // We use the base type 'ListInput' here so that methods like
  // .addItem() or .removeItem() (which return ListInput) assign correctly.
  final ListField<String, String> groceries;

  final FormStatus status;

  InventoryState({
    ListField<String, String>? groceries,
    this.status = FormStatus.initial,
  }) : // Initialize with our specific subclass that contains all the rules
       groceries = groceries ?? GroceryListInput.pure();

  @override
  List<Field> get fields => [groceries];

  InventoryState copyWith({
    ListField<String, String>? groceries,
    FormStatus? status,
  }) {
    return InventoryState(
      groceries: groceries ?? this.groceries,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [groceries, status];
}
