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
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return CyberScaffold(
      title: "RECOVERY",
      body: Center(
        child: GlassCard(
          width: 400,
          child: _sent
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Check your email!',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    PhysicsButton(
                      onPressed: () => context.go('/signin'),
                      backgroundColor: Colors.white,
                      child: const Text(
                        'Back to Sign In',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Enter your email to receive a reset code.',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    StealthInput(
                      label: "Email",
                      icon: PhosphorIconsRegular.envelope,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 24),
                    PhysicsButton(
                      onPressed: () async {
                        await ref
                            .read(authProvider.notifier)
                            .forgotPassword(_emailController.text);
                        setState(() => _sent = true);
                      },
                      backgroundColor: Colors.white,
                      child: const Text(
                        'Send Reset Link',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
