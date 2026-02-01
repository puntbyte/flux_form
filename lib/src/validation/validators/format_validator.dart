// lib/src/validation/validators/format_validator.dart

import 'dart:convert';

import 'package:flux_form/src/validation/validator.dart';

abstract class FormatValidator<E> extends Validator<String, E> {
  const FormatValidator(super.error);

  /// Validates that the string is a valid URL (http/https).
  const factory FormatValidator.url(E error, {bool requireProtocol}) = _UrlValidator;

  /// Validates standard email format.
  const factory FormatValidator.email(E error) = _EmailValidator;

  /// Validates that the string is a valid UUID (v4).
  const factory FormatValidator.uuid(E error) = _UuidValidator;

  /// Validates the number using the Luhn Algorithm.
  const factory FormatValidator.creditCard(E error) = _CreditCardValidator;

  /// Validates that the string is a valid Hex Color (e.g., #FFF or #FFFFFF).
  const factory FormatValidator.hexColor(E error) = _HexColorValidator;

  /// Validates that the string contains only alphabet characters (a-z, A-Z).
  const factory FormatValidator.alpha(E error) = _AlphaValidator;

  /// Validates that the string contains only alphanumeric characters (a-z, 0-9).
  const factory FormatValidator.alphaNumeric(E error) = _AlphaNumericValidator;

  const factory FormatValidator.fileExtension(List<String> allowedExtensions, E error) =
      _FileExtensionValidator;

  /// Validates IPv4 format.
  const factory FormatValidator.ipv4(E error) = _Ipv4Validator;

  /// Validates IPv6 format (basic form — does not cover all compressed variants).
  const factory FormatValidator.ipv6(E error) = _Ipv6Validator;

  /// Validates either IPv4 or IPv6.
  const factory FormatValidator.ip(E error) = _IpValidator;

  /// Validates domain names (example.com, sub.example.co.uk).
  const factory FormatValidator.domain(E error) = _DomainValidator;

  /// Validates E.164 phone numbers (e.g., +1234567890).
  const factory FormatValidator.e164Phone(E error) = _E164PhoneValidator;

  /// Validates slugs (kebab-case: lowercase letters, numbers and dashes).
  const factory FormatValidator.slug(E error) = _SlugValidator;

  /// Validates that the string is valid Base64.
  const factory FormatValidator.base64(E error) = _Base64Validator;

  /// Validates that the string is valid JSON.
  const factory FormatValidator.json(E error) = _JsonValidator;

  /// Validates ISO-8601 date/time strings (attempts DateTime.parse).
  const factory FormatValidator.iso8601(E error) = _Iso8601Validator;

  /// Validates MAC addresses (00:11:22:33:44:55 or 00-11-22-33-44-55).
  const factory FormatValidator.macAddress(E error) = _MacAddressValidator;
}

// ================= Implementation =================

class _UrlValidator<E> extends FormatValidator<E> {
  final bool requireProtocol;

  const _UrlValidator(super.error, {this.requireProtocol = true});

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null) return error;

    if (requireProtocol) {
      if (!uri.hasScheme || !['http', 'https'].contains(uri.scheme)) {
        return error;
      }
    }
    return uri.host.isNotEmpty ? null : error;
  }
}

class _EmailValidator<E> extends FormatValidator<E> {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  const _EmailValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return _emailRegExp.hasMatch(value) ? null : error;
  }
}

class _UuidValidator<E> extends FormatValidator<E> {
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  const _UuidValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return _uuidRegex.hasMatch(value) ? null : error;
  }
}

class _HexColorValidator<E> extends FormatValidator<E> {
  static final RegExp _hexRegex = RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');

  const _HexColorValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return _hexRegex.hasMatch(value) ? null : error;
  }
}

class _AlphaValidator<E> extends FormatValidator<E> {
  static final RegExp _alphaRegex = RegExp(r'^[a-zA-Z]+$');

  const _AlphaValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return _alphaRegex.hasMatch(value) ? null : error;
  }
}

class _AlphaNumericValidator<E> extends FormatValidator<E> {
  static final RegExp _alphaNumRegex = RegExp(r'^[a-zA-Z0-9]+$');

  const _AlphaNumericValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return _alphaNumRegex.hasMatch(value) ? null : error;
  }
}

class _FileExtensionValidator<E> extends FormatValidator<E> {
  final List<String> allowedExtensions;

  const _FileExtensionValidator(this.allowedExtensions, super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    final ext = value.split('.').last.toLowerCase();
    return allowedExtensions.contains(ext) ? null : error;
  }
}

class _CreditCardValidator<E> extends FormatValidator<E> {
  const _CreditCardValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    // Remove spaces/dashes
    final clean = value.replaceAll(RegExp(r'[\s-]'), '');
    if (int.tryParse(clean) == null) return error;

    var sum = 0;
    var alternate = false;

    // Loop backwards
    for (var i = clean.length - 1; i >= 0; i--) {
      var n = int.parse(clean[i]);

      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }

    return (sum % 10 == 0) ? null : error;
  }
}

class _Ipv4Validator<E> extends FormatValidator<E> {
  static final RegExp _ipv4 = RegExp(
    r'^(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)(?:\.(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)){3}$',
  );

  const _Ipv4Validator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return _ipv4.hasMatch(value) ? null : error;
  }
}

class _Ipv6Validator<E> extends FormatValidator<E> {
  // This regex matches basic full-form IPv6 addresses (eight groups).
  // It does not cover every compressed IPv6 form. Use with caution.
  static final RegExp _ipv6 = RegExp(r'^(?:[A-Fa-f0-9]{1,4}:){7}[A-Fa-f0-9]{1,4}$');

  const _Ipv6Validator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return _ipv6.hasMatch(value) ? null : error;
  }
}

class _IpValidator<E> extends FormatValidator<E> {
  const _IpValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    final ipv4 = _Ipv4Validator<E>(error);
    final ipv6 = _Ipv6Validator<E>(error);
    return ipv4.validate(value) == null || ipv6.validate(value) == null ? null : error;
  }
}

class _DomainValidator<E> extends FormatValidator<E> {
  // Very common domain validation: one or more labels separated by dots,
  // labels can't start/end with '-', TLD minimum 2 chars.
  static final RegExp _domain = RegExp(
    r'^(?!-)(?:[A-Za-z0-9-]{1,63}\.)+[A-Za-z]{2,63}$',
  );

  const _DomainValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return _domain.hasMatch(value) ? null : error;
  }
}

class _E164PhoneValidator<E> extends FormatValidator<E> {
  // E.164: + followed by country code and subscriber number, up to 15 digits.
  static final RegExp _e164 = RegExp(r'^\+?[1-9]\d{1,14}$');

  const _E164PhoneValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return _e164.hasMatch(value) ? null : error;
  }
}

class _SlugValidator<E> extends FormatValidator<E> {
  // kebab-case slugs: lowercase letters, numbers and single dashes between segments
  static final RegExp _slug = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

  const _SlugValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return _slug.hasMatch(value) ? null : error;
  }
}

class _Base64Validator<E> extends FormatValidator<E> {
  static final RegExp _b64 = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');

  const _Base64Validator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;

    // quick regex check first
    if (!_b64.hasMatch(value) || value.length % 4 != 0) return error;

    // then try decoding to be more certain
    try {
      base64Decode(value);
      return null;
    } on Object catch (_) {
      return error;
    }
  }
}

class _JsonValidator<E> extends FormatValidator<E> {
  const _JsonValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    try {
      jsonDecode(value);
      return null;
    } on Object catch (_) {
      return error;
    }
  }
}

class _Iso8601Validator<E> extends FormatValidator<E> {
  const _Iso8601Validator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    try {
      DateTime.parse(value);
      return null;
    } on Object catch (_) {
      return error;
    }
  }
}

class _MacAddressValidator<E> extends FormatValidator<E> {
  static final RegExp _mac = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');

  const _MacAddressValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return _mac.hasMatch(value) ? null : error;
  }
}
