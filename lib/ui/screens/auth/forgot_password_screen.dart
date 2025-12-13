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
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return CyberScaffold(
      title: "RECOVERY",
      enableBack: true,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: GlassCard(
              width: double.infinity,
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                  : Form(
                      key: _formKey,
                      child: Column(
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
                            validator: (v) => v?.contains('@') == true
                                ? null
                                : 'Invalid email',
                          ),

                          const SizedBox(height: 32),

                          PhysicsButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final success = await ref
                                    .read(authProvider.notifier)
                                    .forgotPassword(_emailController.text);
                                if (success) setState(() => _sent = true);
                              }
                            },
                            backgroundColor: Colors.white,
                            child: ref.watch(authProvider).isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    'Send Reset Link',
                                    style: TextStyle(color: Colors.black),
                                  ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
