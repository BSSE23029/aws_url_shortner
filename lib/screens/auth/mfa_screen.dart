import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';

class MfaScreen extends ConsumerStatefulWidget {
  const MfaScreen({super.key});

  @override
  ConsumerState<MfaScreen> createState() => _MfaScreenState();
}

class _MfaScreenState extends ConsumerState<MfaScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();

      ref.listenManual(authProvider, (previous, next) {
        // CASE 1: Successfully Authenticated (MFA done)
        if (next.isAuthenticated) {
          context.go('/dashboard');
        } 
        // CASE 2: Account Verified (Signup Confirmation done)
        else if (previous?.confirmationRequired == true && !next.confirmationRequired && next.errorMessage == null) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification successful! Please sign in.'), backgroundColor: AppTheme.success),
          );
          context.go('/signin');
        }
        // CASE 3: Error
        else if (next.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage!), backgroundColor: AppTheme.error),
          );
        }
      });
    });
  }

  Future<void> _handleVerify() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 6) return;

    final authState = ref.read(authProvider);

    if (authState.confirmationRequired) {
      // SIGN UP FLOW: Verify Email
      await ref.read(authProvider.notifier).confirmAccount(code);
    } else {
      // LOGIN FLOW: Verify MFA
      await ref.read(authProvider.notifier).verifyMfa(code);
    }
  }

  Future<void> _handleResendCode() async {
    await ref.read(authProvider.notifier).resendCode();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code resent if email is valid.'), backgroundColor: AppTheme.accentTeal),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check mode to change title
    final isSignupVerification = ref.watch(authProvider).confirmationRequired;

    return Scaffold(
      appBar: AppBar(title: Text(isSignupVerification ? 'Verify Email' : 'Two-Factor Authentication')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                children: [
                   Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppTheme.skyBlue, shape: BoxShape.circle),
                    child: Icon(Icons.mark_email_read, size: 64, color: AppTheme.accentTeal),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    isSignupVerification ? 'Verify Your Account' : 'Security Check',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the 6-digit code sent to ${ref.watch(authProvider).tempEmail ?? "your email"}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Input Fields (Keep existing logic for focus jumping)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50,
                        child: TextFormField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          decoration: InputDecoration(counterText: '', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                          onChanged: (value) {
                            if (value.length == 1 && index < 5) _focusNodes[index + 1].requestFocus();
                            if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
                            if (value.length == 1 && index == 5) _handleVerify();
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: ref.watch(authProvider).isLoading ? null : _handleVerify,
                      child: ref.watch(authProvider).isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Verify'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: _handleResendCode,
                    child: const Text('Resend Code'),
                  ),
                  
                  if (isSignupVerification)
                    TextButton(
                      onPressed: () => context.go('/signup'), // Go back to fix email if wrong
                      child: const Text('Change Email'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}