import 'package:flutter/material.dart';
import 'package:loai/models/ai_model.dart';

class ModelSelector extends StatelessWidget {
  final String? currentModelId;
  final List<AIModel> models;
  final Function(String?) onSelected;
  final bool showAll;

  const ModelSelector({
    super.key,
    this.currentModelId,
    required this.models,
    required this.onSelected,
    this.showAll = false,
  });

  @override
  Widget build(BuildContext context) {
    if (models.isEmpty) {
      return const ListTile(
        title: Text('No models available'),
        subtitle: Text('Download models from settings'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Model:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentModelId,
          hint: const Text('Select a model'),
          items: models.map((model) {
            return DropdownMenuItem<String>(
              value: model.id,
              child: Row(
                children: [
                  if (model.isFavorite)
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text(model.displayName),
                  const SizedBox(width: 8),
                  if (model.status == ModelStatus.downloaded || model.status == ModelStatus.loaded)
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  if (model.status == ModelStatus.downloading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: onSelected,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        
        if (showAll)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _buildModelList(context),
          ),
      ],
    );
  }

  Widget _buildModelList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Available Models:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...models.map((model) => _buildModelCard(context, model)),
      ],
    );
  }

  Widget _buildModelCard(BuildContext context, AIModel model) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          foregroundColor: Theme.of(context).primaryColor,
          child: _getModelIcon(model.type),
        ),
        title: Text(model.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (model.description != null)
              Text(
                model.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  model.fileSizeDisplay,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  model.author ?? 'Unknown',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                model.isFavorite ? Icons.star : Icons.star_border,
                color: model.isFavorite ? Colors.orange : Colors.grey,
              ),
              onPressed: () {
                // Toggle favorite
              },
            ),
            if (model.status == ModelStatus.downloaded || model.status == ModelStatus.loaded)
              IconButton(
                icon: const Icon(Icons.download_done, color: Colors.green),
                onPressed: null,
              ),
            if (model.status == ModelStatus.notDownloaded)
              IconButton(
                icon: const Icon(Icons.download, color: Colors.blue),
                onPressed: () {
                  // Download model
                },
              ),
            if (model.status == ModelStatus.downloading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        onTap: () => onSelected(model.id),
      ),
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

// Model download progress
class ModelDownloadProgress extends StatelessWidget {
  final AIModel model;

  const ModelDownloadProgress({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  model.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(model.progress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: model.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  model.fileSizeDisplay,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  '${model.status.name.replaceAll('_', ' ')}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
