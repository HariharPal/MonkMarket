// V1 — M3 Large AppBar: SliverAppBar collapse + scrolledUnderElevation — LOCKED
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MerchantAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;

  const MerchantAppBar({
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.bottom,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: theme.colorScheme.outline.withAlpha(102),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            )
          : leading,
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

class MerchantSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool pinned;
  final bool floating;

  const MerchantSliverAppBar({
    required this.title,
    this.actions,
    this.pinned = true,
    this.floating = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar.large(
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: theme.colorScheme.outline.withAlpha(102),
      pinned: pinned,
      floating: floating,
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
      actions: actions,
    );
  }
}
