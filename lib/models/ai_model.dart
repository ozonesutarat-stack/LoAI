import 'package:uuid/uuid.dart';

enum ModelType {
  chat,
  image,
  tts,
  stt,
  embedding,
}

enum ModelSource {
  local,
  huggingFace,
  api,
  custom,
}

enum ModelStatus {
  notDownloaded,
  downloading,
  downloaded,
  loading,
  loaded,
  error,
}

class AIModel {
  final String id;
  final String name;
  final String? description;
  final ModelType type;
  final ModelSource source;
  final String? sourceId;
  final String? sourceUrl;
  final String? localPath;
  final String? fileName;
  final int fileSize;
  final String? author;
  final String? license;
  final List<String> tags;
  final Map<String, dynamic> config;
  final ModelStatus status;
  final double progress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? errorMessage;
  final bool isFavorite;
  final int downloadCount;
  final double rating;
  
  AIModel({
    String? id,
    required this.name,
    this.description,
    required this.type,
    required this.source,
    this.sourceId,
    this.sourceUrl,
    this.localPath,
    this.fileName,
    this.fileSize = 0,
    this.author,
    this.license,
    List<String>? tags,
    Map<String, dynamic>? config,
    this.status = ModelStatus.notDownloaded,
    this.progress = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.errorMessage,
    this.isFavorite = false,
    this.downloadCount = 0,
    this.rating = 0.0,
  }) : id = id ?? const Uuid().v4(),
       tags = tags ?? [],
       config = config ?? {},
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
  
  // Check if model is ready to use
  bool get isReady => status == ModelStatus.loaded || 
                      (status == ModelStatus.downloaded && source == ModelSource.local);
  
  // Check if model is from Hugging Face
  bool get isFromHuggingFace => source == ModelSource.huggingFace;
  
  // Check if model is local
  bool get isLocal => source == ModelSource.local;
  
  // Check if model is API-based
  bool get isApi => source == ModelSource.api;
  
  // Get display name
  String get displayName {
    if (author != null && author!.isNotEmpty) {
      return '$name by $author';
    }
    return name;
  }
  
  // Get file size display
  String get fileSizeDisplay {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
  
  // Copy with
  AIModel copyWith({
    String? id,
    String? name,
    String? description,
    ModelType? type,
    ModelSource? source,
    String? sourceId,
    String? sourceUrl,
    String? localPath,
    String? fileName,
    int? fileSize,
    String? author,
    String? license,
    List<String>? tags,
    Map<String, dynamic>? config,
    ModelStatus? status,
    double? progress,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? errorMessage,
    bool? isFavorite,
    int? downloadCount,
    double? rating,
  }) {
    return AIModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      localPath: localPath ?? this.localPath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      author: author ?? this.author,
      license: license ?? this.license,
      tags: tags ?? this.tags,
      config: config ?? this.config,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      isFavorite: isFavorite ?? this.isFavorite,
      downloadCount: downloadCount ?? this.downloadCount,
      rating: rating ?? this.rating,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.index,
      'source': source.index,
      'sourceId': sourceId,
      'sourceUrl': sourceUrl,
      'localPath': localPath,
      'fileName': fileName,
      'fileSize': fileSize,
      'author': author,
      'license': license,
      'tags': tags,
      'config': config,
      'status': status.index,
      'progress': progress,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'errorMessage': errorMessage,
      'isFavorite': isFavorite,
      'downloadCount': downloadCount,
      'rating': rating,
    };
  }
  
  factory AIModel.fromMap(Map<String, dynamic> map) {
    return AIModel(
      id: map['id'] ?? const Uuid().v4(),
      name: map['name'] ?? 'Untitled Model',
      description: map['description'],
      type: ModelType.values[map['type'] ?? 0],
      source: ModelSource.values[map['source'] ?? 0],
      sourceId: map['sourceId'],
      sourceUrl: map['sourceUrl'],
      localPath: map['localPath'],
      fileName: map['fileName'],
      fileSize: map['fileSize'] ?? 0,
      author: map['author'],
      license: map['license'],
      tags: List<String>.from(map['tags'] ?? []),
      config: map['config'] ?? {},
      status: ModelStatus.values[map['status'] ?? 0],
      progress: map['progress'] ?? 0.0,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      errorMessage: map['errorMessage'],
      isFavorite: map['isFavorite'] ?? false,
      downloadCount: map['downloadCount'] ?? 0,
      rating: map['rating'] ?? 0.0,
    );
  }
  
  @override
  String toString() {
    return 'AIModel(id: $id, name: $name, type: $type, status: $status)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIModel && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

// Model configuration for different types
class ModelConfig {
  // Chat model config
  static Map<String, dynamic> getChatConfig({
    double temperature = 0.7,
    int contextLength = 2048,
    int maxTokens = 512,
    double topP = 0.9,
    int topK = 50,
    int repeatPenalty = 1,
    bool useCache = true,
  }) {
    return {
      'temperature': temperature,
      'context_length': contextLength,
      'max_tokens': maxTokens,
      'top_p': topP,
      'top_k': topK,
      'repeat_penalty': repeatPenalty,
      'use_cache': useCache,
    };
  }
  
  // Image model config
  static Map<String, dynamic> getImageConfig({
    int width = 512,
    int height = 512,
    int steps = 50,
    double guidanceScale = 7.5,
    String? negativePrompt,
  }) {
    return {
      'width': width,
      'height': height,
      'steps': steps,
      'guidance_scale': guidanceScale,
      'negative_prompt': negativePrompt,
    };
  }
  
  // TTS model config
  static Map<String, dynamic> getTtsConfig({
    String voice = 'default',
    double speed = 1.0,
    double pitch = 1.0,
    String? language,
  }) {
    return {
      'voice': voice,
      'speed': speed,
      'pitch': pitch,
      'language': language,
    };
  }
  
  // STT model config
  static Map<String, dynamic> getSttConfig({
    String language = 'en',
    bool continuous = false,
    int sampleRate = 16000,
  }) {
    return {
      'language': language,
      'continuous': continuous,
      'sample_rate': sampleRate,
    };
  }
}
