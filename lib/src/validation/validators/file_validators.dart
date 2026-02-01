// lib/src/validation/validators/file_validators.dart

import 'dart:io';
import 'package:flux_form/src/validation/validator.dart';

/// A namespace for File validation rules.
abstract class FileValidator<E> extends Validator<File, E> {
  const FileValidator(super.error);

  /// Validates file size is <= maxBytes.
  const factory FileValidator.sizeMax(int maxBytes, E error) = _FileSizeValidator;

  /// Validates file size is >= minBytes.
  const factory FileValidator.sizeMin(int minBytes, E error) = _FileMinSizeValidator;

  /// Validates file size is between min and max (inclusive).
  const factory FileValidator.sizeRange(int minBytes, int maxBytes, E error) =
      _FileSizeRangeValidator;

  /// Validates file extension (e.g., `['jpg', 'png']`).
  const factory FileValidator.extension(List<String> allowed, E error) = _FileExtensionValidator;

  /// Validates file exists.
  const factory FileValidator.exists(E error) = _FileExistsValidator;

  /// Validates file is not empty (size > 0). If file doesn't exist, returns null
  /// to allow RequiredValidator to handle missing-file semantics.
  const factory FileValidator.notEmpty(E error) = _FileNotEmptyValidator;

  /// Validates filename matches a RegExp.
  const factory FileValidator.namePattern(RegExp pattern, E error) = _FileNamePatternValidator;

  /// Validates the file's mime type (best-effort via extension mapping).
  /// Accepts mime types like 'image/png' or short extensions like 'png' in the allowed list.
  const factory FileValidator.mimeTypes(List<String> allowed, E error) = _FileMimeTypeValidator;
}

class _FileSizeValidator<E> extends FileValidator<E> {
  final int maxBytes;

  const _FileSizeValidator(this.maxBytes, super.error);

  @override
  E? validate(File value) {
    if (!value.existsSync()) return null;
    return value.lengthSync() <= maxBytes ? null : error;
  }
}

class _FileMinSizeValidator<E> extends FileValidator<E> {
  final int minBytes;

  const _FileMinSizeValidator(this.minBytes, super.error);

  @override
  E? validate(File value) {
    if (!value.existsSync()) return null;
    return value.lengthSync() >= minBytes ? null : error;
  }
}

class _FileSizeRangeValidator<E> extends FileValidator<E> {
  final int minBytes;
  final int maxBytes;

  const _FileSizeRangeValidator(this.minBytes, this.maxBytes, super.error);

  @override
  E? validate(File value) {
    if (!value.existsSync()) return null;
    final len = value.lengthSync();
    return (len >= minBytes && len <= maxBytes) ? null : error;
  }
}

class _FileExtensionValidator<E> extends FileValidator<E> {
  final List<String> allowedExtensions;

  const _FileExtensionValidator(this.allowedExtensions, super.error);

  @override
  E? validate(File value) {
    if (!value.existsSync()) return null;
    final ext = value.path.split('.').last.toLowerCase();
    return allowedExtensions.contains(ext) ? null : error;
  }
}

class _FileExistsValidator<E> extends FileValidator<E> {
  const _FileExistsValidator(super.error);

  @override
  E? validate(File value) {
    return value.existsSync() ? null : error;
  }
}

class _FileNotEmptyValidator<E> extends FileValidator<E> {
  const _FileNotEmptyValidator(super.error);

  @override
  E? validate(File value) {
    if (!value.existsSync()) return null;
    return value.lengthSync() > 0 ? null : error;
  }
}

class _FileNamePatternValidator<E> extends FileValidator<E> {
  final RegExp pattern;

  const _FileNamePatternValidator(this.pattern, super.error);

  @override
  E? validate(File value) {
    final name = value.path.split(Platform.pathSeparator).last;
    return pattern.hasMatch(name) ? null : error;
  }
}

class _FileMimeTypeValidator<E> extends FileValidator<E> {
  final List<String> allowed; // can contain mime types or extensions

  const _FileMimeTypeValidator(this.allowed, super.error);

  static const Map<String, String> _extToMime = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'svg': 'image/svg+xml',
    'pdf': 'application/pdf',
    'txt': 'text/plain',
    'csv': 'text/csv',
    'json': 'application/json',
    'xml': 'application/xml',
    'mp4': 'video/mp4',
    'mp3': 'audio/mpeg',
    'wav': 'audio/wav',
    'ogg': 'audio/ogg',
    'doc': 'application/msword',
    'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls': 'application/vnd.ms-excel',
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'ppt': 'application/vnd.ms-powerpoint',
    'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'epub': 'application/epub+zip',
  };

  @override
  E? validate(File value) {
    if (!value.existsSync()) return null;

    final ext = value.path.split('.').last.toLowerCase();
    final mime = _extToMime[ext];

    final allowedNormalized = allowed.map((a) => a.toLowerCase()).toList();

    // Allow either mime strings or plain extensions in the allowed list.
    if (allowedNormalized.contains(ext)) return null;
    if (mime != null && allowedNormalized.contains(mime)) return null;

    return error;
  }
}
