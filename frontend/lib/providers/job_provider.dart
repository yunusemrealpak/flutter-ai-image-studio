import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../services/job_api_service.dart';

/// Provider for job management
class JobProvider with ChangeNotifier {
  final JobApiService _apiService = JobApiService();

  // State
  List<Job> _jobs = [];
  Job? _currentJob;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _pollingTimer;

  // Getters
  List<Job> get jobs => _jobs;
  Job? get currentJob => _currentJob;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Create a new job and start polling for status
  Future<Job> createJob({
    required Uint8List imageBytes,
    required String imageName,
    required String prompt,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final job = await _apiService.createJob(
        imageBytes: imageBytes,
        imageName: imageName,
        prompt: prompt,
      );

      _currentJob = job;
      _jobs.insert(0, job); // Add to beginning of list
      _isLoading = false;
      notifyListeners();

      // Start polling for job status if it's processing
      if (job.isProcessing) {
        _startPolling(job.id);
      }

      return job;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Start polling for job status updates (polls ALL processing jobs)
  void _startPolling(String jobId) {
    // If polling is already running, just return (it will poll all jobs)
    if (_pollingTimer != null && _pollingTimer!.isActive) {
      return;
    }

    // Poll every 2 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        // Get all processing jobs
        final processingJobs = _jobs.where((j) => j.isProcessing).toList();

        if (processingJobs.isEmpty) {
          // No processing jobs, stop polling
          _stopPolling();
          return;
        }

        // Refresh all processing jobs
        for (final job in processingJobs) {
          try {
            await refreshJob(job.id);
          } catch (e) {
            debugPrint('Error refreshing job ${job.id}: $e');
          }
        }
      } catch (e) {
        debugPrint('Polling error: $e');
      }
    });
  }

  /// Stop polling for job status
  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Load all jobs (version history)
  Future<void> loadJobs() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _jobs = await _apiService.getAllJobs();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Refresh current job status
  Future<void> refreshJob(String jobId) async {
    try {
      final job = await _apiService.getJob(jobId);

      // Update in list
      final index = _jobs.indexWhere((j) => j.id == jobId);
      if (index != -1) {
        _jobs[index] = job;
      }

      // Update current if it's the same
      if (_currentJob?.id == jobId) {
        _currentJob = job;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Set current job
  void setCurrentJob(Job job) {
    _currentJob = job;
    notifyListeners();
  }

  /// Delete a job
  Future<void> deleteJob(String jobId) async {
    try {
      await _apiService.deleteJob(jobId);

      _jobs.removeWhere((j) => j.id == jobId);

      if (_currentJob?.id == jobId) {
        _currentJob = null;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear current job
  void clearCurrentJob() {
    _currentJob = null;
    notifyListeners();
  }

  /// Reset all state
  void reset() {
    _stopPolling();
    _jobs = [];
    _currentJob = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
