// lib/widgets/custom_wish_card.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hive/wish_model_hive.dart';
import '../constants/app_colors.dart';
import '../utils/utils.dart';

class CustomWishCard extends ConsumerStatefulWidget {
  final WishH wish;
  final VoidCallback? onEditPressed;
  const CustomWishCard({super.key, required this.wish, this.onEditPressed});

  @override
  ConsumerState<CustomWishCard> createState() => _CustomWishCardState();
}

class _CustomWishCardState extends ConsumerState<CustomWishCard> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await loadImageBytes(widget.wish.imageUrl);
    if (mounted) {
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressPercentage = widget.wish.progressPercentage;
    final color = getProgressColor(progressPercentage);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: getImageProvider(
                  widget.wish.imageUrl,
                  imageBytes: _imageBytes,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.wish.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progressPercentage / 100,
                  backgroundColor: Colors.grey[200],
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  minHeight: 10,
                  semanticsLabel: "${progressPercentage.round()}% complete",
                ),
                const SizedBox(height: 4),
                Text(
                  "${widget.wish.deadline?.day}/${widget.wish.deadline?.month}",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            color: AppColors.primary,
            onPressed: widget.onEditPressed,
          ),
        ],
      ),
    );
  }

  Color getProgressColor(double percentage) {
    if (percentage >= 100) return Colors.green;
    if (percentage >= 75) return AppColors.primary;
    if (percentage >= 50) return Colors.blue;
    if (percentage >= 25) return Colors.orange;
    return Colors.red;
  }
}
