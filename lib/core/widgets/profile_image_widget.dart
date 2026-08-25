import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileImageWidget extends StatelessWidget {
  final String? photoUrl;
  final String? name;
  final double radius;
  final IconData defaultIcon;

  const ProfileImageWidget({
    super.key,
    required this.photoUrl,
    this.name,
    this.radius = 26.0,
    this.defaultIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    final cleanPhoto = photoUrl?.trim();
    Widget? imageContent;

    if (cleanPhoto != null && cleanPhoto.isNotEmpty) {
      if (cleanPhoto.startsWith('data:image')) {
        try {
          final base64Bytes = base64Decode(cleanPhoto.split(',').last);
          imageContent = Image.memory(
            base64Bytes,
            fit: BoxFit.cover,
            width: radius * 2,
            height: radius * 2,
            errorBuilder: (_, __, ___) => _buildFallback(),
          );
        } catch (_) {}
      } else if (cleanPhoto.startsWith('http://') || cleanPhoto.startsWith('https://')) {
        imageContent = Image.network(
          cleanPhoto,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      } else if (cleanPhoto.startsWith('/')) {
        try {
          final file = File(cleanPhoto);
          if (file.existsSync()) {
            imageContent = Image.file(
              file,
              fit: BoxFit.cover,
              width: radius * 2,
              height: radius * 2,
              errorBuilder: (_, __, ___) => _buildFallback(),
            );
          }
        } catch (_) {}
      } else {
        try {
          final base64Bytes = base64Decode(cleanPhoto);
          imageContent = Image.memory(
            base64Bytes,
            fit: BoxFit.cover,
            width: radius * 2,
            height: radius * 2,
            errorBuilder: (_, __, ___) => _buildFallback(),
          );
        } catch (_) {}
      }
    }

    imageContent ??= _buildFallback();

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: imageContent,
        ),
      ),
    );
  }

  Widget _buildFallback() {
    final initial = (name != null && name!.trim().isNotEmpty)
        ? name!.trim()[0].toUpperCase()
        : null;

    if (initial != null) {
      return Center(
        child: Text(
          initial,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.75,
            color: AppTheme.primaryRoyalMaroon,
          ),
        ),
      );
    }

    return Center(
      child: Icon(
        defaultIcon,
        size: radius * 1.1,
        color: AppTheme.primaryRoyalMaroon,
      ),
    );
  }
}
