import 'package:flutter/material.dart';

/// Responsive utility for adaptive layouts
class Responsive {
  final BuildContext context;

  Responsive(this.context);

  /// Screen width
  double get width => MediaQuery.of(context).size.width;

  /// Screen height
  double get height => MediaQuery.of(context).size.height;

  /// Check if mobile (< 600px)
  bool get isMobile => width < 600;

  /// Check if tablet (600px - 1024px)
  bool get isTablet => width >= 600 && width < 1024;

  /// Check if desktop (>= 1024px)
  bool get isDesktop => width >= 1024;

  /// Check if web (desktop or large tablet)
  bool get isWeb => width >= 900;

  /// Responsive padding
  EdgeInsets get pagePadding {
    if (isMobile) return const EdgeInsets.all(16);
    if (isTablet) return const EdgeInsets.all(24);
    return const EdgeInsets.all(32);
  }

  /// Responsive card padding
  EdgeInsets get cardPadding {
    if (isMobile) return const EdgeInsets.all(12);
    if (isTablet) return const EdgeInsets.all(16);
    return const EdgeInsets.all(20);
  }

  /// Responsive spacing
  double get spacing {
    if (isMobile) return 12;
    if (isTablet) return 16;
    return 20;
  }

  /// Responsive font scale
  double get fontScale {
    if (isMobile) return 0.9;
    if (isTablet) return 1.0;
    return 1.1;
  }

  /// Max content width for web
  double get maxContentWidth {
    if (isDesktop) return 1200;
    if (isTablet) return 800;
    return double.infinity;
  }

  /// Responsive icon size
  double get iconSize {
    if (isMobile) return 20;
    if (isTablet) return 24;
    return 28;
  }

  /// Responsive button height
  double get buttonHeight {
    if (isMobile) return 48;
    if (isTablet) return 52;
    return 56;
  }

  /// Get responsive value
  T valueWhen<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Responsive responsive) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    return builder(context, responsive);
  }
}

/// Responsive layout with optional different widgets per breakpoint
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    if (responsive.isDesktop && desktop != null) {
      return desktop!;
    }

    if (responsive.isTablet && tablet != null) {
      return tablet!;
    }

    return mobile;
  }
}

/// Center content with max width for web
class CenteredWebContent extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const CenteredWebContent({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? responsive.maxContentWidth,
        ),
        child: child,
      ),
    );
  }
}
