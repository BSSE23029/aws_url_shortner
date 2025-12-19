import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/physics_button.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../widgets/stealth_input.dart';
import '../../widgets/cyber_feedback.dart';
import '../../../providers/providers.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isValid = false;
  bool _rememberMe = false;
  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final emailValid = _emailRegex.hasMatch(_emailController.text);
    final passValid = _passwordController.text.isNotEmpty;
    if (_isValid != (emailValid && passValid)) {
      setState(() => _isValid = emailValid && passValid);
    }
  }

  void _handleSubmit() {
    if (_isValid) {
      CyberFeedback.authStart(context);
      ref
          .read(authProvider.notifier)
          .signIn(
            _emailController.text.trim(),
            _passwordController.text,
            rememberMe: _rememberMe,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        CyberFeedback.authFailure(context);
      } else if (next.isAuthenticated &&
          !(previous?.isAuthenticated ?? false)) {
        CyberFeedback.authSuccess(context, next.user?.name ?? 'Operator');
      }
    });

    final theme = Theme.of(context);
    final txtColor = theme.colorScheme.onSurface;

    return CyberScaffold(
      enableBack: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: txtColor,
                ),
              ),
              const SizedBox(height: 40),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StealthInput(
                        label: "Email",
                        icon: PhosphorIconsBold.envelopeSimple,
                        controller: _emailController,
                        focusNode: _emailFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_passwordFocus),
                      ),
                      const SizedBox(height: 16),
                      StealthInput(
                        label: "Password",
                        icon: PhosphorIconsBold.lockKey,
                        isPassword: true,
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleSubmit(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (v) =>
                                  setState(() => _rememberMe = v ?? false),
                              activeColor: txtColor,
                              checkColor: theme.scaffoldBackgroundColor,
                              side: BorderSide(
                                color: txtColor.withOpacity(0.4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _rememberMe = !_rememberMe),
                            child: Text(
                              "Keep me signed in",
                              style: TextStyle(
                                color: txtColor.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            child: Text(
                              'Forgot?',
                              style: TextStyle(
                                color: txtColor.withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      PhysicsButton(
                        onPressed:
                            _isValid && !ref.watch(authProvider).isLoading
                            ? _handleSubmit
                            : null,
                        child: ref.watch(authProvider).isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Log In"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => context.push('/signup'),
                child: Text(
                  'Create an Account',
                  style: TextStyle(
                    color: txtColor.withOpacity(0.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
