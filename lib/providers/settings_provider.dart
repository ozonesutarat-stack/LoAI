import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loai/utils/constants.dart';

class SettingsProvider with ChangeNotifier {
  // AI Settings
  double _temperature = AppConstants.defaultTemperature;
  int _contextLength = AppConstants.defaultContextLength;
  int _maxTokens = AppConstants.defaultMaxTokens;
  double _topP = AppConstants.defaultTopP;
  int _topK = AppConstants.defaultTopK;
  int _repeatPenalty = 1;
  bool _useCache = true;
  String? _apiEndpoint;
  String? _apiKey;
  
  // UI Settings
  bool _showTimestamps = true;
  bool _showMessageCount = true;
  bool _showTokenCount = true;
  bool _autoScroll = true;
  bool _useMarkdown = true;
  String _language = 'en';
  
  // Speech Settings
  String _ttsVoice = 'default';
  double _ttsSpeed = 1.0;
  double _ttsPitch = 1.0;
  String _sttLanguage = 'en-US';
  bool _autoListen = false;
  
  // Privacy Settings
  bool _saveChatHistory = true;
  bool _useAnalytics = false;
  bool _autoUpdate = true;
  
  // Getters
  double get temperature => _temperature;
  int get contextLength => _contextLength;
  int get maxTokens => _maxTokens;
  double get topP => _topP;
  int get topK => _topK;
  int get repeatPenalty => _repeatPenalty;
  bool get useCache => _useCache;
  String? get apiEndpoint => _apiEndpoint;
  String? get apiKey => _apiKey;
  
  bool get showTimestamps => _showTimestamps;
  bool get showMessageCount => _showMessageCount;
  bool get showTokenCount => _showTokenCount;
  bool get autoScroll => _autoScroll;
  bool get useMarkdown => _useMarkdown;
  String get language => _language;
  
  String get ttsVoice => _ttsVoice;
  double get ttsSpeed => _ttsSpeed;
  double get ttsPitch => _ttsPitch;
  String get sttLanguage => _sttLanguage;
  bool get autoListen => _autoListen;
  
  bool get saveChatHistory => _saveChatHistory;
  bool get useAnalytics => _useAnalytics;
  bool get autoUpdate => _autoUpdate;
  
  SettingsProvider() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    _temperature = prefs.getDouble('temperature') ?? AppConstants.defaultTemperature;
    _contextLength = prefs.getInt('context_length') ?? AppConstants.defaultContextLength;
    _maxTokens = prefs.getInt('max_tokens') ?? AppConstants.defaultMaxTokens;
    _topP = prefs.getDouble('top_p') ?? AppConstants.defaultTopP;
    _topK = prefs.getInt('top_k') ?? AppConstants.defaultTopK;
    _repeatPenalty = prefs.getInt('repeat_penalty') ?? 1;
    _useCache = prefs.getBool('use_cache') ?? true;
    _apiEndpoint = prefs.getString('api_endpoint');
    // Don't load API key for security
    
    _showTimestamps = prefs.getBool('show_timestamps') ?? true;
    _showMessageCount = prefs.getBool('show_message_count') ?? true;
    _showTokenCount = prefs.getBool('show_token_count') ?? true;
    _autoScroll = prefs.getBool('auto_scroll') ?? true;
    _useMarkdown = prefs.getBool('use_markdown') ?? true;
    _language = prefs.getString('language') ?? 'en';
    
    _ttsVoice = prefs.getString('tts_voice') ?? 'default';
    _ttsSpeed = prefs.getDouble('tts_speed') ?? 1.0;
    _ttsPitch = prefs.getDouble('tts_pitch') ?? 1.0;
    _sttLanguage = prefs.getString('stt_language') ?? 'en-US';
    _autoListen = prefs.getBool('auto_listen') ?? false;
    
    _saveChatHistory = prefs.getBool('save_chat_history') ?? true;
    _useAnalytics = prefs.getBool('use_analytics') ?? false;
    _autoUpdate = prefs.getBool('auto_update') ?? true;
    
    notifyListeners();
  }
  
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setDouble('temperature', _temperature);
    await prefs.setInt('context_length', _contextLength);
    await prefs.setInt('max_tokens', _maxTokens);
    await prefs.setDouble('top_p', _topP);
    await prefs.setInt('top_k', _topK);
    await prefs.setInt('repeat_penalty', _repeatPenalty);
    await prefs.setBool('use_cache', _useCache);
    await prefs.setString('api_endpoint', _apiEndpoint ?? '');
    
    await prefs.setBool('show_timestamps', _showTimestamps);
    await prefs.setBool('show_message_count', _showMessageCount);
    await prefs.setBool('show_token_count', _showTokenCount);
    await prefs.setBool('auto_scroll', _autoScroll);
    await prefs.setBool('use_markdown', _useMarkdown);
    await prefs.setString('language', _language);
    
    await prefs.setString('tts_voice', _ttsVoice);
    await prefs.setDouble('tts_speed', _ttsSpeed);
    await prefs.setDouble('tts_pitch', _ttsPitch);
    await prefs.setString('stt_language', _sttLanguage);
    await prefs.setBool('auto_listen', _autoListen);
    
    await prefs.setBool('save_chat_history', _saveChatHistory);
    await prefs.setBool('use_analytics', _useAnalytics);
    await prefs.setBool('auto_update', _autoUpdate);
  }
  
  // AI Settings setters
  Future<void> setTemperature(double value) async {
    _temperature = value.clamp(0.0, 2.0);
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setContextLength(int value) async {
    _contextLength = value.clamp(256, 32768);
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setMaxTokens(int value) async {
    _maxTokens = value.clamp(1, 32768);
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setTopP(double value) async {
    _topP = value.clamp(0.0, 1.0);
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setTopK(int value) async {
    _topK = value.clamp(1, 1000);
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setRepeatPenalty(int value) async {
    _repeatPenalty = value.clamp(1, 10);
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setUseCache(bool value) async {
    _useCache = value;
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setApiEndpoint(String? value) async {
    _apiEndpoint = value;
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setApiKey(String? value) async {
    _apiKey = value;
    // Don't save API key to preferences for security
    notifyListeners();
  }
  
  // UI Settings setters
  Future<void> setShowTimestamps(bool value) async {
    _showTimestamps = value;
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setShowMessageCount(bool value) async {
    _showMessageCount = value;
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setShowTokenCount(bool value) async {
    _showTokenCount = value;
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setAutoScroll(bool value) async {
    _autoScroll = value;
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setUseMarkdown(bool value) async {
    _useMarkdown = value;
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setLanguage(String value) async {
    _language = value;
    await _savePreferences();
    notifyListeners();
  }
  
  // Speech Settings setters
  Future<void> setTtsVoice(String value) async {
    _ttsVoice = value;
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setTtsSpeed(double value) async {
    _ttsSpeed = value.clamp(0.5, 2.0);
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setTtsPitch(double value) async {
    _ttsPitch = value.clamp(0.5, 2.0);
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setSttLanguage(String value) async {
    _sttLanguage = value;
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setAutoListen(bool value) async {
    _autoListen = value;
    await _savePreferences();
    notifyListeners();
  }
  
  // Privacy Settings setters
  Future<void> setSaveChatHistory(bool value) async {
    _saveChatHistory = value;
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setUseAnalytics(bool value) async {
    _useAnalytics = value;
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setAutoUpdate(bool value) async {
    _autoUpdate = value;
    await _savePreferences();
    notifyListeners();
  }
  
  // Get model config as map
  Map<String, dynamic> getModelConfig() {
    return {
      'temperature': _temperature,
      'context_length': _contextLength,
      'max_tokens': _maxTokens,
      'top_p': _topP,
      'top_k': _topK,
      'repeat_penalty': _repeatPenalty,
      'use_cache': _useCache,
    };
  }
  
  // Reset to defaults
  Future<void> resetToDefaults() async {
    _temperature = AppConstants.defaultTemperature;
    _contextLength = AppConstants.defaultContextLength;
    _maxTokens = AppConstants.defaultMaxTokens;
    _topP = AppConstants.defaultTopP;
    _topK = AppConstants.defaultTopK;
    _repeatPenalty = 1;
    _useCache = true;
    _apiEndpoint = null;
    
    _showTimestamps = true;
    _showMessageCount = true;
    _showTokenCount = true;
    _autoScroll = true;
    _useMarkdown = true;
    _language = 'en';
    
    _ttsVoice = 'default';
    _ttsSpeed = 1.0;
    _ttsPitch = 1.0;
    _sttLanguage = 'en-US';
    _autoListen = false;
    
    _saveChatHistory = true;
    _useAnalytics = false;
    _autoUpdate = true;
    
    await _savePreferences();
    notifyListeners();
  }
  
  // Export settings
  Map<String, dynamic> exportSettings() {
    return {
      'temperature': _temperature,
      'context_length': _contextLength,
      'max_tokens': _maxTokens,
      'top_p': _topP,
      'top_k': _topK,
      'repeat_penalty': _repeatPenalty,
      'use_cache': _useCache,
      'api_endpoint': _apiEndpoint,
      'show_timestamps': _showTimestamps,
      'show_message_count': _showMessageCount,
      'show_token_count': _showTokenCount,
      'auto_scroll': _autoScroll,
      'use_markdown': _useMarkdown,
      'language': _language,
      'tts_voice': _ttsVoice,
      'tts_speed': _ttsSpeed,
      'tts_pitch': _ttsPitch,
      'stt_language': _sttLanguage,
      'auto_listen': _autoListen,
      'save_chat_history': _saveChatHistory,
      'use_analytics': _useAnalytics,
      'auto_update': _autoUpdate,
    };
  }
  
  // Import settings
  Future<void> importSettings(Map<String, dynamic> settings) async {
    _temperature = (settings['temperature'] as num?)?.toDouble() ?? AppConstants.defaultTemperature;
    _contextLength = settings['context_length'] as int? ?? AppConstants.defaultContextLength;
    _maxTokens = settings['max_tokens'] as int? ?? AppConstants.defaultMaxTokens;
    _topP = (settings['top_p'] as num?)?.toDouble() ?? AppConstants.defaultTopP;
    _topK = settings['top_k'] as int? ?? AppConstants.defaultTopK;
    _repeatPenalty = settings['repeat_penalty'] as int? ?? 1;
    _useCache = settings['use_cache'] as bool? ?? true;
    _apiEndpoint = settings['api_endpoint'] as String?;
    
    _showTimestamps = settings['show_timestamps'] as bool? ?? true;
    _showMessageCount = settings['show_message_count'] as bool? ?? true;
    _showTokenCount = settings['show_token_count'] as bool? ?? true;
    _autoScroll = settings['auto_scroll'] as bool? ?? true;
    _useMarkdown = settings['use_markdown'] as bool? ?? true;
    _language = settings['language'] as String? ?? 'en';
    
    _ttsVoice = settings['tts_voice'] as String? ?? 'default';
    _ttsSpeed = (settings['tts_speed'] as num?)?.toDouble() ?? 1.0;
    _ttsPitch = (settings['tts_pitch'] as num?)?.toDouble() ?? 1.0;
    _sttLanguage = settings['stt_language'] as String? ?? 'en-US';
    _autoListen = settings['auto_listen'] as bool? ?? false;
    
    _saveChatHistory = settings['save_chat_history'] as bool? ?? true;
    _useAnalytics = settings['use_analytics'] as bool? ?? false;
    _autoUpdate = settings['auto_update'] as bool? ?? true;
    
    await _savePreferences();
    notifyListeners();
  }
}
