import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF191919) : const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF191919) : Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'プロフィール',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade500, Colors.purple.shade600],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ユーザー',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSettingItem(
                    context: context,
                    icon: Icons.palette_outlined,
                    title: '外観',
                    trailing: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              themeProvider.isDarkMode ? 'ダーク' : 'ライト',
                              style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: themeProvider.isDarkMode,
                              onChanged: (_) => themeProvider.toggleTheme(),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingItem(
                    context: context,
                    icon: Icons.info_outline,
                    title: 'バージョン',
                    trailing: Text(
                      '1.0.0',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Provider.of<AuthProvider>(context, listen: false).logout();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('ログアウト'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151515) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
