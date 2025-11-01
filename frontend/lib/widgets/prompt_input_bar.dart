import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Prompt input bar for AI image generation
class PromptInputBar extends StatefulWidget {
  final TextEditingController controller;
  final bool isLoading;
  final int progress; // Progress percentage (0-100)
  final bool hasImage;
  final bool isEditingExisting;
  final VoidCallback? onGenerate;

  const PromptInputBar({
    super.key,
    required this.controller,
    this.isLoading = false,
    this.progress = 0,
    this.hasImage = false,
    this.isEditingExisting = false,
    this.onGenerate,
  });

  @override
  State<PromptInputBar> createState() => _PromptInputBarState();
}

class _PromptInputBarState extends State<PromptInputBar> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXXL,
        vertical: AppTheme.spacingL,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(top: BorderSide(color: AppTheme.dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildPromptInput()),
          const SizedBox(width: AppTheme.spacingL),
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildPromptInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDarker,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: _focusNode.hasFocus
              ? AppTheme.primaryBlue.withOpacity(0.5)
              : AppTheme.dividerColor,
          width: 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: !widget.isLoading && widget.hasImage,
        maxLines: 1,
        style: AppTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: _getHintText(),
          hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingM,
          ),
          prefixIcon: Icon(
            Icons.edit_outlined,
            color: widget.hasImage ? AppTheme.iconColor : AppTheme.textTertiary,
            size: 20,
          ),
        ),
        onSubmitted: (_) => _handleGenerate(),
      ),
    );
  }

  Widget _buildGenerateButton() {
    final bool canGenerate =
        widget.hasImage &&
        widget.controller.text.trim().isNotEmpty &&
        !widget.isLoading;

    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: canGenerate ? _handleGenerate : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canGenerate
              ? AppTheme.primaryBlue
              : AppTheme.surfaceDarker,
          foregroundColor: canGenerate
              ? AppTheme.textPrimary
              : AppTheme.textTertiary,
          disabledBackgroundColor: AppTheme.surfaceDarker,
          disabledForegroundColor: AppTheme.textTertiary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXXL),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
        child: widget.isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Text('${widget.progress}% Generating...'),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.auto_awesome, size: 18),
                  SizedBox(width: AppTheme.spacingS),
                  Text('Generate'),
                ],
              ),
      ),
    );
  }

  String _getHintText() {
    if (!widget.hasImage) {
      return 'Upload an image first to start editing';
    }
    if (widget.isEditingExisting) {
      return 'Continue editing with a new prompt...';
    }
    return 'Describe how you want to edit the image...';
  }

  void _handleGenerate() {
    if (widget.controller.text.trim().isEmpty || !widget.hasImage) {
      return;
    }
    widget.onGenerate?.call();
    _focusNode.unfocus();
  }
}
