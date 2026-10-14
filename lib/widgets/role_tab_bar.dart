import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int badge;
  const TabItem(this.label, this.icon, this.activeIcon, [this.badge = 0]);
}

// Bottom tab bar shared by the customer, owner and worker (RoleTabBar.jsx)
class RoleTabBar extends StatelessWidget {
  final List<TabItem> items;
  final int index;
  final ValueChanged<int> onTap;

  const RoleTabBar({super.key, required this.items, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFC),
        border: const Border(top: BorderSide(color: AppColors.line)),
        boxShadow: [BoxShadow(color: const Color(0xFF101828).withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onTap(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Badge(
                            isLabelVisible: items[i].badge > 0,
                            label: Text("${items[i].badge}"),
                            backgroundColor: AppColors.danger,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 34,
                              height: 30,
                              decoration: BoxDecoration(
                                color: i == index ? const Color(0xFFF4EFE8) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                i == index ? items[i].activeIcon : items[i].icon,
                                size: 21,
                                color: i == index ? AppColors.tabActive : AppColors.neutral,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[i].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: i == index ? AppColors.black : const Color(0xFF8F847B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
