import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/job_provider.dart';
import '../widgets/editor_app_bar.dart';
import '../widgets/editor_sidebar.dart';
import '../widgets/editor_canvas.dart';
import '../widgets/editor_settings_panel.dart';
import '../widgets/recent_edits_bar.dart';

/// Main editor screen with full layout
class EditorScreen extends StatefulWidget {
  const EditorScreen({Key? key}) : super(key: key);

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    try {
      await context.read<JobProvider>().loadJobs();
    } catch (e) {
      _showError('Failed to load jobs: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleSaveExport() {
    // TODO: Implement save/export functionality
    _showInfo('Save/Export functionality coming soon');
  }

  void _handleShare() {
    // TODO: Implement share functionality
    _showInfo('Share functionality coming soon');
  }

  void _showInfo(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.primaryBlue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Column(
        children: [
          EditorAppBar(
            onSaveExport: _handleSaveExport,
            onShare: _handleShare,
          ),
          Expanded(
            child: Row(
              children: [
                const EditorSidebar(),
                Expanded(
                  child: _buildMainContent(),
                ),
                const EditorSettingsPanel(),
              ],
            ),
          ),
          _buildRecentEditsBar(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        final currentJob = jobProvider.currentJob;

        return EditorCanvas(
          imageUrl: currentJob?.editedImageUrl,
          beforeImageUrl: currentJob?.originalImageUrl,
        );
      },
    );
  }

  Widget _buildRecentEditsBar() {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        // Only show completed jobs in recent edits
        final completedJobs = jobProvider.jobs
            .where((job) => job.isCompleted)
            .toList();

        return RecentEditsBar(
          jobs: completedJobs,
          selectedJob: jobProvider.currentJob,
          onJobSelected: (job) {
            jobProvider.setCurrentJob(job);
          },
        );
      },
    );
  }
}
