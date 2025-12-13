import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/physics_button.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../../providers/providers.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _acceptTerms = false;

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      await ref
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
    return CyberScaffold(
      // No app bar title, handled in body like screenshot
      enableBack: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title outside the card
              const Text(
                'Create Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w500, // Minimalist weight
                ),
              ),
              const SizedBox(height: 40),

              // The Main Card
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildStealthInput(
                          "Full Name",
                          PhosphorIconsRegular.user,
                          _nameController,
                        ),
                        const SizedBox(height: 16),
                        _buildStealthInput(
                          "Email",
                          PhosphorIconsRegular.envelopeSimple,
                          _emailController,
                        ),
                        const SizedBox(height: 16),
                        _buildStealthInput(
                          "Password",
                          PhosphorIconsRegular.lockKey,
                          _passwordController,
                          isObscure: true,
                        ),
                        const SizedBox(height: 16),
                        _buildStealthInput(
                          "Confirm Password",
                          PhosphorIconsRegular.lockKeyOpen,
                          _confirmController,
                          isObscure: true,
                        ),

                        const SizedBox(height: 24),

                        // Checkbox
                        GestureDetector(
                          onTap: () =>
                              setState(() => _acceptTerms = !_acceptTerms),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                  color: _acceptTerms
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                                child: _acceptTerms
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.black,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'I accept the Terms & Privacy Policy',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Main Button
                        PhysicsButton(
                          onPressed: ref.watch(authProvider).isLoading
                              ? null
                              : _handleSignUp,
                          backgroundColor: const Color(
                            0xFF222222,
                          ), // Dark charcoal
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
                                  'Sign Up',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Bottom Link
              TextButton(
                onPressed: () => context.go('/signin'),
                child: const Text(
                  'Already have an account? Sign In',
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStealthInput(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool isObscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7), size: 22),
        // The specific outline style from your screenshot
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        filled: false, // Transparent background inside input
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
      ),
      validator: (v) => v?.isEmpty == true ? 'Required' : null,
    );
  }
}
