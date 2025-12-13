import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/providers.dart';
import 'models/models.dart';

// Screen Imports
import 'ui/screens/auth/sign_in_screen.dart';
import 'ui/screens/auth/sign_up_screen.dart';
import 'ui/screens/auth/mfa_screen.dart';
import 'ui/screens/auth/forgot_password_screen.dart';
import 'ui/screens/dashboard/dashboard_screen.dart';
import 'ui/screens/url/create_url_screen.dart';
import 'ui/screens/url/url_details_screen.dart';
import 'ui/screens/url/all_urls_screen.dart';
import 'ui/screens/error/waf_blocked_screen.dart';
import 'ui/screens/settings/appearance_screen.dart';

void main() {
  runApp(const ProviderScope(child: UrlShortenerApp()));
}

class UrlShortenerApp extends ConsumerWidget {
  const UrlShortenerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch Theme Changes
    final themeSettings = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'AWS URL Shortener',
      debugShowCheckedModeBanner: false,

      // 1. Generate LIGHT version
      theme: AppTheme.generate(themeSettings, brightness: Brightness.light),

      // 2. Generate DARK version
      darkTheme: AppTheme.generate(themeSettings, brightness: Brightness.dark),

      // 3. Let settings decide (System, Light, or Dark)
      themeMode: themeSettings.mode,

      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
        ],
      ),
      routerConfig: _router(ref),
    );
  }

  GoRouter _router(WidgetRef ref) => GoRouter(
    initialLocation: '/signin',
    routes: [
      GoRoute(path: '/signin', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
      GoRoute(path: '/mfa', builder: (_, __) => const MfaScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/create-url', builder: (_, __) => const CreateUrlScreen()),
      GoRoute(path: '/all-urls', builder: (_, __) => const AllUrlsScreen()),
      GoRoute(
        path: '/appearance',
        builder: (_, __) => const AppearanceScreen(),
      ),
      GoRoute(
        path: '/waf-blocked',
        builder: (_, __) => const WafBlockedScreen(),
      ),
      GoRoute(
        path: '/url-details',
        builder: (_, state) {
          final url = state.extra as UrlModel?;
          return url != null
              ? UrlDetailsScreen(url: url)
              : const DashboardScreen();
        },
      ),
    ],
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final isAuth = auth.isAuthenticated;
      final isAuthRoute =
          state.matchedLocation.startsWith('/signin') ||
          state.matchedLocation.startsWith('/signup') ||
          state.matchedLocation.startsWith('/mfa') ||
          state.matchedLocation.startsWith('/forgot-password');

      if (isAuth && isAuthRoute) return '/dashboard';
      if (!isAuth && !isAuthRoute) return '/signin';
      return null;
    },
  );
}
