import 'package:flutter/material.dart';

import '../models/job.dart';
import '../theme/app_theme.dart';

/// Bottom bar showing recent edit thumbnails
class RecentEditsBar extends StatelessWidget {
  final List<Job> jobs;
  final Job? selectedJob;
  final ValueChanged<Job>? onJobSelected;

  const RecentEditsBar({
    super.key,
    required this.jobs,
    this.selectedJob,
    this.onJobSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTheme.recentEditsHeight,
      color: AppTheme.backgroundDark,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXXL,
        vertical: AppTheme.spacingL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppTheme.spacingM),
          Expanded(child: _buildThumbnailList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Text('Recent Edits', style: AppTheme.headingMedium);
  }

  Widget _buildThumbnailList() {
    if (jobs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: jobs.length,
      separatorBuilder: (context, index) =>
          const SizedBox(width: AppTheme.spacingM),
      itemBuilder: (context, index) {
        final job = jobs[index];
        final isSelected = selectedJob?.id == job.id;

        return _RecentEditThumbnail(
          job: job,
          isSelected: isSelected,
          onTap: () => onJobSelected?.call(job),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No recent edits',
        style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
      ),
    );
  }
}

/// Individual thumbnail widget
class _RecentEditThumbnail extends StatelessWidget {
  final Job job;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecentEditThumbnail({
    required this.job,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppTheme.recentEditsThumbnailSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          child: _buildThumbnailImage(),
        ),
      ),
    );
  }

  Widget _buildThumbnailImage() {
    // Use edited image if available, otherwise original
    final imageUrl = job.editedImageUrl ?? job.originalImageUrl;

    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingIndicator();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.surfaceDark,
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppTheme.iconColor, size: 32),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: AppTheme.surfaceDark,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.primaryBlue,
          ),
        ),
      ),
    );
  }
}
