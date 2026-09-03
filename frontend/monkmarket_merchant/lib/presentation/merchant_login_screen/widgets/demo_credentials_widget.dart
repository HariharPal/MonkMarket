import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class DemoCredentialsWidget extends StatelessWidget {
  const DemoCredentialsWidget({super.key});

  static const _email = 'merchant@monkmarket.in';
  static const _password = 'MonkMerchant2026!';

  void _copy(String value, String field) {
    Clipboard.setData(ClipboardData(text: value));
    Fluttertoast.showToast(
      msg: '$field copied to clipboard',
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Demo Credentials',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _credentialRow(
            theme,
            label: 'Email',
            value: _email,
            onCopy: () => _copy(_email, 'Email'),
          ),
          const SizedBox(height: 6),
          _credentialRow(
            theme,
            label: 'Password',
            value: _password,
            onCopy: () => _copy(_password, 'Password'),
          ),
        ],
      ),
    );
  }

  Widget _credentialRow(
    ThemeData theme, {
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        InkWell(
          onTap: onCopy,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.copy_rounded, size: 14, color: AppTheme.primary),
          ),
        ),
      ],
    );
  }
}
