import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import '../widgets/app_bottom_nav.dart';
import 'search_screen.dart';
import 'shuffle_screen.dart';

class TopicDetailScreen extends StatefulWidget {
  final int situationId;
  final int topicId;

  const TopicDetailScreen({super.key, required this.situationId, required this.topicId});

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _topic;
  List<dynamic> _childTopics = [];
  bool _isLoading = true;
  int? _expandedQuestionId;

  @override
  void initState() {
    super.initState();
    _loadTopic();
  }

  Future<void> _loadTopic() async {
    try {
      final topic = await _apiService.getTopic(widget.situationId, widget.topicId);
      final topics = await _apiService.getTopics(widget.situationId);
      setState(() {
        _topic = topic;
        _childTopics = topics
            .where((item) => item['parent_id'] == widget.topicId)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showQuestionDialog({Map<String, dynamic>? question}) {
    final questionController = TextEditingController(text: question?['question'] ?? '');
    final answerController = TextEditingController(text: question?['answer'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(question == null ? '新しい質問' : '質問を編集'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: '質問',
                  hintText: '例：趣味は何ですか？',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(
                  labelText: '回答',
                  hintText: '準備しておきたい回答を入力してください',
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (questionController.text.isNotEmpty) {
                if (question == null) {
                  await _apiService.createQuestion(
                    widget.situationId,
                    widget.topicId,
                    questionController.text,
                    answerController.text,
                  );
                } else {
                  await _apiService.updateQuestion(
                    widget.situationId,
                    widget.topicId,
                    question['id'],
                    questionController.text,
                    answerController.text,
                  );
                }
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadTopic();
              }
            },
            child: Text(question == null ? '追加' : '更新'),
          ),
        ],
      ),
    );
  }

  void _showCreateTopicDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('フォルダを作成'),
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
                  widget.situationId,
                  titleController.text,
                  descController.text,
                  parentId: widget.topicId,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadTopic();
              }
            },
            child: const Text('作成'),
          ),
        ],
      ),
    );
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('フォルダを作成'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateTopicDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('質問を追加'),
                onTap: () {
                  Navigator.pop(context);
                  _showQuestionDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteQuestion(int questionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('この質問を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _apiService.deleteQuestion(widget.situationId, widget.topicId, questionId);
      _loadTopic();
    }
  }

  void _handleBottomNavTap(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
      return;
    }
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ShuffleScreen()),
      );
      return;
    }
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          initialTabIndex: index,
          initialActionIndex: index,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(_topic?['title'] ?? 'トピック'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _topic == null
              ? const Center(child: Text('トピックが見つかりません'))
              : RefreshIndicator(
                  onRefresh: _loadTopic,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_childTopics.isNotEmpty) ...[
                                    const Text(
                                      'フォルダ',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? const Color(0xFF151515)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white12
                                              : Colors.black12,
                                        ),
                                        boxShadow: Theme.of(context).brightness == Brightness.dark
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.06),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                      ),
                                      child: Column(
                                        children: List.generate(_childTopics.length, (index) {
                                          final child = _childTopics[index];
                                          final isLast = index == _childTopics.length - 1;
                                          return Column(
                                            children: [
                                              Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => TopicDetailScreen(
                                                          situationId: widget.situationId,
                                                          topicId: child['id'],
                                                        ),
                                                      ),
                                                    ).then((_) => _loadTopic());
                                                  },
                                                  borderRadius: BorderRadius.circular(16),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          width: 30,
                                                          height: 30,
                                                          decoration: BoxDecoration(
                                                            color: Colors.orange.withValues(
                                                              alpha: 0.18,
                                                            ),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          child: Icon(
                                                            Icons.folder_outlined,
                                                            color: Colors.orange.shade600,
                                                            size: 16,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            child['title'] ?? '',
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              fontSize: 16,
                                                              height: 1.2,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        const Icon(Icons.chevron_right),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (!isLast)
                                                Divider(
                                                  height: 1,
                                                  thickness: 1,
                                                  color:
                                                      Theme.of(context).brightness == Brightness.dark
                                                          ? Colors.white12
                                                          : Colors.black12,
                                                ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  const SizedBox.shrink(),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '質問',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              if (_topic!['questions']?.isEmpty ?? true)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.help_outline,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'まだ質問がありません',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text('最初の質問を追加して、回答を準備しましょう'),
                                        const SizedBox(height: 24),
                                        ElevatedButton.icon(
                                          onPressed: () => _showQuestionDialog(),
                                          icon: const Icon(Icons.add),
                                          label: const Text('最初の質問を追加'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _topic!['questions'].length,
                                  itemBuilder: (context, index) {
                                    final question = _topic!['questions'][index];
                                    final isExpanded = _expandedQuestionId == question['id'];

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF151515) : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isDark ? Colors.white12 : Colors.black12,
                                        ),
                                        boxShadow: isDark
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.06),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _expandedQuestionId =
                                                  isExpanded ? null : question['id'];
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(20),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 30,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange.withValues(alpha: 0.18),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Icon(
                                                        Icons.help_outline,
                                                        color: Colors.orange.shade600,
                                                        size: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        question['question'],
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 16,
                                                          height: 1.2,
                                                        ),
                                                      ),
                                                    ),
                                                    PopupMenuButton(
                                                      itemBuilder: (context) => [
                                                        const PopupMenuItem(
                                                          value: 'edit',
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.edit, size: 20),
                                                              SizedBox(width: 8),
                                                              Text('編集'),
                                                            ],
                                                          ),
                                                        ),
                                                        const PopupMenuItem(
                                                          value: 'delete',
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.delete,
                                                                  size: 20, color: Colors.red),
                                                              SizedBox(width: 8),
                                                              Text('削除',
                                                                  style: TextStyle(color: Colors.red)),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                      onSelected: (value) {
                                                        if (value == 'edit') {
                                                          _showQuestionDialog(question: question);
                                                        } else if (value == 'delete') {
                                                          _deleteQuestion(question['id']);
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                if (isExpanded) ...[
                                                  const SizedBox(height: 10),
                                                  Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? const Color(0xFF111111)
                                                          : const Color(0xFF1B1B1B),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      question['answer'] ?? '（未回答）',
                                                      style: const TextStyle(
                                                        height: 1.5,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _showCreateOptions,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 0,
        onTap: _handleBottomNavTap,
      ),
    );
  }
}
