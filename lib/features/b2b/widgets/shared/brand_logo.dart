import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BrandLogo extends StatelessWidget {
  final String imageUrl;

  const BrandLogo({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[100],
            child: Center(
              child: Icon(
                Icons.image_not_supported,
                size: 24,
                color: Colors.grey[400],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
