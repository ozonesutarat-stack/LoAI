import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loai/providers/theme_provider.dart';
import 'package:loai/providers/settings_provider.dart';
import 'package:loai/providers/model_provider.dart';
import 'package:loai/screens/model_manager_screen.dart';
import 'package:loai/screens/persona_manager_screen.dart';
import 'package:loai/screens/tool_manager_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'AI'),
            Tab(text: 'UI'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const GeneralSettingsScreen(),
          const AISettingsScreen(),
          const UISettingsScreen(),
        ],
      ),
    );
  }
}

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final modelProvider = Provider.of<ModelProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Language', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: settingsProvider.language,
                    items: [
                      'en',
                      'es',
                      'fr',
                      'de',
                      'it',
                    ].map((lang) {
                      return DropdownMenuItem<String>(
                        value: lang,
                        child: Text(_getLanguageName(lang)),
                      );
                    }).toList(),
                    onChanged: (value) => settingsProvider.setLanguage(value!),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Chat history
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chat History', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Save chat history'),
                    value: settingsProvider.saveChatHistory,
                    onChanged: (value) => settingsProvider.setSaveChatHistory(value),
                    secondary: const Icon(Icons.history),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Auto update
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Updates', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Auto check for updates'),
                    value: settingsProvider.autoUpdate,
                    onChanged: (value) => settingsProvider.setAutoUpdate(value),
                    secondary: const Icon(Icons.system_update),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Privacy
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Privacy', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Usage analytics'),
                    subtitle: const Text('Help improve LoAI by sending anonymous usage data'),
                    value: settingsProvider.useAnalytics,
                    onChanged: (value) => settingsProvider.setUseAnalytics(value),
                    secondary: const Icon(Icons.analytics),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Reset settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reset Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Reset all settings to their default values'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.restore, color: Colors.red),
                    label: const Text('Reset to Defaults', style: TextStyle(color: Colors.red)),
                    onPressed: () => _showResetDialog(context, settingsProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    const names = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
    };
    return names[code] ?? code;
  }

  void _showResetDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              settingsProvider.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class AISettingsScreen extends StatelessWidget {
  const AISettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final modelProvider = Provider.of<ModelProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Model Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Temperature
                  _buildSliderSetting(
                    context,
                    'Temperature',
                    settingsProvider.temperature,
                    0.0,
                    2.0,
                    (value) => settingsProvider.setTemperature(value),
                    'Controls randomness. Lower values produce more deterministic outputs.',
                  ),
                  const SizedBox(height: 16),
                  
                  // Context length
                  _buildSliderSetting(
                    context,
                    'Context Length',
                    settingsProvider.contextLength.toDouble(),
                    256,
                    32768,
                    (value) => settingsProvider.setContextLength(value.toInt()),
                    'Maximum number of tokens in the conversation context.',
                  ),
                  const SizedBox(height: 16),
                  
                  // Max tokens
                  _buildSliderSetting(
                    context,
                    'Max Tokens',
                    settingsProvider.maxTokens.toDouble(),
                    1,
                    32768,
                    (value) => settingsProvider.setMaxTokens(value.toInt()),
                    'Maximum number of tokens to generate in the response.',
                  ),
                  const SizedBox(height: 16),
                  
                  // Top P
                  _buildSliderSetting(
                    context,
                    'Top P (Nucleus Sampling)',
                    settingsProvider.topP,
                    0.0,
                    1.0,
                    (value) => settingsProvider.setTopP(value),
                    'Sample from the top p probability mass.',
                  ),
                  const SizedBox(height: 16),
                  
                  // Top K
                  _buildSliderSetting(
                    context,
                    'Top K',
                    settingsProvider.topK.toDouble(),
                    1,
                    1000,
                    (value) => settingsProvider.setTopK(value.toInt()),
                    'Sample from the top k most likely tokens.',
                  ),
                  const SizedBox(height: 16),
                  
                  // Repeat penalty
                  _buildSliderSetting(
                    context,
                    'Repeat Penalty',
                    settingsProvider.repeatPenalty.toDouble(),
                    1,
                    10,
                    (value) => settingsProvider.setRepeatPenalty(value.toInt()),
                    'Penalize repeated tokens to reduce repetition.',
                  ),
                  const SizedBox(height: 16),
                  
                  // Use cache
                  SwitchListTile(
                    title: const Text('Use Cache'),
                    subtitle: const Text('Cache model outputs for faster responses'),
                    value: settingsProvider.useCache,
                    onChanged: (value) => settingsProvider.setUseCache(value),
                    secondary: const Icon(Icons.memory),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // API settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('API Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'API Endpoint',
                      hintText: 'https://api.example.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => settingsProvider.setApiEndpoint(value),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'API Key',
                      hintText: 'Enter your API key',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.visibility_off),
                        onPressed: () {
                          // Toggle visibility
                        },
                      ),
                    ),
                    obscureText: true,
                    onChanged: (value) => settingsProvider.setApiKey(value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Model management
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Model Management', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Manage your AI models and download new ones'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.manage_history),
                    label: const Text('Manage Models'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ModelManagerScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    BuildContext context,
    String title,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)),
          ],
        ),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class UISettingsScreen extends StatefulWidget {
  const UISettingsScreen({super.key});

  @override
  State<UISettingsScreen> createState() => _UISettingsScreenState();
}

class _UISettingsScreenState extends State<UISettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Theme', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<ThemeMode>(
                          title: const Text('Light'),
                          value: ThemeMode.light,
                          groupValue: themeProvider.themeMode,
                          onChanged: (value) => themeProvider.setThemeMode(value!),
                          secondary: const Icon(Icons.light_mode),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<ThemeMode>(
                          title: const Text('Dark'),
                          value: ThemeMode.dark,
                          groupValue: themeProvider.themeMode,
                          onChanged: (value) => themeProvider.setThemeMode(value!),
                          secondary: const Icon(Icons.dark_mode),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<ThemeMode>(
                          title: const Text('System'),
                          value: ThemeMode.system,
                          groupValue: themeProvider.themeMode,
                          onChanged: (value) => themeProvider.setThemeMode(value!),
                          secondary: const Icon(Icons.brightness_auto),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Colors
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Colors', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  _buildColorSetting(
                    context,
                    'Primary Color',
                    themeProvider.primaryColor,
                    (color) => themeProvider.setPrimaryColor(color),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildColorSetting(
                    context,
                    'Secondary Color',
                    themeProvider.secondaryColor,
                    (color) => themeProvider.setSecondaryColor(color),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildColorSetting(
                    context,
                    'Accent Color',
                    themeProvider.accentColor,
                    (color) => themeProvider.setAccentColor(color),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Chat bubble style
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chat Bubble Style', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('Use Gradient'),
                    subtitle: const Text('Use gradient colors for chat bubbles'),
                    value: themeProvider.useGradient,
                    onChanged: (value) => themeProvider.setUseGradient(value),
                    secondary: const Icon(Icons.gradient),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSliderSetting(
                    context,
                    'Blur',
                    themeProvider.blur,
                    0.0,
                    100.0,
                    (value) => themeProvider.setBlur(value),
                    'Background blur for chat bubbles',
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSliderSetting(
                    context,
                    'Transparency',
                    themeProvider.transparency,
                    0.0,
                    1.0,
                    (value) => themeProvider.setTransparency(value),
                    'Transparency of chat bubbles',
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSliderSetting(
                    context,
                    'Edge Thickness',
                    themeProvider.edgeThickness,
                    0.0,
                    10.0,
                    (value) => themeProvider.setEdgeThickness(value),
                    'Thickness of chat bubble edges',
                  ),
                  const SizedBox(height: 16),
                  
                  _buildColorSetting(
                    context,
                    'Edge Color',
                    themeProvider.edgeColor,
                    (color) => themeProvider.setEdgeColor(color),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSliderSetting(
                    context,
                    'Edge Transparency',
                    themeProvider.edgeTransparency,
                    0.0,
                    1.0,
                    (value) => themeProvider.setEdgeTransparency(value),
                    'Transparency of chat bubble edges',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Display settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Display Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('Show Timestamps'),
                    subtitle: const Text('Show message timestamps'),
                    value: settingsProvider.showTimestamps,
                    onChanged: (value) => settingsProvider.setShowTimestamps(value),
                    secondary: const Icon(Icons.schedule),
                  ),
                  const SizedBox(height: 8),
                  
                  SwitchListTile(
                    title: const Text('Show Message Count'),
                    subtitle: const Text('Show message count in conversations'),
                    value: settingsProvider.showMessageCount,
                    onChanged: (value) => settingsProvider.setShowMessageCount(value),
                    secondary: const Icon(Icons.message),
                  ),
                  const SizedBox(height: 8),
                  
                  SwitchListTile(
                    title: const Text('Show Token Count'),
                    subtitle: const Text('Show token count for messages'),
                    value: settingsProvider.showTokenCount,
                    onChanged: (value) => settingsProvider.setShowTokenCount(value),
                    secondary: const Icon(Icons.token),
                  ),
                  const SizedBox(height: 8),
                  
                  SwitchListTile(
                    title: const Text('Auto Scroll'),
                    subtitle: const Text('Automatically scroll to new messages'),
                    value: settingsProvider.autoScroll,
                    onChanged: (value) => settingsProvider.setAutoScroll(value),
                    secondary: const Icon(Icons.vertical_align_bottom),
                  ),
                  const SizedBox(height: 8),
                  
                  SwitchListTile(
                    title: const Text('Use Markdown'),
                    subtitle: const Text('Render markdown formatting in messages'),
                    value: settingsProvider.useMarkdown,
                    onChanged: (value) => settingsProvider.setUseMarkdown(value),
                    secondary: const Icon(Icons.format_align_left),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSetting(
    BuildContext context,
    String title,
    Color currentColor,
    Function(Color) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: currentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.color_lens),
          label: const Text('Change Color'),
          onPressed: () => _showColorPicker(context, currentColor, onChanged),
        ),
      ],
    );
  }

  Widget _buildSliderSetting(
    BuildContext context,
    String title,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)),
          ],
        ),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _showColorPicker(
    BuildContext context,
    Color currentColor,
    Function(Color) onChanged,
  ) {
    // Simple color picker dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color palette
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Colors.red,
                Colors.pink,
                Colors.purple,
                Colors.deepPurple,
                Colors.indigo,
                Colors.blue,
                Colors.lightBlue,
                Colors.cyan,
                Colors.teal,
                Colors.green,
                Colors.lightGreen,
                Colors.lime,
                Colors.yellow,
                Colors.amber,
                Colors.orange,
                Colors.deepOrange,
                Colors.brown,
                Colors.grey,
                Colors.blueGrey,
              ].map((color) => GestureDetector(
                onTap: () {
                  onChanged(color);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: currentColor == color ? Colors.black : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
