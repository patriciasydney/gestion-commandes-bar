import 'package:flutter/material.dart';

import 'app_skeleton.dart';

/// Indicateur de chargement — skeleton par défaut pour les écrans de contenu.
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool useSkeleton;

  const LoadingIndicator({
    super.key,
    this.message,
    this.useSkeleton = true,
  });

  @override
  Widget build(BuildContext context) {
    if (useSkeleton) {
      return const SkeletonList(itemCount: 5);
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: const TextStyle(color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}
