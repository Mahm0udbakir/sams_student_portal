import 'package:flutter/material.dart';

import '../ui/sams_ui_tokens.dart';

class SamsPressable extends StatefulWidget {
  const SamsPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.985,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final BorderRadius? borderRadius;

  @override
  State<SamsPressable> createState() => _SamsPressableState();
}

class _SamsPressableState extends State<SamsPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted || widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(SamsUiTokens.radiusLg);

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: SamsUiTokens.fastAnimation,
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: radius,
          child: widget.child,
        ),
      ),
    );
  }
}
