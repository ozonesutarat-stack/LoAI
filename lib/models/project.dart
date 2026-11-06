import 'package:uuid/uuid.dart';

class Project {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> conversationIds;
  final List<String> fileIds;
  final List<String> modelIds;
  final Map<String, dynamic> settings;
  final bool isFavorite;
  final String? color;
  
  Project({
    String? id,
    required this.name,
    this.description,
    this.icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? conversationIds,
    List<String>? fileIds,
    List<String>? modelIds,
    Map<String, dynamic>? settings,
    this.isFavorite = false,
    this.color,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       conversationIds = conversationIds ?? [],
       fileIds = fileIds ?? [],
       modelIds = modelIds ?? [],
       settings = settings ?? {};
  
  // Get conversation count
  int get conversationCount => conversationIds.length;
  
  // Get file count
  int get fileCount => fileIds.length;
  
  // Copy with
  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? conversationIds,
    List<String>? fileIds,
    List<String>? modelIds,
    Map<String, dynamic>? settings,
    bool? isFavorite,
    String? color,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      conversationIds: conversationIds ?? this.conversationIds,
      fileIds: fileIds ?? this.fileIds,
      modelIds: modelIds ?? this.modelIds,
      settings: settings ?? this.settings,
      isFavorite: isFavorite ?? this.isFavorite,
      color: color ?? this.color,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'conversationIds': conversationIds,
      'fileIds': fileIds,
      'modelIds': modelIds,
      'settings': settings,
      'isFavorite': isFavorite,
      'color': color,
    };
  }
  
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? const Uuid().v4(),
      name: map['name'] ?? 'Untitled Project',
      description: map['description'],
      icon: map['icon'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      conversationIds: List<String>.from(map['conversationIds'] ?? []),
      fileIds: List<String>.from(map['fileIds'] ?? []),
      modelIds: List<String>.from(map['modelIds'] ?? []),
      settings: map['settings'] ?? {},
      isFavorite: map['isFavorite'] ?? false,
      color: map['color'],
    );
  }
  
  @override
  String toString() {
    return 'Project(id: $id, name: $name, conversationCount: $conversationCount)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
