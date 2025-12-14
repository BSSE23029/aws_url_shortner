import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CyberScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool enableBack;

  const CyberScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.enableBack = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // FIX: Use theme color instead of hardcoded black
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: title != null || enableBack
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
              leading: enableBack && GoRouter.of(context).canPop()
                  ? IconButton(
                      icon: Icon(PhosphorIconsBold.caretLeft),
                      onPressed: () => context.pop(),
                    )
                  : null,
              title: title != null
                  ? Text(
                      title!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    )
                  : null,
              actions: actions,
            )
          : null,
      body: Stack(
        children: [
          // 1. Subtle Radial Gradient (Dynamic based on theme)
          Positioned(
            top: -300,
            left: 0,
            right: 0,
            height: 600,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 2. Content
          SafeArea(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
