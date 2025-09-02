import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool expanded;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final btn = FilledButton(onPressed: onPressed, child: Text(text));
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
