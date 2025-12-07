import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'providers/providers.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/mfa_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/url/create_url_screen.dart';
import 'screens/url/url_details_screen.dart';
import 'screens/url/all_urls_screen.dart';
import 'screens/error/waf_blocked_screen.dart';
import 'models/models.dart';

void main() {
  runApp(const ProviderScope(child: UrlShortenerApp()));
}

class UrlShortenerApp extends ConsumerWidget {
  const UrlShortenerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = _createRouter(ref);
    
    return MaterialApp.router(
      title: 'AWS URL Shortener',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }

  GoRouter _createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/signin',
      routes: [
        GoRoute(
          path: '/signin',
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/mfa',
          builder: (context, state) => const MfaScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/create-url',
          builder: (context, state) => const CreateUrlScreen(),
        ),
        GoRoute(
          path: '/all-urls',
          builder: (context, state) => const AllUrlsScreen(),
        ),
        GoRoute(
          path: '/url-details',
          builder: (context, state) {
            final url = state.extra as UrlModel?;
            if (url == null) {
              return const DashboardScreen();
            }
            return UrlDetailsScreen(url: url);
          },
        ),
        GoRoute(
          path: '/waf-blocked',
          builder: (context, state) => const WafBlockedScreen(),
        ),
      ],
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        final isAuthenticated = authState.isAuthenticated;
        final isOnAuthPage = state.matchedLocation == '/signin' ||
            state.matchedLocation == '/signup' ||
            state.matchedLocation == '/mfa' ||
            state.matchedLocation == '/forgot-password';

        // Redirect to dashboard if authenticated and on auth page
        if (isAuthenticated && isOnAuthPage) {
          return '/dashboard';
        }

        // Redirect to signin if not authenticated and not on auth page
        if (!isAuthenticated && !isOnAuthPage) {
          return '/signin';
        }

        return null; // No redirect needed
      },
    );
  }
}


