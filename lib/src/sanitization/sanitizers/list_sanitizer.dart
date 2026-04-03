// lib/src/sanitization/sanitizers/list_sanitizer.dart

import 'package:flux_form/src/sanitization/sanitizer.dart';

/// A namespace for [List] transformation rules.
abstract class ListSanitizer<T> extends Sanitizer<List<T>> {
  const ListSanitizer();

  /// Removes duplicate items (preserves first occurrence, maintains order).
  const factory ListSanitizer.unique() = _UniqueSanitizer<T>;

  /// Removes all occurrences of [value] from the list.
  const factory ListSanitizer.remove(T value) = _RemoveItemSanitizer<T>;

  /// Removes every item for which [predicate] returns true.
  ///
  /// Useful for:
  /// - Stripping empty strings from a tags list before submission.
  /// - Removing nulls from a nullable list (pass `(item) => item == null`).
  /// - Filtering out sentinel / placeholder values.
  ///
  /// Not `const` because it captures a function.
  ///
  /// ```dart
  /// // Remove blank tags before the list is validated or stored.
  /// ListSanitizer.removeWhere((tag) => (tag as String).trim().isEmpty)
  ///
  /// // Remove null entries from List<String?>.
  /// ListSanitizer.removeWhere((item) => item == null)
  /// ```
  const factory ListSanitizer.removeWhere(bool Function(T item) predicate) = _RemoveWhereSanitizer<T>;

  /// Sorts the list naturally.
  ///
  /// ⚠️ Requires [T] to implement [Comparable]. Throws at runtime if [T]
  /// is not comparable. Prefer testing with your specific type before shipping.
  const factory ListSanitizer.sort() = _SortSanitizer<T>;
}

// ─────────────────────────────────────────────────────────────────────────────
// Implementations
// ─────────────────────────────────────────────────────────────────────────────

class _UniqueSanitizer<T> extends ListSanitizer<T> {
  const _UniqueSanitizer();

  @override
  List<T> sanitize(List<T> value) {
    // LinkedHashSet preserves insertion order while deduplicating.
    final seen = <T>{};
    return value.where(seen.add).toList();
  }
}

class _RemoveItemSanitizer<T> extends ListSanitizer<T> {
  final T itemToRemove;

  const _RemoveItemSanitizer(this.itemToRemove);

  @override
  List<T> sanitize(List<T> value) => value.where((e) => e != itemToRemove).toList();
}

class _RemoveWhereSanitizer<T> extends ListSanitizer<T> {
  final bool Function(T) predicate;

  const _RemoveWhereSanitizer(this.predicate);

  @override
  List<T> sanitize(List<T> value) => value.where((e) => !predicate(e)).toList();
}

class _SortSanitizer<T> extends ListSanitizer<T> {
  const _SortSanitizer();

  @override
  List<T> sanitize(List<T> value) {
    final newList = List<T>.of(value);
    if (newList.isEmpty) return newList;

    if (newList.first is Comparable) {
      newList.sort();
    } else {
      try {
        newList.sort();
      } on Object catch (_) {
        // T is not Comparable — return original unsorted.
        return value;
      }
    }
    return newList;
  }
}
