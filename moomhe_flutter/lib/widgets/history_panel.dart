import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../models/history_entry.dart';

class HistoryPanel extends StatelessWidget {
  final List<HistoryEntry> history;
  final bool isLoading;
  final bool hasMore;
  final bool isDisabled;
  final Function(HistoryEntry) onImageSelect;
  final VoidCallback onLoadMore;

  const HistoryPanel({
    super.key,
    required this.history,
    required this.isLoading,
    required this.hasMore,
    required this.onImageSelect,
    required this.onLoadMore,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return _buildEmptyState();
    }
    return _buildHistoryList(context);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.sparkles,
            size: 16,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            'אין היסטוריה עדיין',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: history.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == history.length) {
            return _buildLoadingIndicator();
          }
          return _buildHistoryThumbnail(history[index]);
        },
      ),
    );
  }

  Widget _buildHistoryThumbnail(HistoryEntry entry) {
    return GestureDetector(
      onTap: isDisabled ? null : () => onImageSelect(entry),
      child: Container(
        width: 70,
        height: 70,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: _buildEntryImage(entry),
        ),
      ),
    );
  }

  Widget _buildEntryImage(HistoryEntry entry) {
    final imageUrl = entry.thumbnailUrl ?? entry.imageUrl;
    
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: 70,
        height: 70,
        placeholder: (context, url) => Container(
          color: AppColors.surface,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: AppColors.primary400,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.surface,
          child: const Icon(
            LucideIcons.imageOff,
            color: AppColors.textMuted,
            size: 20,
          ),
        ),
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: 70,
        height: 70,
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        width: 70,
        height: 70,
      );
    }
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 70,
      height: 70,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: AppColors.primary400,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
