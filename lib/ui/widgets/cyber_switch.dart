import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// A standardized switch tile widget with consistent styling across the app.
/// Follows the same design patterns as PhysicsButton for UI coherence.
class CyberSwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CyberSwitch({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txtColor = theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: txtColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: txtColor.withValues(alpha: 0.7),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: txtColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: txtColor.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Switch
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: txtColor,
                inactiveThumbColor: txtColor.withValues(alpha: 0.3),
                inactiveTrackColor: txtColor.withValues(alpha: 0.1),
                activeTrackColor: txtColor.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
