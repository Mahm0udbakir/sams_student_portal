import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
  Size get preferredSize => const Size.fromHeight(58);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final showBackButton = forceShowBackButton || canPop;

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      toolbarHeight: 58,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      leadingWidth: 66,
      leading: showBackButton
          ? CupertinoNavigationBarBackButton(
              onPressed: () => Navigator.of(context).maybePop(),
              color: Colors.white,
              previousPageTitle: '',
            )
          : null,
      title: showLogo
          ? SamsLogoTitle(
              title: title,
              logoSize: 20,
              fallbackIconColor: Colors.white,
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
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
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
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
