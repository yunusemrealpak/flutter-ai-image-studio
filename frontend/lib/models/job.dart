/// Job status enum
enum JobStatus {
  pending,
  processing,
  completed,
  failed;

  /// Parse status from string
  static JobStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return JobStatus.pending;
      case 'processing':
        return JobStatus.processing;
      case 'completed':
        return JobStatus.completed;
      case 'failed':
        return JobStatus.failed;
      default:
        return JobStatus.pending;
    }
  }
}

/// Job model representing an image editing task
class Job {
  final String id;
  final String originalImageUrl;
  final String? editedImageUrl;
  final String prompt;
  final JobStatus status;
  final int progress; // Progress percentage (0-100)
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Job({
    required this.id,
    required this.originalImageUrl,
    this.editedImageUrl,
    required this.prompt,
    required this.status,
    this.progress = 0,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create Job from JSON
  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      originalImageUrl: json['original_image_url'] as String,
      editedImageUrl: json['edited_image_url'] as String?,
      prompt: json['prompt'] as String,
      status: JobStatus.fromString(json['status'] as String),
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      errorMessage: json['error_message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert Job to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_image_url': originalImageUrl,
      'edited_image_url': editedImageUrl,
      'prompt': prompt,
      'status': status.name,
      'progress': progress,
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of Job with updated fields
  Job copyWith({
    String? id,
    String? originalImageUrl,
    String? editedImageUrl,
    String? prompt,
    JobStatus? status,
    int? progress,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Job(
      id: id ?? this.id,
      originalImageUrl: originalImageUrl ?? this.originalImageUrl,
      editedImageUrl: editedImageUrl ?? this.editedImageUrl,
      prompt: prompt ?? this.prompt,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isCompleted => status == JobStatus.completed;
  bool get isProcessing => status == JobStatus.processing;
  bool get isFailed => status == JobStatus.failed;
  bool get isPending => status == JobStatus.pending;
  bool get hasEditedImage => editedImageUrl != null && editedImageUrl!.isNotEmpty;
}
