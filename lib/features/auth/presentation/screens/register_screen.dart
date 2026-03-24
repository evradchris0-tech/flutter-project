import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/async_result.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _firstNameCtrl   = TextEditingController();
  final _lastNameCtrl    = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _confirmCtrl     = TextEditingController();
  bool  _obscure         = true;
  bool  _obscureConfirm  = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(authNotifierProvider.notifier).register(
          email:     _emailCtrl.text.trim(),
          password:  _passwordCtrl.text,
          firstName: _firstNameCtrl.text.trim(),
          lastName:  _lastNameCtrl.text.trim(),
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
    final authState   = ref.watch(authNotifierProvider);
    final isLoading   = authState is Loading;
    final colorScheme = Theme.of(context).colorScheme;

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation:       0,
        leading: IconButton(
          icon:      const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _Header(colorScheme: colorScheme),
                  const SizedBox(height: 32),
                  _RegisterForm(
                    formKey:          _formKey,
                    firstNameCtrl:    _firstNameCtrl,
                    lastNameCtrl:     _lastNameCtrl,
                    emailCtrl:        _emailCtrl,
                    passwordCtrl:     _passwordCtrl,
                    confirmCtrl:      _confirmCtrl,
                    obscure:          _obscure,
                    obscureConfirm:   _obscureConfirm,
                    onToggleObscure:  () => setState(() => _obscure = !_obscure),
                    onToggleConfirm:  () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  const SizedBox(height: 32),
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
                            'Créer mon compte',
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
                  const SizedBox(height: 40),
                  _LoginLink(),
                  const SizedBox(height: 24),
                ]),
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
          'Créer un compte 🌍',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rejoignez la communauté des explorateurs du Cameroun',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.obscure,
    required this.obscureConfirm,
    required this.onToggleObscure,
    required this.onToggleConfirm,
  });

  final GlobalKey<FormState>  formKey;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool                  obscure;
  final bool                  obscureConfirm;
  final VoidCallback          onToggleObscure;
  final VoidCallback          onToggleConfirm;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AuthTextField(
                  controller: firstNameCtrl,
                  label:      'Prénom',
                  hint:       'Jean',
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requis' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AuthTextField(
                  controller: lastNameCtrl,
                  label:      'Nom',
                  hint:       'Dupont',
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requis' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller:   emailCtrl,
            label:        'Email',
            hint:         'vous@exemple.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon:   Icons.email_outlined,
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
            controller:  passwordCtrl,
            label:       'Mot de passe',
            hint:        '••••••••',
            obscureText: obscure,
            prefixIcon:  Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: onToggleObscure,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Mot de passe requis';
              if (v.length < 8) return 'Minimum 8 caractères';
              if (!RegExp(r'(?=.*[A-Z])').hasMatch(v)) {
                return 'Au moins une majuscule';
              }
              if (!RegExp(r'(?=.*\d)').hasMatch(v)) {
                return 'Au moins un chiffre';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller:  confirmCtrl,
            label:       'Confirmer le mot de passe',
            hint:        '••••••••',
            obscureText: obscureConfirm,
            prefixIcon:  Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: onToggleConfirm,
            ),
            validator: (v) {
              if (v != passwordCtrl.text) {
                return 'Les mots de passe ne correspondent pas';
              }
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

class _LoginLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Déjà un compte ?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Se connecter'),
        ),
      ],
    );
  }
}
