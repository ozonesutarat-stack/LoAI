import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loai/models/ai_model.dart';
import 'package:loai/models/persona.dart';
import 'package:loai/utils/constants.dart';

class ModelProvider with ChangeNotifier {
  List<AIModel> _models = [];
  List<Persona> _personas = [];
  AIModel? _currentChatModel;
  AIModel? _currentImageModel;
  AIModel? _currentTtsModel;
  AIModel? _currentSttModel;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _downloadError;
  List<String> _downloadedModelIds = [];
  
  // Getters
  List<AIModel> get models => _models;
  List<Persona> get personas => _personas;
  AIModel? get currentChatModel => _currentChatModel;
  AIModel? get currentImageModel => _currentImageModel;
  AIModel? get currentTtsModel => _currentTtsModel;
  AIModel? get currentSttModel => _currentSttModel;
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;
  String? get downloadError => _downloadError;
  List<String> get downloadedModelIds => _downloadedModelIds;
  
  // Get models by type
  List<AIModel> get chatModels => _models.where((m) => m.type == ModelType.chat).toList();
  List<AIModel> get imageModels => _models.where((m) => m.type == ModelType.image).toList();
  List<AIModel> get ttsModels => _models.where((m) => m.type == ModelType.tts).toList();
  List<AIModel> get sttModels => _models.where((m) => m.type == ModelType.stt).toList();
  
  // Get downloaded models
  List<AIModel> get downloadedModels => _models.where((m) => m.status == ModelStatus.downloaded || m.status == ModelStatus.loaded).toList();
  
  // Get local models
  List<AIModel> get localModels => _models.where((m) => m.source == ModelSource.local).toList();
  
  // Get Hugging Face models
  List<AIModel> get huggingFaceModels => _models.where((m) => m.source == ModelSource.huggingFace).toList();
  
  // Get API models
  List<AIModel> get apiModels => _models.where((m) => m.source == ModelSource.api).toList();
  
  // Get favorite models
  List<AIModel> get favoriteModels => _models.where((m) => m.isFavorite).toList();
  
  // Get preset personas
  List<Persona> get presetPersonas => _personas.where((p) => p.isPreset).toList();
  
  // Get custom personas
  List<Persona> get customPersonas => _personas.where((p) => !p.isPreset).toList();
  
  ModelProvider() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    await _loadPreferences();
    _personas = Persona.getPresetPersonas();
    notifyListeners();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _downloadedModelIds = prefs.getStringList('downloaded_models') ?? [];
  }
  
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('downloaded_models', _downloadedModelIds);
  }
  
  // Initialize with existing models
  void initialize(List<AIModel> models) {
    _models = models;
    notifyListeners();
  }
  
  // Add model
  void addModel(AIModel model) {
    _models.add(model);
    notifyListeners();
  }
  
  // Remove model
  void removeModel(String modelId) {
    _models.removeWhere((m) => m.id == modelId);
    if (_currentChatModel?.id == modelId) _currentChatModel = null;
    if (_currentImageModel?.id == modelId) _currentImageModel = null;
    if (_currentTtsModel?.id == modelId) _currentTtsModel = null;
    if (_currentSttModel?.id == modelId) _currentSttModel = null;
    notifyListeners();
  }
  
  // Set current chat model
  void setCurrentChatModel(String? modelId) {
    _currentChatModel = _models.firstWhere(
      (m) => m.id == modelId,
      orElse: () => null,
    );
    notifyListeners();
  }
  
  // Set current image model
  void setCurrentImageModel(String? modelId) {
    _currentImageModel = _models.firstWhere(
      (m) => m.id == modelId,
      orElse: () => null,
    );
    notifyListeners();
  }
  
  // Set current TTS model
  void setCurrentTtsModel(String? modelId) {
    _currentTtsModel = _models.firstWhere(
      (m) => m.id == modelId,
      orElse: () => null,
    );
    notifyListeners();
  }
  
  // Set current STT model
  void setCurrentSttModel(String? modelId) {
    _currentSttModel = _models.firstWhere(
      (m) => m.id == modelId,
      orElse: () => null,
    );
    notifyListeners();
  }
  
  // Toggle favorite model
  void toggleFavoriteModel(String modelId) {
    final model = _models.firstWhere(
      (m) => m.id == modelId,
      orElse: () => null,
    );
    
    if (model != null) {
      final index = _models.indexOf(model);
      _models[index] = model.copyWith(isFavorite: !model.isFavorite);
      notifyListeners();
    }
  }
  
  // Download model (simulated)
  Future<void> downloadModel(String modelId) async {
    final model = _models.firstWhere(
      (m) => m.id == modelId,
      orElse: () => null,
    );
    
    if (model == null) {
      _downloadError = 'Model not found';
      notifyListeners();
      return;
    }
    
    if (model.status == ModelStatus.downloaded || model.status == ModelStatus.loaded) {
      return;
    }
    
    _isDownloading = true;
    _downloadProgress = 0.0;
    _downloadError = null;
    notifyListeners();
    
    try {
      // Simulate download progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        _downloadProgress = i / 100;
        notifyListeners();
      }
      
      // Update model status
      final index = _models.indexOf(model);
      _models[index] = model.copyWith(
        status: ModelStatus.downloaded,
        progress: 1.0,
        localPath: '/path/to/downloaded/${model.name}',
      );
      
      _downloadedModelIds.add(modelId);
      await _savePreferences();
      
      _isDownloading = false;
      _downloadProgress = 0.0;
      notifyListeners();
      
    } catch (e) {
      _downloadError = e.toString();
      _isDownloading = false;
      _downloadProgress = 0.0;
      notifyListeners();
    }
  }
  
  // Load model
  Future<void> loadModel(String modelId) async {
    final model = _models.firstWhere(
      (m) => m.id == modelId,
      orElse: () => null,
    );
    
    if (model == null) {
      _downloadError = 'Model not found';
      notifyListeners();
      return;
    }
    
    if (model.status == ModelStatus.loaded) {
      return;
    }
    
    // Update model status
    final index = _models.indexOf(model);
    _models[index] = model.copyWith(status: ModelStatus.loading);
    notifyListeners();
    
    // Simulate loading
    await Future.delayed(const Duration(seconds: 2));
    
    _models[index] = model.copyWith(status: ModelStatus.loaded);
    notifyListeners();
  }
  
  // Unload model
  void unloadModel(String modelId) {
    final model = _models.firstWhere(
      (m) => m.id == modelId,
      orElse: () => null,
    );
    
    if (model != null) {
      final index = _models.indexOf(model);
      _models[index] = model.copyWith(status: ModelStatus.downloaded);
      notifyListeners();
    }
  }
  
  // Search models from Hugging Face
  Future<List<AIModel>> searchHuggingFaceModels(String query, ModelType type) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock results
    final mockModels = [
      AIModel(
        name: 'llama-2-7b-chat',
        description: 'Llama 2 7B parameter chat model',
        type: ModelType.chat,
        source: ModelSource.huggingFace,
        sourceId: 'meta-llama/Llama-2-7b-chat',
        sourceUrl: 'https://huggingface.co/meta-llama/Llama-2-7b-chat',
        author: 'Meta',
        fileSize: 14 * 1024 * 1024 * 1024, // 14GB
        tags: ['llama', 'chat', '7b'],
      ),
      AIModel(
        name: 'mistral-7b-instruct',
        description: 'Mistral 7B parameter instruction model',
        type: ModelType.chat,
        source: ModelSource.huggingFace,
        sourceId: 'mistralai/Mistral-7B-Instruct-v0.2',
        sourceUrl: 'https://huggingface.co/mistralai/Mistral-7B-Instruct-v0.2',
        author: 'Mistral AI',
        fileSize: 14 * 1024 * 1024 * 1024, // 14GB
        tags: ['mistral', 'chat', '7b'],
      ),
      AIModel(
        name: 'phi-2',
        description: 'Phi-2 2.7B parameter model',
        type: ModelType.chat,
        source: ModelSource.huggingFace,
        sourceId: 'microsoft/phi-2',
        sourceUrl: 'https://huggingface.co/microsoft/phi-2',
        author: 'Microsoft',
        fileSize: 2 * 1024 * 1024 * 1024, // 2GB
        tags: ['phi', 'chat', '2.7b'],
      ),
      AIModel(
        name: 'stable-diffusion-v1-5',
        description: 'Stable Diffusion v1.5 image generation model',
        type: ModelType.image,
        source: ModelSource.huggingFace,
        sourceId: 'runwayml/stable-diffusion-v1-5',
        sourceUrl: 'https://huggingface.co/runwayml/stable-diffusion-v1-5',
        author: 'Runway ML',
        fileSize: 2 * 1024 * 1024 * 1024, // 2GB
        tags: ['stable-diffusion', 'image'],
      ),
    ];
    
    return mockModels
      .where((m) => m.name.toLowerCase().contains(query.toLowerCase()) || 
                    m.description.toLowerCase().contains(query.toLowerCase()))
      .where((m) => m.type == type)
      .toList();
  }
  
  // Add custom persona
  void addPersona(Persona persona) {
    _personas.add(persona);
    notifyListeners();
  }
  
  // Update persona
  void updatePersona(Persona persona) {
    final index = _personas.indexWhere((p) => p.id == persona.id);
    if (index != -1) {
      _personas[index] = persona;
      notifyListeners();
    }
  }
  
  // Delete persona
  void deletePersona(String personaId) {
    _personas.removeWhere((p) => p.id == personaId);
    notifyListeners();
  }
  
  // Toggle favorite persona
  void toggleFavoritePersona(String personaId) {
    final persona = _personas.firstWhere(
      (p) => p.id == personaId,
      orElse: () => null,
    );
    
    if (persona != null) {
      final index = _personas.indexOf(persona);
      _personas[index] = persona.copyWith(isFavorite: !persona.isFavorite);
      notifyListeners();
    }
  }
  
  // Get persona by ID
  Persona? getPersonaById(String personaId) {
    return _personas.firstWhere(
      (p) => p.id == personaId,
      orElse: () => null,
    );
  }
  
  // Get model by ID
  AIModel? getModelById(String modelId) {
    return _models.firstWhere(
      (m) => m.id == modelId,
      orElse: () => null,
    );
  }
  
  // Copy model file (simulated)
  Future<bool> copyModelFile(String modelId) async {
    final model = getModelById(modelId);
    if (model == null) return false;
    
    // Simulate file copy
    await Future.delayed(const Duration(seconds: 1));
    
    // Update model to indicate it's now local
    final index = _models.indexOf(model);
    _models[index] = model.copyWith(
      source: ModelSource.local,
      localPath: '/path/to/copied/${model.name}',
    );
    
    notifyListeners();
    return true;
  }
  
  // Check for extended models (simulated)
  Future<List<AIModel>> checkForExtendedModels(String modelId) async {
    final baseModel = getModelById(modelId);
    if (baseModel == null) return [];
    
    // Simulate checking for extended models
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock extended models
    if (baseModel.name.toLowerCase().contains('llama')) {
      return [
        AIModel(
          name: '${baseModel.name}-mmproj',
          description: 'MMProj adapter for ${baseModel.name}',
          type: baseModel.type,
          source: ModelSource.huggingFace,
          sourceId: '${baseModel.sourceId}-mmproj',
          fileSize: 500 * 1024 * 1024, // 500MB
          tags: ['mmproj', 'adapter', baseModel.name],
        ),
      ];
    }
    
    return [];
  }
}
