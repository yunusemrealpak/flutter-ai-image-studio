import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../screens/settings_screen.dart';
import '../theme/app_theme.dart';

/// Main application drawer with job list and settings
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surfaceDark,
      width: 320,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildJobsList(context)),
          _buildSettingsButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDarker,
        border: Border(
          bottom: BorderSide(color: AppTheme.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.accentOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Image Editor',
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                'Your Projects',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        final jobs = jobProvider.jobs;

        if (jobs.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            final isSelected = jobProvider.currentJob?.id == job.id;

            return _buildJobItem(
              context: context,
              imageUrl: job.editedImageUrl ?? job.originalImageUrl,
              prompt: job.prompt,
              timestamp: job.createdAt,
              isSelected: isSelected,
              isCompleted: job.isCompleted,
              onTap: () {
                jobProvider.setCurrentJob(job);
                Navigator.of(context).pop(); // Close drawer
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 64,
              color: AppTheme.iconColor.withOpacity(0.3),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'No projects yet',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Upload an image and generate your first edit',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobItem({
    required BuildContext context,
    required String? imageUrl,
    required String prompt,
    required DateTime timestamp,
    required bool isSelected,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingXS,
        ),
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.surfaceDarker,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_outlined,
                            color: AppTheme.iconColor,
                            size: 24,
                          );
                        },
                      )
                    : const Icon(
                        Icons.image_outlined,
                        color: AppTheme.iconColor,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          prompt,
                          style: AppTheme.bodyMedium.copyWith(
                            color: isSelected
                                ? AppTheme.primaryBlue
                                : AppTheme.textPrimary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isCompleted) ...[
                        const SizedBox(width: AppTheme.spacingS),
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    _formatTimestamp(timestamp),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.dividerColor, width: 1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop(); // Close drawer
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingXL),
            child: Row(
              children: [
                const Icon(
                  Icons.settings,
                  color: AppTheme.iconColor,
                  size: 24,
                ),
                const SizedBox(width: AppTheme.spacingL),
                const Text(
                  'Settings',
                  style: AppTheme.bodyMedium,
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.iconColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
