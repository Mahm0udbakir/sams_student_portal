import 'package:flutter/material.dart';

import '../ui/sams_ui_tokens.dart';
import 'sams_logo_title.dart';

class SamsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SamsAppBar({
    super.key,
    required this.title,
    this.showLogo = true,
    this.forceShowBackButton = false,
    this.actions,
  });

  final String title;
  final bool showLogo;
  final bool forceShowBackButton;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final showBackButton = forceShowBackButton || canPop;

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      toolbarHeight: 68,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      leadingWidth: 56,
      leading: showBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
                child: BackButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  color: Colors.white,
                ),
              ),
            )
          : null,
      title: showLogo
          ? SamsLogoTitle(
              title: title,
              logoSize: 22,
              fallbackIconColor: Colors.white,
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            )
          : Text(title),
      actions: actions,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [SamsUiTokens.primary, Color(0xFF0A4D78)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x2A001728),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}
