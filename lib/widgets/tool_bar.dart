import 'package:flutter/material.dart';
import 'package:loai/models/tool.dart';

class ToolBar extends StatelessWidget {
  final List<Tool> tools;

  const ToolBar({super.key, required this.tools});

  @override
  Widget build(BuildContext context) {
    if (tools.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 48,
      color: Theme.of(context).cardTheme.color,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: tools.map((tool) => _buildToolButton(context, tool)).toList(),
        ),
      ),
    );
  }

  Widget _buildToolButton(BuildContext context, Tool tool) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: tool.description,
        child: IconButton(
          icon: Text(
            tool.icon ?? '?',
            style: const TextStyle(fontSize: 20),
          ),
          onPressed: tool.canExecute ? () => _onToolSelected(context, tool) : null,
          tooltip: tool.name,
          style: IconButton.styleFrom(
            backgroundColor: tool.canExecute 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey[300],
            foregroundColor: tool.canExecute 
              ? Theme.of(context).primaryColor
              : Colors.grey,
            padding: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  void _onToolSelected(BuildContext context, Tool tool) {
    // This will be handled by the parent widget
    // The tool bar just displays the tools
  }
}

// Tool selection dialog
class ToolSelectionDialog extends StatelessWidget {
  final List<Tool> tools;
  final Function(Tool) onSelected;

  const ToolSelectionDialog({
    super.key,
    required this.tools,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select a Tool',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: tools.length,
                itemBuilder: (context, index) {
                  final tool = tools[index];
                  return ListTile(
                    leading: Text(
                      tool.icon ?? '?',
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(tool.name),
                    subtitle: Text(tool.description),
                    trailing: tool.canExecute 
                      ? const Icon(Icons.chevron_right, color: Colors.green)
                      : const Icon(Icons.lock, color: Colors.red),
                    onTap: tool.canExecute ? () {
                      Navigator.pop(context);
                      onSelected(tool);
                    } : null,
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
