import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum MerchantStatus {
  paid,
  pending,
  failed,
  cancelled,
  active,
  paused,
  aiAssisted,
  blocked,
  success,
  warning,
  info,
}

class StatusBadgeWidget extends StatelessWidget {
  final String label;
  final MerchantStatus status;
  final bool compact;

  const StatusBadgeWidget({
    required this.label,
    required this.status,
    this.compact = false,
    super.key,
  });

  _StatusStyle _resolve(BuildContext context) {
    switch (status) {
      case MerchantStatus.paid:
      case MerchantStatus.active:
      case MerchantStatus.success:
        return _StatusStyle(
          bg: const Color(0xFFDCF0E5),
          fg: const Color(0xFF1A6B3A),
          icon: Icons.check_circle_rounded,
        );
      case MerchantStatus.pending:
      case MerchantStatus.info:
        return _StatusStyle(
          bg: const Color(0xFFDCEAFE),
          fg: const Color(0xFF1D4ED8),
          icon: Icons.schedule_rounded,
        );
      case MerchantStatus.failed:
      case MerchantStatus.cancelled:
        return _StatusStyle(
          bg: const Color(0xFFFEE2E2),
          fg: const Color(0xFFB91C1C),
          icon: Icons.cancel_rounded,
        );
      case MerchantStatus.paused:
      case MerchantStatus.warning:
        return _StatusStyle(
          bg: const Color(0xFFFEF3C7),
          fg: const Color(0xFFB45309),
          icon: Icons.pause_circle_rounded,
        );
      case MerchantStatus.aiAssisted:
        return _StatusStyle(
          bg: const Color(0xFFF3E8FF),
          fg: const Color(0xFF7C3AED),
          icon: Icons.smart_toy_rounded,
        );
      case MerchantStatus.blocked:
        return _StatusStyle(
          bg: const Color(0xFFFFF7ED),
          fg: const Color(0xFFEA580C),
          icon: Icons.shield_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolve(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: compact ? 10 : 12, color: style.fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: style.fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  final Color bg;
  final Color fg;
  final IconData icon;
  const _StatusStyle({required this.bg, required this.fg, required this.icon});
}
