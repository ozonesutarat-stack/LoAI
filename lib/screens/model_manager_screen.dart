import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loai/providers/model_provider.dart';
import 'package:loai/models/ai_model.dart';
import 'package:loai/widgets/model_selector.dart';

class ModelManagerScreen extends StatefulWidget {
  const ModelManagerScreen({super.key});

  @override
  State<ModelManagerScreen> createState() => _ModelManagerScreenState();
}

class _ModelManagerScreenState extends State<ModelManagerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _showDownloadedOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadInitialModels();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialModels() {
    final modelProvider = Provider.of<ModelProvider>(context, listen: false);
    
    // Add some initial models if none exist
    if (modelProvider.models.isEmpty) {
      modelProvider.addModel(
        AIModel(
          name: 'Llama 2 7B Chat',
          description: 'Llama 2 7B parameter chat model from Meta',
          type: ModelType.chat,
          source: ModelSource.huggingFace,
          sourceId: 'meta-llama/Llama-2-7b-chat',
          sourceUrl: 'https://huggingface.co/meta-llama/Llama-2-7b-chat',
          author: 'Meta',
          fileSize: 14 * 1024 * 1024 * 1024, // 14GB
          tags: ['llama', 'chat', '7b'],
          status: ModelStatus.downloaded,
        ),
      );
      
      modelProvider.addModel(
        AIModel(
          name: 'Mistral 7B Instruct',
          description: 'Mistral 7B parameter instruction model',
          type: ModelType.chat,
          source: ModelSource.huggingFace,
          sourceId: 'mistralai/Mistral-7B-Instruct-v0.2',
          sourceUrl: 'https://huggingface.co/mistralai/Mistral-7B-Instruct-v0.2',
          author: 'Mistral AI',
          fileSize: 14 * 1024 * 1024 * 1024, // 14GB
          tags: ['mistral', 'chat', '7b'],
          status: ModelStatus.notDownloaded,
        ),
      );
      
      modelProvider.addModel(
        AIModel(
          name: 'Phi-2',
          description: 'Phi-2 2.7B parameter model from Microsoft',
          type: ModelType.chat,
          source: ModelSource.huggingFace,
          sourceId: 'microsoft/phi-2',
          sourceUrl: 'https://huggingface.co/microsoft/phi-2',
          author: 'Microsoft',
          fileSize: 2 * 1024 * 1024 * 1024, // 2GB
          tags: ['phi', 'chat', '2.7b'],
          status: ModelStatus.notDownloaded,
        ),
      );
      
      modelProvider.addModel(
        AIModel(
          name: 'Stable Diffusion v1.5',
          description: 'Stable Diffusion v1.5 image generation model',
          type: ModelType.image,
          source: ModelSource.huggingFace,
          sourceId: 'runwayml/stable-diffusion-v1-5',
          sourceUrl: 'https://huggingface.co/runwayml/stable-diffusion-v1-5',
          author: 'Runway ML',
          fileSize: 2 * 1024 * 1024 * 1024, // 2GB
          tags: ['stable-diffusion', 'image'],
          status: ModelStatus.notDownloaded,
        ),
      );
      
      modelProvider.addModel(
        AIModel(
          name: 'TTS Model',
          description: 'Text-to-speech model for multiple languages',
          type: ModelType.tts,
          source: ModelSource.local,
          fileSize: 500 * 1024 * 1024, // 500MB
          tags: ['tts', 'speech'],
          status: ModelStatus.downloaded,
        ),
      );
      
      modelProvider.addModel(
        AIModel(
          name: 'STT Model',
          description: 'Speech-to-text model for transcription',
          type: ModelType.stt,
          source: ModelSource.local,
          fileSize: 300 * 1024 * 1024, // 300MB
          tags: ['stt', 'speech'],
          status: ModelStatus.downloaded,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final modelProvider = Provider.of<ModelProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddModelDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Chat'),
            Tab(text: 'Image'),
            Tab(text: 'TTS/STT'),
          ],
        ),
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
                      hintText: 'Search models...',
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
                  label: const Text('Downloaded Only'),
                  selected: _showDownloadedOnly,
                  onSelected: (value) => setState(() => _showDownloadedOnly = value),
                ),
              ],
            ),
          ),
          
          // Model list
          Expanded(
            child: _buildModelList(modelProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildModelList(ModelProvider modelProvider) {
    List<AIModel> models = modelProvider.models;
    
    // Filter by tab
    switch (_tabController.index) {
      case 1: // Chat
        models = models.where((m) => m.type == ModelType.chat).toList();
        break;
      case 2: // Image
        models = models.where((m) => m.type == ModelType.image).toList();
        break;
      case 3: // TTS/STT
        models = models.where((m) => m.type == ModelType.tts || m.type == ModelType.stt).toList();
        break;
    }
    
    // Filter by search
    if (_searchQuery.isNotEmpty) {
      models = models.where((m) => 
        m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        m.description!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        m.author!.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Filter by downloaded only
    if (_showDownloadedOnly) {
      models = models.where((m) => 
        m.status == ModelStatus.downloaded || m.status == ModelStatus.loaded
      ).toList();
    }
    
    if (models.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No models found',
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
      itemCount: models.length,
      itemBuilder: (context, index) {
        final model = models[index];
        return _buildModelCard(modelProvider, model);
      },
    );
  }

  Widget _buildModelCard(ModelProvider modelProvider, AIModel model) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showModelDetails(context, modelProvider, model),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getModelIcon(model.type),
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (model.author != null)
                              Text(
                                model.author!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      model.isFavorite ? Icons.star : Icons.star_border,
                      color: model.isFavorite ? Colors.orange : Colors.grey,
                    ),
                    onPressed: () => modelProvider.toggleFavoriteModel(model.id),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (model.description != null)
                Text(
                  model.description!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    model.fileSizeDisplay,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  _buildStatusWidget(model),
                ],
              ),
              if (model.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 4,
                    children: model.tags.map((tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 10)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusWidget(AIModel model) {
    switch (model.status) {
      case ModelStatus.downloaded:
        return IconButton(
          icon: const Icon(Icons.download_done, color: Colors.green),
          onPressed: null,
        );
      case ModelStatus.loaded:
        return IconButton(
          icon: const Icon(Icons.check_circle, color: Colors.blue),
          onPressed: null,
        );
      case ModelStatus.downloading:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case ModelStatus.loading:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      default:
        return IconButton(
          icon: const Icon(Icons.download, color: Colors.blue),
          onPressed: () => _downloadModel(model),
        );
    }
  }

  IconData _getModelIcon(ModelType type) {
    switch (type) {
      case ModelType.chat:
        return Icons.chat;
      case ModelType.image:
        return Icons.image;
      case ModelType.tts:
        return Icons.volume_up;
      case ModelType.stt:
        return Icons.mic;
      case ModelType.embedding:
        return Icons.analytics;
      default:
        return Icons.help_outline;
    }
  }

  void _downloadModel(AIModel model) {
    final modelProvider = Provider.of<ModelProvider>(context, listen: false);
    modelProvider.downloadModel(model.id);
  }

  void _showModelDetails(BuildContext context, ModelProvider modelProvider, AIModel model) {
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
                Text(
                  model.displayName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (model.description != null)
              Text(model.description!),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDetailItem('Type', _getModelTypeName(model.type)),
                const SizedBox(width: 16),
                _buildDetailItem('Author', model.author ?? 'Unknown'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDetailItem('Size', model.fileSizeDisplay),
                const SizedBox(width: 16),
                _buildDetailItem('Status', model.status.name.replaceAll('_', ' ')),
              ],
            ),
            const SizedBox(height: 16),
            if (model.source == ModelSource.huggingFace)
              TextButton.icon(
                icon: const Icon(Icons.link),
                label: const Text('View on Hugging Face'),
                onPressed: () {
                  // Open URL
                },
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (model.status == ModelStatus.downloaded || model.status == ModelStatus.loaded)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    onPressed: () => _showDeleteDialog(context, modelProvider, model),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (model.status == ModelStatus.notDownloaded)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    onPressed: () => _downloadModel(model),
                  ),
                if (model.status == ModelStatus.downloaded)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Load'),
                    onPressed: () => modelProvider.loadModel(model.id),
                  ),
                if (model.status == ModelStatus.loaded)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.stop),
                    label: const Text('Unload'),
                    onPressed: () => modelProvider.unloadModel(model.id),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getModelTypeName(ModelType type) {
    switch (type) {
      case ModelType.chat:
        return 'Chat';
      case ModelType.image:
        return 'Image';
      case ModelType.tts:
        return 'TTS';
      case ModelType.stt:
        return 'STT';
      case ModelType.embedding:
        return 'Embedding';
      default:
        return 'Unknown';
    }
  }

  void _showDeleteDialog(BuildContext context, ModelProvider modelProvider, AIModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Model'),
        content: Text('Are you sure you want to delete ${model.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              modelProvider.removeModel(model.id);
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

  void _showAddModelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Model'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add a new model from Hugging Face'),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Model Name',
                  hintText: 'e.g., meta-llama/Llama-2-7b-chat',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ModelType>(
                value: ModelType.chat,
                items: ModelType.values.map((type) {
                  return DropdownMenuItem<ModelType>(
                    value: type,
                    child: Text(_getModelTypeName(type)),
                  );
                }).toList(),
                onChanged: (value) {},
                decoration: InputDecoration(
                  labelText: 'Model Type',
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
              // Add model
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: ModelSearchDelegate(),
    );
  }
}

class ModelSearchDelegate extends SearchDelegate<String> {
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
    final models = modelProvider.models.where((m) => 
      m.name.toLowerCase().contains(query.toLowerCase()) ||
      m.description!.toLowerCase().contains(query.toLowerCase())
    ).toList();
    
    return ListView.builder(
      itemCount: models.length,
      itemBuilder: (context, index) {
        final model = models[index];
        return ListTile(
          leading: Icon(_getModelIcon(model.type)),
          title: Text(model.displayName),
          subtitle: Text(model.description ?? ''),
          onTap: () {
            close(context, model.id);
          },
        );
      },
    );
  }

  IconData _getModelIcon(ModelType type) {
    switch (type) {
      case ModelType.chat:
        return Icons.chat;
      case ModelType.image:
        return Icons.image;
      case ModelType.tts:
        return Icons.volume_up;
      case ModelType.stt:
        return Icons.mic;
      case ModelType.embedding:
        return Icons.analytics;
      default:
        return Icons.help_outline;
    }
  }
}
