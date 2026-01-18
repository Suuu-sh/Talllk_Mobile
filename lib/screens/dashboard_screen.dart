import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../providers/theme_provider.dart';
import 'situation_detail_screen.dart';
import 'topic_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _apiService = ApiService();
  List<dynamic> _situations = [];
  bool _isLoading = true;
  int _selectedTabIndex = 0;
  List<Map<String, dynamic>> _searchTopics = [];
  List<Map<String, dynamic>> _searchQuestions = [];
  List<int> _recentSituationIds = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSituations();
    _loadSituations();
  }

  Future<void> _loadRecentSituations() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList('recent_situation_ids') ?? [];
    setState(() {
      _recentSituationIds = values.map(int.parse).toList();
    });
  }

  Future<void> _loadSituations() async {
    try {
      final situations = await _apiService.getSituations();
      setState(() {
        _situations = situations;
        _isLoading = false;
      });
      _pruneRecentSituations();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _recordRecentSituation(int situationId) async {
    final next = [situationId, ..._recentSituationIds.where((id) => id != situationId)];
    final trimmed = next.take(3).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'recent_situation_ids',
      trimmed.map((id) => id.toString()).toList(),
    );
    setState(() {
      _recentSituationIds = trimmed;
    });
  }

  void _pruneRecentSituations() {
    if (_situations.isEmpty || _recentSituationIds.isEmpty) return;
    final validIds = _situations.map((situation) => situation['id'] as int).toSet();
    final filtered = _recentSituationIds.where(validIds.contains).toList();
    if (filtered.length == _recentSituationIds.length) return;
    _recentSituationIds = filtered;
  }

  Future<void> _removeRecentSituation(int situationId) async {
    if (_recentSituationIds.isEmpty) return;
    final next = _recentSituationIds.where((id) => id != situationId).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'recent_situation_ids',
      next.map((id) => id.toString()).toList(),
    );
    setState(() {
      _recentSituationIds = next;
    });
  }

  void _showEditSituationDialog(Map<String, dynamic> situation) {
    final titleController = TextEditingController(text: situation['title']);
    final descController = TextEditingController(text: situation['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('シチュエーションを編集'),
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
          TextButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('削除確認'),
                  content: const Text('このシチュエーションを削除しますか？'),
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
              if (confirmed != true) return;
              await _apiService.deleteSituation(situation['id']);
              await _removeRecentSituation(situation['id']);
              if (!context.mounted) return;
              Navigator.pop(context);
              _loadSituations();
            },
            child: const Text('削除'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) return;
              await _apiService.updateSituation(
                situation['id'],
                titleController.text,
                descController.text,
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              _loadSituations();
            },
            child: const Text('更新'),
          ),
        ],
      ),
    );
  }

  Future<void> _buildSearchIndex() async {
    if (_situations.isEmpty) return;
    final topics = <Map<String, dynamic>>[];
    final questions = <Map<String, dynamic>>[];

    for (final situation in _situations) {
      final situationId = situation['id'] as int;
      final detail = await _apiService.getSituation(situationId);
      final topicList = List<dynamic>.from(detail['topics'] ?? []);
      final questionList = List<dynamic>.from(detail['questions'] ?? []);
      final topicTitleById = <int, String>{
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

    _searchTopics = topics;
    _searchQuestions = questions;
  }

  void _showCreateDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しいシチュエーション'),
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
                await _apiService.createSituation(
                  titleController.text,
                  descController.text,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadSituations();
              }
            },
            child: const Text('作成'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('設定'),
        content: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.orange,
                  ),
                  title: const Text('シチュエーション'),
                  subtitle: Text(themeProvider.isDarkMode ? 'ダークモード' : 'ライトモード'),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showSearch() {
    final controller = TextEditingController();
    String query = '';
    bool isLoading = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await _buildSearchIndex();
                if (!context.mounted) return;
                setModalState(() {
                  isLoading = false;
                });
              });
            }

            final lowerQuery = query.toLowerCase();
            final situationMatches = _situations
                .where((situation) =>
                    (situation['title'] ?? '').toString().toLowerCase().contains(lowerQuery))
                .toList();
            final topicMatches = _searchTopics
                .where((topic) =>
                    (topic['title'] ?? '').toString().toLowerCase().contains(lowerQuery))
                .toList();
            final questionMatches = _searchQuestions
                .where((question) =>
                    (question['question'] ?? '').toString().toLowerCase().contains(lowerQuery))
                .toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'ファイル・フォルダを検索',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  controller.clear();
                                  setModalState(() {
                                    query = '';
                                  });
                                },
                              ),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          query = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      )
                    else if (query.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text('検索ワードを入力してください'),
                      )
                    else ...[
                      if (situationMatches.isNotEmpty || topicMatches.isNotEmpty) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'フォルダ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...situationMatches.map(
                          (situation) => ListTile(
                            leading: const Icon(Icons.folder_outlined),
                            title: Text(situation['title']),
                            subtitle: const Text('シチュエーション'),
                            onTap: () {
                              Navigator.pop(context);
                              _recordRecentSituation(situation['id']);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SituationDetailScreen(situationId: situation['id']),
                                ),
                              ).then((_) => _loadSituations());
                            },
                          ),
                        ),
                        ...topicMatches.map(
                          (topic) => ListTile(
                            leading: const Icon(Icons.folder_open),
                            title: Text(topic['title']),
                            subtitle: Text(topic['situationTitle'] ?? ''),
                            onTap: () {
                              Navigator.pop(context);
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
                      if (questionMatches.isNotEmpty) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ファイル',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...questionMatches.map(
                          (question) => ListTile(
                            leading: const Icon(Icons.description_outlined),
                            title: Text(question['question']),
                            subtitle: Text(question['topicTitle'] ?? ''),
                            onTap: () {
                              Navigator.pop(context);
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
                      if (situationMatches.isEmpty &&
                          topicMatches.isEmpty &&
                          questionMatches.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text('該当する結果がありません'),
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<dynamic> _recentSituations() {
    if (_situations.isEmpty || _recentSituationIds.isEmpty) return [];
    final byId = {for (final situation in _situations) situation['id'] as int: situation};
    final ordered = <dynamic>[];
    for (final id in _recentSituationIds) {
      final situation = byId[id];
      if (situation != null) {
        ordered.add(situation);
      }
    }
    return ordered;
  }

  Widget _buildRecentSection() {
    final recent = _recentSituations();
    if (recent.isEmpty) {
      return const SizedBox.shrink();
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最近閲覧したページ',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recent.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final situation = recent[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SituationDetailScreen(situationId: situation['id']),
                    ),
                  ).then((_) => _loadSituations());
                  _recordRecentSituation(situation['id']);
                },
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.description_outlined, color: Colors.orange.shade500, size: 18),
                      const Spacer(),
                      Text(
                        situation['title'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFolderList() {
    if (_situations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.orange.shade600,
            ),
            const SizedBox(height: 16),
            const Text(
              'まだシチュエーションがありません',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('最初のシチュエーションを作成して、会話の準備を始めましょう'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add),
              label: const Text('最初のシチュエーションを作成'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _situations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final situation = _situations[index];
        return SizedBox(
          width: double.infinity,
          child: Slidable(
            key: ValueKey(situation['id']),
            endActionPane: ActionPane(
              motion: const StretchMotion(),
            extentRatio: 0.42,
            children: [
              SlidableAction(
                onPressed: (_) {
                  _showEditSituationDialog(situation);
                },
                backgroundColor: Colors.orange.shade50,
                foregroundColor: Colors.orange.shade700,
                icon: Icons.edit_outlined,
                label: '編集',
                borderRadius: BorderRadius.circular(16),
              ),
              SlidableAction(
                onPressed: (_) {
                  // TODO: toggle favorite
                },
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                icon: Icons.star_outline,
                label: 'お気に入り',
                borderRadius: BorderRadius.circular(16),
              ),
            ],
          ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _recordRecentSituation(situation['id']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SituationDetailScreen(situationId: situation['id']),
                    ),
                  ).then((_) => _loadSituations());
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_outlined, color: Colors.orange.shade600, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          situation['title'],
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
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / 4;
            return Container(
              height: 58,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    left: itemWidth * _selectedTabIndex,
                    top: 6,
                    child: Container(
                      width: itemWidth,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(4, (index) {
                      final isActive = _selectedTabIndex == index;
                      final iconColor = isActive
                          ? Colors.orange.shade600
                          : (isDark ? Colors.white70 : Colors.black54);
                      final labelColor = isActive
                          ? Colors.orange.shade600
                          : (isDark ? Colors.white60 : Colors.black54);
                      return Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = index;
                            });
                            if (index == 1) {
                              _showCreateDialog();
                            } else if (index == 2) {
                              _showSearch();
                            } else if (index == 3) {
                              _showSettings();
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                index == 0
                                    ? (isActive ? Icons.home : Icons.home_outlined)
                                    : index == 1
                                        ? (isActive ? Icons.add_circle : Icons.add_circle_outline)
                                        : index == 2
                                            ? (isActive ? Icons.search : Icons.search_outlined)
                                            : (isActive ? Icons.settings : Icons.settings_outlined),
                                size: 22,
                                color: iconColor,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                index == 0
                                    ? 'ホーム'
                                    : index == 1
                                        ? '作成'
                                        : index == 2
                                            ? '検索'
                                            : '設定',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: labelColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSituations,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: Text(
                        'Talllk',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  _buildRecentSection(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Talllkシチュエーション',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${_situations.length}件',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white54
                              : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildFolderList(),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}
