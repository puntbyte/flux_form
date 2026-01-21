import 'package:example/inputs/grocery_list_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flux_form/flux_form.dart';

part 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit() : super(InventoryState());

  void addItem() {
    // .addItem returns ListInput<String, String>, which matches our State definition
    final newList = state.groceries.addItem('');
    emit(state.copyWith(groceries: newList));
  }

  void updateItem(int index, String value) {
    final newList = state.groceries.setItem(index, value);
    emit(state.copyWith(groceries: newList));
  }

  void removeItem(int index) {
    final newList = state.groceries.removeItemAt(index);
    emit(state.copyWith(groceries: newList));
  }
}