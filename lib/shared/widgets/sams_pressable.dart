import 'package:flutter/material.dart';

import '../ui/sams_ui_tokens.dart';

class SamsPressable extends StatefulWidget {
  const SamsPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.982,
    this.borderRadius,
    this.baseShadow,
    this.hoverShadow,
    this.pressedShadow,
    this.enableLift = true,
    this.ensureMinTouchTarget = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? baseShadow;
  final List<BoxShadow>? hoverShadow;
  final List<BoxShadow>? pressedShadow;
  final bool enableLift;
  final bool ensureMinTouchTarget;

  @override
  State<SamsPressable> createState() => _SamsPressableState();
}

class _SamsPressableState extends State<SamsPressable> {
  bool _pressed = false;
  bool _hovered = false;

  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() => _pressed = value);
  }

  void _setHovered(bool value) {
    if (!mounted) return;
    setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius =
        widget.borderRadius ?? BorderRadius.circular(SamsUiTokens.radiusLg);
    const defaultBaseShadow = [
      BoxShadow(color: Color(0x12091C2B), blurRadius: 10, offset: Offset(0, 4)),
    ];
    const defaultHoverShadow = [
      BoxShadow(color: Color(0x1A091C2B), blurRadius: 16, offset: Offset(0, 7)),
    ];
    const defaultPressedShadow = [
      BoxShadow(color: Color(0x22091C2B), blurRadius: 20, offset: Offset(0, 9)),
    ];

    final activeShadow = !widget.enableLift
        ? const <BoxShadow>[]
        : _pressed
        ? (widget.pressedShadow ?? defaultPressedShadow)
        : _hovered
        ? (widget.hoverShadow ?? defaultHoverShadow)
        : (widget.baseShadow ?? defaultBaseShadow);

    final liftY = !widget.enableLift
        ? 0.0
        : _pressed
        ? -1.2
        : _hovered
        ? -0.6
        : 0.0;
    final content = widget.ensureMinTouchTarget
        ? ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            child: widget.child,
          )
        : widget.child;

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) {
        _setHovered(false);
        _setPressed(false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: SamsUiTokens.fastAnimation,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: activeShadow,
          ),
          child: AnimatedScale(
            scale: _pressed ? widget.scale : 1,
            duration: SamsUiTokens.fastAnimation,
            curve: Curves.easeOut,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: liftY),
              duration: SamsUiTokens.fastAnimation,
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: child,
                );
              },
              child: ClipRRect(borderRadius: radius, child: content),
            ),
          ),
        ),
      ),
    );
  }
}

class SamsTapScale extends StatefulWidget {
  const SamsTapScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.pressedScale = 0.98,
  });

  final Widget child;
  final bool enabled;
  final double pressedScale;

  @override
  State<SamsTapScale> createState() => _SamsTapScaleState();
}

class _SamsTapScaleState extends State<SamsTapScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted || !widget.enabled) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: SamsUiTokens.fastAnimation,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
