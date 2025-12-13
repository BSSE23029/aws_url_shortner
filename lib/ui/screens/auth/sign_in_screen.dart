import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/physics_button.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../widgets/stealth_input.dart';
import '../../../providers/providers.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(authProvider, (previous, next) {
        if (next.isAuthenticated) context.go('/dashboard');
        if (next.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CyberScaffold(
      enableBack: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        StealthInput(
                          label: "Email",
                          icon: PhosphorIconsRegular.envelopeSimple,
                          controller: _emailController,
                          validator: (v) =>
                              v?.contains('@') == true ? null : 'Invalid Email',
                        ),
                        const SizedBox(height: 16),
                        StealthInput(
                          label: "Password",
                          icon: PhosphorIconsRegular.lockKey,
                          isObscure: true,
                          controller: _passwordController,
                          validator: (v) =>
                              v?.isEmpty == true ? 'Required' : null,
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        PhysicsButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ref
                                  .read(authProvider.notifier)
                                  .signIn(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                            }
                          },
                          backgroundColor: const Color(0xFF222222),
                          child: ref.watch(authProvider).isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Log In",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              TextButton(
                onPressed: () => context.push('/signup'),
                child: const Text(
                  'Create an Account',
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
