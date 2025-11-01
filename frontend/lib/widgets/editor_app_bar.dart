import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../theme/app_theme.dart';

/// Top application bar for the editor
class EditorAppBar extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const EditorAppBar({
    Key? key,
    this.onMenuTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTheme.headerHeight,
      color: AppTheme.headerBackground,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXXL,
        vertical: AppTheme.spacingL,
      ),
      child: Row(
        children: [
          _buildMenuButton(),
          const SizedBox(width: AppTheme.spacingL),
          _buildLogo(),
          const SizedBox(width: AppTheme.spacingXXL),
          _buildNewEditButton(context),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildMenuButton() {
    return IconButton(
      icon: const Icon(Icons.menu, color: AppTheme.iconColor),
      onPressed: onMenuTap,
      tooltip: 'Menu',
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: AppTheme.textPrimary,
        size: 24,
      ),
    );
  }

  Widget _buildNewEditButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Clear current job and navigate to home
        context.read<JobProvider>().clearCurrentJob();
        context.go('/');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingL,
          vertical: AppTheme.spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
      ),
      icon: const Icon(Icons.add, size: 18),
      label: const Text(
        'New Edit',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
