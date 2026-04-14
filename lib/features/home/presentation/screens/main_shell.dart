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
  static const _navItems = [
    (label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home_rounded),
    (
      label: 'Messages',
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
    ),
    (
      label: 'Scan',
      icon: Icons.qr_code_scanner_outlined,
      activeIcon: Icons.qr_code_scanner_rounded,
    ),
    (
      label: 'Help Desk',
      icon: Icons.headset_mic_outlined,
      activeIcon: Icons.headset_mic_rounded,
    ),
    (label: 'Menu', icon: Icons.menu_outlined, activeIcon: Icons.menu_rounded),
  ];

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

  List<NavigationDestination> _buildDestinations(int selectedIndex) {
    return _navItems
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final item = entry.value;
          final selected = selectedIndex == index;

          return NavigationDestination(
            icon: _NavItemIcon(icon: item.icon, selected: selected),
            selectedIcon: _NavItemIcon(icon: item.activeIcon, selected: true),
            label: item.label,
          );
        })
        .toList(growable: false);
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
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color(0x22001426),
              blurRadius: 22,
              offset: Offset(0, -4),
            ),
          ],
          borderRadius: BorderRadius.circular(SamsUiTokens.navTopRadius),
          border: Border.all(color: const Color(0xFFE0E7EF)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SamsUiTokens.navTopRadius),
          child: NavigationBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _onTap,
            backgroundColor: Colors.white,
            indicatorColor: _samsPrimary.withValues(alpha: 0.13),
            indicatorShape: const StadiumBorder(),
            surfaceTintColor: Colors.transparent,
            height: navBarHeight,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: compact ? 11.2 : 12,
                height: 1.1,
                letterSpacing: 0.1,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? _samsPrimary : const Color(0xFF7E8794),
              );
            }),
            destinations: _buildDestinations(
              widget.navigationShell.currentIndex,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemIcon extends StatelessWidget {
  const _NavItemIcon({required this.icon, required this.selected});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final primary = SamsUiTokens.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(
        horizontal: selected ? 11 : 8,
        vertical: selected ? 5 : 3,
      ),
      decoration: BoxDecoration(
        color: selected ? primary.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        scale: selected ? 1.05 : 1,
        child: Icon(icon),
      ),
    );
  }
}
