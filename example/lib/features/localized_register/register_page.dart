import 'package:example/features/localized_register/cubit/register_cubit.dart';
import 'package:example/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Localized Errors')),
        drawer: const AppDrawer(),
        body: const _RegisterView(),
      ),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RegisterCubit>().state;
    final cubit = context.read<RegisterCubit>();
    final lang = state.languageCode;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Language:', style: TextStyle(fontWeight: FontWeight.bold)),
              Switch(
                value: lang == 'es',
                onChanged: (_) => cubit.toggleLanguage(),
                activeThumbColor: Colors.orange,
                thumbIcon: WidgetStateProperty.resolveWith((states) {
                  return Icon(lang == 'es' ? Icons.language : Icons.flag);
                }),
              ),
              Text(lang.toUpperCase()),
            ],
          ),
          const Divider(height: 30),

          TextField(
            onChanged: cubit.emailChanged,
            decoration: InputDecoration(
              labelText: lang == 'es' ? 'Correo Electrónico' : 'Email',
              // 1. Get the Typed Error (AuthError?)
              // 2. If not null, call .translate()
              errorText: state.email.displayError(state.status)?.translate(lang),
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            onChanged: cubit.passwordChanged,
            obscureText: true,
            decoration: InputDecoration(
              labelText: lang == 'es' ? 'Contraseña' : 'Password',
              // Logic: Get Error Enum -> Convert to String
              errorText: state.password.displayError(state.status)?.translate(lang),
            ),
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: cubit.submit,
            child: Text(lang == 'es' ? 'Registrarse' : 'Register'),
          ),

          if (state.status.isSucceeded)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                lang == 'es' ? '¡Registro Exitoso!' : 'Registration Successful!',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
