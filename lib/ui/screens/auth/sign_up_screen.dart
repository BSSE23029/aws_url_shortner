import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/physics_button.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../widgets/stealth_input.dart';
import '../../../providers/providers.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _acceptTerms = false;
  bool _isValid = false;
  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmController.addListener(_validateForm);
  }

  void _validateForm() {
    final nameValid = _nameController.text.length >= 2;
    final emailValid = _emailRegex.hasMatch(_emailController.text);
    final passValid = _passwordController.text.length >= 8;
    final matchValid = _passwordController.text == _confirmController.text;
    final newState =
        nameValid && emailValid && passValid && matchValid && _acceptTerms;
    if (_isValid != newState) setState(() => _isValid = newState);
  }

  void _handleSubmit() {
    if (_isValid) {
      ref
          .read(authProvider.notifier)
          .signUp(
            email: _emailController.text,
            password: _passwordController.text,
            name: _nameController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Safe Listener
    ref.listen(authProvider, (previous, next) {
      if (next.confirmationRequired) context.push('/mfa');
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    final theme = Theme.of(context);
    final txtColor = theme.colorScheme.onSurface;

    return CyberScaffold(
      enableBack: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StealthInput(
                        label: "Full Name",
                        icon: PhosphorIconsRegular.user,
                        controller: _nameController,
                        focusNode: _nameFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_emailFocus),
                      ),
                      const SizedBox(height: 16),
                      StealthInput(
                        label: "Email",
                        icon: PhosphorIconsRegular.envelopeSimple,
                        controller: _emailController,
                        focusNode: _emailFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_passFocus),
                      ),
                      const SizedBox(height: 16),
                      StealthInput(
                        label: "Password (Min 8 chars)",
                        icon: PhosphorIconsRegular.lockKey,
                        controller: _passwordController,
                        isObscure: true,
                        focusNode: _passFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_confirmFocus),
                      ),
                      const SizedBox(height: 16),
                      StealthInput(
                        label: "Confirm Password",
                        icon: PhosphorIconsRegular.lockKeyOpen,
                        controller: _confirmController,
                        isObscure: true,
                        focusNode: _confirmFocus,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleSubmit(),
                      ),

                      const SizedBox(height: 24),

                      GestureDetector(
                        onTap: () {
                          setState(() => _acceptTerms = !_acceptTerms);
                          _validateForm();
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: txtColor.withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                                color: _acceptTerms
                                    ? txtColor
                                    : Colors.transparent,
                              ),
                              child: _acceptTerms
                                  ? Icon(
                                      Icons.check,
                                      size: 16,
                                      color: theme.scaffoldBackgroundColor,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'I accept the Terms & Privacy Policy',
                              style: TextStyle(
                                color: txtColor.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      PhysicsButton(
                        onPressed:
                            _isValid && !ref.watch(authProvider).isLoading
                            ? _handleSubmit
                            : null,
                        child: ref.watch(authProvider).isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: theme.scaffoldBackgroundColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Sign Up'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              TextButton(
                onPressed: () => context.go('/signin'),
                child: Text(
                  'Already have an account? Sign In',
                  style: TextStyle(color: txtColor.withValues(alpha: 0.6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
