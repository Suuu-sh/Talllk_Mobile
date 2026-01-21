import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../services/api_service.dart';
import 'topic_detail_screen.dart';
import 'dashboard_screen.dart';
import '../widgets/app_bottom_nav.dart';
import 'search_screen.dart';
import 'shuffle_screen.dart';
import '../theme/app_colors.dart';

class SituationDetailScreen extends StatefulWidget {
  final int situationId;

  const SituationDetailScreen({super.key, required this.situationId});

  @override
  State<SituationDetailScreen> createState() => _SituationDetailScreenState();
}

class _SituationDetailScreenState extends State<SituationDetailScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _situation;
  List<dynamic> _topics = [];
  List<dynamic> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSituation();
  }

  Future<void> _loadSituation() async {
    try {
      final situation = await _apiService.getSituation(widget.situationId);
      setState(() {
        _situation = situation;
        _topics = List<dynamic>.from(situation['topics'] ?? [])
            .where((topic) => topic['parent_id'] == null)
            .toList();
        _questions = List<dynamic>.from(situation['questions'] ?? []);
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
                  color: AppColors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('フォルダを作成'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateDialog();
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

  void _handleBottomNavTap(int index) {
    if (index == 1) {
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
                  widget.situationId,
                  titleController.text,
                  descController.text,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadSituation();
              }
            },
            child: const Text('作成'),
          ),
        ],
      ),
    );
  }

  void _showEditTopicDialog(Map<String, dynamic> topic) {
    final titleController = TextEditingController(text: topic['title']);
    final descController = TextEditingController(text: topic['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('フォルダを編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル',
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
              if (titleController.text.isEmpty) return;
              await _apiService.updateTopic(
                widget.situationId,
                topic['id'],
                titleController.text,
                descController.text,
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              _loadSituation();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTopic(int topicId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除しますか？'),
        content: const Text('このフォルダ内の質問も削除されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _apiService.deleteTopic(widget.situationId, topicId);
      _loadSituation();
    }
  }

  void _showQuestionDialog() {
    if (_topics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('先にフォルダを作成してください')),
      );
      return;
    }

    final questionController = TextEditingController();
    final answerController = TextEditingController();
    int selectedTopicId = _topics.first['id'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('質問を追加'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedTopicId,
                decoration: const InputDecoration(labelText: 'フォルダ'),
                items: _topics
                    .map(
                      (topic) => DropdownMenuItem<int>(
                        value: topic['id'],
                        child: Text(topic['title']),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedTopicId = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: '質問',
                  hintText: '例：自己紹介をしてください',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(
                  labelText: '回答',
                  hintText: '準備しておきたい回答を入力してください',
                ),
                maxLines: 4,
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
                await _apiService.createQuestion(
                  widget.situationId,
                  selectedTopicId,
                  questionController.text,
                  answerController.text,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadSituation();
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_situation?['title'] ?? 'シチュエーション詳細'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _situation == null
              ? const Center(child: Text('シチュエーションが見つかりません'))
              : RefreshIndicator(
                  onRefresh: _loadSituation,
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
                                    color: AppColors.orange600,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'まだトピックがありません',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('最初のトピックを作成して、会話の準備を始めましょう'),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _showCreateOptions,
                                    icon: const Icon(Icons.add),
                                    label: const Text('追加する'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkSurface
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? AppColors.white12
                                      : AppColors.black12,
                                ),
                                boxShadow: Theme.of(context).brightness == Brightness.dark
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: AppColors.black.withOpacity(0.06),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                              ),
                              child: Column(
                                children: List.generate(_topics.length, (index) {
                                  final topic = _topics[index];
                                  final isLast = index == _topics.length - 1;
                                  return Column(
                                    children: [
                                      Slidable(
                                        key: ValueKey(topic['id']),
                                        endActionPane: ActionPane(
                                          motion: const StretchMotion(),
                                          extentRatio: 0.36,
                                          children: [
                                            SlidableAction(
                                              onPressed: (_) => _showEditTopicDialog(topic),
                                              backgroundColor: AppColors.orange600,
                                              foregroundColor: AppColors.white,
                                              icon: Icons.edit,
                                              label: '編集',
                                            ),
                                            SlidableAction(
                                              onPressed: (_) => _deleteTopic(topic['id']),
                                              backgroundColor: AppColors.error,
                                              foregroundColor: AppColors.white,
                                              icon: Icons.delete,
                                              label: '削除',
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: AppColors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => TopicDetailScreen(
                                                    situationId: widget.situationId,
                                                    topicId: topic['id'],
                                                  ),
                                                ),
                                              ).then((_) => _loadSituation());
                                            },
                                            borderRadius: BorderRadius.circular(16),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 6,
                                              ),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 28,
                                                    height: 28,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.orange500.withOpacity(0.18),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Icon(
                                                      Icons.folder_outlined,
                                                      color: AppColors.orange600,
                                                      size: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      topic['title'],
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 14,
                                                          height: 1.2,
                                                        ),
                                                    ),
                                                  ),
                                                  const Icon(Icons.chevron_right),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (!isLast)
                                        Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? AppColors.white12
                                              : AppColors.black12,
                                        ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ],
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
