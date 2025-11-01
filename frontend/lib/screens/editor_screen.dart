import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../providers/job_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/editor_app_bar.dart';
import '../widgets/editor_canvas.dart';
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
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      _showError('Please enter a prompt');
      return;
    }

    final jobProvider = context.read<JobProvider>();
    Uint8List? imageBytes;
    String imageName;

    // Check if continuing from an existing edited image
    if (jobProvider.currentJob != null &&
        jobProvider.currentJob!.editedImageUrl != null &&
        _selectedImageBytes == null) {
      // Download the edited image from URL
      try {
        imageBytes = await _downloadImageFromUrl(
          jobProvider.currentJob!.editedImageUrl!,
        );
        imageName = 'edited_${jobProvider.currentJob!.id}.png';
      } catch (e) {
        _showError('Failed to load image for editing: $e');
        return;
      }
    } else if (_selectedImageBytes != null) {
      // Use newly uploaded image
      imageBytes = _selectedImageBytes;
      imageName = _selectedImageName ?? 'image.png';
    } else {
      _showError('Please upload an image first');
      return;
    }

    try {
      await jobProvider.createJob(
        imageBytes: imageBytes!,
        imageName: imageName,
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

  Future<Uint8List> _downloadImageFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to download image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      drawer: const AppDrawer(),
      body: Builder(
        builder: (context) => Column(
          children: [
            EditorAppBar(
              onMenuTap: () => Scaffold.of(context).openDrawer(),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _buildMainContent()),
                  _buildPromptInputBar(),
                ],
              ),
            ),
            _buildRecentEditsBar(),
          ],
        ),
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
        final hasNewImage = _selectedImageBytes != null;
        final hasExistingImage = jobProvider.currentJob?.editedImageUrl != null;
        final isEditingExisting = hasExistingImage && !hasNewImage;

        return PromptInputBar(
          controller: _promptController,
          isLoading: jobProvider.isLoading,
          hasImage: hasNewImage || hasExistingImage,
          isEditingExisting: isEditingExisting,
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
