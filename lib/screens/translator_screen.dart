import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loai/providers/settings_provider.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  String _sourceLanguage = 'auto';
  String _targetLanguage = 'en';
  String _inputText = '';
  String _translatedText = '';
  bool _isTranslating = false;
  String _exampleUsage = '';

  final List<String> _languages = [
    'auto',
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ru',
    'zh',
    'ja',
    'ko',
    'ar',
    'hi',
  ];

  final Map<String, String> _languageNames = {
    'auto': 'Auto-detect',
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
    'ar': 'Arabic',
    'hi': 'Hindi',
  };

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Translator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Show translation history
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Language selectors
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardTheme.color,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sourceLanguage,
                    items: _languages.map((lang) {
                      return DropdownMenuItem<String>(
                        value: lang,
                        child: Text(_languageNames[lang] ?? lang),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _sourceLanguage = value!),
                    decoration: InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: _swapLanguages,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _targetLanguage,
                    items: _languages.map((lang) {
                      return DropdownMenuItem<String>(
                        value: lang,
                        child: Text(_languageNames[lang] ?? lang),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _targetLanguage = value!),
                    decoration: InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Input section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Input Text',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        hintText: 'Enter text to translate...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      onChanged: (value) => setState(() => _inputText = value),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Translate button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: _isTranslating || _inputText.isEmpty ? null : _translate,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isTranslating
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Translate'),
            ),
          ),
          
          // Output section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Translation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      child: _translatedText.isEmpty
                        ? Center(
                            child: Text(
                              'Translation will appear here',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          )
                        : SelectableText(
                            _translatedText,
                            style: const TextStyle(fontSize: 16),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Example usage
          if (_exampleUsage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Example Usage:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Text(_exampleUsage),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
    });
  }

  void _translate() {
    if (_inputText.isEmpty) return;
    
    setState(() {
      _isTranslating = true;
      _translatedText = '';
      _exampleUsage = '';
    });

    // Simulate translation
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isTranslating = false;
        _translatedText = '[Translated] ${_inputText} [${_sourceLanguage} -> ${_targetLanguage}]';
        _exampleUsage = 'Example: This is how you would use "${_inputText.split(' ').first}" in a sentence.';
      });
    });
  }
}
