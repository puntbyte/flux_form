import 'package:flux_form/src/forms/field.dart';

/// A mixin that enforces **O(1) read performance** for validation results.
///
/// Use this mixin when you have complex validation logic (e.g., heavy Regex or
/// large Lists) and you want to ensure [validate] is run exactly once per instance.
///
/// ⚠️ **Constraint:** Classes using this mixin **cannot** have `const` constructors
/// because `late final` fields are initialized at runtime.
mixin FieldCacheMixin<T, E> on Field<T, E> {
  /// The validation result is calculated the first time it is accessed
  /// and stored in memory for the lifetime of this object.
  late final E? _runtimeCache = validate(value);

  @override
  E? get localError => _runtimeCache;
}
