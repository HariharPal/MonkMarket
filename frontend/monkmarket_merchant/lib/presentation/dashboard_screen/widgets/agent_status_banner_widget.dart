import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../features/dashboard/viewmodels/dashboard_viewmodel.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/loading_skeleton_widget.dart';

class AgentStatusBannerWidget extends ConsumerWidget {
  const AgentStatusBannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return summaryAsync.when(
      loading: () => const LoadingSkeletonWidget(
        width: double.infinity,
        height: 72,
        borderRadius: 16,
      ),
      error: (e, _) => const SizedBox.shrink(),
      data: (summary) => _buildBanner(context, summary.agentStatus),
    );
  }

  Widget _buildBanner(BuildContext context, String agentStatus) {
    final isActive = agentStatus.toUpperCase() == 'ACTIVE';
    final isPaused = agentStatus.toUpperCase() == 'PAUSED';

    Color bgColor;
    Color borderColor;
    Color iconColor;
    Color textColor;
    IconData icon;
    String statusLabel;
    String description;

    if (isActive) {
      bgColor = AppTheme.successContainer;
      borderColor = AppTheme.success.withAlpha(77);
      iconColor = AppTheme.success;
      textColor = AppTheme.success;
      icon = Icons.smart_toy_rounded;
      statusLabel = 'ACTIVE';
      description =
          'Sahayak AI agent is operational and handling customer queries.';
    } else if (isPaused) {
      bgColor = AppTheme.warningContainer;
      borderColor = AppTheme.warning.withAlpha(77);
      iconColor = AppTheme.warning;
      textColor = AppTheme.warning;
      icon = Icons.pause_circle_rounded;
      statusLabel = 'PAUSED';
      description =
          'Sahayak AI agent is paused. Customers cannot initiate AI-assisted shopping.';
    } else {
      bgColor = const Color(0xFFEEEEEE);
      borderColor = Colors.grey.withAlpha(77);
      iconColor = Colors.grey;
      textColor = Colors.grey.shade700;
      icon = Icons.help_outline_rounded;
      statusLabel = agentStatus;
      description = 'Agent status is currently unavailable.';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(38),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Sahayak Agent',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withAlpha(38),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isActive)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: iconColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Text(
                            statusLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: textColor.withAlpha(204),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: iconColor.withAlpha(153),
            size: 18,
          ),
        ],
      ),
    );
  }
}
