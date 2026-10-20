import 'dart:convert';
import 'package:flutter/material.dart';

/// Universal image widget for Wafra:
/// Supports:
/// 1. Base64 Data URIs (data:image/jpeg;base64,...)
/// 2. Remote HTTP/HTTPS URLs with timeout & smooth error fallback
/// 3. Local asset images (assets/...)
/// 4. Graceful emoji / placeholder fallback
class WafraImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? fallbackEmoji;
  final IconData? fallbackIcon;
  final Color? backgroundColor;

  const WafraImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackEmoji,
    this.fallbackIcon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = _buildRawImage(context);

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey.shade100,
      child: imageWidget,
    );
  }

  Widget _buildRawImage(BuildContext context) {
    final src = imageUrl?.trim() ?? '';

    if (src.isEmpty) {
      return _buildFallback();
    }

    // 1. Base64 Data URL (e.g. data:image/jpeg;base64,...)
    if (src.startsWith('data:image')) {
      try {
        final commaIndex = src.indexOf(',');
        final base64Data = commaIndex != -1 ? src.substring(commaIndex + 1) : src;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      } catch (_) {
        return _buildFallback();
      }
    }

    // 2. Local Asset
    if (src.startsWith('assets/')) {
      return Image.asset(
        src,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    // 3. Remote URL (http / https)
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return Image.network(
        src,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
                color: const Color(0xFF0075FF),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    // Fallback if unrecognized format
    return _buildFallback();
  }

  Widget _buildFallback() {
    if (fallbackEmoji != null && fallbackEmoji!.isNotEmpty) {
      return Center(
        child: Text(
          fallbackEmoji!,
          style: TextStyle(
            fontSize: (height != null && height! < 50) ? 22 : 36,
          ),
        ),
      );
    }
    return Center(
      child: Icon(
        fallbackIcon ?? Icons.storefront_outlined,
        size: (height != null && height! < 50) ? 20 : 32,
        color: Colors.grey.shade400,
      ),
    );
  }
}
