import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/sams_ui_tokens.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.currentIndex = 0,
    this.useSafeArea = true,
  });

  final Widget child;
  final int currentIndex;
  final bool useSafeArea;

  void _onTap(BuildContext context, int i) {
    switch (i) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/messages');
        break;
      case 2:
        context.go('/scan');
        break;
      case 3:
        context.go('/help-desk');
        break;
      case 4:
        context.go('/menu');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SamsUiTokens.scaffoldBackground,
      body: useSafeArea ? SafeArea(bottom: false, child: child) : child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: SamsUiTokens.softTopShadow,
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) => _onTap(context, i),
          backgroundColor: Colors.white,
          indicatorColor: SamsUiTokens.primary.withValues(alpha: 0.12),
          surfaceTintColor: Colors.transparent,
          height: 66,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
    );
  }
}
