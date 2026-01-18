import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TopicDetailScreen extends StatefulWidget {
  final int topicId;

  const TopicDetailScreen({super.key, required this.topicId});

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _topic;
  bool _isLoading = true;
  int? _expandedQuestionId;

  @override
  void initState() {
    super.initState();
    _loadTopic();
  }

  Future<void> _loadTopic() async {
    try {
      final topic = await _apiService.getTopic(widget.topicId);
      setState(() {
        _topic = topic;
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
                    widget.topicId,
                    questionController.text,
                    answerController.text,
                  );
                } else {
                  await _apiService.updateQuestion(
                    widget.topicId,
                    question['id'],
                    questionController.text,
                    answerController.text,
                  );
                }
                if (mounted) {
                  Navigator.pop(context);
                  _loadTopic();
                }
              }
            },
            child: Text(question == null ? '追加' : '更新'),
          ),
        ],
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
      await _apiService.deleteQuestion(widget.topicId, questionId);
      _loadTopic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('トピック詳細'),
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _topic!['title'],
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _topic!['description'] ?? '説明なし',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '質問数: ${_topic!['questions']?.length ?? 0}',
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '質問と回答',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _showQuestionDialog(),
                                    icon: const Icon(Icons.add, size: 20),
                                    label: const Text('追加'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
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

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: isExpanded
                                              ? Colors.orange.shade300
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _expandedQuestionId = isExpanded ? null : question['id'];
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.orange.shade500,
                                                          Colors.orange.shade600,
                                                        ],
                                                      ),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${index + 1}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Q: ',
                                                              style: TextStyle(
                                                                color: Colors.orange.shade600,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                question['question'],
                                                                style: const TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
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
                                                            Icon(Icons.delete, size: 20, color: Colors.red),
                                                            SizedBox(width: 8),
                                                            Text('削除', style: TextStyle(color: Colors.red)),
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
                                              const SizedBox(height: 12),
                                              AnimatedContainer(
                                                duration: const Duration(milliseconds: 300),
                                                constraints: BoxConstraints(
                                                  maxHeight: isExpanded ? 500 : 100,
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.grey.shade50,
                                                          Colors.orange.shade50,
                                                        ],
                                                      ),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  child: SingleChildScrollView(
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'A: ',
                                                          style: TextStyle(
                                                            color: Colors.green.shade600,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            question['answer'] ?? '（未回答）',
                                                            style: const TextStyle(height: 1.5),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (!isExpanded && (question['answer']?.length ?? 0) > 100)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        'タップして全文を表示',
                                                        style: TextStyle(
                                                          color: Colors.orange.shade600,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.keyboard_arrow_down,
                                                        size: 16,
                                                        color: Colors.orange.shade600,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (isExpanded)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        'タップして閉じる',
                                                        style: TextStyle(
                                                          color: Colors.grey.shade600,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.keyboard_arrow_up,
                                                        size: 16,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
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
    );
  }
}
