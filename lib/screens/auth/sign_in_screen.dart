import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../utils/responsive.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Future<void> _handleSignIn() async {
  //   if (_formKey.currentState!.validate()) {
  //     await ref
  //         .read(authProvider.notifier)
  //         .signIn(_emailController.text, _passwordController.text);
  //   }
  // }
  Future<void> _handleSignIn() async {
  if (_formKey.currentState!.validate()) {
    await ref
        .read(authProvider.notifier)
        .signIn(_emailController.text, _passwordController.text);
  }
}



  @override
  void initState() {
    super.initState();
    // Listen to auth state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(authProvider, (previous, next) {
        if (next.requiresMfa) {
          context.go('/mfa');
        } else if (next.isAuthenticated) {
          context.go('/dashboard');
        } else if (next.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, responsive) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: responsive.pagePadding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: responsive.valueWhen(
                      mobile: 400,
                      tablet: 450,
                      desktop: 500,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo / Brand
                        Icon(
                          Icons.link,
                          size: responsive.valueWhen(
                            mobile: 48,
                            tablet: 56,
                            desktop: 64,
                          ),
                          color: AppTheme.accentTeal,
                        ),
                        SizedBox(height: responsive.spacing),
                        Text(
                          'URL Shortener',
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                fontSize: responsive.valueWhen(
                                  mobile: 28,
                                  tablet: 32,
                                  desktop: 36,
                                ),
                              ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: responsive.spacing * 0.5),
                        Text(
                          'Serverless. Secure. Scalable.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.push('/forgot-password');
                            },
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Sign In Button
                        ElevatedButton(
                          onPressed: ref.watch(authProvider).isLoading
                              ? null
                              : _handleSignIn,
                          child: ref.watch(authProvider).isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Sign In'),
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'OR',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () {
                                context.push('/signup');
                              },
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),

                        // Security Badge
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Protected by AWS WAF & Cognito',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
