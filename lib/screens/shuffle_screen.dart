import 'dart:math';

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'search_screen.dart';

class ShuffleScreen extends StatefulWidget {
  const ShuffleScreen({super.key});

  @override
  State<ShuffleScreen> createState() => _ShuffleScreenState();
}

class _ShuffleScreenState extends State<ShuffleScreen> {
  final _apiService = ApiService();
  final _random = Random();

  List<dynamic> _situations = [];
  Map<String, dynamic>? _selectedSituation;
  List<dynamic> _questions = [];
  List<int> _remainingQuestionIds = [];
  Map<String, dynamic>? _currentQuestion;
  bool _isLoading = true;
  bool _isFetchingQuestions = false;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _loadSituations();
  }

  Future<void> _loadSituations() async {
    try {
      final situations = await _apiService.getSituations();
      setState(() {
        _situations = situations;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectSituation(Map<String, dynamic>? situation) async {
    if (situation == null) return;
    setState(() {
      _selectedSituation = situation;
      _isFetchingQuestions = true;
      _currentQuestion = null;
      _questions = [];
      _remainingQuestionIds = [];
      _showAnswer = false;
    });

    try {
      final detail = await _apiService.getSituation(situation['id']);
      final questions = List<dynamic>.from(detail['questions'] ?? []);
      setState(() {
        _questions = questions;
        _remainingQuestionIds = questions.map((q) => q['id'] as int).toList();
        _isFetchingQuestions = false;
      });
      _nextQuestion();
    } catch (_) {
      setState(() {
        _isFetchingQuestions = false;
      });
    }
  }

  void _nextQuestion() {
    if (_remainingQuestionIds.isEmpty) {
      setState(() {
        _currentQuestion = null;
        _showAnswer = false;
      });
      return;
    }
    final index = _random.nextInt(_remainingQuestionIds.length);
    final id = _remainingQuestionIds.removeAt(index);
    final question =
        _questions.firstWhere((item) => item['id'] == id, orElse: () => {});
    setState(() {
      _currentQuestion = question is Map<String, dynamic> && question.isNotEmpty
          ? question
          : null;
      _showAnswer = false;
    });
  }

  void _showEditAnswerDialog() {
    final current = _currentQuestion;
    if (current == null) return;
    final situationId = _selectedSituation?['id'];
    if (situationId == null) return;
    final answerController = TextEditingController(text: current['answer'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('回答を編集'),
        content: TextField(
          controller: answerController,
          decoration: const InputDecoration(
            labelText: '回答',
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _apiService.updateQuestion(
                situationId,
                current['topic_id'],
                current['id'],
                current['question'] ?? '',
                answerController.text,
              );
              if (!context.mounted) return;
              setState(() {
                current['answer'] = answerController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _resetShuffle() {
    setState(() {
      _remainingQuestionIds = _questions.map((q) => q['id'] as int).toList();
      _currentQuestion = null;
      _showAnswer = false;
    });
    _nextQuestion();
  }

  void _handleBottomNavTap(int index) {
    if (index == 2) return;
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
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
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const Text(
              'シャッフル',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<int>(
                value: _selectedSituation?['id'],
                decoration: const InputDecoration(
                  labelText: 'シチュエーションを選択',
                ),
                items: _situations
                    .map(
                      (situation) => DropdownMenuItem<int>(
                        value: situation['id'],
                        child: Text(situation['title']),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  final selected =
                      _situations.firstWhere((item) => item['id'] == value);
                  _selectSituation(selected);
                },
              ),
            const SizedBox(height: 20),
            if (_isFetchingQuestions)
              const Center(child: CircularProgressIndicator())
            else if (_selectedSituation == null)
              const Text('シチュエーションを選ぶと質問をシャッフルします。')
            else if (_questions.isEmpty)
              const Text('このシチュエーションに質問がありません。')
            else if (_currentQuestion == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('質問がすべて出題されました。'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _resetShuffle,
                    icon: const Icon(Icons.refresh),
                    label: const Text('リセット'),
                  ),
                ],
              )
            else
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentQuestion?['question'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_showAnswer)
                        Text(
                          _currentQuestion?['answer'] ?? '（未回答）',
                          style: const TextStyle(height: 1.5),
                        )
                      else
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showAnswer = true;
                            });
                          },
                          child: const Text('回答を見る'),
                        ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _showEditAnswerDialog,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('回答を編集'),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (_selectedSituation != null && _questions.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _nextQuestion,
                      icon: const Icon(Icons.shuffle),
                      label: const Text('次の質問'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 2,
        onTap: _handleBottomNavTap,
      ),
    );
  }
}
