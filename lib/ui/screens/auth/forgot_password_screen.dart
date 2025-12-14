import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/physics_button.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../widgets/stealth_input.dart';
import '../../../providers/providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  bool _isValid = false;
  bool _sent = false;

  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    super.initState();
    // Listen for changes to enable/disable button
    _emailController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid = _emailRegex.hasMatch(_emailController.text.trim());
    if (_isValid != isValid) {
      setState(() => _isValid = isValid);
    }
  }

  Future<void> _handleReset() async {
    if (_isValid) {
      // Dismiss keyboard
      FocusManager.instance.primaryFocus?.unfocus();

      final success = await ref
          .read(authProvider.notifier)
          .forgotPassword(_emailController.text.trim());
      if (success && mounted) {
        setState(() => _sent = true);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txtColor = theme.colorScheme.onSurface;

    return CyberScaffold(
      enableBack: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Recovery',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: txtColor,
                ),
              ),
              const SizedBox(height: 40),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: GlassCard(
                  width: double.infinity,
                  child: _sent
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Check your email!',
                              style: TextStyle(
                                color: txtColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            PhysicsButton(
                              onPressed: () => context.go('/signin'),
                              backgroundColor: txtColor,
                              child: Text(
                                'Back to Sign In',
                                style: TextStyle(
                                  color: theme.scaffoldBackgroundColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Enter your email to receive a reset code.',
                              style: TextStyle(
                                color: txtColor.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            StealthInput(
                              label: "Email",
                              icon: PhosphorIconsBold.envelope,
                              controller: _emailController,
                              focusNode: _emailFocus,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              // Submit when Enter is pressed
                              onSubmitted: (_) => _handleReset(),
                              validator: (v) => _emailRegex.hasMatch(v ?? '')
                                  ? null
                                  : 'Invalid email',
                            ),

                            const SizedBox(height: 32),

                            PhysicsButton(
                              // Disabled unless valid
                              onPressed:
                                  _isValid && !ref.watch(authProvider).isLoading
                                  ? _handleReset
                                  : null,
                              backgroundColor: txtColor,
                              child: ref.watch(authProvider).isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.scaffoldBackgroundColor,
                                      ),
                                    )
                                  : Text(
                                      'Send Reset Link',
                                      style: TextStyle(
                                        // color: theme.scaffoldBackgroundColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 32),

              TextButton(
                onPressed: () => context.go('/signin'),
                child: Text(
                  'Back to Sign In',
                  style: TextStyle(
                    color: txtColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
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
