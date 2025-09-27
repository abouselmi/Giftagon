// lib/widgets/sidebar_icon_button.dart

import 'package:flutter/material.dart';

class SidebarIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback onPressed;
  final String semanticLabel;

  const SidebarIconButton({
    super.key,
    required this.icon,
    required this.color,
    this.backgroundColor,
    required this.onPressed,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
      ),
    );
  }
}