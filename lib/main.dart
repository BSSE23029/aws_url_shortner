import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

// Theme & State
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/providers.dart';
import 'models/models.dart';

// Screens - Auth
import 'ui/screens/auth/sign_in_screen.dart';
import 'ui/screens/auth/sign_up_screen.dart';
import 'ui/screens/auth/mfa_screen.dart';
import 'ui/screens/auth/forgot_password_screen.dart';

// Screens - Dashboard
import 'ui/screens/dashboard/dashboard_screen.dart';
import 'ui/screens/dashboard/stats_screen.dart';

// Screens - URL Management
import 'ui/screens/url/create_url_screen.dart';
import 'ui/screens/url/url_details_screen.dart';
import 'ui/screens/url/all_urls_screen.dart';

// Screens - Settings & Error
import 'ui/screens/settings/appearance_screen.dart';
import 'ui/screens/profile/profile_screen.dart';
import 'ui/screens/error/waf_blocked_screen.dart';

// Widgets
import 'ui/widgets/stealth_rail.dart';

void main() {
  // Ensure Flutter is initialized before anything else
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: UrlShortenerApp()));
}

class UrlShortenerApp extends ConsumerWidget {
  const UrlShortenerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Rad Link',
      debugShowCheckedModeBanner: false,

      // Dynamic Theme Generation
      theme: AppTheme.generate(themeSettings, brightness: Brightness.light),
      darkTheme: AppTheme.generate(themeSettings, brightness: Brightness.dark),
      themeMode: themeSettings.mode,

      // Global Responsive Scaling
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 600, name: MOBILE),
          const Breakpoint(start: 601, end: 1100, name: TABLET),
          const Breakpoint(start: 1101, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),

      routerConfig: _router(ref),
    );
  }

  GoRouter _router(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/signin',
      routes: [
        // --- AUTHENTICATION ROUTES (Zero UI Shell) ---
        GoRoute(path: '/signin', builder: (_, __) => const SignInScreen()),
        GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
        GoRoute(path: '/mfa', builder: (_, __) => const MfaScreen()),
        GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const ForgotPasswordScreen(),
        ),

        // --- MAIN APPLICATION SHELL (With Stealth Rail) ---
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            final width = MediaQuery.of(context).size.width;
            final theme = Theme.of(context);

            return Scaffold(
              body: Row(
                children: [
                  // RAIL: Only visible on Tablet/Desktop
                  if (width > 600)
                    StealthRail(navigationShell: navigationShell),

                  // MAIN CONTENT
                  Expanded(child: navigationShell),
                ],
              ),

              // BOTTOM NAV: Only visible on Mobile
              bottomNavigationBar: width <= 600
                  ? BottomNavigationBar(
                      currentIndex: navigationShell.currentIndex,
                      onTap: (index) => navigationShell.goBranch(index),
                      selectedItemColor: theme.colorScheme.primary,
                      unselectedItemColor: theme.colorScheme.onSurface
                          .withValues(alpha: 0.4),
                      backgroundColor: theme.scaffoldBackgroundColor,
                      type: BottomNavigationBarType.fixed,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.dashboard_rounded),
                          label: 'Dash',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.analytics_rounded),
                          label: 'Stats',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.tune_rounded),
                          label: 'Prefs',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person_rounded),
                          label: 'Account',
                        ),
                      ],
                    )
                  : null,
            );
          },
          branches: [
            // Branch 0: Dashboard Overview
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/dashboard',
                  builder: (_, __) => const DashboardScreen(),
                ),
              ],
            ),
            // Branch 1: Stats / Analytics
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/dashboard/stats',
                  builder: (_, __) => const StatsScreen(),
                ),
              ],
            ),
            // Branch 2: Preferences (Settings Context)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings/preferences',
                  builder: (_, __) => const AppearanceScreen(),
                ),
              ],
            ),
            // Branch 3: Profile (Settings Context)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings/profile',
                  builder: (_, __) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),

        // --- GLOBAL OVERLAYS (Modal-style routes without sidebar) ---
        GoRoute(
          path: '/create-url',
          builder: (_, __) => const CreateUrlScreen(),
        ),
        GoRoute(path: '/all-urls', builder: (_, __) => const AllUrlsScreen()),
        GoRoute(
          path: '/waf-blocked',
          builder: (_, __) => const WafBlockedScreen(),
        ),
        GoRoute(
          path: '/url-details',
          builder: (context, state) {
            final url = state.extra as UrlModel?;
            return url != null
                ? UrlDetailsScreen(url: url)
                : const DashboardScreen();
          },
        ),
      ],

      // --- ROUTE GUARD (Authentication Control) ---
      redirect: (context, state) {
        final auth = ref.read(authProvider);
        final isAuth = auth.isAuthenticated;

        // Check if current destination is an Auth page
        final isAuthRoute =
            state.matchedLocation.startsWith('/signin') ||
            state.matchedLocation.startsWith('/signup') ||
            state.matchedLocation.startsWith('/mfa') ||
            state.matchedLocation.startsWith('/forgot-password');

        // Logic:
        // 1. If logged in and trying to access Signin -> Go to Dash
        if (isAuth && isAuthRoute) return '/dashboard';

        // 2. If not logged in and trying to access App -> Go to Signin
        if (!isAuth && !isAuthRoute) return '/signin';

        return null; // No redirection needed
      },
    );
  }
}
