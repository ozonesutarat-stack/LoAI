import 'package:flutter/material.dart';
import 'package:loai/widgets/code_block.dart';

class CoDebugScreen extends StatefulWidget {
  const CoDebugScreen({super.key});

  @override
  State<CoDebugScreen> createState() => _CoDebugScreenState();
}

class _CoDebugScreenState extends State<CoDebugScreen> {
  String _code = '';
  String _language = 'python';
  String _output = '';
  String _aiResponse = '';
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Co-debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCode,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          // Language selector
          Container(
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).cardTheme.color,
            child: Row(
              children: [
                const Text('Language: '),
                DropdownButton<String>(
                  value: _language,
                  items: [
                    'python',
                    'javascript',
                    'java',
                    'cpp',
                    'c',
                    'bash',
                  ].map((lang) {
                    return DropdownMenuItem<String>(
                      value: lang,
                      child: Text(CodeBlock.getDisplayName(lang)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _language = value!),
                ),
              ],
            ),
          ),
          
          // Code editor
          Expanded(
            child: CodeBlockWidget(
              code: _code,
              language: _language,
              onCopy: _copyCode,
              onDownload: _downloadCode,
              onDebug: _runCode,
            ),
          ),
          
          // Divider
          Divider(height: 1, color: Colors.grey[300]),
          
          // Output section
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Output',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          onPressed: _copyOutput,
                          color: Colors.white70,
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () => setState(() => _output = ''),
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    _output.isEmpty ? 'Code output will appear here...' : _output,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // AI chat section
          Container(
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).cardTheme.color,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ask AI about the code...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: _sendToAI,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendToAI,
                ),
              ],
            ),
          ),
          
          // AI response
          if (_aiResponse.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue, width: 1),
              ),
              margin: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Response:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(_aiResponse),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _sendToAI(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _aiResponse = 'Analyzing your code...';
    });
    
    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _aiResponse = 'Based on your code, here are some suggestions:\n\n' +
                     '1. The code looks good overall.\n' +
                     '2. Consider adding error handling for file operations.\n' +
                     '3. You might want to add comments to explain complex logic.\n' +
                     '4. The function names are clear and descriptive.';
      });
    });
  }

  void _runCode() {
    if (_code.trim().isEmpty) {
      setState(() {
        _output = 'No code to run';
      });
      return;
    }
    
    setState(() {
      _isRunning = true;
      _output = 'Running code...\n';
    });
    
    // Simulate code execution
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isRunning = false;
        _output = 'Code executed successfully!\n\n' +
                  'Output:\n' +
                  'Hello, World!\n' +
                  'Process completed in 0.5 seconds';
      });
    });
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied to clipboard')),
    );
  }

  void _downloadCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code download will be implemented soon')),
    );
  }

  void _copyOutput() {
    Clipboard.setData(ClipboardData(text: _output));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Output copied to clipboard')),
    );
  }

  void _saveCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code save will be implemented soon')),
    );
  }

  void _clearAll() {
    setState(() {
      _code = '';
      _output = '';
      _aiResponse = '';
    });
  }
}
