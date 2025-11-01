import 'package:flutter/material.dart';
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
          _buildUserProfile(),
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

  Widget _buildUserProfile() {
    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: AppTheme.spacingM),
        _buildUserInfo(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.dividerColor,
          width: 1,
        ),
      ),
      child: const Icon(
        Icons.person,
        color: AppTheme.textSecondary,
        size: 20,
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Lucas Fabian',
          style: AppTheme.bodyMedium,
        ),
        SizedBox(height: 2),
        Text(
          'example@gmail.com',
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }
}
