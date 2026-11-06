import 'package:uuid/uuid.dart';

enum ToolType {
  webSearch,
  knowledgeBase,
  custom,
  codeExecution,
  translation,
  documentReader,
}

enum ToolStatus {
  available,
  running,
  completed,
  error,
  disabled,
}

class Tool {
  final String id;
  final String name;
  final String description;
  final ToolType type;
  final String? icon;
  final String? color;
  final Map<String, dynamic> config;
  final ToolStatus status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEnabled;
  final bool isCustom;
  final String? customCode;
  final List<String> requiredPermissions;
  
  Tool({
    String? id,
    required this.name,
    required this.description,
    required this.type,
    this.icon,
    this.color,
    Map<String, dynamic>? config,
    this.status = ToolStatus.available,
    this.errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isEnabled = true,
    this.isCustom = false,
    this.customCode,
    List<String>? requiredPermissions,
  }) : id = id ?? const Uuid().v4(),
       config = config ?? {},
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       requiredPermissions = requiredPermissions ?? [];
  
  // Get display name
  String get displayName {
    if (icon != null && icon!.isNotEmpty) {
      return '$icon $name';
    }
    return name;
  }
  
  // Check if tool can be executed
  bool get canExecute => isEnabled && status == ToolStatus.available;
  
  // Get preset tools
  static List<Tool> getPresetTools() {
    return [
      Tool(
        name: 'Web Search',
        description: 'Search the web for current information and answers',
        type: ToolType.webSearch,
        icon: '🌐',
        color: '#4285F4',
        config: {
          'search_engine': 'google',
          'max_results': 5,
          'timeout': 10,
        },
        requiredPermissions: ['internet'],
      ),
      Tool(
        name: 'Knowledge Base',
        description: 'Search through imported documents and knowledge',
        type: ToolType.knowledgeBase,
        icon: '📚',
        color: '#34A853',
        config: {
          'index_type': 'vector',
          'max_results': 3,
          'similarity_threshold': 0.7,
        },
        requiredPermissions: ['storage'],
      ),
      Tool(
        name: 'Code Execution',
        description: 'Execute code in a safe sandbox environment',
        type: ToolType.codeExecution,
        icon: '💻',
        color: '#FBBC05',
        config: {
          'supported_languages': ['python', 'javascript', 'bash'],
          'timeout': 30,
          'memory_limit': '512MB',
        },
        requiredPermissions: ['storage'],
      ),
      Tool(
        name: 'Smart Translator',
        description: 'Translate text between languages with context',
        type: ToolType.translation,
        icon: '🌍',
        color: '#EA4335',
        config: {
          'default_source': 'auto',
          'default_target': 'en',
          'include_examples': true,
        },
      ),
      Tool(
        name: 'Document Reader',
        description: 'Read and summarize documents',
        type: ToolType.documentReader,
        icon: '📄',
        color: '#673AB7',
        config: {
          'max_file_size': 50,
          'supported_types': ['pdf', 'txt', 'doc', 'docx'],
          'summary_length': 'medium',
        },
        requiredPermissions: ['storage'],
      ),
    ];
  }
  
  // Copy with
  Tool copyWith({
    String? id,
    String? name,
    String? description,
    ToolType? type,
    String? icon,
    String? color,
    Map<String, dynamic>? config,
    ToolStatus? status,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEnabled,
    bool? isCustom,
    String? customCode,
    List<String>? requiredPermissions,
  }) {
    return Tool(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      config: config ?? this.config,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEnabled: isEnabled ?? this.isEnabled,
      isCustom: isCustom ?? this.isCustom,
      customCode: customCode ?? this.customCode,
      requiredPermissions: requiredPermissions ?? this.requiredPermissions,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.index,
      'icon': icon,
      'color': color,
      'config': config,
      'status': status.index,
      'errorMessage': errorMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEnabled': isEnabled,
      'isCustom': isCustom,
      'customCode': customCode,
      'requiredPermissions': requiredPermissions,
    };
  }
  
  factory Tool.fromMap(Map<String, dynamic> map) {
    return Tool(
      id: map['id'] ?? const Uuid().v4(),
      name: map['name'] ?? 'Untitled Tool',
      description: map['description'] ?? '',
      type: ToolType.values[map['type'] ?? 0],
      icon: map['icon'],
      color: map['color'],
      config: map['config'] ?? {},
      status: ToolStatus.values[map['status'] ?? 0],
      errorMessage: map['errorMessage'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      isEnabled: map['isEnabled'] ?? true,
      isCustom: map['isCustom'] ?? false,
      customCode: map['customCode'],
      requiredPermissions: List<String>.from(map['requiredPermissions'] ?? []),
    );
  }
  
  @override
  String toString() {
    return 'Tool(id: $id, name: $name, type: $type, status: $status)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tool && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

// Tool result class
class ToolResult {
  final String id;
  final String toolId;
  final String toolName;
  final ToolType toolType;
  final String input;
  final String output;
  final Map<String, dynamic> data;
  final ToolStatus status;
  final String? errorMessage;
  final DateTime timestamp;
  final Duration executionTime;
  
  ToolResult({
    String? id,
    required this.toolId,
    required this.toolName,
    required this.toolType,
    required this.input,
    required this.output,
    Map<String, dynamic>? data,
    this.status = ToolStatus.completed,
    this.errorMessage,
    DateTime? timestamp,
    Duration? executionTime,
  }) : id = id ?? const Uuid().v4(),
       data = data ?? {},
       timestamp = timestamp ?? DateTime.now(),
       executionTime = executionTime ?? Duration.zero;
  
  // Check if successful
  bool get isSuccessful => status == ToolStatus.completed && errorMessage == null;
  
  // Copy with
  ToolResult copyWith({
    String? id,
    String? toolId,
    String? toolName,
    ToolType? toolType,
    String? input,
    String? output,
    Map<String, dynamic>? data,
    ToolStatus? status,
    String? errorMessage,
    DateTime? timestamp,
    Duration? executionTime,
  }) {
    return ToolResult(
      id: id ?? this.id,
      toolId: toolId ?? this.toolId,
      toolName: toolName ?? this.toolName,
      toolType: toolType ?? this.toolType,
      input: input ?? this.input,
      output: output ?? this.output,
      data: data ?? this.data,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      timestamp: timestamp ?? this.timestamp,
      executionTime: executionTime ?? this.executionTime,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'toolId': toolId,
      'toolName': toolName,
      'toolType': toolType.index,
      'input': input,
      'output': output,
      'data': data,
      'status': status.index,
      'errorMessage': errorMessage,
      'timestamp': timestamp.toIso8601String(),
      'executionTime': executionTime.inMilliseconds,
    };
  }
  
  factory ToolResult.fromMap(Map<String, dynamic> map) {
    return ToolResult(
      id: map['id'] ?? const Uuid().v4(),
      toolId: map['toolId'] ?? '',
      toolName: map['toolName'] ?? '',
      toolType: ToolType.values[map['toolType'] ?? 0],
      input: map['input'] ?? '',
      output: map['output'] ?? '',
      data: map['data'] ?? {},
      status: ToolStatus.values[map['status'] ?? 0],
      errorMessage: map['errorMessage'],
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      executionTime: Duration(milliseconds: map['executionTime'] ?? 0),
    );
  }
  
  @override
  String toString() {
    return 'ToolResult(tool: $toolName, status: $status, output: ${output.length > 50 ? output.substring(0, 50) + '...' : output})';
  }
}
