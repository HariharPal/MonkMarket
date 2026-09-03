import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../features/dashboard/models/activity_event.dart';
import '../../../features/dashboard/viewmodels/dashboard_viewmodel.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_skeleton_widget.dart';

class RecentActivityWidget extends ConsumerWidget {
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(recentActivityProvider);

    return Container(
      decoration: AppTheme.elevatedCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View all',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Activity list
          activityAsync.when(
            loading: () => Column(
              children: List.generate(5, (i) => const SkeletonActivityItem()),
            ),
            error: (e, _) => _buildError(context, ref),
            data: (events) {
              if (events.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: EmptyStateWidget(
                    icon: Icons.history_rounded,
                    title: 'No activity yet',
                    message:
                        'Store activity will appear here once operations begin.',
                  ),
                );
              }
              return Column(
                children: [
                  ...events.take(10).toList().asMap().entries.map((entry) {
                    return _ActivityItemWidget(
                      event: entry.value,
                      isLast: entry.key == events.take(10).length - 1,
                    );
                  }),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Couldn\'t load recent activity. Pull down to retry.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItemWidget extends StatelessWidget {
  final ActivityEvent event;
  final bool isLast;

  const _ActivityItemWidget({required this.event, required this.isLast});

  _ActivityStyle _resolveStyle() {
    switch (event.source) {
      case ActivityEventSource.payment:
        return _ActivityStyle(
          iconBg: const Color(0xFFDCEAFE),
          iconColor: AppTheme.info,
          icon: Icons.payments_rounded,
        );
      case ActivityEventSource.order:
        return _ActivityStyle(
          iconBg: AppTheme.primaryContainer,
          iconColor: AppTheme.primary,
          icon: Icons.receipt_long_rounded,
        );
      case ActivityEventSource.agent:
        return _ActivityStyle(
          iconBg: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF7C3AED),
          icon: Icons.smart_toy_rounded,
        );
      case ActivityEventSource.guardrail:
        return _ActivityStyle(
          iconBg: AppTheme.warningContainer,
          iconColor: AppTheme.warning,
          icon: Icons.shield_rounded,
        );
      case ActivityEventSource.product:
        return _ActivityStyle(
          iconBg: AppTheme.successContainer,
          iconColor: AppTheme.success,
          icon: Icons.inventory_2_rounded,
        );
      case ActivityEventSource.webhook:
        return _ActivityStyle(
          iconBg: const Color(0xFFE0F2FE),
          iconColor: const Color(0xFF0369A1),
          icon: Icons.webhook_rounded,
        );
      case ActivityEventSource.commerce:
        return _ActivityStyle(
          iconBg: AppTheme.secondaryContainer,
          iconColor: AppTheme.secondary,
          icon: Icons.store_rounded,
        );
      case ActivityEventSource.unknown:
        return _ActivityStyle(
          iconBg: const Color(0xFFF3F4F6),
          iconColor: Colors.grey,
          icon: Icons.circle_outlined,
        );
    }
  }

  Color _outcomeColor() {
    switch (event.outcome) {
      case ActivityEventOutcome.success:
        return AppTheme.success;
      case ActivityEventOutcome.failure:
        return AppTheme.error;
      case ActivityEventOutcome.warning:
        return AppTheme.warning;
      case ActivityEventOutcome.info:
        return AppTheme.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _resolveStyle();
    final outcomeColor = _outcomeColor();

    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: style.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(style.icon, color: style.iconColor, size: 20),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.operation,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: outcomeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            event.source.name.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: style.iconColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                          if (event.orderId != null) ...[
                            Text(
                              ' · ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            Text(
                              '#${event.orderId!.length > 8 ? event.orderId!.substring(0, 8) : event.orderId!}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Timestamp
                Text(
                  _formatTimestamp(event.timestamp),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 68,
            endIndent: 16,
            color: theme.colorScheme.outlineVariant,
          ),
      ],
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(dt);
  }
}

class _ActivityStyle {
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  const _ActivityStyle({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
  });
}
