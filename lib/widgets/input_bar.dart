import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loai/providers/theme_provider.dart';
import 'package:loai/providers/settings_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class InputBar extends StatefulWidget {
  final Function(String) onSend;
  final Function(String) onImageSend;
  final Function(String, String, String) onFileSend;
  final VoidCallback onVoiceInput;
  final bool isLoading;
  final String currentInput;
  final Function(String) onInputChanged;

  const InputBar({
    super.key,
    required this.onSend,
    required this.onImageSend,
    required this.onFileSend,
    required this.onVoiceInput,
    required this.isLoading,
    required this.currentInput,
    required this.onInputChanged,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.currentInput;
  }

  @override
  void didUpdateWidget(InputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentInput != widget.currentInput) {
      _controller.text = widget.currentInput;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          // Voice input button
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: widget.onVoiceInput,
            tooltip: 'Voice Input',
            color: themeProvider.primaryColor,
          ),
          const SizedBox(width: 8),
          
          // File attachment button
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _showAttachmentMenu,
            tooltip: 'Attach File',
            color: themeProvider.primaryColor,
          ),
          const SizedBox(width: 8),
          
          // Text input
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                suffixIcon: widget.isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeProvider.primaryColor),
                      ),
                    )
                  : null,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  widget.onSend(text);
                  _controller.clear();
                }
              },
              onChanged: widget.onInputChanged,
            ),
          ),
          const SizedBox(width: 8),
          
          // Send button
          FloatingActionButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                widget.onSend(_controller.text);
                _controller.clear();
              }
            },
            backgroundColor: themeProvider.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const CircleBorder(),
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Choose File'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final result = await picker.pickImage(source: source);
      
      if (result != null) {
        widget.onImageSend(result.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString()}' )),
      );
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileName = file.name;
        final filePath = file.path ?? '';
        final fileType = fileName.split('.').last.toLowerCase();
        
        widget.onFileSend(filePath, fileName, fileType);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: ${e.toString()}' )),
      );
    }
  }
}
