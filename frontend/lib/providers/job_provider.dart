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

  // Getters
  List<Job> get jobs => _jobs;
  Job? get currentJob => _currentJob;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Create a new job
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

      return job;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
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
    _jobs = [];
    _currentJob = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
