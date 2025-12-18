import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/providers.dart';
import 'models/models.dart';

import 'ui/screens/auth/sign_in_screen.dart';
import 'ui/screens/auth/sign_up_screen.dart';
import 'ui/screens/auth/mfa_screen.dart';
import 'ui/screens/auth/forgot_password_screen.dart';
import 'ui/screens/dashboard/dashboard_screen.dart';
import 'ui/screens/dashboard/stats_screen.dart';
import 'ui/screens/url/create_url_screen.dart';
import 'ui/screens/url/url_details_screen.dart';
import 'ui/screens/settings/appearance_screen.dart';
import 'ui/screens/profile/profile_screen.dart';
import 'ui/widgets/stealth_rail.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/signin',
    refreshListenable: _AuthListenable(ref),
    routes: [
      GoRoute(
        path: '/signin',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignInScreen(),
          transitionsBuilder: (context, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignUpScreen(),
          transitionsBuilder: (context, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      ),
      GoRoute(path: '/mfa', builder: (context, state) => const MfaScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final width = MediaQuery.of(context).size.width;
          return Scaffold(
            body: Row(
              children: [
                if (width > 600) StealthRail(navigationShell: navigationShell),
                Expanded(child: navigationShell),
              ],
            ),
            bottomNavigationBar: width <= 600
                ? BottomNavigationBar(
                    currentIndex: navigationShell.currentIndex,
                    onTap: (index) => navigationShell.goBranch(index),
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
                        label: 'User',
                      ),
                    ],
                  )
                : null,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard/stats',
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings/preferences',
                builder: (context, state) => const AppearanceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/url-details',
        builder: (context, state) =>
            UrlDetailsScreen(url: state.extra as UrlModel),
      ),
      GoRoute(
        path: '/create-url',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CreateUrlScreen(),
          transitionsBuilder: (context, anim, _, child) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(scale: anim, child: child),
          ),
        ),
      ),
    ],
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      if (!auth.isInitialized) return null;

      final isAuth = auth.isAuthenticated;
      final path = state.matchedLocation;
      final isAuthPath =
          path == '/signin' ||
          path == '/signup' ||
          path == '/mfa' ||
          path == '/forgot-password';

      if (!isAuth && !isAuthPath) return '/signin';
      if (isAuth && isAuthPath) return '/dashboard';
      if (auth.confirmationRequired && path != '/mfa') return '/mfa';

      return null;
    },
  );
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: UrlShortenerApp()));
}

class UrlShortenerApp extends ConsumerWidget {
  const UrlShortenerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    final authState = ref.watch(
      authStateProvider,
    ); // Accessing auth state specifically
    final router = ref.watch(routerProvider);

    if (!authState.isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.generate(themeSettings, brightness: Brightness.dark),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return MaterialApp.router(
      title: 'Rad Link',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.generate(themeSettings, brightness: Brightness.light),
      darkTheme: AppTheme.generate(themeSettings, brightness: Brightness.dark),
      themeMode: themeSettings.mode,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 600, name: MOBILE),
          const Breakpoint(start: 601, end: 1100, name: TABLET),
          const Breakpoint(start: 1101, end: double.infinity, name: DESKTOP),
        ],
      ),
      routerConfig: router,
    );
  }
}

class _AuthListenable extends ChangeNotifier {
  final Ref ref;
  bool? _lastLogin;
  _AuthListenable(this.ref) {
    ref.listen<AuthState>(authProvider, (_, next) {
      if (_lastLogin != next.isAuthenticated) {
        _lastLogin = next.isAuthenticated;
        notifyListeners();
      }
    });
  }
}
