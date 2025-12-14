import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/physics_button.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../../providers/providers.dart';

class MfaScreen extends ConsumerStatefulWidget {
  const MfaScreen({super.key});

  @override
  ConsumerState<MfaScreen> createState() => _MfaScreenState();
}

class _MfaScreenState extends ConsumerState<MfaScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Future<void> _handleVerify() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 6) return;

    final authState = ref.read(authProvider);
    if (authState.confirmationRequired) {
      await ref.read(authProvider.notifier).confirmAccount(code);
    } else {
      await ref.read(authProvider.notifier).verifyMfa(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CyberScaffold(
      title: "SECURITY CHECK",
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                PhosphorIconsBold.shieldCheck,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              const Text(
                'Verification Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the code sent to your email',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 32),

              GlassCard(
                width: 400,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                        (index) => SizedBox(
                          width: 45,
                          height: 55,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLength: 1,
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              counterText: '',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (val) {
                              if (val.isNotEmpty && index < 5)
                                _focusNodes[index + 1].requestFocus();
                              if (val.isEmpty && index > 0)
                                _focusNodes[index - 1].requestFocus();
                              if (val.isNotEmpty && index == 5) _handleVerify();
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    PhysicsButton(
                      onPressed: ref.watch(authProvider).isLoading
                          ? null
                          : _handleVerify,
                      backgroundColor: Colors.white,
                      child: ref.watch(authProvider).isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'VERIFY',
                              style: TextStyle(color: Colors.black),
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () =>
                          ref.read(authProvider.notifier).resendCode(),
                      child: const Text(
                        'Resend Code',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
