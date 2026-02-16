import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cowork/core/di/app_providers.dart';

class ResolvedAvatar extends ConsumerWidget {
  final String? photoUrl;
  final double radius;
  final Color backgroundColor;
  final Widget fallback;

  const ResolvedAvatar({
    super.key,
    required this.photoUrl,
    required this.radius,
    required this.backgroundColor,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = photoUrl?.trim();
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: fallback,
      );
    }

    return FutureBuilder<String?>(
      future: ref.read(resolvePhotoUrlUseCaseProvider).call(url),
      builder: (context, snapshot) {
        final resolved = snapshot.data;
        if (resolved == null || resolved.isEmpty) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor,
            child: fallback,
          );
        }
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          backgroundImage: NetworkImage(resolved),
        );
      },
    );
  }
}
