import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loai/providers/chat_provider.dart';
import 'package:loai/models/project.dart';
import 'package:loai/widgets/conversation_list.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Project> _projects = [];
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    // Mock projects for now
    setState(() {
      _projects = [
        Project(
          name: 'AI Research',
          description: 'Research on AI models and their applications',
          conversationIds: ['conv1', 'conv2'],
          fileIds: ['file1', 'file2'],
          color: '#4285F4',
        ),
        Project(
          name: 'Code Development',
          description: 'Software development projects',
          conversationIds: ['conv3'],
          fileIds: ['file3'],
          color: '#34A853',
        ),
        Project(
          name: 'Document Analysis',
          description: 'Analyzing various documents',
          conversationIds: ['conv4', 'conv5', 'conv6'],
          fileIds: ['file4', 'file5', 'file6'],
          color: '#FBBC05',
        ),
        Project(
          name: 'Learning Materials',
          description: 'Educational content and tutorials',
          conversationIds: ['conv7'],
          fileIds: ['file7'],
          color: '#EA4335',
        ),
        Project(
          name: 'Creative Writing',
          description: 'Writing stories and articles',
          conversationIds: ['conv8', 'conv9'],
          fileIds: ['file8', 'file9'],
          color: '#673AB7',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final recentProjects = _projects
      .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    final displayedProjects = _showAll 
      ? recentProjects 
      : recentProjects.take(3).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewProject,
          ),
        ],
      ),
      body: Column(
        children: [
          // Recent projects
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: displayedProjects.length + (_showAll ? 0 : 1),
              itemBuilder: (context, index) {
                if (!_showAll && index == displayedProjects.length) {
                  return _buildShowMoreButton();
                }
                return _buildProjectCard(displayedProjects[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openProject(project),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (project.color != null)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Color(int.parse(project.color!.replaceAll('#', '0xFF'))),
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  if (project.isFavorite)
                    const Icon(Icons.star, color: Colors.orange),
                ],
              ),
              const SizedBox(height: 8),
              if (project.description != null)
                Text(
                  project.description!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat('Chats', project.conversationCount),
                  _buildStat('Files', project.fileCount),
                  _buildStat('Updated', _formatDate(project.updatedAt)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildShowMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: OutlinedButton(
        onPressed: () => setState(() => _showAll = true),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Show more projects'),
      ),
    );
  }

  void _createNewProject() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText: 'Enter project name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter project description',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Create new project
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _openProject(Project project) {
    // Navigate to project detail
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(project: project),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class ProjectDetailScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            icon: Icon(project.isFavorite ? Icons.star : Icons.star_border),
            onPressed: () {
              // Toggle favorite
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Project header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: project.color != null 
                ? Color(int.parse(project.color!.replaceAll('#', '0xFF')))
                : Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                if (project.description != null)
                  Text(
                    project.description!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat('Chats', project.conversationCount, Colors.white),
                    _buildStat('Files', project.fileCount, Colors.white),
                    _buildStat('Updated', _formatDate(project.updatedAt), Colors.white),
                  ],
                ),
              ],
            ),
          ),
          
          // Tabs
          DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Conversations'),
                    Tab(text: 'Files'),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 250,
                  child: const TabBarView(
                    children: [
                      Center(child: Text('Conversations will appear here')),
                      Center(child: Text('Files will appear here')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, dynamic value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
