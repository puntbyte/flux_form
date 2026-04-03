// lib/features/edit_profile/cubit/edit_profile_cubit.dart

import 'package:example/features/edit_profile/forms/profile_schema.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_form/flux_form.dart';

part 'edit_profile_state.dart';

// Simulated server response — represents the user's existing profile data.
final Map<String, Object> _serverProfile = {
  'display_name': 'Jane Doe',
  'bio': 'Flutter developer. Check out my work at www.example.com',
  'website': 'https://www.example.com',
  'address': {
    'street': '10 Baker St',
    'city': 'London',
    'post_code': 'NW1 6XE',
  },
};

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit() : super(EditProfileState()) {
    _load();
  }

  void _load() {
    // populateFrom — fills every input from the server map and marks
    // all inputs as touched (they have real values, not pristine defaults).
    final populated = ProfileSchema().populateFrom(_serverProfile);
    emit(state.copyWith(schema: populated));
  }

  // ── Display Name ──────────────────────────────────────────────────────────

  void displayNameChanged(String v) =>
      _update((s) => s.copyWith(displayName: s.displayName.replaceValue(v)));

  // ── Bio — live mode ────────────────────────────────────────────────────────

  void bioChanged(String v) => _update((s) => s.copyWith(bio: s.bio.replaceValue(v)));

  // ── Website — blur mode contract ───────────────────────────────────────────
  // In onChanged → setValue (value updated, NOT touched → error hidden).
  // In onEditingComplete → markTouched (NOW the error becomes visible).

  void websiteChanged(String v) => _update((s) => s.copyWith(website: s.website.setValue(v)));

  void websiteBlurred() => _update((s) => s.copyWith(website: s.website.markTouched()));

  // ── Address ────────────────────────────────────────────────────────────────

  void streetChanged(String v) => _addr((a) => a.copyWith(street: a.street.replaceValue(v)));

  void cityChanged(String v) => _addr((a) => a.copyWith(city: a.city.replaceValue(v)));

  void postCodeChanged(String v) => _addr((a) => a.copyWith(postCode: a.postCode.replaceValue(v)));

  void _addr(AddressSchema Function(AddressSchema) fn) =>
      _update((s) => s.copyWith(address: fn(s.address)));

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> save() async {
    final (touched, isValid) = state.schema.validate();
    if (!isValid) {
      emit(state.copyWith(schema: touched as ProfileSchema, status: SubmissionStatus.failure));
      return;
    }
    await FormSubmitter<void>(
      onStart: () => emit(state.copyWith(status: SubmissionStatus.inProgress)),
      // changedValues — only sends fields that differ from initialValue (PATCH).
      onSubmit: () async {
        final payload = state.schema.changedValues;
        // ignore: avoid_print
        print('PATCH payload: $payload');
        await Future.delayed(const Duration(milliseconds: 600));
      },
      onSuccess: (_) => emit(state.copyWith(status: SubmissionStatus.success)),
      onError: (_, _) => emit(state.copyWith(status: SubmissionStatus.failure)),
    ).submit();
  }

  // ─────────────────────────────────────────────────────────────────────────

  void _update(ProfileSchema Function(ProfileSchema) fn) => emit(
    state.copyWith(schema: fn(state.schema), status: SubmissionStatus.idle),
  );
}
