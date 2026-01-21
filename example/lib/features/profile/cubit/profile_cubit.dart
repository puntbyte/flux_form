import 'package:equatable/equatable.dart';

// Assuming you have this from previous steps
import 'package:example/inputs/bool_field.dart';
import 'package:example/inputs/dynamic_string_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_form/flux_form.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  void nameChanged(String value) {
    // 1. Sanitize
    final sanitized = SanitizerPipeline.sanitize(value, [const TrimSanitizer()]);

    // 2. Update with Dynamic Validation
    final newName = DynamicStringField.touched(
      value: sanitized,
      validators: const [RequiredValidator('Name is required')],
    );

    emit(state.copyWith(name: newName));
  }

  void employedChanged(bool value) {
    // Cast as BoolField to maintain type safety
    final newEmployed = state.isEmployed.copyWith(value: value, isTouched: true) as BoolField;

    // 3. Conditional Logic: Re-evaluate company requirements
    final newCompany = _buildCompanyField(state.company.value, isEmployed: value);

    emit(
      state.copyWith(
        isEmployed: newEmployed,
        company: newCompany,
      ),
    );
  }

  void companyChanged(String value) {
    final newCompany = _buildCompanyField(value, isEmployed: state.isEmployed.value);
    emit(state.copyWith(company: newCompany));
  }

  /// Helper to construct the Company field with dynamic logic
  StringField _buildCompanyField(String value, {required bool isEmployed}) {
    return DynamicStringField.touched(
      value: value,
      validators: [
        // 4. Using WhenValidator (was WhenRule)
        WhenValidator(
          condition: isEmployed,
          validator: const RequiredValidator('Company is required if employed'),
        ),
      ],
    );
  }

  void submit() {
    if (state.isValid) {
      emit(state.copyWith(status: FormStatus.succeeded));
    } else {
      emit(state.copyWith(status: FormStatus.failed));
    }
  }
}
