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
    return Scaffold(
      backgroundColor: Colors.black, // Pure black background
      extendBodyBehindAppBar: true,
      appBar: title != null || enableBack
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
              leading: enableBack && GoRouter.of(context).canPop()
                  ? IconButton(
                      icon: Icon(PhosphorIconsRegular.caretLeft),
                      onPressed: () => context.pop(),
                    )
                  : null,
              title: title != null
                  ? Text(
                      title!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    )
                  : null,
              actions: actions,
            )
          : null,
      body: Stack(
        children: [
          // 1. Subtle Radial Gradient (Optional spotlight effect at top center)
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
                    Colors.white.withOpacity(0.08), // Very subtle spotlight
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
