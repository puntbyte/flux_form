/// A strongly typed error enums.
/// This decouples the "Error Reason" from the "Display Text".
enum AuthError {
  empty,
  invalidEmail,
  shortPassword,
  noSpecialChar
  ;

  /// A simple localized translator.
  /// In a real app, this would use `AppLocalizations.of(context)` or `easy_localization`.
  String translate(String languageCode) {
    final isEs = languageCode == 'es';

    return switch (this) {
      AuthError.empty => isEs ? 'Este campo es obligatorio' : 'This field is required',
      AuthError.invalidEmail => isEs ? 'Correo inválido' : 'Invalid email address',
      AuthError.shortPassword => isEs ? 'Mínimo 6 caracteres' : 'Must be at least 6 chars',
      AuthError.noSpecialChar =>
        isEs ? 'Falta carácter especial (!@#)' : 'Missing special char (!@#)',
    };
  }
}
