import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const itemCount = 4;
            return Container(
              height: 58,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: isDark ? AppColors.white12 : AppColors.black12,
                ),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Row(
                children: List.generate(itemCount, (index) {
                  final isActive = selectedIndex == index;
                  final iconColor = isActive
                      ? AppColors.orange600
                      : (isDark ? AppColors.white60 : AppColors.black60);
                  final labels = ['ホーム', 'シャッフル', '検索', '見つける'];
                  final icons = [
                    Icons.home_outlined,
                    Icons.shuffle,
                    Icons.search,
                    Icons.explore_outlined,
                  ];
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(index),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.symmetric(
                            horizontal: isActive ? 12 : 0,
                            vertical: isActive ? 6 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.orange600.withOpacity(isDark ? 0.15 : 0.1)
                                : AppColors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icons[index],
                                size: 22,
                                color: iconColor,
                              ),
                              if (isActive) ...[
                                const SizedBox(width: 6),
                                Text(
                                  labels[index],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.orange600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}
