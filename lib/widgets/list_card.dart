import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ListCard extends StatelessWidget {
  const ListCard({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.icon = Icons.folder_outlined,
    this.showChevron = true,
    this.trailing,
    this.iconBackgroundColor,
    this.iconColor,
    this.titleColor,
    this.subtitleColor,
    this.chevronColor,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final IconData icon;
  final bool showChevron;
  final Widget? trailing;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final Color? chevronColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            height: subtitle == null ? 48 : 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ??
                        AppColors.orange500.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.orange600,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 1.2,
                          color: titleColor ??
                              (isDark ? AppColors.white : AppColors.lightText),
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 12,
                            height: 1.2,
                            color: subtitleColor ??
                                (isDark ? AppColors.white60 : AppColors.black60),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ] else if (showChevron) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color:
                        chevronColor ?? (isDark ? AppColors.white60 : AppColors.black60),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
