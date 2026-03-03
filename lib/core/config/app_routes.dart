import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/phone_auth_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/expense/presentation/screens/add_expense_screen.dart';
import '../../features/expense/presentation/screens/edit_expense_screen.dart';
import '../../features/expense/presentation/screens/expense_detail_screen.dart';
import '../../features/home/presentation/screens/main_shell.dart';
import '../../features/invite/presentation/screens/invite_member_screen.dart';
import '../../features/invite/presentation/screens/manage_members_screen.dart';
import '../../features/khata/presentation/screens/create_khata_screen.dart';
import '../../features/khata/presentation/screens/khata_detail_screen.dart';
import '../../features/khata/presentation/screens/khata_settings_screen.dart';
import '../../features/notification/presentation/screens/notifications_screen.dart';
import '../../features/settings/presentation/screens/edit_profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

class AppRoutes {
  AppRoutes._();

  // Auth
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String phoneAuth = '/phone-auth';
  static const String forgotPassword = '/forgot-password';

  // Main (bottom nav shell)
  static const String dashboard = '/dashboard';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  // Khata
  static const String createKhata = '/khata/create';
  static const String khataDetail = '/khata/:accountId';
  static const String khataSettings = '/khata/:accountId/settings';

  // Expenses
  static const String addExpense = '/khata/:accountId/expense/add';
  static const String expenseDetail = '/khata/:accountId/expense/:expenseId';
  static const String editExpense =
      '/khata/:accountId/expense/:expenseId/edit';

  // Members / Invite
  static const String manageMembers = '/khata/:accountId/members';
  static const String inviteMember = '/khata/:accountId/invite';

  // Chat
  static const String khataChat = '/khata/:accountId/chat';

  // Profile
  static const String editProfile = '/settings/profile';

  static const Set<String> _authRoutes = {
    splash,
    welcome,
    login,
    register,
    phoneAuth,
    forgotPassword,
  };
}

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static int _getIndexForPath(String path) {
    if (path.startsWith('/dashboard')) return 0;
    if (path.startsWith('/notifications')) return 1;
    if (path.startsWith('/settings')) return 2;
    return 0;
  }

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final status = authProvider.status;
        final path = state.uri.path;

        // Allow splash
        if (path == AppRoutes.splash) return null;

        // Redirect unauthenticated users to welcome
        if (status == AuthStatus.unauthenticated) {
          if (!AppRoutes._authRoutes.contains(path)) {
            return AppRoutes.welcome;
          }
          return null;
        }

        // Redirect authenticated users away from auth routes
        if (status == AuthStatus.authenticated) {
          if (AppRoutes._authRoutes.contains(path)) {
            return AppRoutes.dashboard;
          }
          return null;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          name: 'welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.phoneAuth,
          name: 'phoneAuth',
          builder: (context, state) => const PhoneAuthScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // Main Shell
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return MainShell(
              currentIndex: _getIndexForPath(state.uri.path),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              name: 'dashboard',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: DashboardScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.notifications,
              name: 'notifications',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: NotificationsScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.settings,
              name: 'settings',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SettingsScreen(),
              ),
            ),
          ],
        ),

        // Khata routes
        GoRoute(
          path: AppRoutes.createKhata,
          name: 'createKhata',
          builder: (context, state) => const CreateKhataScreen(),
        ),
        GoRoute(
          path: AppRoutes.khataDetail,
          name: 'khataDetail',
          builder: (context, state) {
            final accountId = state.pathParameters['accountId']!;
            return KhataDetailScreen(accountId: accountId);
          },
        ),
        GoRoute(
          path: AppRoutes.khataSettings,
          name: 'khataSettings',
          builder: (context, state) {
            final accountId = state.pathParameters['accountId']!;
            return KhataSettingsScreen(accountId: accountId);
          },
        ),

        // Expense routes
        GoRoute(
          path: AppRoutes.addExpense,
          name: 'addExpense',
          builder: (context, state) {
            final accountId = state.pathParameters['accountId']!;
            return AddExpenseScreen(accountId: accountId);
          },
        ),
        GoRoute(
          path: AppRoutes.expenseDetail,
          name: 'expenseDetail',
          builder: (context, state) {
            final accountId = state.pathParameters['accountId']!;
            final expenseId = state.pathParameters['expenseId']!;
            return ExpenseDetailScreen(
                accountId: accountId, expenseId: expenseId);
          },
        ),
        GoRoute(
          path: AppRoutes.editExpense,
          name: 'editExpense',
          builder: (context, state) {
            final accountId = state.pathParameters['accountId']!;
            final expenseId = state.pathParameters['expenseId']!;
            return EditExpenseScreen(
                accountId: accountId, expenseId: expenseId);
          },
        ),

        // Members / Invite
        GoRoute(
          path: AppRoutes.manageMembers,
          name: 'manageMembers',
          builder: (context, state) {
            final accountId = state.pathParameters['accountId']!;
            return ManageMembersScreen(accountId: accountId);
          },
        ),
        GoRoute(
          path: AppRoutes.inviteMember,
          name: 'inviteMember',
          builder: (context, state) {
            final accountId = state.pathParameters['accountId']!;
            return InviteMemberScreen(accountId: accountId);
          },
        ),

        // Chat
        GoRoute(
          path: AppRoutes.khataChat,
          name: 'khataChat',
          builder: (context, state) {
            final accountId = state.pathParameters['accountId']!;
            return ChatScreen(accountId: accountId);
          },
        ),

        // Profile
        GoRoute(
          path: AppRoutes.editProfile,
          name: 'editProfile',
          builder: (context, state) => const EditProfileScreen(),
        ),
      ],

      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page not found: ${state.uri.path}'),
            ],
          ),
        ),
      ),
    );
  }
}
