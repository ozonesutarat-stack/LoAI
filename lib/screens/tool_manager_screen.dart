import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loai/providers/chat_provider.dart';
import 'package:loai/models/tool.dart';

class ToolManagerScreen extends StatefulWidget {
  const ToolManagerScreen({super.key});

  @override
  State<ToolManagerScreen> createState() => _ToolManagerScreenState();
}

class _ToolManagerScreenState extends State<ToolManagerScreen> {
  String _searchQuery = '';
  bool _showEnabledOnly = true;

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tool Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddToolDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter
          Container(
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).cardTheme.color,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search tools...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Enabled Only'),
                  selected: _showEnabledOnly,
                  onSelected: (value) => setState(() => _showEnabledOnly = value),
                ),
              ],
            ),
          ),
          
          // Tool list
          Expanded(
            child: _buildToolList(chatProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildToolList(ChatProvider chatProvider) {
    List<Tool> tools = chatProvider.availableTools;
    
    // Filter by search
    if (_searchQuery.isNotEmpty) {
      tools = tools.where((t) => 
        t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Filter by enabled only
    if (_showEnabledOnly) {
      tools = tools.where((t) => t.isEnabled).toList();
    }
    
    if (tools.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tools found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return _buildToolCard(chatProvider, tool);
      },
    );
  }

  Widget _buildToolCard(ChatProvider chatProvider, Tool tool) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showToolDetails(context, chatProvider, tool),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tool.color != null 
                    ? Color(int.parse(tool.color!.replaceAll('#', '0xFF')))
                    : Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  tool.icon ?? '?',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      tool.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (tool.isCustom)
                          Chip(
                            label: const Text('Custom', style: TextStyle(fontSize: 10)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        const SizedBox(width: 4),
                        if (tool.isEnabled)
                          Chip(
                            label: const Text('Enabled', style: TextStyle(fontSize: 10)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: Colors.green[50],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: tool.isEnabled,
                onChanged: (value) {
                  // Toggle enabled
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showToolDetails(BuildContext context, ChatProvider chatProvider, Tool tool) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (tool.icon != null)
                      Text(
                        tool.icon!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      tool.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(tool.description),
            const SizedBox(height: 16),
            const Text(
              'Configuration:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...tool.config.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${entry.key}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(entry.value.toString()),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            if (tool.requiredPermissions.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Required Permissions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: tool.requiredPermissions.map((permission) => Chip(
                      label: Text(permission, style: const TextStyle(fontSize: 12)),
                    )).toList(),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: ${tool.status.name.replaceAll('_', ' ')}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (tool.isCustom)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: () => _showEditToolDialog(context, chatProvider, tool),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (tool.isCustom)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Duplicate'),
                    onPressed: () => _duplicateTool(context, chatProvider, tool),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    onPressed: () => _showDeleteDialog(context, chatProvider, tool),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showEditToolDialog(BuildContext context, ChatProvider chatProvider, Tool tool) {
    final nameController = TextEditingController(text: tool.name);
    final descriptionController = TextEditingController(text: tool.description);
    final iconController = TextEditingController(text: tool.icon);
    final colorController = TextEditingController(text: tool.color);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tool'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: iconController,
                decoration: InputDecoration(
                  labelText: 'Icon (emoji)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: colorController,
                decoration: InputDecoration(
                  labelText: 'Color (hex)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update tool
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddToolDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final iconController = TextEditingController();
    final colorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Tool'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: iconController,
                decoration: InputDecoration(
                  labelText: 'Icon (emoji)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: colorController,
                decoration: InputDecoration(
                  labelText: 'Color (hex)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add custom tool
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _duplicateTool(BuildContext context, ChatProvider chatProvider, Tool tool) {
    // Duplicate tool logic
    Navigator.pop(context);
  }

  void _showDeleteDialog(BuildContext context, ChatProvider chatProvider, Tool tool) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tool'),
        content: Text('Are you sure you want to delete ${tool.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete tool
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: ToolSearchDelegate(),
    );
  }
}

class ToolSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Center(child: Text('Search results will appear here'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final tools = chatProvider.availableTools.where((t) => 
      t.name.toLowerCase().contains(query.toLowerCase()) ||
      t.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
    
    return ListView.builder(
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return ListTile(
          leading: Text(tool.icon ?? '?', style: const TextStyle(fontSize: 24)),
          title: Text(tool.name),
          subtitle: Text(tool.description),
          onTap: () {
            close(context, tool.id);
          },
        );
      },
    );
  }
}
