import 'dart:async';

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'situation_detail_screen.dart';
import 'topic_detail_screen.dart';
import 'shuffle_screen.dart';
import 'discover_screen.dart';
import '../theme/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _apiService = ApiService();
  final _controller = TextEditingController();
  Timer? _debounce;
  bool _isIndexLoading = true;
  bool _isSearching = false;
  String _query = '';

  List<dynamic> _situations = [];
  List<Map<String, dynamic>> _searchTopics = [];
  List<Map<String, dynamic>> _searchQuestions = [];

  List<dynamic> _situationMatches = [];
  List<Map<String, dynamic>> _topicMatches = [];
  List<Map<String, dynamic>> _questionMatches = [];

  @override
  void initState() {
    super.initState();
    _loadIndex();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadIndex() async {
    try {
      final situations = await _apiService.getSituations();
      final topics = <Map<String, dynamic>>[];
      final questions = <Map<String, dynamic>>[];

      for (final situation in situations) {
        final situationId = situation['id'] as int;
        final detail = await _apiService.getSituation(situationId);
        final topicList = List<dynamic>.from(detail['topics'] ?? []);
        final questionList = List<dynamic>.from(detail['questions'] ?? []);
        final topicTitleById = {
          for (final topic in topicList) topic['id'] as int: topic['title'] as String,
        };

        for (final topic in topicList) {
          topics.add({
            'id': topic['id'],
            'title': topic['title'],
            'description': topic['description'],
            'situationId': situationId,
            'situationTitle': situation['title'],
          });
        }

        for (final question in questionList) {
          questions.add({
            'id': question['id'],
            'question': question['question'],
            'topicId': question['topic_id'],
            'situationId': situationId,
            'topicTitle': topicTitleById[question['topic_id']] ?? '',
          });
        }
      }

      setState(() {
        _situations = situations;
        _searchTopics = topics;
        _searchQuestions = questions;
        _isIndexLoading = false;
      });
      _applySearch();
    } catch (_) {
      setState(() {
        _isIndexLoading = false;
      });
    }
  }

  void _onQueryChanged(String value) {
    setState(() {
      _query = value;
      _isSearching = true;
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _applySearch);
  }

  void _applySearch() {
    final lowerQuery = _query.toLowerCase();
    if (lowerQuery.isEmpty) {
      setState(() {
        _situationMatches = [];
        _topicMatches = [];
        _questionMatches = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _situationMatches = _situations
          .where((situation) =>
              (situation['title'] ?? '').toString().toLowerCase().contains(lowerQuery))
          .toList();
      _topicMatches = _searchTopics
          .where((topic) => (topic['title'] ?? '').toString().toLowerCase().contains(lowerQuery))
          .toList();
      _questionMatches = _searchQuestions
          .where((question) =>
              (question['question'] ?? '').toString().toLowerCase().contains(lowerQuery))
          .toList();
      _isSearching = false;
    });
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
    if (index == 2) {
      return;
    }
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DiscoverScreen()),
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
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'ファイル・フォルダを検索',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    if (_query.isNotEmpty) {
                      _controller.clear();
                      _onQueryChanged('');
                      return;
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
              onChanged: _onQueryChanged,
            ),
            const SizedBox(height: 16),
            if (_isIndexLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_query.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('検索ワードを入力してください'),
              )
            else ...[
              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              if (_situationMatches.isNotEmpty || _topicMatches.isNotEmpty) ...[
                const Text('フォルダ'),
                const SizedBox(height: 8),
                ..._situationMatches.map(
                  (situation) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.folder_outlined),
                    title: Text(situation['title']),
                    subtitle: const Text('シチュエーション'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SituationDetailScreen(situationId: situation['id']),
                        ),
                      );
                    },
                  ),
                ),
                ..._topicMatches.map(
                  (topic) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.folder_open),
                    title: Text(topic['title']),
                    subtitle: Text(topic['situationTitle'] ?? ''),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TopicDetailScreen(
                            situationId: topic['situationId'],
                            topicId: topic['id'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (_questionMatches.isNotEmpty) ...[
                const Text('ファイル'),
                const SizedBox(height: 8),
                ..._questionMatches.map(
                  (question) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.description_outlined),
                    title: Text(question['question']),
                    subtitle: Text(question['topicTitle'] ?? ''),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TopicDetailScreen(
                            situationId: question['situationId'],
                            topicId: question['topicId'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (_situationMatches.isEmpty && _topicMatches.isEmpty && _questionMatches.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('該当する結果がありません'),
                ),
            ],
            if (!_isIndexLoading && _query.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '検索結果 ${_situationMatches.length + _topicMatches.length + _questionMatches.length} 件',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.white60 : AppColors.black60,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 2,
        onTap: _handleBottomNavTap,
      ),
    );
  }
}
