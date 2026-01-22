import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/list_card.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<String?> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSheet : AppColors.lightScaffold,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkSheet : AppColors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'プロフィール',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: isDark ? AppColors.white : AppColors.lightText,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  FutureBuilder<String?>(
                    future: _loadUserName(),
                    builder: (context, snapshot) {
                      final name = snapshot.data?.trim();
                      return Text(
                        name?.isNotEmpty == true ? name! : 'ユーザー',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: isDark ? AppColors.white : AppColors.lightText,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
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
                                color: isDark ? AppColors.white60 : AppColors.black60,
                                fontSize: 12,
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
                        color: isDark ? AppColors.white60 : AppColors.black60,
                        fontSize: 12,
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
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
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
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? AppColors.white60 : AppColors.black60,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.white : AppColors.lightText,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  Future<String?> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF0A0A0A) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0A0A0A),
                  const Color(0xFF0F0F0F),
                ],
              )
            : null,
        color: isDark ? null : Colors.white,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Avatar with gradient
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.orange500.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FutureBuilder<String?>(
                      future: _loadUserName(),
                      builder: (context, snapshot) {
                        final name = snapshot.data?.trim();
                        final handle = name?.isNotEmpty == true ? name! : 'talllk';
                        return Text(
                          '@$handle',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.orange600,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu Items
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
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
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    children: [
                      _drawerItem(
                        context,
                        icon: Icons.person_outline_rounded,
                        label: 'プロフィール',
                        iconColor: AppColors.blue500,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        color: isDark ? AppColors.white12 : AppColors.black12,
                      ),
                      _drawerItem(
                        context,
                        icon: Icons.palette_outlined,
                        label: '外観',
                        iconColor: AppColors.purple500,
                        onTap: () {
                          Navigator.pop(context);
                          _showThemeDialog(context);
                        },
                      ),
                      Divider(
                        height: 1,
                        color: isDark ? AppColors.white12 : AppColors.black12,
                      ),
                      _drawerItem(
                        context,
                        icon: Icons.settings_outlined,
                        label: '設定',
                        iconColor: AppColors.grey600,
                        onTap: () => Navigator.pop(context),
                      ),
                      Divider(
                        height: 1,
                        color: isDark ? AppColors.white12 : AppColors.black12,
                      ),
                      _drawerItem(
                        context,
                        icon: Icons.logout_rounded,
                        label: 'ログアウト',
                        isDestructive: true,
                        onTap: () {
                          Provider.of<AuthProvider>(context, listen: false).logout();
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                      ),
                      Divider(
                        height: 1,
                        color: isDark ? AppColors.white12 : AppColors.black12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Talllk v1.0.0',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? Colors.white.withOpacity(0.3)
                      : Colors.black.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListCard(
      title: label,
      onTap: onTap,
      icon: icon,
      iconBackgroundColor:
          isDestructive ? AppColors.error.withOpacity(0.12) : null,
      iconColor: isDestructive
          ? AppColors.error
          : iconColor,
      titleColor: isDestructive
          ? AppColors.error
          : (isDark ? AppColors.white : AppColors.lightText),
      chevronColor: isDark ? AppColors.white60 : AppColors.black60,
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('外観'),
        content: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return ListTile(
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: const Color(0xFF6366F1),
              ),
              title: const Text('テーマ'),
              subtitle: Text(themeProvider.isDarkMode ? 'ダーク' : 'ライト'),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
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
}
