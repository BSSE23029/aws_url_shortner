import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txtColor = theme.colorScheme.onSurface;

    return CyberScaffold(
      title: "SECURITY CHECK",
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(PhosphorIconsBold.shieldCheck, size: 64, color: txtColor),
              const SizedBox(height: 24),
              Text(
                'Verification Required',
                style: TextStyle(
                  color: txtColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the code sent to your email',
                style: TextStyle(color: txtColor.withOpacity(0.6)),
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
                            style: TextStyle(
                              color: txtColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLength: 1,
                            decoration: InputDecoration(
                              counterText: '',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: txtColor.withOpacity(0.2),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: txtColor),
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
                      child: ref.watch(authProvider).isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('VERIFY'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () =>
                          ref.read(authProvider.notifier).resendCode(),
                      child: Text(
                        'Resend Code',
                        style: TextStyle(color: txtColor.withOpacity(0.6)),
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
