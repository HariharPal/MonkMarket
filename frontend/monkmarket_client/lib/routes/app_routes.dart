import '../core/app_export.dart';
import '../features/auth/views/login_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String profile = '/profile';
  static const String checkout = '/checkout';
}

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.initial,
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);
