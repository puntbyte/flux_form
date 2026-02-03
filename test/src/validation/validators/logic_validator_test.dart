// test/src/validation/validators/logic_validator_test.dart

import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validators/logic_validator.dart';
import 'package:test/test.dart';

/// Small helper validators used in tests.
class AlwaysFail extends Validator<String, String> {
  final String err;

  const AlwaysFail(this.err) : super(err);

  @override
  String? validate(String value) => err;
}

class AlwaysPass extends Validator<String, String> {
  const AlwaysPass() : super(null);

  @override
  String? validate(String value) => null;
}

/// Fails when the value contains [substr], otherwise passes.
class ContainsFail extends Validator<String, String> {
  final String substr;
  final String err;

  const ContainsFail(this.substr, this.err) : super(err);

  @override
  String? validate(String value) => value.contains(substr) ? err : null;
}

/// Passes only when value length >= minLen, otherwise returns [err].
class MinLenValidator extends Validator<String, String> {
  final int minLen;
  final String err;

  const MinLenValidator(this.minLen, this.err) : super(err);

  @override
  String? validate(String value) => value.length >= minLen ? null : err;
}

void main() {
  group('LogicValidator.when / unless', () {
    test('when applies validator only if condition true', () {
      var called = false;
      const validator = ContainsFail('bad', 'containsBad');
      final whenV = LogicValidator.when(
        condition: () {
          called = true;
          return true;
        },
        validator: validator,
      );

      // condition true -> validator invoked -> returns error for this value
      expect(whenV.validate('this is bad'), 'containsBad');
      expect(called, isTrue);
    });

    test('when skips validator when condition false', () {
      const validator = ContainsFail('bad', 'containsBad');
      final whenV = LogicValidator.when(
        condition: () => false,
        validator: validator,
      );

      // condition false -> skip -> null
      expect(whenV.validate('this is bad'), isNull);
    });

    test('unless applies validator only if condition false', () {
      const validator = ContainsFail('bad', 'containsBad');

      final unlessTrue = LogicValidator.unless(
        condition: () => true,
        validator: validator,
      );
      // condition true -> unless should skip -> null
      expect(unlessTrue.validate('this is bad'), isNull);

      final unlessFalse = LogicValidator.unless(
        condition: () => false,
        validator: validator,
      );
      // condition false -> apply -> error
      expect(unlessFalse.validate('this is bad'), 'containsBad');
    });
  });

  group('LogicValidator.where', () {
    test('where applies validator only when predicate(value) is true', () {
      bool pred(String v) => v.startsWith('x');
      const validator = ContainsFail('bad', 'containsBad');

      final whereV = LogicValidator.where(
        predicate: pred,
        validator: validator,
      );

      // value doesn't satisfy predicate -> skip
      expect(whereV.validate('hello bad'), isNull);

      // value satisfies predicate, contains 'bad' -> validator runs and returns error
      expect(whereV.validate('xbad here'), 'containsBad');
    });
  });

  group('LogicValidator.any', () {
    test('any returns null if at least one validator passes', () {
      const v = LogicValidator<String, String>.any(
        [
          AlwaysFail('err1'),
          AlwaysPass(),
          AlwaysFail('err2'),
        ],
        'groupErr',
      );

      // one AlwaysPass exists -> any should return null (valid)
      expect(v.validate('anything'), isNull);
    });

    test('any returns group error when all validators fail', () {
      const v = LogicValidator<String, String>.any(
        [
          AlwaysFail('a'),
          ContainsFail('x', 'containsX'), // will fail for test value
        ],
        'groupErr',
      );

      expect(v.validate('no x here'), 'groupErr');
    });

    test('any with empty validators returns group error', () {
      const v = LogicValidator<String, String>.any([], 'groupErr');
      expect(v.validate('whatever'), 'groupErr');
    });
  });

  group('LogicValidator.all', () {
    test('all returns null when all validators pass', () {
      const v = LogicValidator<String, String>.all(
        [
          AlwaysPass(),
          MinLenValidator(1, 'short'),
        ],
        'groupErr',
      );

      expect(v.validate('ok'), isNull);
    });

    test('all returns first failing validator error', () {
      const v = LogicValidator<String, String>.all(
        [
          ContainsFail('x', 'hasX'), // fails for test value
          AlwaysPass(),
        ],
        'groupErr',
      );

      // first validator fails -> its error is returned
      expect(v.validate('no x here'), 'hasX');
    });
  });

  group('LogicValidator.none', () {
    test('none returns null when none of the validators pass (all fail)', () {
      const v = LogicValidator<String, String>.none(
        [
          AlwaysFail('a'),
          ContainsFail('y', 'hasY'), // fails for value without 'y'
        ],
        'noneErr',
      );

      // both validators fail -> none is valid -> returns null
      expect(v.validate('no y here'), isNull);
    });

    test('none returns error when any validator passes', () {
      const v = LogicValidator<String, String>.none(
        [
          AlwaysFail('a'),
          AlwaysPass(),
        ],
        'noneErr',
      );

      // one validator passes -> none should return error
      expect(v.validate('anything'), 'noneErr');
    });
  });

  group('LogicValidator.xor', () {
    test('xor returns null when exactly one validator passes', () {
      const v = LogicValidator<String, String>.xor(
        [
          AlwaysFail('a'),
          AlwaysPass(),
          AlwaysFail('b'),
        ],
        'xorErr',
      );

      // exactly one pass -> valid
      expect(v.validate('anything'), isNull);
    });

    test('xor returns error when zero or more than one pass', () {
      // zero pass -> error
      const nonePass = LogicValidator<String, String>.xor(
        [
          AlwaysFail('a'),
          ContainsFail('x', 'hasX'), // will fail for test value
        ],
        'xorErr',
      );
      expect(nonePass.validate('no x here'), 'xorErr');

      // two pass -> error
      const twoPass = LogicValidator<String, String>.xor(
        [
          AlwaysPass(),
          AlwaysPass(),
          AlwaysFail('a'),
        ],
        'xorErr',
      );
      expect(twoPass.validate('anything'), 'xorErr');
    });
  });

  group('LogicValidator.custom / dynamic', () {
    test('custom uses provided callback and returns its result', () {
      // callback returns error when value == 'bad'
      final dyn = LogicValidator<String, String>.custom(
        (v) => v == 'bad' ? 'badError' : null,
      );

      expect(dyn.validate('ok'), isNull);
      expect(dyn.validate('bad'), 'badError');
    });

    test('dynamic validator allowed to return null error in constructor', () {
      // ensure no crash when super.error is null (constructor uses null)
      final dyn = LogicValidator<String, String>.custom(
        (v) => null,
      );

      expect(dyn.validate('anything'), isNull);
    });
  });
}
