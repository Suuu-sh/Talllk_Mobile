import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/list_card.dart';
import '../theme/app_colors.dart';
import 'discover_situation_detail_screen.dart';
import '../widgets/app_bottom_nav.dart';
import 'shuffle_screen.dart';
import 'dashboard_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _apiService = ApiService();
  List<dynamic> _situations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSituations();
  }

  Future<void> _loadSituations() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _apiService.getPublicSituations();
      if (!mounted) return;
      setState(() {
        _situations = data;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
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
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSituations,
              child: SafeArea(
                bottom: false,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  children: [
                    Row(
                      children: [
                        Container(
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
                            '見つける',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.orange600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_situations.length}件',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.white60
                                : AppColors.black60,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_situations.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          '公開されたシチュエーションはまだありません',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                        ),
                      )
                    else
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
                          children: List.generate(_situations.length, (index) {
                            final situation = _situations[index];
                            final isLast = index == _situations.length - 1;
                            return Column(
                              children: [
                                ListCard(
                                  title: situation['title'] ?? '',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DiscoverSituationDetailScreen(
                                          situationId: situation['id'],
                                        ),
                                      ),
                                    );
                                  },
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
            ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 3,
        onTap: _handleBottomNavTap,
      ),
    );
  }
}
