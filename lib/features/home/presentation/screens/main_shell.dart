import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const Set<String> _rootTabPaths = {
    '/home',
    '/messages',
    '/scan',
    '/help-desk',
    '/menu',
  };

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

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
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

  List<NavigationRailDestination> _buildRailDestinations(int selectedIndex) {
    return _navItems
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final item = entry.value;
          final selected = selectedIndex == index;

          return NavigationRailDestination(
            icon: _NavItemIcon(icon: item.icon, selected: selected),
            selectedIcon: _NavItemIcon(icon: item.activeIcon, selected: true),
            label: Text(item.label),
          );
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final navSurface = colorScheme.surfaceContainerHighest;
    final navBorder = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.9 : 0.6,
    );
    final navShadowColor = Colors.black.withValues(alpha: isDark ? 0.34 : 0.14);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final location = GoRouterState.of(context).uri.path;
    final showShellNavigation = _rootTabPaths.contains(location);
    final compact = SamsUiTokens.isCompactWidth(context);
    final ultraNarrow = screenWidth < 390;
    final useDesktopRail = SamsUiTokens.isDesktopWidth(context);
    final navBarHeight = compact
        ? SamsUiTokens.navBarCompactHeight
        : SamsUiTokens.navBarHeight;
    const floatingBottomGap = 12.0;
    const floatingSideGap = 12.0;
    const floatingTopGap = 6.0;

    if (useDesktopRail) {
      if (!showShellNavigation) {
        return SafeArea(child: widget.navigationShell);
      }

      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: navSurface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: navShadowColor,
                        blurRadius: 20,
                        offset: Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: navBorder),
                  ),
                  child: NavigationRail(
                    selectedIndex: widget.navigationShell.currentIndex,
                    onDestinationSelected: _onTap,
                    backgroundColor: navSurface,
                    useIndicator: true,
                    indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
                    labelType: NavigationRailLabelType.all,
                    minWidth: 80,
                    minExtendedWidth: 132,
                    destinations: _buildRailDestinations(
                      widget.navigationShell.currentIndex,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                bottom: false,
                child: widget.navigationShell,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(top: false, bottom: false, child: widget.navigationShell),
      bottomNavigationBar: showShellNavigation
          ? SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(
                floatingSideGap,
                floatingTopGap,
                floatingSideGap,
                floatingBottomGap,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: navSurface,
                  boxShadow: [
                    BoxShadow(
                      color: navShadowColor,
                      blurRadius: 24,
                      offset: Offset(0, -6),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(
                    SamsUiTokens.navTopRadius,
                  ),
                  border: Border.all(color: navBorder),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    SamsUiTokens.navTopRadius,
                  ),
                  child: NavigationBar(
                    selectedIndex: widget.navigationShell.currentIndex,
                    onDestinationSelected: _onTap,
                    backgroundColor: navSurface,
                    indicatorColor: colorScheme.primary.withValues(
                      alpha: isDark ? 0.24 : 0.13,
                    ),
                    indicatorShape: const StadiumBorder(),
                    surfaceTintColor: Colors.transparent,
                    height: navBarHeight,
                    labelBehavior: ultraNarrow
                        ? NavigationDestinationLabelBehavior.onlyShowSelected
                        : NavigationDestinationLabelBehavior.alwaysShow,
                    labelTextStyle: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return TextStyle(
                        fontSize: compact ? 11.2 : 12,
                        height: 1.1,
                        letterSpacing: 0.1,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      );
                    }),
                    destinations: _buildDestinations(
                      widget.navigationShell.currentIndex,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _NavItemIcon extends StatelessWidget {
  const _NavItemIcon({required this.icon, required this.selected});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      scale: selected ? 1.05 : 1,
      child: Icon(icon),
    );
  }
}
