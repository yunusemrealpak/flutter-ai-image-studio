import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/job.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/job_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/editor_app_bar.dart';
import '../widgets/editor_canvas.dart';
import '../widgets/prompt_input_bar.dart';
import '../widgets/recent_edits_bar.dart';

/// Main editor screen with full layout
class EditorScreen extends StatefulWidget {
  final String? initialJobId;

  const EditorScreen({super.key, this.initialJobId});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final TextEditingController _promptController = TextEditingController();
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  Job? _previousJob; // Track previous job state

  @override
  void initState() {
    super.initState();

    // Listen to job changes to clear selected image when job completes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<JobProvider>().addListener(_onJobChanged);

      // First load all jobs
      await _loadJobs();

      // Then if initialJobId is provided, load that specific job
      if (widget.initialJobId != null) {
        await _loadInitialJob(widget.initialJobId!);
      }
    });
  }

  @override
  void didUpdateWidget(EditorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If initialJobId changed, load the new job
    if (widget.initialJobId != oldWidget.initialJobId) {
      if (widget.initialJobId != null) {
        _loadInitialJob(widget.initialJobId!);
      } else {
        // If initialJobId is null, clear current job
        context.read<JobProvider>().clearCurrentJob();
      }
    }
  }

  Future<void> _loadInitialJob(String jobId) async {
    final jobProvider = context.read<JobProvider>();

    try {
      // Find the job in the loaded jobs list
      final job = jobProvider.jobs.firstWhere((j) => j.id == jobId);
      jobProvider.setCurrentJob(job);
    } catch (e) {
      // Job not found, show error
      _showError('Job not found');
    }
  }

  void _onJobChanged() {
    final jobProvider = context.read<JobProvider>();
    final currentJob = jobProvider.currentJob;

    // Only clear when state transitions occur, not on every change
    if (_selectedImageBytes != null) {
      // Case 1: Job transitioned from PROCESSING to COMPLETED
      if (_previousJob != null &&
          _previousJob!.isProcessing &&
          currentJob != null &&
          currentJob.id == _previousJob!.id &&
          currentJob.isCompleted) {
        setState(() {
          _selectedImageBytes = null;
          _selectedImageName = null;
        });
      }
      // Case 2: Job was cleared (New Edit button)
      else if (_previousJob != null && currentJob == null) {
        setState(() {
          _selectedImageBytes = null;
          _selectedImageName = null;
        });
      }
    }

    // Update previous job
    _previousJob = currentJob;
  }

  @override
  void dispose() {
    context.read<JobProvider>().removeListener(_onJobChanged);
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
        // Clear prompt after job creation
        // Note: _selectedImageBytes will be cleared when job completes (see _onJobChanged)
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
            EditorAppBar(onMenuTap: () => Scaffold.of(context).openDrawer()),
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
        final isProcessing = currentJob?.isProcessing ?? false;
        final progress = currentJob?.progress ?? 0;

        return Column(
          children: [
            Expanded(
              child: EditorCanvas(
                imageUrl: currentJob?.editedImageUrl,
                beforeImageUrl: currentJob?.originalImageUrl,
                selectedImageBytes: _selectedImageBytes,
                isProcessing: isProcessing,
                progress: progress,
                onImagePick: _handleImagePick,
              ),
            ),
            // Show the prompt used for the current job
            if (currentJob != null && currentJob.prompt.isNotEmpty)
              _buildUsedPromptDisplay(currentJob.prompt),
          ],
        );
      },
    );
  }

  Widget _buildUsedPromptDisplay(String prompt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXL,
        vertical: AppTheme.spacingL,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.08),
        border: const Border(
          top: BorderSide(color: AppTheme.primaryBlue, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 20,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Text(
              prompt,
              style: AppTheme.bodyMedium.copyWith(
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptInputBar() {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        final hasNewImage = _selectedImageBytes != null;
        final hasExistingImage = jobProvider.currentJob?.editedImageUrl != null;
        final isEditingExisting = hasExistingImage && !hasNewImage;
        final currentJob = jobProvider.currentJob;
        final isProcessing = currentJob?.isProcessing ?? false;
        final progress = currentJob?.progress ?? 0;

        return PromptInputBar(
          controller: _promptController,
          isLoading: isProcessing,
          progress: progress,
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
            // Navigate to job URL
            context.go('/job/${job.id}');
          },
        );
      },
    );
  }
}
