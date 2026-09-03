import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/merchant_login_screen/merchant_login_screen.dart';
import '../widgets/app_scaffold.dart';

import '../presentation/audit_screen/audit_screen.dart';
import '../presentation/audit_user_screen/audit_user_screen.dart';
import '../presentation/audit_session_screen/audit_session_screen.dart';
import '../presentation/products_screen/products_screen.dart';
import '../presentation/product_detail_screen/product_detail_screen.dart';
import '../presentation/product_form_screen/product_form_screen.dart';
import '../presentation/orders_screen/orders_screen.dart';
import '../presentation/order_detail_screen/order_detail_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String root = '/';
  static const String dashboardScreen = '/dashboard';
  static const String auditScreen = '/audit';
  static const String merchantLoginScreen = '/merchant-login-screen';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.dashboardScreen,

  routes: [
    GoRoute(
      path: AppRoutes.root,
      redirect: (_, __) => AppRoutes.dashboardScreen,
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboardScreen,
              pageBuilder: (context, state) {
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: const DashboardScreen(),
                  transitionDuration: const Duration(milliseconds: 280),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                          child: child,
                        );
                      },
                );
              },
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) {
                return const OrdersScreen();
              },
              routes: [
                GoRoute(
                  path: ':orderId',
                  builder: (context, state) {
                    final orderId = state.pathParameters['orderId']!;

                    return OrderDetailScreen(orderId: orderId);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/products',
              builder: (context, state) {
                return const ProductsScreen();
              },
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (context, state) {
                    return const ProductFormScreen(
                      mode: ProductFormMode.create,
                    );
                  },
                ),

                GoRoute(
                  path: ':productId',
                  builder: (context, state) {
                    final productId = state.pathParameters['productId']!;

                    return ProductDetailScreen(productId: productId);
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) {
                        final productId = state.pathParameters['productId']!;

                        return ProductFormScreen(
                          mode: ProductFormMode.edit,
                          productId: productId,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/audit',
              builder: (context, state) {
                return const AuditScreen();
              },
              routes: [
                GoRoute(
                  path: 'user/:userId',
                  builder: (context, state) {
                    final userId = state.pathParameters['userId']!;

                    return AuditUserScreen(userId: userId);
                  },
                  routes: [
                    GoRoute(
                      path: 'session/:sessionId',
                      builder: (context, state) {
                        final sessionId = state.pathParameters['sessionId']!;

                        return AuditSessionScreen(sessionId: sessionId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: AppRoutes.merchantLoginScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const MerchantLoginScreen(),
          transitionDuration: const Duration(milliseconds: 280),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );
      },
    ),
  ],
);
