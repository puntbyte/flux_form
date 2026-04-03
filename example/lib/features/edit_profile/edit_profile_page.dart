// lib/features/edit_profile/edit_profile_page.dart

import 'package:example/features/edit_profile/cubit/edit_profile_cubit.dart';
import 'package:example/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileCubit(),
      child: const _EditProfileScaffold(),
    );
  }
}

class _EditProfileScaffold extends StatelessWidget {
  const _EditProfileScaffold();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditProfileCubit>().state;
    final cubit = context.read<EditProfileCubit>();
    final schema = state.schema;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          // isModified — true when ANY input (including nested AddressSchema)
          // differs from its initialValue.
          if (schema.isModified)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('Modified', style: TextStyle(fontSize: 11)),
                backgroundColor: Color(0xFFFFE0B2),
              ),
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _FeatureTag(
            'populateFrom · isModified · isDirty · changedValues · '
            'nestedSchemas · SchemaValidator · blur mode',
          ),
          const SizedBox(height: 16),

          // ── Display Name ─────────────────────────────────────────────────
          // collapseWhitespace sanitizer: "Jane  Doe" → "Jane Doe"
          _field(
            label: 'Display Name',
            value: schema.displayName.value,
            onChanged: cubit.displayNameChanged,
            error: schema.displayName.displayError(state.status),
            // isDirty — true when current value ≠ initialValue (the server value)
            helper: schema.displayName.isDirty ? '✏ Modified' : null,
          ),
          const SizedBox(height: 14),

          // ── Bio — live mode ────────────────────────────────────────────────
          TextFormField(
            initialValue: schema.bio.value,
            onChanged: cubit.bioChanged,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Bio (max 160 chars)',
              counterText: '${schema.bio.value.length}/160',
              helperText: schema.bio.isDirty ? '✏ Modified' : null,
              helperStyle: const TextStyle(color: Colors.orange),
              errorText: schema.bio.displayError(state.status),
            ),
          ),
          const SizedBox(height: 14),

          // ── Website — blur mode ────────────────────────────────────────────
          // setValue in onChanged: value updates, field stays untouched.
          // markTouched in onEditingComplete: NOW the error appears.
          _field(
            label: 'Website URL',
            value: schema.website.value,
            onChanged: cubit.websiteChanged,
            onEditingComplete: cubit.websiteBlurred,
            error: schema.website.displayError(state.status),
            helper: schema.website.isUntouched
                ? 'Error shows only after leaving this field (blur mode)'
                : schema.website.isDirty
                ? '✏ Modified'
                : null,
            helperColor: schema.website.isUntouched ? Colors.blue : Colors.orange,
          ),

          // ── Cross-field SchemaValidator error ──────────────────────────────
          if (state.status.isFailure && schema.schemaErrors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade50,
                child: Text(
                  schema.schemaErrors.first.toString(),
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ),
            ),

          const SizedBox(height: 20),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Address  (nested FormSchema)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // ── Address — nestedSchemas ────────────────────────────────────────
          // AddressSchema is declared in ProfileSchema.nestedSchemas.
          // It participates in isValid, isTouched, isModified, values,
          // and changedValues automatically.
          _field(
            label: 'Street',
            value: schema.address.street.value,
            onChanged: cubit.streetChanged,
            error: schema.address.street.displayError(state.status),
            helper: schema.address.street.isDirty ? '✏ Modified' : null,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _field(
                  label: 'City',
                  value: schema.address.city.value,
                  onChanged: cubit.cityChanged,
                  error: schema.address.city.displayError(state.status),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  label: 'Post Code',
                  value: schema.address.postCode.value,
                  onChanged: cubit.postCodeChanged,
                  error: schema.address.postCode.displayError(state.status),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── changedValues debug panel ────────────────────────────────────
          // changedValues builds {key: value} only for inputs where isDirty.
          // Nested schemas appear under their key only when address.isModified.
          if (schema.isModified) ...[
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.orange.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'schema.changedValues — PATCH payload:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${schema.changedValues}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          ElevatedButton(
            onPressed: state.status.isInProgress ? null : cubit.save,
            child: state.status.isInProgress
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save Changes'),
          ),

          if (state.status.isSuccess) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.green.shade50,
              child: const Text(
                '✓ Profile saved! PATCH payload was printed to console.',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Convenience factory for a TextFormField with a stable controller.
  Widget _field({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    VoidCallback? onEditingComplete,
    String? error,
    String? helper,
    Color? helperColor,
  }) {
    final controller = TextEditingController(text: value)
      ..selection = TextSelection.collapsed(offset: value.length);
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(
        labelText: label,
        errorText: error,
        helperText: helper,
        helperStyle: TextStyle(color: helperColor ?? Colors.orange),
      ),
    );
  }
}

class _FeatureTag extends StatelessWidget {
  final String text;

  const _FeatureTag(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.teal.shade50,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 10, color: Colors.teal.shade700),
    ),
  );
}
