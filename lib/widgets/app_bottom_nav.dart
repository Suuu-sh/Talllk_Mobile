import 'package:flutter/material.dart';

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
            const itemCount = 5;
            final itemWidth = constraints.maxWidth / itemCount;
            return Container(
              height: 58,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF151515) : Colors.white,
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
                    left: itemWidth * selectedIndex,
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
                    children: List.generate(itemCount, (index) {
                      final isActive = selectedIndex == index;
                      final iconColor = isActive
                          ? Colors.orange.shade600
                          : (isDark ? Colors.white70 : Colors.black54);
                      final labelColor = isActive
                          ? Colors.orange.shade600
                          : (isDark ? Colors.white60 : Colors.black54);
                      return Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => onTap(index),
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
                                            : index == 3
                                                ? Icons.shuffle
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
                                            : index == 3
                                                ? 'シャッフル'
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
}
