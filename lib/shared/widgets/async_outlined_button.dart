import 'package:flutter/material.dart';

class AsyncOutlinedButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  final Widget child;

  const AsyncOutlinedButton({
    super.key,
    required this.loading,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : child,
    );
  }
}
