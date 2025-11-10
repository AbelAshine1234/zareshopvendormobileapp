import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExhibitionCard extends StatelessWidget {
  final String imageUrl;

  const ExhibitionCard({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.image),
        ),
      ),
    );
  }
}
