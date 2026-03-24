import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/async_result.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool  _obscure      = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(authNotifierProvider.notifier).login(
          email:    _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    if (!mounted) return;

    final state = ref.read(authNotifierProvider);
    if (state is Success) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is Loading;
    final colorScheme = Theme.of(context).colorScheme;

    // Affiche les erreurs via SnackBar
    ref.listen<AuthState>(authNotifierProvider, (_, next) {
      if (next case Failure(:final failure)) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(failure.message),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: colorScheme.onError,
              onPressed: () =>
                  ref.read(authNotifierProvider.notifier).resetState(),
            ),
          ));
      }
    });

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    _Header(colorScheme: colorScheme),
                    const SizedBox(height: 40),
                    _LoginForm(
                      formKey:      _formKey,
                      emailCtrl:    _emailCtrl,
                      passwordCtrl: _passwordCtrl,
                      obscure:      _obscure,
                      onToggleObscure: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {/* TODO: forgot password */},
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width:  20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Se connecter',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 24),
                    _Divider(),
                    const SizedBox(height: 24),
                    SocialLoginButton(
                      label:    'Continuer avec Google',
                      iconPath: 'assets/icons/google.svg',
                      onTap:    () {/* TODO */},
                    ),
                    const Spacer(),
                    _RegisterLink(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bon retour 👋',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connectez-vous pour explorer le Cameroun',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.obscure,
    required this.onToggleObscure,
  });

  final GlobalKey<FormState>    formKey;
  final TextEditingController   emailCtrl;
  final TextEditingController   passwordCtrl;
  final bool                    obscure;
  final VoidCallback            onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          AuthTextField(
            controller:  emailCtrl,
            label:       'Email',
            hint:        'vous@exemple.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon:  Icons.email_outlined,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email requis';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller:   passwordCtrl,
            label:        'Mot de passe',
            hint:         '••••••••',
            obscureText:  obscure,
            prefixIcon:   Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
              onPressed: onToggleObscure,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Mot de passe requis';
              if (v.length < 6) return 'Minimum 6 caractères';
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _RegisterLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pas encore de compte ?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(RegisterScreen.routeName),
          child: const Text('Créer un compte'),
        ),
      ],
    );
  }
}

