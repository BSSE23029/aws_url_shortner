import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/physics_button.dart';
import '../../widgets/stealth_input.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../../providers/providers.dart';

class CreateUrlScreen extends ConsumerStatefulWidget {
  const CreateUrlScreen({super.key});

  @override
  ConsumerState<CreateUrlScreen> createState() => _CreateUrlScreenState();
}

class _CreateUrlScreenState extends ConsumerState<CreateUrlScreen> {
  final _urlController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _useCustomCode = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(urlsProvider.notifier)
        .createUrl(
          originalUrl: _urlController.text,
          customCode: _useCustomCode ? _codeController.text : null,
        );
    if (mounted && ref.read(urlsProvider).errorMessage == null) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txtColor = theme.colorScheme.onSurface;

    return CyberScaffold(
      title: "NEW DEPLOYMENT",
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: GlassCard(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      PhosphorIconsThin.rocketLaunch,
                      size: 64,
                      color: txtColor,
                    ),
                    const SizedBox(height: 32),
                    StealthInput(
                      label: "Target URL",
                      icon: PhosphorIconsRegular.link,
                      controller: _urlController,
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Switch(
                          value: _useCustomCode,
                          onChanged: (v) => setState(() => _useCustomCode = v),
                          activeColor: theme.scaffoldBackgroundColor,
                          activeTrackColor: txtColor,
                          inactiveThumbColor: txtColor.withValues(alpha: 0.5),
                          inactiveTrackColor: txtColor.withValues(alpha: 0.1),
                        ),
                        const SizedBox(width: 8),
                        Text("Custom Alias", style: TextStyle(color: txtColor)),
                      ],
                    ),
                    if (_useCustomCode) ...[
                      const SizedBox(height: 16),
                      StealthInput(
                        label: "Alias",
                        icon: PhosphorIconsRegular.tag,
                        controller: _codeController,
                      ),
                    ],
                    const SizedBox(height: 32),
                    PhysicsButton(
                      onPressed: ref.watch(urlsProvider).isLoading
                          ? null
                          : _submit,
                      child: ref.watch(urlsProvider).isLoading
                          ? CircularProgressIndicator(
                              color: theme.scaffoldBackgroundColor,
                            )
                          : const Text("INITIALIZE"),
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
