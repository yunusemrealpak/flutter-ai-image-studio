import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Settings screen for API configuration and preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _enableSafetyChecker = true;
  bool _autoSaveEdits = false;
  String _imageQuality = 'high';
  bool _showApiKey = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    // TODO: Load settings from storage
    setState(() {
      _apiKeyController.text = '';
    });
  }

  Future<void> _saveSettings() async {
    // TODO: Save settings to storage
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: AppTheme.primaryBlue,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppTheme.spacingXXL),
              _buildApiKeySection(),
              const SizedBox(height: AppTheme.spacingXXL),
              _buildGeneralSettingsSection(),
              const SizedBox(height: AppTheme.spacingXXL),
              _buildImageSettingsSection(),
              const SizedBox(height: AppTheme.spacingXXL * 2),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surfaceDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.iconColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Settings',
        style: AppTheme.headingMedium,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Application Settings',
          style: AppTheme.headingLarge,
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          'Configure your API keys and preferences',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeySection() {
    return _buildSection(
      title: 'API Configuration',
      icon: Icons.key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fal.ai API Key',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          TextField(
            controller: _apiKeyController,
            obscureText: !_showApiKey,
            style: AppTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Enter your Fal.ai API key',
              hintStyle: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textTertiary,
              ),
              filled: true,
              fillColor: AppTheme.surfaceDarker,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: const BorderSide(
                  color: AppTheme.primaryBlue,
                  width: 2,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _showApiKey ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.iconColor,
                ),
                onPressed: () {
                  setState(() {
                    _showApiKey = !_showApiKey;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  'Get your API key from fal.ai dashboard',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettingsSection() {
    return _buildSection(
      title: 'General Settings',
      icon: Icons.settings,
      child: Column(
        children: [
          _buildSwitchTile(
            title: 'Enable Safety Checker',
            subtitle: 'Filter inappropriate content in generated images',
            value: _enableSafetyChecker,
            onChanged: (value) {
              setState(() {
                _enableSafetyChecker = value;
              });
            },
          ),
          const SizedBox(height: AppTheme.spacingL),
          _buildSwitchTile(
            title: 'Auto-save Edits',
            subtitle: 'Automatically save edited images to local storage',
            value: _autoSaveEdits,
            onChanged: (value) {
              setState(() {
                _autoSaveEdits = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageSettingsSection() {
    return _buildSection(
      title: 'Image Settings',
      icon: Icons.image,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Default Image Quality',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildQualitySelector(),
        ],
      ),
    );
  }

  Widget _buildQualitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDarker,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          _buildQualityOption('high', 'High', 'Best quality, larger file size'),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildQualityOption(
              'medium', 'Medium', 'Balanced quality and file size'),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildQualityOption('low', 'Low', 'Smaller file size, faster upload'),
        ],
      ),
    );
  }

  Widget _buildQualityOption(String value, String title, String subtitle) {
    final isSelected = _imageQuality == value;
    return InkWell(
      onTap: () {
        setState(() {
          _imageQuality = value;
        });
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.iconColor,
            ),
            const SizedBox(width: AppTheme.spacingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    subtitle,
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: AppTheme.spacingM),
              Text(
                title,
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXL),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                subtitle,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppTheme.spacingL),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryBlue,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.save, size: 20),
            SizedBox(width: AppTheme.spacingM),
            Text(
              'Save Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
