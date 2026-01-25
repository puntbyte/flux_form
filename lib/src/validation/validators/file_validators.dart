import 'dart:io';
import 'package:flux_form/src/validation/validator.dart';

/// Validates file size (works with File object or just length in bytes).
class FileSizeValidator<E> extends Validator<File, E> {
  final int maxBytes;

  const FileSizeValidator(this.maxBytes, super.error);

  @override
  E? validate(File value) {
    if (!value.existsSync()) return null; // Let RequiredValidator handle null/missing
    return value.lengthSync() <= maxBytes ? null : error;
  }
}

/// Validates file extension via String path.
class FileExtensionValidator<E> extends Validator<String, E> {
  final List<String> allowedExtensions;

  const FileExtensionValidator(this.allowedExtensions, super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    final ext = value.split('.').last.toLowerCase();
    return allowedExtensions.contains(ext) ? null : error;
  }
}
