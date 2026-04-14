import 'package:flutter/material.dart';

import '../ui/sams_ui_tokens.dart';

class ShimmerWidget extends StatefulWidget {
  const ShimmerWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1300),
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerWidget.circle({
    super.key,
    required double size,
    this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1300),
  })  : width = size,
        height = size,
        borderRadius = null;

  const ShimmerWidget.line({
    super.key,
    required this.height,
    this.width,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1300),
  })  : child = null,
        borderRadius = const BorderRadius.all(Radius.circular(8));

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant ShimmerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller
        ..duration = widget.duration
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? const Color(0xFFE3ECF5);
    final highlight =
        widget.highlightColor ?? SamsUiTokens.primary.withValues(alpha: 0.16);

    final shape = widget.borderRadius == null ? BoxShape.circle : BoxShape.rectangle;

    final skeleton = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: base,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? widget.borderRadius : null,
      ),
      child: widget.child,
    );

    return AnimatedBuilder(
      animation: _controller,
      child: skeleton,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                base,
                highlight,
                base,
              ],
              stops: const [0.1, 0.45, 0.9],
              transform: _SlidingGradientTransform(_controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final translated = bounds.width * (slidePercent * 2.2 - 0.8);
    return Matrix4.translationValues(translated, 0, 0);
  }
}
