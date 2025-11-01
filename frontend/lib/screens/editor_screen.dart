import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/job_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/editor_app_bar.dart';
import '../widgets/editor_canvas.dart';
import '../widgets/editor_settings_panel.dart';
import '../widgets/editor_sidebar.dart';
import '../widgets/recent_edits_bar.dart';
import '../widgets/prompt_input_bar.dart';

/// Main editor screen with full layout
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final TextEditingController _promptController = TextEditingController();
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
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
        SnackBar(content: Text(message), backgroundColor: Colors.red),
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
        SnackBar(content: Text(message), backgroundColor: AppTheme.primaryBlue),
      );
    }
  }

  Future<void> _handleImagePick() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() {
            _selectedImageBytes = file.bytes;
            _selectedImageName = file.name;
          });
        }
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _handleGenerate() async {
    if (_selectedImageBytes == null) {
      _showError('Please upload an image first');
      return;
    }

    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      _showError('Please enter a prompt');
      return;
    }

    try {
      final jobProvider = context.read<JobProvider>();
      await jobProvider.createJob(
        imageBytes: _selectedImageBytes!,
        imageName: _selectedImageName ?? 'image.png',
        prompt: prompt,
      );

      if (mounted) {
        _showInfo('Image generated successfully!');
        // Clear the selected image after successful generation
        setState(() {
          _selectedImageBytes = null;
          _selectedImageName = null;
        });
        _promptController.clear();
      }
    } catch (e) {
      _showError('Failed to generate image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Column(
        children: [
          EditorAppBar(onSaveExport: _handleSaveExport, onShare: _handleShare),
          Expanded(
            child: Row(
              children: [
                const EditorSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: _buildMainContent()),
                      _buildPromptInputBar(),
                    ],
                  ),
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
          selectedImageBytes: _selectedImageBytes,
          onImagePick: _handleImagePick,
        );
      },
    );
  }

  Widget _buildPromptInputBar() {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        return PromptInputBar(
          controller: _promptController,
          isLoading: jobProvider.isLoading,
          hasImage: _selectedImageBytes != null,
          onGenerate: _handleGenerate,
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
