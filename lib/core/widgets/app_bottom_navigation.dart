import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    this.items,
  }) : assert(items == null || items.length > 0);

  static const employeeItems = <AppBottomNavigationItem>[
    AppBottomNavigationItem('Home', AppIcons.home),
    AppBottomNavigationItem('History', AppIcons.history),
    AppBottomNavigationItem('Leaves', AppIcons.leaves),
    AppBottomNavigationItem('Profile', AppIcons.profile),
  ];

  final int currentIndex;
  final ValueChanged<int> onChanged;
  final List<AppBottomNavigationItem>? items;

  @override
  Widget build(BuildContext context) {
    final tabs = items ?? employeeItems;

    return Container(
      height: 70,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      color: AppColors.scaffold,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SizedBox(
            height: 70,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = constraints.maxWidth / tabs.length;
                final indicatorLeft =
                    (tabWidth - 48) / 2 + (tabWidth * currentIndex);

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      left: indicatorLeft,
                      top: 11,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x662F3A8E),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(tabs.length, (index) {
                        final selected = currentIndex == index;
                        final tab = tabs[index];
                        return Expanded(
                          child: Semantics(
                            selected: selected,
                            label: tab.label,
                            button: true,
                            child: InkResponse(
                              onTap: () {
                                if (selected) return;
                                HapticFeedback.selectionClick();
                                onChanged(index);
                              },
                              radius: 28,
                              child: SizedBox(
                                height: double.infinity,
                                child: Center(
                                  child: Icon(
                                    tab.icon,
                                    size: 20,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class AppBottomNavigationItem {
  const AppBottomNavigationItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
