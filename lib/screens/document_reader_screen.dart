import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DocumentReaderScreen extends StatefulWidget {
  const DocumentReaderScreen({super.key});

  @override
  State<DocumentReaderScreen> createState() => _DocumentReaderScreenState();
}

class _DocumentReaderScreenState extends State<DocumentReaderScreen> {
  String? _fileName;
  String? _fileType;
  String _documentContent = '';
  String _summary = '';
  bool _isProcessing = false;
  String _processingStatus = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: _uploadDocument,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          // Upload section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardTheme.color,
            child: Column(
              children: [
                if (_fileName == null)
                  GestureDetector(
                    onTap: _uploadDocument,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!, width: 2, style: BorderStyle.dashed),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.upload, size: 48, color: Colors.grey[600]),
                          const SizedBox(height: 8),
                          Text(
                            'Upload Document',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Supports: PDF, TXT, DOC, DOCX',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_fileName != null)
                  Row(
                    children: [
                      Icon(
                        _getFileIcon(_fileType),
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fileName!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _fileType?.toUpperCase() ?? '',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _clearAll,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Processing status
          if (_isProcessing)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(_processingStatus),
                ],
              ),
            ),
          
          // Document content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Document Content',
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
                      child: _documentContent.isEmpty
                        ? Center(
                            child: Text(
                              'Document content will appear here',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          )
                        : SingleChildScrollView(
                            child: SelectableText(
                              _documentContent,
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardTheme.color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: _summary.isEmpty
                    ? Text(
                        'Document summary will appear here',
                        style: TextStyle(color: Colors.grey[500]),
                      )
                    : SelectableText(
                        _summary,
                        style: const TextStyle(fontSize: 16, height: 1.4),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _uploadDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'doc', 'docx'],
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _fileName = file.name;
          _fileType = file.name.split('.').last.toLowerCase();
          _documentContent = '';
          _summary = '';
          _isProcessing = true;
          _processingStatus = 'Uploading document...';
        });
        
        // Simulate document processing
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _processingStatus = 'Extracting text...';
        });
        
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _documentContent = 'This is the extracted content from ${file.name}.\n\n' +
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. ' +
                            'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ' +
                            'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.\n\n' +
                            'Document has multiple sections and paragraphs. ' +
                            'This text would be the actual content extracted from the uploaded file.';
          _processingStatus = 'Generating summary...';
        });
        
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _summary = 'Document Summary:\n\n' +
                    'This document contains information about ${file.name.split('.').first}. ' +
                    'It has approximately 5 pages of content covering various topics. ' +
                    'The main points include:\n' +
                    '1. Introduction to the subject\n' +
                    '2. Detailed analysis\n' +
                    '3. Conclusions and recommendations\n\n' +
                    'The document is well-structured and provides comprehensive information.';
          _isProcessing = false;
          _processingStatus = '';
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _processingStatus = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading document: ${e.toString()}' )),
      );
    }
  }

  void _clearAll() {
    setState(() {
      _fileName = null;
      _fileType = null;
      _documentContent = '';
      _summary = '';
      _isProcessing = false;
      _processingStatus = '';
    });
  }

  IconData _getFileIcon(String? fileType) {
    switch (fileType?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'txt':
      case 'md':
        return Icons.text_snippet;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}
