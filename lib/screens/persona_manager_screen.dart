import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loai/providers/model_provider.dart';
import 'package:loai/models/persona.dart';

class PersonaManagerScreen extends StatefulWidget {
  const PersonaManagerScreen({super.key});

  @override
  State<PersonaManagerScreen> createState() => _PersonaManagerScreenState();
}

class _PersonaManagerScreenState extends State<PersonaManagerScreen> {
  String _searchQuery = '';
  bool _showPresetsOnly = false;

  @override
  Widget build(BuildContext context) {
    final modelProvider = Provider.of<ModelProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persona Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPersonaDialog(context),
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
                      hintText: 'Search personas...',
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
                  label: const Text('Presets Only'),
                  selected: _showPresetsOnly,
                  onSelected: (value) => setState(() => _showPresetsOnly = value),
                ),
              ],
            ),
          ),
          
          // Persona list
          Expanded(
            child: _buildPersonaList(modelProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonaList(ModelProvider modelProvider) {
    List<Persona> personas = modelProvider.personas;
    
    // Filter by search
    if (_searchQuery.isNotEmpty) {
      personas = personas.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Filter by presets only
    if (_showPresetsOnly) {
      personas = personas.where((p) => p.isPreset).toList();
    }
    
    if (personas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No personas found',
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
      itemCount: personas.length,
      itemBuilder: (context, index) {
        final persona = personas[index];
        return _buildPersonaCard(modelProvider, persona);
      },
    );
  }

  Widget _buildPersonaCard(ModelProvider modelProvider, Persona persona) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showPersonaDetails(context, modelProvider, persona),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: persona.color != null 
                    ? Color(int.parse(persona.color!.replaceAll('#', '0xFF')))
                    : Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  persona.icon ?? '?',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      persona.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      persona.description,
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
                        if (persona.isPreset)
                          Chip(
                            label: const Text('Preset', style: TextStyle(fontSize: 10)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        const SizedBox(width: 4),
                        if (persona.isFavorite)
                          Chip(
                            label: const Text('Favorite', style: TextStyle(fontSize: 10)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  persona.isFavorite ? Icons.star : Icons.star_border,
                  color: persona.isFavorite ? Colors.orange : Colors.grey,
                ),
                onPressed: () => modelProvider.toggleFavoritePersona(persona.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPersonaDetails(BuildContext context, ModelProvider modelProvider, Persona persona) {
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
                    if (persona.icon != null)
                      Text(
                        persona.icon!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      persona.name,
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
            Text(persona.description),
            const SizedBox(height: 16),
            const Text(
              'System Prompt:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: SelectableText(
                persona.systemPrompt,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Usage: ${persona.usageCount} times',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (!persona.isPreset)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: () => _showEditPersonaDialog(context, modelProvider, persona),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (!persona.isPreset)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Duplicate'),
                    onPressed: () => _duplicatePersona(context, modelProvider, persona),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    onPressed: () => _showDeleteDialog(context, modelProvider, persona),
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

  void _showEditPersonaDialog(BuildContext context, ModelProvider modelProvider, Persona persona) {
    final nameController = TextEditingController(text: persona.name);
    final descriptionController = TextEditingController(text: persona.description);
    final promptController = TextEditingController(text: persona.systemPrompt);
    final iconController = TextEditingController(text: persona.icon);
    final colorController = TextEditingController(text: persona.color);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Persona'),
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
              const SizedBox(height: 16),
              TextField(
                controller: promptController,
                decoration: InputDecoration(
                  labelText: 'System Prompt',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 5,
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
              final updatedPersona = persona.copyWith(
                name: nameController.text,
                description: descriptionController.text,
                icon: iconController.text,
                color: colorController.text,
                systemPrompt: promptController.text,
              );
              modelProvider.updatePersona(updatedPersona);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddPersonaDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final promptController = TextEditingController();
    final iconController = TextEditingController();
    final colorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Persona'),
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
              const SizedBox(height: 16),
              TextField(
                controller: promptController,
                decoration: InputDecoration(
                  labelText: 'System Prompt',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 5,
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
              final modelProvider = Provider.of<ModelProvider>(context, listen: false);
              final newPersona = Persona(
                name: nameController.text,
                description: descriptionController.text,
                systemPrompt: promptController.text,
                icon: iconController.text,
                color: colorController.text,
                isPreset: false,
              );
              modelProvider.addPersona(newPersona);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _duplicatePersona(BuildContext context, ModelProvider modelProvider, Persona persona) {
    final newPersona = persona.copyWith(
      id: null,
      name: '${persona.name} (Copy)',
      isPreset: false,
      usageCount: 0,
    );
    modelProvider.addPersona(newPersona);
    Navigator.pop(context);
  }

  void _showDeleteDialog(BuildContext context, ModelProvider modelProvider, Persona persona) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Persona'),
        content: Text('Are you sure you want to delete ${persona.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              modelProvider.deletePersona(persona.id);
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
      delegate: PersonaSearchDelegate(),
    );
  }
}

class PersonaSearchDelegate extends SearchDelegate<String> {
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
    final modelProvider = Provider.of<ModelProvider>(context);
    final personas = modelProvider.personas.where((p) => 
      p.name.toLowerCase().contains(query.toLowerCase()) ||
      p.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
    
    return ListView.builder(
      itemCount: personas.length,
      itemBuilder: (context, index) {
        final persona = personas[index];
        return ListTile(
          leading: Text(persona.icon ?? '?', style: const TextStyle(fontSize: 24)),
          title: Text(persona.name),
          subtitle: Text(persona.description),
          onTap: () {
            close(context, persona.id);
          },
        );
      },
    );
  }
}
