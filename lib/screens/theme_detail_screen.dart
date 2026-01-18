import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'topic_detail_screen.dart';

class ThemeDetailScreen extends StatefulWidget {
  final int themeId;

  const ThemeDetailScreen({super.key, required this.themeId});

  @override
  State<ThemeDetailScreen> createState() => _ThemeDetailScreenState();
}

class _ThemeDetailScreenState extends State<ThemeDetailScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _theme;
  List<dynamic> _topics = [];
  List<dynamic> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final theme = await _apiService.getTheme(widget.themeId);
      setState(() {
        _theme = theme;
        _topics = List<dynamic>.from(theme['topics'] ?? []);
        _questions = List<dynamic>.from(theme['questions'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _countQuestions(int topicId) {
    return _questions.where((q) => q['topic_id'] == topicId).length;
  }

  void _showCreateDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しいトピック'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                hintText: '例：面接、デート、商談',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: '説明（任意）',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await _apiService.createTopic(
                  widget.themeId,
                  titleController.text,
                  descController.text,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadTheme();
              }
            },
            child: const Text('作成'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_theme?['title'] ?? 'テーマ詳細'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _theme == null
              ? const Center(child: Text('テーマが見つかりません'))
              : RefreshIndicator(
                  onRefresh: _loadTheme,
                  child: _topics.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 64,
                                    color: Colors.orange.shade600,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'まだトピックがありません',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('最初のトピックを作成して、会話の準備を始めましょう'),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _showCreateDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text('最初のトピックを作成'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _topics.length,
                          itemBuilder: (context, index) {
                            final topic = _topics[index];
                            final count = _countQuestions(topic['id']);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                title: Text(
                                  topic['title'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(topic['description'] ?? '説明なし'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.help_outline, color: Colors.orange.shade600, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$count',
                                      style: TextStyle(
                                        color: Colors.orange.shade600,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TopicDetailScreen(
                                        themeId: widget.themeId,
                                        topicId: topic['id'],
                                      ),
                                    ),
                                  ).then((_) => _loadTheme());
                                },
                              ),
                            );
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
