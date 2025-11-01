import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Top application bar for the editor
class EditorAppBar extends StatelessWidget {
  final VoidCallback? onSaveExport;
  final VoidCallback? onShare;

  const EditorAppBar({
    Key? key,
    this.onSaveExport,
    this.onShare,
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
          _buildLogo(),
          const SizedBox(width: AppTheme.spacingXXL),
          _buildUserProfile(),
          const Spacer(),
          _buildActionButtons(),
        ],
      ),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        _ShareButton(onTap: onShare),
        const SizedBox(width: AppTheme.spacingM),
        _SaveExportButton(onTap: onSaveExport),
      ],
    );
  }
}

/// Share button component
class _ShareButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _ShareButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.textPrimary,
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingL,
          vertical: AppTheme.spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
      ),
      child: const Text(
        'Share',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Save/Export button component
class _SaveExportButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _SaveExportButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: AppTheme.primaryButtonStyle,
      child: const Text('Save / Export'),
    );
  }
}
