import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  static const Color _samsPrimary = SamsUiTokens.primary;
  late final AnimationController _tabSwitchController;

  @override
  void initState() {
    super.initState();
    _tabSwitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1,
    );
  }

  @override
  void dispose() {
    _tabSwitchController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    final switchingBranch = index != widget.navigationShell.currentIndex;

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );

    if (switchingBranch) {
      _tabSwitchController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final compact = SamsUiTokens.isCompactWidth(context);
    final navBarHeight = compact
        ? SamsUiTokens.navBarCompactHeight
        : SamsUiTokens.navBarHeight;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _tabSwitchController,
        child: widget.navigationShell,
        builder: (context, child) {
          final progress = Curves.easeOutCubic.transform(
            _tabSwitchController.value,
          );
          final opacity = lerpDouble(0.9, 1, progress)!;
          final scale = lerpDouble(0.992, 1, progress)!;
          final horizontalShift = lerpDouble(6, 0, progress)!;

          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(horizontalShift, 0),
              child: Transform.scale(
                scale: scale,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: navBarHeight + bottomInset + 4,
                  ),
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: bottomInset),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: SamsUiTokens.softTopShadow,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SamsUiTokens.navTopRadius),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SamsUiTokens.navTopRadius),
          ),
          child: NavigationBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _onTap,
            backgroundColor: Colors.white,
            indicatorColor: _samsPrimary.withValues(alpha: 0.12),
            surfaceTintColor: Colors.transparent,
            height: navBarHeight,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: compact ? 11 : 11.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? _samsPrimary : const Color(0xFF7E8794),
              );
            }),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: Icon(Icons.chat_bubble_rounded),
                label: 'Messages',
              ),
              NavigationDestination(
                icon: Icon(Icons.qr_code_scanner_outlined),
                selectedIcon: Icon(Icons.qr_code_scanner_rounded),
                label: 'Scan',
              ),
              NavigationDestination(
                icon: Icon(Icons.headset_mic_outlined),
                selectedIcon: Icon(Icons.headset_mic_rounded),
                label: 'Help Desk',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_outlined),
                selectedIcon: Icon(Icons.menu_rounded),
                label: 'Menu',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
