import 'package:flutter/material.dart';
import 'package:loai/models/chat_message.dart';
import 'package:highlight/highlight.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

class CodeBlockWidget extends StatelessWidget {
  final String code;
  final String language;
  final String? fileName;
  final VoidCallback? onCopy;
  final VoidCallback? onDownload;
  final VoidCallback? onDebug;

  const CodeBlockWidget({
    super.key,
    required this.code,
    required this.language,
    this.fileName,
    this.onCopy,
    this.onDownload,
    this.onDebug,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with file name and actions
          if (fileName != null || onCopy != null || onDownload != null || onDebug != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (fileName != null)
                    Text(
                      fileName!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onCopy != null)
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          onPressed: onCopy,
                          tooltip: 'Copy',
                          color: Colors.white70,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      if (onDownload != null)
                        IconButton(
                          icon: const Icon(Icons.download, size: 16),
                          onPressed: onDownload,
                          tooltip: 'Download',
                          color: Colors.white70,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      if (onDebug != null)
                        IconButton(
                          icon: const Icon(Icons.bug_report, size: 16),
                          onPressed: onDebug,
                          tooltip: 'Debug',
                          color: Colors.green,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          
          // Code content
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 24,
                ),
                child: CodeEditor(
                  text: code,
                  language: language,
                  readOnly: true,
                  style: CodeEditorStyle(
                    backgroundColor: Colors.transparent,
                    lineNumberColor: Colors.grey[700],
                    lineNumberTextStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    cursorColor: Colors.white,
                    selectionColor: Colors.blue.withOpacity(0.3),
                    syntaxHighlighter: _getHighlighter(language),
                    textStyle: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Language label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Text(
              CodeBlock.getDisplayName(language),
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  SyntaxHighlighter _getHighlighter(String language) {
    // Map language names to Highlight.js language names
    final langMap = {
      'python': 'python',
      'javascript': 'javascript',
      'typescript': 'typescript',
      'java': 'java',
      'cpp': 'cpp',
      'c': 'c',
      'dart': 'dart',
      'go': 'go',
      'rust': 'rust',
      'php': 'php',
      'ruby': 'ruby',
      'swift': 'swift',
      'kotlin': 'kotlin',
      'bash': 'bash',
      'sql': 'sql',
      'html': 'html',
      'css': 'css',
      'json': 'json',
      'xml': 'xml',
    };
    
    final hlLanguage = langMap[language.toLowerCase()] ?? 'plaintext';
    
    return SyntaxHighlighter(
      language: hlLanguage,
      theme: _getHighlightTheme(),
    );
  }

  HighlightTheme _getHighlightTheme() {
    return HighlightTheme(
      styles: {
        'root': TextStyle(color: Colors.white),
        'keyword': TextStyle(color: Colors.pink[400], fontWeight: FontWeight.bold),
        'literal': TextStyle(color: Colors.orange[400]),
        'string': TextStyle(color: Colors.green[400]),
        'number': TextStyle(color: Colors.purple[400]),
        'comment': TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
        'class': TextStyle(color: Colors.yellow[400]),
        'function': TextStyle(color: Colors.blue[400]),
        'variable': TextStyle(color: Colors.white),
        'operator': TextStyle(color: Colors.white),
        'punctuation': TextStyle(color: Colors.white),
        'property': TextStyle(color: Colors.cyan[400]),
        'tag': TextStyle(color: Colors.red[400]),
        'attr': TextStyle(color: Colors.yellow[400]),
      },
    );
  }
}

// Simple code block without editor
class SimpleCodeBlock extends StatelessWidget {
  final String code;
  final String language;
  final VoidCallback? onCopy;

  const SimpleCodeBlock({
    super.key,
    required this.code,
    required this.language,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CodeBlock.getDisplayName(language),
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              if (onCopy != null)
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: onCopy,
                  color: Colors.white70,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            code,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
