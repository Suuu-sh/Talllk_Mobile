import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/list_card.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import 'shuffle_screen.dart';
import 'dashboard_screen.dart';
import 'topic_detail_screen.dart';
import 'situation_detail_screen.dart';

class DiscoverSituationDetailScreen extends StatefulWidget {
  const DiscoverSituationDetailScreen({super.key, required this.situationId});

  final int situationId;

  @override
  State<DiscoverSituationDetailScreen> createState() => _DiscoverSituationDetailScreenState();
}

class _DiscoverSituationDetailScreenState extends State<DiscoverSituationDetailScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _situation;
  List<dynamic> _topics = [];
  List<dynamic> _questions = [];
  List<dynamic> _mySituations = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSituation();
  }

  Future<void> _loadSituation() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _apiService.getPublicSituation(widget.situationId);
      if (!mounted) return;
      setState(() {
        _situation = data;
        _topics = List<dynamic>.from(data['topics'] ?? []);
        _questions = List<dynamic>.from(data['questions'] ?? []);
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _ensureMySituations() async {
    if (_mySituations.isNotEmpty) return;
    final data = await _apiService.getSituations();
    if (!mounted) return;
    setState(() {
      _mySituations = data;
    });
  }

  Future<void> _saveSituation() async {
    if (_situation == null || _isSaving) return;
    setState(() {
      _isSaving = true;
    });
    try {
      await _apiService.savePublicSituation(_situation!['id']);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('シチュエーションを保存しました')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _saveTopic(int topicId) async {
    await _ensureMySituations();
    if (_mySituations.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('先に自分のシチュエーションを作成してください')),
      );
      return;
    }

    final targetSituationId = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          children: [
            const Text(
              '保存先シチュエーション',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 8),
            ..._mySituations.map(
              (situation) => ListCard(
                title: situation['title'] ?? '',
                onTap: () => Navigator.pop(context, situation['id'] as int),
              ),
            ),
          ],
        ),
      ),
    );

    if (targetSituationId == null) return;
    await _apiService.savePublicTopic(topicId, targetSituationId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('トピックを保存しました')),
    );
  }

  Future<void> _saveQuestion(int questionId) async {
    await _ensureMySituations();
    if (_mySituations.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('先に自分のシチュエーションを作成してください')),
      );
      return;
    }

    final targetSituationId = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          children: [
            const Text(
              '保存先シチュエーション',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 8),
            ..._mySituations.map(
              (situation) => ListCard(
                title: situation['title'] ?? '',
                onTap: () => Navigator.pop(context, situation['id'] as int),
              ),
            ),
          ],
        ),
      ),
    );

    if (targetSituationId == null) return;
    final topics = await _apiService.getTopics(targetSituationId);
    if (!mounted) return;
    if (topics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存先シチュエーションにトピックがありません')),
      );
      return;
    }

    final targetTopicId = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          children: [
            const Text(
              '保存先トピック',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 8),
            ...topics.map(
              (topic) => ListCard(
                title: topic['title'] ?? '',
                onTap: () => Navigator.pop(context, topic['id'] as int),
              ),
            ),
          ],
        ),
      ),
    );

    if (targetTopicId == null) return;
    await _apiService.savePublicQuestion(questionId, targetTopicId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('質問を保存しました')),
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
    if (index == 2) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(
            initialTabIndex: 2,
            initialActionIndex: 2,
          ),
        ),
        (route) => false,
      );
      return;
    }
    if (index == 3) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _situation == null
              ? const Center(child: Text('シチュエーションが見つかりません'))
              : RefreshIndicator(
                  onRefresh: _loadSituation,
                  child: SafeArea(
                    bottom: false,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _isSaving ? null : _saveSituation,
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('保存する'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _situation?['title'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDark ? AppColors.white : AppColors.lightText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'トピック',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(height: 8),
                        if (_topics.isEmpty)
                          const Text(
                            'トピックはまだありません',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? AppColors.white12 : AppColors.black12,
                              ),
                              boxShadow: isDark
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
                                    ListCard(
                                      title: topic['title'] ?? '',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DiscoverSituationDetailScreen(
                                              situationId: widget.situationId,
                                            ),
                                          ),
                                        );
                                      },
                                      showChevron: false,
                                      trailing: IconButton(
                                        icon: const Icon(Icons.download),
                                        onPressed: () => _saveTopic(topic['id']),
                                      ),
                                    ),
                                    if (!isLast)
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: isDark ? AppColors.white12 : AppColors.black12,
                                      ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        const SizedBox(height: 16),
                        const Text(
                          '質問',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(height: 8),
                        if (_questions.isEmpty)
                          const Text(
                            '質問はまだありません',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                          )
                        else
                          Column(
                            children: List.generate(_questions.length, (index) {
                              final question = _questions[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurface : AppColors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark ? AppColors.white12 : AppColors.black12,
                                  ),
                                  boxShadow: isDark
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: AppColors.black.withOpacity(0.06),
                                            blurRadius: 16,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              question['question'] ?? '',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: isDark
                                                    ? AppColors.white
                                                    : AppColors.lightText,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              question['answer'] ?? '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark
                                                    ? AppColors.white60
                                                    : AppColors.black60,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.download),
                                        onPressed: () => _saveQuestion(question['id']),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 3,
        onTap: _handleBottomNavTap,
      ),
    );
  }
}
