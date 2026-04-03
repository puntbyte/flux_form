// test/src/forms/form_input_test.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/submission_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:test/test.dart';

/// Concrete test implementation of FormInput for String values and String errors.
class TestInput extends FormInput<String, String> {
  const TestInput.untouched({
    required super.value,
    super.mode,
    super.errorCache,
  }) : super.untouched();

  const TestInput.touched({
    required super.value,
    super.initialValue,
    super.mode,
    super.remoteError,
    super.errorCache,
  }) : super.touched();

  TestInput.fromData(super.data) : super.fromData();

  /// Trim whitespace as sanitization.
  @override
  String sanitize(String value) => value.trim();

  /// Simple validation rule: invalid if contains substring "bad".
  @override
  String? validate(String value) => value.contains('bad') ? 'invalid' : null;

  @override
  Future<String?> validateAsync(String value) async => null;

  @override
  FormInput<String, String> update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    String? remoteError,
  }) {
    final data = prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError,
    );
    return TestInput.fromData(data);
  }
}

void main() {
  group('FormInput (TestInput) basics', () {
    test('untouched constructor sets initialValue == value and statuses', () {
      const i = TestInput.untouched(value: 'hello');
      expect(i.value, 'hello');
      expect(i.initialValue, 'hello');
      expect(i.isUntouched, isTrue);
      expect(i.isTouched, isFalse);
      expect(i.isPristine, isTrue);
      expect(i.mode, ValidationMode.live);
    });

    test('touched constructor keeps provided initialValue and remoteError', () {
      const i = TestInput.touched(
        value: 'abc',
        initialValue: 'orig',
        remoteError: 'serverErr',
      );
      expect(i.value, 'abc');
      expect(i.initialValue, 'orig');
      expect(i.isTouched, isTrue);
      // check public getter for error (remote has precedence)
      expect(i.error, 'serverErr');
    });

    test('localError returns cached error if provided', () {
      const i = TestInput.untouched(value: 'whatever', errorCache: 'cachedErr');
      expect(i.localError, 'cachedErr');
    });

    test('local validation runs when no cached error', () {
      const iValid = TestInput.untouched(value: 'good');
      const iInvalid = TestInput.untouched(value: 'this is bad');

      expect(iValid.localError, isNull);
      expect(iInvalid.localError, 'invalid');
    });

    test('error prefers remoteError over localError', () {
      const localBad = TestInput.untouched(value: 'this is bad');
      expect(localBad.localError, 'invalid');

      const remote = TestInput.touched(value: 'this is bad', remoteError: 'serverErr');
      expect(remote.error, 'serverErr');
    });

    test('isValid / isNotValid reflect local+remote errors', () {
      const ok = TestInput.untouched(value: 'fine');
      expect(ok.isValid, isTrue);
      expect(ok.isNotValid, isFalse);

      const localErr = TestInput.untouched(value: 'bad stuff');
      expect(localErr.isValid, isFalse);

      const remoteErr = TestInput.touched(value: 'fine', remoteError: 'server');
      expect(remoteErr.isValid, isFalse);
    });

    test('== and hashCode compare important fields', () {
      const a = TestInput.untouched(value: 'x');
      const b = TestInput.untouched(value: 'x');
      const c = TestInput.untouched(value: 'y');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a == c, isFalse);
    });
  });

  group('prepareUpdate / update behavior', () {
    test('update sanitizes provided value', () {
      const original = TestInput.touched(value: 'hello', initialValue: 'hello');
      final updated = original.update(value: '  new value  ') as TestInput;

      // sanitize trims whitespace
      expect(updated.value, 'new value');
      // initialValue preserved
      expect(updated.initialValue, original.initialValue);
    });

    test('update clears remote error when value changed', () {
      const orig = TestInput.touched(value: 'email@example.com', remoteError: 'taken');
      expect(orig.error, 'taken');

      // change value => remote error assumed stale and cleared
      final updated = orig.update(value: 'different@example.com') as TestInput;
      expect(updated.error, isNull);
      expect(updated.localError, isNull);
    });

    test('update preserves remote error when value NOT changed and no explicit remoteError', () {
      const orig = TestInput.touched(value: 'keep@me', remoteError: 'serverErr');
      final updated = orig.update() as TestInput;
      expect(updated.error, 'serverErr');
    });

    test('explicit remoteError passed to update overwrites previous remote error', () {
      const orig = TestInput.touched(value: 'v', remoteError: 'oldErr');
      final updated = orig.update(remoteError: 'newErr') as TestInput;
      expect(updated.error, 'newErr');
    });

    test('setting status to untouched clears external remote errors', () {
      const orig = TestInput.touched(value: 'v', remoteError: 'oldErr');
      final updated = orig.update(status: InputStatus.untouched) as TestInput;
      expect(updated.isUntouched, isTrue);
      expect(updated.error, isNull);
    });

    test('computed error is re-evaluated when value changed even if cached exists', () {
      // Create instance with cached error set to something (simulate prior validation)
      const orig = TestInput.untouched(value: 'good', errorCache: 'cachedErr');
      // update to a bad value, it should run validation and compute invalid
      final updated = orig.update(value: 'now bad') as TestInput;
      expect(updated.localError, 'invalid');
    });

    test('isValidating reflects InputStatus.validating', () {
      const orig = TestInput.touched(value: 'v', initialValue: 'v');
      final validating = orig.update(status: InputStatus.validating) as TestInput;
      expect(validating.isValidating, isTrue);
    });
  });

  group('displayError behavior (ValidationMode)', () {
    test('displayError returns error immediately when form status is failed', () {
      const inp = TestInput.touched(value: 'bad', remoteError: 'serverErr');
      const failedStatus = SubmissionStatus.failure;
      expect(inp.displayError(failedStatus), 'serverErr');
    });

    test('displayError hides errors for deferred mode until submit failure', () {
      const normalStatus = SubmissionStatus.idle;
      const deferred = TestInput.touched(value: 'bad', mode: ValidationMode.deferred);

      // deferred should hide until failed
      expect(deferred.displayError(normalStatus), isNull);
    });

    test('displayError shows error for live/blur only when touched', () {
      const touched = TestInput.touched(value: 'bad');
      const untouched = TestInput.untouched(value: 'bad');
      const normalStatus = SubmissionStatus.idle;

      expect(touched.displayError(normalStatus), 'invalid'); // touched -> shows error
      expect(untouched.displayError(normalStatus), isNull); // untouched -> hides error
    });
  });
}
