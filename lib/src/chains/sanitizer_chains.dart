// lib/src/chains/sanitizer_chains.dart

import 'package:flux_form/src/chains/flux_chain.dart';
import 'package:flux_form/src/sanitization/sanitizers/string_sanitizer.dart';

class StringSanitizerChain extends SanitizerChain<String, StringSanitizerChain> {
  StringSanitizerChain trim() => add(const StringSanitizer.trim());

  StringSanitizerChain toLowerCase() => add(const StringSanitizer.toLowerCase());

  StringSanitizerChain toUpperCase() => add(const StringSanitizer.toUpperCase());

  StringSanitizerChain digitsOnly() => add(const StringSanitizer.digitsOnly());

  StringSanitizerChain removeSpaces() => add(const StringSanitizer.removeSpaces());

  StringSanitizerChain capitalize() => add(const StringSanitizer.capitalize());
}
