import 'package:uuid/uuid.dart';

class Persona {
  final String id;
  final String name;
  final String description;
  final String systemPrompt;
  final String? icon;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPreset;
  final bool isFavorite;
  final int usageCount;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  
  Persona({
    String? id,
    required this.name,
    required this.description,
    required this.systemPrompt,
    this.icon,
    this.color,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPreset = false,
    this.isFavorite = false,
    this.usageCount = 0,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       tags = tags ?? [],
       metadata = metadata ?? {};
  
  // Create preset personas
  static List<Persona> getPresetPersonas() {
    return [
      Persona(
        name: 'Tutor',
        description: 'Helpful tutor for explaining concepts and providing guidance',
        systemPrompt: 'You are a helpful tutor. Explain concepts clearly and provide step-by-step guidance. Be patient and encourage learning.',
        icon: '🎓',
        color: '#4CAF50',
        isPreset: true,
      ),
      Persona(
        name: 'Math Teacher',
        description: 'Expert math teacher for solving problems and explaining concepts',
        systemPrompt: 'You are a math teacher. Solve problems step-by-step and explain mathematical concepts clearly. Show your work and provide detailed explanations.',
        icon: '➗',
        color: '#2196F3',
        isPreset: true,
      ),
      Persona(
        name: 'Developer',
        description: 'Senior developer for coding assistance and debugging',
        systemPrompt: 'You are a senior developer. Provide code solutions, debug issues, and explain programming concepts. Write clean, efficient, and well-documented code.',
        icon: '💻',
        color: '#FF5722',
        isPreset: true,
      ),
      Persona(
        name: 'Roleplaying',
        description: 'Creative roleplaying assistant for various scenarios',
        systemPrompt: 'You are a roleplaying assistant. Stay in character and respond appropriately to the roleplay scenario. Be creative and immersive.',
        icon: '🎭',
        color: '#9C27B0',
        isPreset: true,
      ),
      Persona(
        name: 'Writer',
        description: 'Creative writer for story ideas and writing improvement',
        systemPrompt: 'You are a creative writer. Help with story ideas, character development, and writing improvement. Provide engaging and well-written content.',
        icon: '✍️',
        color: '#795548',
        isPreset: true,
      ),
      Persona(
        name: 'Translator',
        description: 'Professional translator for accurate translations',
        systemPrompt: 'You are a professional translator. Provide accurate translations with context and examples. Handle different languages and dialects.',
        icon: '🌍',
        color: '#FF9800',
        isPreset: true,
      ),
      Persona(
        name: 'Therapist',
        description: 'Supportive therapist for emotional support and advice',
        systemPrompt: 'You are a supportive therapist. Provide emotional support, advice, and coping strategies. Be empathetic, understanding, and non-judgmental.',
        icon: '💙',
        color: '#E91E63',
        isPreset: true,
      ),
      Persona(
        name: 'Scientist',
        description: 'Knowledgeable scientist for explaining scientific concepts',
        systemPrompt: 'You are a knowledgeable scientist. Explain scientific concepts accurately and provide evidence-based information. Use clear and understandable language.',
        icon: '🔬',
        color: '#3F51B5',
        isPreset: true,
      ),
    ];
  }
  
  // Copy with
  Persona copyWith({
    String? id,
    String? name,
    String? description,
    String? systemPrompt,
    String? icon,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPreset,
    bool? isFavorite,
    int? usageCount,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return Persona(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPreset: isPreset ?? this.isPreset,
      isFavorite: isFavorite ?? this.isFavorite,
      usageCount: usageCount ?? this.usageCount,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'systemPrompt': systemPrompt,
      'icon': icon,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPreset': isPreset,
      'isFavorite': isFavorite,
      'usageCount': usageCount,
      'tags': tags,
      'metadata': metadata,
    };
  }
  
  factory Persona.fromMap(Map<String, dynamic> map) {
    return Persona(
      id: map['id'] ?? const Uuid().v4(),
      name: map['name'] ?? 'Untitled Persona',
      description: map['description'] ?? '',
      systemPrompt: map['systemPrompt'] ?? '',
      icon: map['icon'],
      color: map['color'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      isPreset: map['isPreset'] ?? false,
      isFavorite: map['isFavorite'] ?? false,
      usageCount: map['usageCount'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      metadata: map['metadata'] ?? {},
    );
  }
  
  @override
  String toString() {
    return 'Persona(id: $id, name: $name, isPreset: $isPreset)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Persona && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
