import 'package:flutter/material.dart';

class SamsLogoTitle extends StatelessWidget {
  const SamsLogoTitle({super.key, required this.title, this.logoSize = 24});

  final String title;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/sams_logo.png',
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.shield_rounded,
            size: 22,
            color: Color(0xFF063454),
          ),
        ),
        const SizedBox(width: 8),
        Text(title),
      ],
    );
  }
}