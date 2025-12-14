import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/physics_button.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../widgets/stealth_input.dart';
import '../../../providers/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final txtColor = Theme.of(context).colorScheme.onSurface;

    return CyberScaffold(
      title: "IDENTITY",
      actions: [
        IconButton(
          icon: Icon(PhosphorIconsRegular.signOut, color: Colors.redAccent),
          onPressed: () {
            ref.read(authProvider.notifier).signOut();
            context.go('/signin');
          },
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ID Card
            GlassCard(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: txtColor, width: 2),
                    ),
                    child: Icon(
                      PhosphorIconsBold.user,
                      size: 40,
                      color: txtColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? "Unknown User",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: txtColor,
                    ),
                  ),
                  Text(
                    user?.email ?? "No Email",
                    style: TextStyle(color: txtColor.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 24),
                  _buildReadOnlyField("User ID", user?.id ?? "---", txtColor),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(
                    "Created At",
                    user?.createdAt.toIso8601String().split('T')[0] ?? "---",
                    txtColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Security Settings
            GlassCard(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      PhosphorIconsRegular.lockKey,
                      color: txtColor,
                    ),
                    title: Text(
                      "Change Password",
                      style: TextStyle(color: txtColor),
                    ),
                    trailing: Icon(
                      PhosphorIconsRegular.caretRight,
                      color: txtColor.withValues(alpha: 0.5),
                    ),
                    onTap: () {
                      // Trigger password change flow (Future implementation)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Feature coming soon")),
                      );
                    },
                  ),
                  Divider(height: 1, color: txtColor.withValues(alpha: 0.1)),
                  ListTile(
                    leading: Icon(
                      PhosphorIconsRegular.shieldCheck,
                      color: txtColor,
                    ),
                    title: Text(
                      "MFA Settings",
                      style: TextStyle(color: txtColor),
                    ),
                    subtitle: Text(
                      user?.mfaEnabled == true ? "Enabled" : "Disabled",
                      style: TextStyle(
                        color: txtColor.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    trailing: Icon(
                      PhosphorIconsRegular.caretRight,
                      color: txtColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: color, fontFamily: 'Courier'),
          ),
        ],
      ),
    );
  }
}
