part of 'profile_cubit.dart';

class ProfileState extends Equatable with FormMixin {
  final StringInput<String> name;
  final BoolField isEmployed;
  final StringInput<String> company;
  final FormStatus status;

  const ProfileState({
    this.name = const StringInput.untouched(),
    this.isEmployed = const BoolField.untouched(),
    this.company = const StringInput.untouched(),
    this.status = FormStatus.initial,
  });

  // --- FORM MIXIN ---
  // Registers fields for validation checks (isValid, isTouched, etc)
  @override
  List<FormInput<dynamic, String>> get inputs => [name, isEmployed, company];

  // --- SERIALIZATION ---
  // Easy export to JSON
  Map<String, dynamic> get toMap => {
    'name': name.value,
    'is_employed': isEmployed.value,
    'company': company.value,
  };

  ProfileState copyWith({
    StringInput<String>? name,
    BoolField? isEmployed,
    StringInput<String>? company,
    FormStatus? status,
  }) {
    return ProfileState(
      name: name ?? this.name,
      isEmployed: isEmployed ?? this.isEmployed,
      company: company ?? this.company,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [name, isEmployed, company, status];
}
