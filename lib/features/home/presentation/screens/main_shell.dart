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
  static const Color _samsPrimary = SamsUiTokens.primary;

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: SamsUiTokens.softTopShadow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: NavigationBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _onTap,
            backgroundColor: Colors.white,
            indicatorColor: _samsPrimary.withValues(alpha: 0.12),
            surfaceTintColor: Colors.transparent,
            height: 66,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 11.5,
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
