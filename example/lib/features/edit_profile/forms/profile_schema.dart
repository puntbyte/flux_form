// lib/features/edit_profile/forms/profile_schema.dart
//
// Demonstrates:
//   • nestedSchemas — AddressSchema embedded inside ProfileSchema
//   • SchemaValidator — cross-field rule at the schema level
//   • populateFrom — pre-fill from a server response map
//   • changedValues / isModified / isDirty — PATCH API support

import 'package:flux_form/flux_form.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AddressSchema — a nested sub-schema
// ─────────────────────────────────────────────────────────────────────────────

class AddressSchema extends FormSchema {
  final SimpleStringInput<String> street;
  final SimpleStringInput<String> city;
  final SimpleStringInput<String> postCode;

  static final StringInputBuilder<String> _required = StringInputBuilder<String>()
      .required('Required')
      .trim();
  static final StringInputBuilder<String> _postCode = StringInputBuilder<String>()
      .trim()
      .required('Post code required')
      .minLength(4, 'Too short')
      .maxLength(10, 'Too long');

  AddressSchema({
    SimpleStringInput<String>? street,
    SimpleStringInput<String>? city,
    SimpleStringInput<String>? postCode,
  }) : street = street ?? _required.buildUntouched(),
       city = city ?? _required.buildUntouched(),
       postCode = postCode ?? _postCode.buildUntouched();

  @override
  Map<String, FormInput<dynamic, dynamic>> get namedInputs => {
    'street': street,
    'city': city,
    'post_code': postCode,
  };

  AddressSchema copyWith({
    SimpleStringInput<String>? street,
    SimpleStringInput<String>? city,
    SimpleStringInput<String>? postCode,
  }) => AddressSchema(
    street: street ?? this.street,
    city: city ?? this.city,
    postCode: postCode ?? this.postCode,
  );

  @override
  AddressSchema touchAll() => copyWith(
    street: street.markTouched(),
    city: city.markTouched(),
    postCode: postCode.markTouched(),
  );

  @override
  AddressSchema reset() => AddressSchema();

  @override
  AddressSchema populateFrom(Map<String, dynamic> data) => copyWith(
    street: street.replaceValue(data['street'] as String? ?? ''),
    city: city.replaceValue(data['city'] as String? ?? ''),
    postCode: postCode.replaceValue(data['post_code'] as String? ?? ''),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ProfileSchema — parent with nested AddressSchema
// ─────────────────────────────────────────────────────────────────────────────

class ProfileSchema extends FormSchema {
  final SimpleStringInput<String> displayName;
  final SimpleStringInput<String> bio;
  final SimpleStringInput<String> website;
  final AddressSchema address; // ← nested schema

  static final StringInputBuilder<String> _nameBuilder = StringInputBuilder<String>()
      .trim()
      //.collapseWhitespace()  // "John  Doe" → "John Doe"
      .required('Display name is required')
      .minLength(2, 'Too short')
      .maxLength(50, 'Too long');

  static final StringInputBuilder<String> _bioBuilder = StringInputBuilder<String>()
      .trim()
      .maxLength(160, 'Bio must be 160 characters or fewer')
      .mode(ValidationMode.live);

  static final StringInputBuilder<String> _websiteBuilder = StringInputBuilder<String>()
      .trim()
      .url('Enter a valid URL (include https://)', requireProtocol: true)
      .mode(ValidationMode.blur);

  ProfileSchema({
    SimpleStringInput<String>? displayName,
    SimpleStringInput<String>? bio,
    SimpleStringInput<String>? website,
    AddressSchema? address,
  }) : displayName = displayName ?? _nameBuilder.buildUntouched(),
       bio = bio ?? _bioBuilder.buildUntouched(),
       website = website ?? _websiteBuilder.buildUntouched(),
       address = address ?? AddressSchema();

  @override
  Map<String, FormInput<dynamic, dynamic>> get namedInputs => {
    'display_name': displayName,
    'bio': bio,
    'website': website,
  };

  /// [nestedSchemas] — AddressSchema participates in aggregate validity,
  /// isTouched, isModified, values, and changedValues automatically.
  @override
  Map<String, FormSchema> get nestedSchemas => {'address': address};

  /// [schemaValidators] — cross-field rule: website required when bio mentions a link.
  @override
  List<SchemaValidator<dynamic>> get schemaValidators => [
    SchemaValidator.of<ProfileSchema, String>((s) {
      final bioHasLink =
          s.bio.value.toLowerCase().contains('http') || s.bio.value.toLowerCase().contains('www');
      if (!bioHasLink) return null;
      return s.website.value.trim().isEmpty
          ? 'Your bio mentions a link — please fill in the website field'
          : null;
    }),
  ];

  ProfileSchema copyWith({
    SimpleStringInput<String>? displayName,
    SimpleStringInput<String>? bio,
    SimpleStringInput<String>? website,
    AddressSchema? address,
  }) => ProfileSchema(
    displayName: displayName ?? this.displayName,
    bio: bio ?? this.bio,
    website: website ?? this.website,
    address: address ?? this.address,
  );

  @override
  ProfileSchema touchAll() => copyWith(
    displayName: displayName.markTouched(),
    bio: bio.markTouched(),
    website: website.markTouched(),
    address: address.touchAll(), // cascade into nested
  );

  @override
  ProfileSchema reset() => ProfileSchema();

  /// [populateFrom] — loads an existing user profile into the schema.
  /// Called on screen open when editing an existing profile.
  @override
  ProfileSchema populateFrom(Map<String, dynamic> data) => copyWith(
    displayName: displayName.replaceValue(data['display_name'] as String? ?? ''),
    bio: bio.replaceValue(data['bio'] as String? ?? ''),
    website: website.replaceValue(data['website'] as String? ?? ''),
    address: address.populateFrom(data['address'] as Map<String, dynamic>? ?? {}),
  );
}
