import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../settings/viewmodels/settings_viewmodel.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final settingsState = ref.watch(settingsViewModelProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = authState.user;

    final displayName = user?.email.isNotEmpty == true ? user!.email : 'User';

    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        initial,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName, style: theme.textTheme.titleLarge),

                          const SizedBox(height: 4),

                          if (user?.email.isNotEmpty == true)
                            Text(
                              user!.email,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),

                          if (user?.role.isNotEmpty == true)
                            const SizedBox(height: 4),

                          if (user?.role.isNotEmpty == true)
                            Text(
                              user!.role,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text('Appearance', style: theme.textTheme.titleMedium),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  _ThemeOption(
                    label: 'System Default',
                    icon: Icons.brightness_auto_rounded,
                    isSelected: settingsState.themeMode == ThemeMode.system,
                    onTap: () => ref
                        .read(settingsViewModelProvider.notifier)
                        .setThemeMode(ThemeMode.system),
                  ),

                  const Divider(height: 1),

                  _ThemeOption(
                    label: 'Light Mode',
                    icon: Icons.light_mode_rounded,
                    isSelected: settingsState.themeMode == ThemeMode.light,
                    onTap: () => ref
                        .read(settingsViewModelProvider.notifier)
                        .setThemeMode(ThemeMode.light),
                  ),

                  const Divider(height: 1),

                  _ThemeOption(
                    label: 'Dark Mode',
                    icon: Icons.dark_mode_rounded,
                    isSelected: settingsState.themeMode == ThemeMode.dark,
                    onTap: () => ref
                        .read(settingsViewModelProvider.notifier)
                        .setThemeMode(ThemeMode.dark),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text('Quick Access', style: theme.textTheme.titleMedium),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  _NavTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Chat with Sahayak',
                    onTap: () => context.go('/chat'),
                  ),

                  const Divider(height: 1),

                  _NavTile(
                    icon: Icons.shopping_cart_outlined,
                    label: 'My Cart',
                    onTap: () => context.go('/cart'),
                  ),

                  const Divider(height: 1),

                  _NavTile(
                    icon: Icons.receipt_long_outlined,
                    label: 'My Orders',
                    onTap: () => context.go('/orders'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authViewModelProvider.notifier).logout();

                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                icon: Icon(Icons.logout_rounded, color: colorScheme.error),
                label: Text(
                  'Sign Out',
                  style: TextStyle(color: colorScheme.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.error),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(label),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
