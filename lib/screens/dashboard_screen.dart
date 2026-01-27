import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'situation_detail_screen.dart';
import 'topic_detail_screen.dart';
import 'shuffle_screen.dart';
import 'profile_screen.dart';
import 'discover_screen.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/list_card.dart';
import '../theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  final int initialTabIndex;
  final int? initialActionIndex;

  const DashboardScreen({
    super.key,
    this.initialTabIndex = 0,
    this.initialActionIndex,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _apiService = ApiService();
  List<dynamic> _situations = [];
  List<dynamic> _favoriteSituations = [];
  Set<int> _favoriteSituationIds = {};
  bool _isLoading = true;
  int _selectedTabIndex = 0;
  List<Map<String, dynamic>> _searchTopics = [];
  List<Map<String, dynamic>> _searchQuestions = [];
  List<int> _recentSituationIds = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchInline = false;
  bool _isSearchIndexLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    _loadRecentSituations();
    _loadSituations();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || widget.initialActionIndex == null) return;
      await _handleInitialAction(widget.initialActionIndex!);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleInitialAction(int index) async {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ShuffleScreen()),
      );
      return;
    }
    if (index == 2) {
      await _toggleSearchInline();
      return;
    }
    if (index == 3) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DiscoverScreen()),
      );
      if (!mounted) return;
      setState(() {
        _selectedTabIndex = 0;
      });
    }
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
      });
      try {
        final favorites = await _apiService.getFavoriteSituations();
        if (!mounted) return;
        setState(() {
          _favoriteSituations = favorites;
          _favoriteSituationIds =
              favorites.map((item) => item['id'] as int).toSet();
        });
      } catch (_) {}
      if (!mounted) return;
      setState(() {
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
    final next = [
      situationId,
      ..._recentSituationIds.where((id) => id != situationId)
    ];
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
    final validIds =
        _situations.map((situation) => situation['id'] as int).toSet();
    final filtered = _recentSituationIds.where(validIds.contains).toList();
    if (filtered.length == _recentSituationIds.length) return;
    _recentSituationIds = filtered;
  }

  Future<void> _toggleFavorite(int situationId) async {
    final isFavorite = _favoriteSituationIds.contains(situationId);
    Map<String, dynamic>? match;
    for (final item in _situations) {
      if (item['id'] == situationId) {
        match = Map<String, dynamic>.from(item as Map);
        break;
      }
    }
    setState(() {
      if (isFavorite) {
        _favoriteSituationIds.remove(situationId);
        _favoriteSituations =
            _favoriteSituations.where((item) => item['id'] != situationId).toList();
      } else {
        _favoriteSituationIds.add(situationId);
        if (match != null) {
          _favoriteSituations = [match, ..._favoriteSituations];
        }
      }
    });

    try {
      if (isFavorite) {
        await _apiService.removeFavoriteSituation(situationId);
      } else {
        await _apiService.addFavoriteSituation(situationId);
      }
    } catch (e) {
      setState(() {
        if (isFavorite) {
          _favoriteSituationIds.add(situationId);
          if (match != null) {
            _favoriteSituations = [match, ..._favoriteSituations];
          }
        } else {
          _favoriteSituationIds.remove(situationId);
          _favoriteSituations = _favoriteSituations
              .where((item) => item['id'] != situationId)
              .toList();
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('お気に入りの更新に失敗しました')),
      );
    }
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
    final descController =
        TextEditingController(text: situation['description'] ?? '');

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
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error),
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
        for (final topic in topicList)
          topic['id'] as int: topic['title'] as String,
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

  Future<void> _toggleSearchInline() async {
    if (_isSearchInline) {
      setState(() {
        _isSearchInline = false;
        _searchQuery = '';
        _searchController.clear();
        _selectedTabIndex = 0;
      });
      return;
    }

    setState(() {
      _isSearchInline = true;
      _selectedTabIndex = 2;
      _isSearchIndexLoading = true;
    });
    await _buildSearchIndex();
    if (!mounted) return;
    setState(() {
      _isSearchIndexLoading = false;
    });
  }

  List<dynamic> _recentSituations() {
    if (_situations.isEmpty || _recentSituationIds.isEmpty) return [];
    final byId = {
      for (final situation in _situations) situation['id'] as int: situation
    };
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
          'さっき見たページ',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
                      builder: (context) =>
                          SituationDetailScreen(situationId: situation['id']),
                    ),
                  ).then((_) => _loadSituations());
                  _recordRecentSituation(situation['id']);
                },
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppColors.white12 : AppColors.black12,
                    ),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.description_outlined,
                          color: AppColors.orange500, size: 18),
                      const Spacer(),
                      Text(
                        situation['title'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w300),
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

  Widget _buildSearchInlineSection() {
    final lowerQuery = _searchQuery.toLowerCase();
    final situationMatches = _situations
        .where((situation) => (situation['title'] ?? '')
            .toString()
            .toLowerCase()
            .contains(lowerQuery))
        .toList();
    final topicMatches = _searchTopics
        .where((topic) => (topic['title'] ?? '')
            .toString()
            .toLowerCase()
            .contains(lowerQuery))
        .toList();
    final questionMatches = _searchQuestions
        .where((question) => (question['question'] ?? '')
            .toString()
            .toLowerCase()
            .contains(lowerQuery))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isSearchIndexLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_searchQuery.isEmpty)
          const SizedBox.shrink()
        else ...[
          if (situationMatches.isNotEmpty || topicMatches.isNotEmpty) ...[
            const Text('フォルダ'),
            const SizedBox(height: 8),
            ...situationMatches.map(
              (situation) => ListCard(
                title: situation['title'],
                icon: Icons.folder_outlined,
                onTap: () {
                  _recordRecentSituation(situation['id']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SituationDetailScreen(
                        situationId: situation['id'],
                      ),
                    ),
                  ).then((_) => _loadSituations());
                },
              ),
            ),
            ...topicMatches.map(
              (topic) => ListCard(
                title: topic['title'],
                icon: Icons.folder_open,
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
          if (questionMatches.isNotEmpty) ...[
            const Text('ファイル'),
            const SizedBox(height: 8),
            ...questionMatches.map(
              (question) => ListCard(
                title: question['question'],
                icon: Icons.description_outlined,
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
          if (situationMatches.isEmpty &&
              topicMatches.isEmpty &&
              questionMatches.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('該当する結果がありません'),
            ),
        ],
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
              color: AppColors.orange600,
            ),
            const SizedBox(height: 16),
            const Text(
              'まだシチュエーションがありません',
              style: TextStyle(fontSize: 14),
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

    final orderedSituations = [
      ..._situations.where(
        (item) => _favoriteSituationIds.contains(item['id'] as int),
      ),
      ..._situations.where(
        (item) => !_favoriteSituationIds.contains(item['id'] as int),
      ),
    ];

    return Container(
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
        children: List.generate(orderedSituations.length, (index) {
          final situation = orderedSituations[index];
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final isLast = index == orderedSituations.length - 1;
          return Column(
            children: [
              Slidable(
                key: ValueKey(situation['id']),
                endActionPane: ActionPane(
                  motion: const StretchMotion(),
                  extentRatio: 0.25,
                  children: [
                    CustomSlidableAction(
                      onPressed: (_) {
                        _showEditSituationDialog(situation);
                      },
                      backgroundColor: AppColors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppColors.yellow500, AppColors.yellow600]
                                : [AppColors.yellow500, AppColors.yellow600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.yellow600.withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.edit_rounded,
                            color: AppColors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    CustomSlidableAction(
                      onPressed: (_) => _toggleFavorite(situation['id']),
                      backgroundColor: AppColors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppColors.orange500, AppColors.orange600]
                                : [AppColors.orange500, AppColors.orange600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.orange600.withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.star_rounded,
                            color: AppColors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                child: ListCard(
                  title: situation['title'],
                  icon: _favoriteSituationIds.contains(situation['id'] as int)
                      ? Icons.star_rounded
                      : Icons.folder_outlined,
                  iconColor: _favoriteSituationIds.contains(situation['id'] as int)
                      ? AppColors.yellow600
                      : AppColors.orange600,
                  iconBackgroundColor: _favoriteSituationIds.contains(situation['id'] as int)
                      ? AppColors.yellow500.withOpacity(0.18)
                      : AppColors.orange500.withOpacity(0.18),
                  onTap: () {
                    _recordRecentSituation(situation['id']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SituationDetailScreen(situationId: situation['id']),
                      ),
                    ).then((_) => _loadSituations());
                  },
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
    );
  }


  Future<void> _handleTabTap(int index) async {
    setState(() {
      _selectedTabIndex = index;
    });
    if (index != 2 && _isSearchInline) {
      setState(() {
        _isSearchInline = false;
        _searchQuery = '';
        _searchController.clear();
      });
    }
    if (index == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ShuffleScreen()),
      );
      if (!mounted) return;
      setState(() {
        _selectedTabIndex = 0;
      });
      return;
    }
    if (index == 2) {
      await _toggleSearchInline();
      return;
    }
    if (index == 3) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DiscoverScreen()),
      );
      if (!mounted) return;
      setState(() {
        _selectedTabIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.78,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkDrawer
            : AppColors.white,
        child: const ProfileDrawer(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSituations,
              child: Stack(
                children: [
                  if (!_isSearchInline)
                    SafeArea(
                      bottom: false,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: InkWell(
                                    onTap: () =>
                                        Scaffold.of(context).openDrawer(),
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppColors.darkSurface
                                            : AppColors.white,
                                        border: Border.all(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppColors.white12
                                              : AppColors.black12,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.person_outline,
                                          size: 16),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.orange600,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Talllk',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.orange600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 30, height: 30),
                              ],
                            ),
                          ),
                          _buildRecentSection(),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'シチュエーション',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w300),
                              ),
                              Text(
                                '${_situations.length}件',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.white60
                                      : AppColors.black60,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildFolderList(),
                        ],
                      ),
                    ),
                  if (_isSearchInline)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        final focus = FocusScope.of(context);
                        if (focus.hasFocus) focus.unfocus();
                      },
                      child: Stack(
                        children: [
                          SafeArea(
                            bottom: false,
                            child: ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 80),
                              children: [
                                _buildSearchInlineSection(),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 12,
                            child: SafeArea(
                              top: false,
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'ファイル・フォルダを検索',
                                  prefixIcon:
                                      const Icon(Icons.search, size: 18),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () {
                                      final focus = FocusScope.of(context);
                                      if (focus.hasFocus) focus.unfocus();
                                    },
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedTabIndex,
        onTap: _handleTabTap,
      ),
      floatingActionButton: _isSearchInline
          ? null
          : FloatingActionButton.small(
              onPressed: _showCreateDialog,
              child: const Icon(Icons.add),
            ),
    );
  }
}
