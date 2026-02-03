// lib/src/sanitization/sanitizers/list_sanitizer.dart

import 'package:flux_form/src/sanitization/sanitizer.dart';

/// A namespace for List transformation rules.
abstract class ListSanitizer<T> extends Sanitizer<List<T>> {
  const ListSanitizer();

  /// Removes duplicate items from the list.
  /// (Uses `.toSet().toList()` logic).
  const factory ListSanitizer.unique() = _UniqueSanitizer<T>;

  /// Removes any `null` values if T is nullable (requires casting usually),
  /// but simpler use case: Remove specific [value] from list.
  const factory ListSanitizer.remove(T value) = _RemoveItemSanitizer<T>;

  /// Sorts the list naturally (if T is Comparable) or uses default sort order.
  /// WARNING: Ensure T is comparable, otherwise this might throw at runtime.
  const factory ListSanitizer.sort() = _SortSanitizer<T>;
}

// ================= Implementation =================

class _UniqueSanitizer<T> extends ListSanitizer<T> {
  const _UniqueSanitizer();

  @override
  List<T> sanitize(List<T> value) {
    // Returns a new list to maintain immutability principles
    return value.toSet().toList();
  }
}

class _RemoveItemSanitizer<T> extends ListSanitizer<T> {
  final T itemToRemove;

  const _RemoveItemSanitizer(this.itemToRemove);

  @override
  List<T> sanitize(List<T> value) {
    return value.where((element) => element != itemToRemove).toList();
  }
}

class _SortSanitizer<T> extends ListSanitizer<T> {
  const _SortSanitizer();

  @override
  List<T> sanitize(List<T> value) {
    final newList = List<T>.of(value);
    if (newList.isNotEmpty && newList.first is Comparable) {
      newList.sort();
    } else {
      // Fallback or explicit check could go here
      try {
        newList.sort();
      } on Object catch (_) {
        // T is not comparable, return original
        return value;
      }
    }
    return newList;
  }
}
