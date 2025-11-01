import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/job.dart';

/// API service for job management
class JobApiService {
  final String baseUrl;

  JobApiService({
    this.baseUrl = 'https://flutter-ai-image-studio.onrender.com',
  });

  /// Helper to get MIME type from filename
  String _getMimeType(String filename) {
    final extension = filename.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Create a new job
  Future<Job> createJob({
    required Uint8List imageBytes,
    required String imageName,
    required String prompt,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/jobs');
      final request = http.MultipartRequest('POST', uri);

      // Add image file
      final mimeType = _getMimeType(imageName);
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // Add prompt
      request.fields['prompt'] = prompt;

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final jsonData = json.decode(responseBody);
        return Job.fromJson(jsonData);
      } else {
        final errorData = json.decode(responseBody);
        throw Exception(errorData['detail'] ?? 'Failed to create job');
      }
    } catch (e) {
      throw Exception('Failed to create job: $e');
    }
  }

  /// Get job by ID
  Future<Job> getJob(String jobId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/jobs/$jobId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Job.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to get job');
      }
    } catch (e) {
      throw Exception('Failed to get job: $e');
    }
  }

  /// Get all jobs (version history)
  Future<List<Job>> getAllJobs() async {
    try {
      final uri = Uri.parse('$baseUrl/api/jobs');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Job.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to get jobs');
      }
    } catch (e) {
      throw Exception('Failed to get jobs: $e');
    }
  }

  /// Delete a job
  Future<void> deleteJob(String jobId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/jobs/$jobId');
      final response = await http.delete(uri);

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to delete job');
      }
    } catch (e) {
      throw Exception('Failed to delete job: $e');
    }
  }
}
